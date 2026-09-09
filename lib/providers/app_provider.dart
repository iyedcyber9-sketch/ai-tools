import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/ai_model.dart';
import '../models/chat_models.dart';
import '../services/hardware_service.dart';
import '../services/gpu_service.dart';
import '../services/model_registry.dart';
import '../services/storage_service.dart';
import '../services/llama_service.dart';
import '../services/pdf_service.dart';
import '../services/download_service.dart';

class AppProvider extends ChangeNotifier {
  final ModelRegistry registry = ModelRegistry();
  final HardwareService hardwareService = HardwareService();
  final GpuService gpuService = GpuService();
  final StorageService storage = StorageService();
  final LlamaService llama = LlamaService();
  final PdfService pdfService = PdfService();

  HardwareInfo? hardware;
  GpuInfo? gpu;
  List<AiModel> allModels = [];
  List<AiModel> filteredModels = [];
  bool showAllModels = false;
  bool useGpu = true;
  double temperature = 0.7;

  List<ChatSession> sessions = [];
  ChatSession? currentSession;
  bool isGenerating = false;
  bool isVerifying = false;
  String? streamingBuffer;

  String? statusMessage;

  List<String> downloadedModelIds = [];

  // Auto download state
  bool isDownloading = false;
  DownloadProgress? downloadProgress;
  AiModel? downloadingModel;
  CancelToken? _downloadCancelToken;
  StreamSubscription<DownloadProgress>? _downloadSub;
  final DownloadService downloadService = DownloadService();

  // Flag to avoid duplicate auto start
  bool _autoDownloadStarted = false;

  Future<void> init() async {
    await storage.init();
    await registry.load();
    allModels = registry.models;
    hardware = await hardwareService.getHardwareInfo();
    gpu = await gpuService.detectGpu();
    showAllModels = storage.getShowAllModels();
    useGpu = storage.getUseGpu();
    temperature = storage.getTemperature();
    statusMessage = await llama.getStatusMessage();
    _applyFilter();
    sessions = storage.getAllSessions();
    if (sessions.isEmpty) {
      currentSession = ChatSession(title: 'New Chat');
      await storage.saveSession(currentSession!);
      sessions = storage.getAllSessions();
    } else {
      currentSession = sessions.first;
    }
    // Check downloaded models
    for (var m in allModels) {
      if (await llama.isModelDownloaded(m.id)) downloadedModelIds.add(m.id);
    }
    notifyListeners();

    // Auto-download if enabled and no model present
    if (storage.getAutoDownloadEnabled() && downloadedModelIds.isEmpty && !_autoDownloadStarted) {
      // Small delay to let UI render first
      Future.delayed(const Duration(milliseconds: 800), () {
        _startAutoDownloadIfNeeded();
      });
    }
  }

  AiModel? pickRecommendedModel({bool forLowPC = false}) {
    if (hardware == null) return filteredModels.isNotEmpty ? filteredModels.first : null;
    final isLow = forLowPC || hardware!.isLowRam;
    final max = hardware!.recommendedMaxModelGB;
    final sorted = List<AiModel>.from(filteredModels)..sort((a, b) => a.ramRequiredGB.compareTo(b.ramRequiredGB));
    // For low PC, prefer Q2 quantized and smallest that is still capable (lighter network & RAM)
    if (isLow) {
      final lowCandidates = sorted.where((m) => m.quant.contains('Q2') || m.params == '0.5B' || m.id.contains('0.5b') || m.id.contains('1.5b-q2')).toList();
      if (lowCandidates.isNotEmpty) {
        // Pick the largest Q2 that still fits, or smallest if none fits
        AiModel? bestLow;
        for (var m in lowCandidates) {
          if (m.ramRequiredGB <= max) bestLow = m;
        }
        if (bestLow != null) return bestLow;
        return lowCandidates.first;
      }
      // Fallback to smallest overall for low PC
      return sorted.firstWhere((m) => m.ramRequiredGB <= 1.0, orElse: () => sorted.first);
    }
    // 1) Prefer already downloaded models that fit best performance
    final downloadedCompatible = sorted.where((m) => downloadedModelIds.contains(m.id)).toList();
    if (downloadedCompatible.isNotEmpty) {
      AiModel? bestDownloaded;
      for (var m in downloadedCompatible) {
        if (m.ramRequiredGB <= max) bestDownloaded = m;
      }
      bestDownloaded ??= downloadedCompatible.last;
      return bestDownloaded;
    }
    // 2) Otherwise pick largest compatible that fits recommended max (for auto-download)
    AiModel? best;
    for (var m in sorted) {
      if (m.ramRequiredGB <= max) best = m;
    }
    best ??= sorted.isNotEmpty ? sorted.first : null;
    if (hardware!.isLowRam) {
      try {
        final q15 = sorted.firstWhere((m) => m.id == 'qwen2.5-1.5b-q4');
        if (q15.ramRequiredGB <= max * 1.2) best = q15;
      } catch (_) {}
      if (best != null && best.ramRequiredGB > max) {
        try {
          final q05 = sorted.firstWhere((m) => m.id == 'qwen2.5-0.5b-q4');
          best = q05;
        } catch (_) {}
      }
    }
    return best;
  }

  // Low PC helper: get smallest light model for download
  AiModel? getLightestForLowPC() => pickRecommendedModel(forLowPC: true);

  Future<void> _startAutoDownloadIfNeeded() async {
    if (_autoDownloadStarted) return;
    if (downloadedModelIds.isNotEmpty) return;
    if (!storage.getAutoDownloadEnabled()) return;
    final rec = pickRecommendedModel();
    if (rec == null) return;
    _autoDownloadStarted = true;
    // Auto select model first
    selectModel(rec.id);
    await startDownload(rec);
  }

  Future<void> startDownload(AiModel model) async {
    if (isDownloading) {
      // cancel previous if different model
      if (downloadingModel?.id != model.id) {
        await cancelDownload();
      } else {
        return;
      }
    }
    isDownloading = true;
    downloadingModel = model;
    downloadProgress = DownloadProgress(modelId: model.id, received: 0, total: 100, percent: 0, status: 'Preparing download...');
    _downloadCancelToken = CancelToken();
    notifyListeners();

    try {
      final stream = downloadService.downloadModelStream(model, cancelToken: _downloadCancelToken);
      _downloadSub = stream.listen(
        (prog) {
          downloadProgress = prog;
          notifyListeners();
        },
        onDone: () async {
          isDownloading = false;
          // Verify downloaded
          final ok = await downloadService.isDownloaded(model);
          if (ok) {
            if (!downloadedModelIds.contains(model.id)) downloadedModelIds.add(model.id);
            statusMessage = 'Model ${model.name} ready!';
            // Mark auto setup done
            await storage.setHasDoneAutoSetup(true);
          } else {
            statusMessage = 'Download finished but verification failed for ${model.name}';
          }
          downloadingModel = null;
          downloadProgress = null;
          _downloadCancelToken = null;
          notifyListeners();
          // Refresh status
          statusMessage = await llama.getStatusMessage();
          notifyListeners();
        },
        onError: (e) {
          isDownloading = false;
          downloadProgress = DownloadProgress(modelId: model.id, received: 0, total: 0, percent: 0, status: 'Error: $e', isError: true);
          notifyListeners();
        },
        cancelOnError: false,
      );
      // Wait for completion to not return early? But we want UI to show progress while method returns.
      // We keep subscription alive; completion handled via onDone.
    } catch (e) {
      isDownloading = false;
      downloadProgress = DownloadProgress(modelId: model.id, received: 0, total: 0, percent: 0, status: 'Error: $e', isError: true);
      notifyListeners();
    }
  }

  Future<void> cancelDownload() async {
    try {
      _downloadCancelToken?.cancel('User cancelled');
      await _downloadSub?.cancel();
    } catch (_) {}
    isDownloading = false;
    downloadingModel = null;
    downloadProgress = null;
    _downloadCancelToken = null;
    notifyListeners();
  }

  // Retry auto download if user dismissed and wants to enable again
  Future<void> retryAutoDownload() async {
    _autoDownloadStarted = false;
    await _startAutoDownloadIfNeeded();
  }

  void _applyFilter() {
    if (hardware == null) {
      filteredModels = allModels;
      return;
    }
    final gpuVram = gpu?.vramGB ?? 0;
    final actuallyUseGpu = useGpu && gpuService.shouldUseGpu(gpu!, userPrefGpu: useGpu);
    var base = hardwareService.filterCompatible(allModels, hardware!, showAll: showAllModels, useGpu: actuallyUseGpu, gpuVramGB: gpuVram);
    // Low PC mode: only show light models (<=3GB or Q2) to keep UI and download light
    if (storage.getLowPcMode() || (hardware != null && hardware!.isLowRam)) {
      // Prefer light, but still allow Show All to reveal all
      if (!showAllModels) {
        base = base.where((m) => m.ramRequiredGB <= 3.0 || m.quant.contains('Q2') || m.params == '0.5B').toList();
        // Ensure at least one light model is shown
        if (base.isEmpty) {
          base = allModels.where((m) => m.ramRequiredGB <= 1.5).toList();
        }
      }
    }
    filteredModels = base;
  }

  bool get isLowPcMode => storage.getLowPcMode();
  Future<void> setLowPcMode(bool v) async {
    await storage.setLowPcMode(v);
    _applyFilter();
    notifyListeners();
  }

  void toggleShowAll(bool v) {
    showAllModels = v;
    storage.setShowAllModels(v);
    _applyFilter();
    notifyListeners();
  }

  void toggleUseGpu(bool v) {
    useGpu = v;
    storage.setUseGpu(v);
    _applyFilter();
    notifyListeners();
  }

  void setTemperature(double t) {
    temperature = t;
    storage.setTemperature(t);
    notifyListeners();
  }

  String getSelectedModelId() {
    final saved = storage.getSelectedModelId();
    if (saved != null && filteredModels.any((m) => m.id == saved)) return saved;
    if (filteredModels.isNotEmpty) return filteredModels.first.id;
    if (allModels.isNotEmpty) return allModels.first.id;
    return 'qwen2.5-1.5b-q4';
  }

  void selectModel(String id) {
    storage.setSelectedModelId(id);
    if (currentSession != null) {
      currentSession!.modelId = id;
      storage.saveSession(currentSession!);
    }
    notifyListeners();
  }

  Future<void> newChat() async {
    final s = ChatSession(title: 'New Chat');
    s.modelId = getSelectedModelId();
    await storage.saveSession(s);
    sessions = storage.getAllSessions();
    currentSession = s;
    notifyListeners();
  }

  Future<void> switchSession(ChatSession s) async {
    currentSession = s;
    notifyListeners();
  }

  Future<void> deleteSession(String id) async {
    await storage.deleteSession(id);
    sessions = storage.getAllSessions();
    if (currentSession?.id == id) {
      if (sessions.isNotEmpty) currentSession = sessions.first;
      else {
        await newChat();
        return;
      }
    }
    notifyListeners();
  }

  Future<void> renameSession(String id, String title) async {
    final s = storage.getSession(id);
    if (s != null) {
      s.title = title;
      await storage.saveSession(s);
      sessions = storage.getAllSessions();
      notifyListeners();
    }
  }

  Future<void> setPdf(String path, String text) async {
    if (currentSession == null) return;
    currentSession!.pdfPath = path;
    currentSession!.pdfText = text;
    await storage.saveSession(currentSession!);
    notifyListeners();
  }

  Future<void> clearPdf() async {
    if (currentSession == null) return;
    currentSession!.pdfPath = null;
    currentSession!.pdfText = null;
    await storage.saveSession(currentSession!);
    notifyListeners();
  }

  ModelCompatibility getCompat(AiModel m) {
    if (hardware == null || gpu == null) return ModelCompatibility.compatible;
    final actuallyUseGpu = useGpu && gpuService.shouldUseGpu(gpu!, userPrefGpu: useGpu);
    return hardwareService.checkCompatibility(m, hardware!, useGpu: actuallyUseGpu, gpuVramGB: gpu?.vramGB ?? 0);
  }

  Future<void> sendMessage(String text) async {
    if (currentSession == null || text.trim().isEmpty) return;
    final modelId = currentSession!.modelId ?? getSelectedModelId();
    final userMsg = ChatMessage(role: MessageRole.user, content: text, modelId: modelId);
    currentSession!.messages.add(userMsg);
    if (currentSession!.messages.length == 1) {
      currentSession!.title = text.length > 40 ? text.substring(0, 40) : text;
    }
    final assistantMsg = ChatMessage(role: MessageRole.assistant, content: '', modelId: modelId, isStreaming: true);
    currentSession!.messages.add(assistantMsg);
    await storage.saveSession(currentSession!);
    isGenerating = true;
    isVerifying = false;
    streamingBuffer = '';
    notifyListeners();

    try {
      String finalPrompt = text;
      String? system = 'You are a helpful assistant. Answer concisely and accurately. Double-check facts before answering.';
      final bool hasPdf = currentSession!.pdfText != null && currentSession!.pdfText!.isNotEmpty;
      if (hasPdf) {
        finalPrompt = pdfService.buildRagPrompt(text, currentSession!.pdfText!);
        system = 'You are a helpful assistant that answers using the provided PDF context. Be accurate and cite page context. Verify your answer against the PDF.';
      }

      final history = currentSession!.messages
          .where((m) => m.id != assistantMsg.id && m.id != userMsg.id)
          .toList()
          .reversed
          .take(6)
          .toList()
          .reversed
          .map((m) => {'role': m.role == MessageRole.user ? 'user' : 'assistant', 'content': m.content})
          .toList();

      final bool shouldVerify = storage.getVerifyResponses() && !isLowPcMode;
      // For low PC, skip verification to save time/RAM, unless explicitly enabled and not low RAM
      final bool doVerify = shouldVerify && !(hardware?.isLowRam ?? false);

      String buffer = '';

      if (doVerify) {
        // Phase 1: Generate draft silently (don't stream to UI yet)
        String draft = '';
        final draftStream = llama.generate(
          modelId: modelId,
          prompt: finalPrompt,
          systemPrompt: system,
          history: history.isEmpty ? null : history,
          temperature: temperature,
        );
        await for (final token in draftStream) {
          draft += token;
        }
        if (draft.trim().isEmpty) draft = 'No response generated.';

        // Phase 2: Verify before showing
        isVerifying = true;
        // Show verifying indicator with draft hidden
        final idxV = currentSession!.messages.indexWhere((m) => m.id == assistantMsg.id);
        if (idxV != -1) {
          currentSession!.messages[idxV] = assistantMsg.copyWith(content: '▌ Verifying answer...', isStreaming: true);
          streamingBuffer = 'Verifying...';
          notifyListeners();
        }

        String verified;
        try {
          verified = await llama.verifyDraft(
            modelId: modelId,
            question: text,
            draft: draft,
            pdfContext: hasPdf ? currentSession!.pdfText : null,
            temperature: 0.2,
          );
        } catch (_) {
          verified = draft;
        }

        isVerifying = false;
        buffer = verified.trim().isEmpty ? draft : verified;

        // Phase 3: Stream verified result to UI (char by char for smooth UX, but fast)
        // Instead of streaming token by token again, we stream the verified buffer with a small delay for UX
        String streamed = '';
        // Update to empty before streaming verified
        final idx0 = currentSession!.messages.indexWhere((m) => m.id == assistantMsg.id);
        if (idx0 != -1) {
          currentSession!.messages[idx0] = assistantMsg.copyWith(content: '', isStreaming: true);
          notifyListeners();
        }
        // Stream verified in chunks for visual effect, but quickly
        for (int i = 0; i < buffer.length; i++) {
          streamed += buffer[i];
          // Update every 12 chars or at end to avoid too many rebuilds on low PC
          if (i % 12 == 0 || i == buffer.length - 1) {
            final idx = currentSession!.messages.indexWhere((m) => m.id == assistantMsg.id);
            if (idx != -1) {
              currentSession!.messages[idx] = assistantMsg.copyWith(content: streamed, isStreaming: true);
              streamingBuffer = streamed;
              notifyListeners();
            }
            // Small delay for low PC smoothness, but not too slow
            if (i % 48 == 0) await Future.delayed(const Duration(milliseconds: 1));
          }
        }
        buffer = streamed;
      } else {
        // No verification: stream directly as before (light for low PC)
        final stream = llama.generate(
          modelId: modelId,
          prompt: finalPrompt,
          systemPrompt: system,
          history: history.isEmpty ? null : history,
          temperature: temperature,
        );
        await for (final token in stream) {
          buffer += token;
          final idx = currentSession!.messages.indexWhere((m) => m.id == assistantMsg.id);
          if (idx != -1) {
            currentSession!.messages[idx] = assistantMsg.copyWith(content: buffer, isStreaming: true);
            streamingBuffer = buffer;
            notifyListeners();
          }
        }
      }

      // Finalize
      final idx = currentSession!.messages.indexWhere((m) => m.id == assistantMsg.id);
      if (idx != -1) {
        currentSession!.messages[idx] = ChatMessage(
          id: assistantMsg.id,
          role: MessageRole.assistant,
          content: buffer,
          modelId: modelId,
          isStreaming: false,
        );
      }
      isGenerating = false;
      isVerifying = false;
      streamingBuffer = null;
      await storage.saveSession(currentSession!);
      sessions = storage.getAllSessions();
      notifyListeners();
    } catch (e) {
      final idx = currentSession!.messages.indexWhere((m) => m.id == assistantMsg.id);
      if (idx != -1) {
        currentSession!.messages[idx] = ChatMessage(
          id: assistantMsg.id,
          role: MessageRole.assistant,
          content: 'Error: $e\n\n${await llama.getStatusMessage()}',
          modelId: modelId,
          isStreaming: false,
        );
      }
      isGenerating = false;
      isVerifying = false;
      streamingBuffer = null;
      await storage.saveSession(currentSession!);
      notifyListeners();
    }
  }

  void stopGeneration() {
    isGenerating = false;
    notifyListeners();
  }

  Future<void> clearCurrentChat() async {
    if (currentSession == null) return;
    currentSession!.messages.clear();
    await storage.saveSession(currentSession!);
    notifyListeners();
  }
}
