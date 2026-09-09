import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'ollama_service.dart';

/// Unified inference service.
/// - Desktop (Windows/Linux/macOS): uses Ollama HTTP API (local free).
/// - Android: tries llama_cpp_dart; if not available, uses Ollama if installed, else instructs user.
/// For MVP we implement Ollama path fully; llama_cpp_dart path is scaffolded for future native build.
class LlamaService {
  final OllamaService ollama = OllamaService();
  // placeholder for future native engine
  bool _nativeInitialized = false;

  // Map our model IDs to Ollama model names (include all variants user might have)
  static const Map<String, String> ollamaModelMap = {
    'deepseek-coder-1.3b-q4': 'deepseek-coder:1.3b',
    'deepseek-r1-1.5b-q4': 'deepseek-r1:1.5b',
    'deepseek-r1-7b-q4': 'deepseek-r1:7b',
    'deepseek-r1-14b-q4': 'deepseek-r1:14b',
    'deepseek-r1-32b-q4': 'deepseek-r1:32b',
    'deepseek-coder-6.7b-q4': 'deepseek-coder:6.7b',
    'qwen2.5-0.5b-q4': 'qwen2.5:0.5b',
    'qwen2.5-1.5b-q4': 'qwen2.5:1.5b',
    'qwen2.5-1.5b-q2': 'qwen2.5:1.5b',
    'qwen2.5-3b-q4': 'qwen2.5:3b',
    'qwen2.5-7b-q4': 'qwen2.5:7b',
    'qwen2.5-7b-q2': 'qwen2.5:7b',
    'qwen2.5-14b-q4': 'qwen2.5:14b',
    'qwen2.5-32b-q4': 'qwen2.5:32b',
    'qwen2.5-coder-7b-q4': 'qwen2.5-coder:7b',
    'qwen3-0.6b-q4': 'qwen3:0.6b',
    'qwen3-1.7b-q4': 'qwen3:1.7b',
    'qwen3-4b-q4': 'qwen3:4b',
    'qwen3-8b-q4': 'qwen3:8b',
    'qwen3-14b-q4': 'qwen3:14b',
    'qwen3-32b-q4': 'qwen3:32b',
    'llama3.1-8b-q4': 'llama3.1',
    'mistral-7b-q4': 'mistral',
    'gemma2-9b-q4': 'gemma2:9b',
    'deepseek-r1-8b-q4': 'deepseek-r1:8b',
    'phi3-mini-3.8b-q4': 'phi3:mini',
    'llama3.2-1b-q4': 'llama3.2:1b',
    'llama3.2-3b-q4': 'llama3.2:3b',
  };

  // Reverse map: Ollama name -> our ID (first match)
  String? ollamaToId(String ollamaName) {
    for (var e in ollamaModelMap.entries) {
      if (e.value == ollamaName) return e.key;
    }
    // Try fuzzy: check base name
    final base = ollamaName.split(':').first;
    for (var e in ollamaModelMap.entries) {
      if (e.value.startsWith(base)) return e.key;
    }
    return null;
  }

  String mapToOllama(String modelId) {
    return ollamaModelMap[modelId] ?? modelId;
  }

  Future<bool> isAvailable() async {
    if (Platform.isAndroid) {
      // For now, check if we can use native llama_cpp_dart files, else fallback to Ollama check
      final available = await ollama.isAvailable();
      if (available) return true;
      // Check if GGUF model file exists for native
      return _nativeInitialized;
    }
    return await ollama.isAvailable();
  }

  Future<String> getStatusMessage() async {
    final avail = await ollama.isAvailable();
    if (avail) {
      final models = await ollama.listModels();
      return 'Ollama running. Models: ${models.isEmpty ? "none - pull one" : models.join(", ")}';
    } else {
      if (Platform.isAndroid) {
        return 'No local engine yet. On Android, download a GGUF model. On Desktop, install Ollama from https://ollama.com and run "ollama pull qwen2.5:1.5b"';
      }
      return 'Ollama not running. Install from https://ollama.com then run: ollama pull qwen2.5:1.5b  (or deepseek-coder:1.3b for coding)';
    }
  }

  // Get local GGUF path for a model id (for Android native)
  Future<String> getModelPath(String modelId) async {
    final dir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${dir.path}/models');
    if (!await modelsDir.exists()) await modelsDir.create(recursive: true);
    // Try to find local file mapping
    // We look for files matching modelId
    return '${modelsDir.path}/$modelId.gguf';
  }

  Future<bool> isModelDownloaded(String modelId) async {
    // Check Ollama list first if available - EXACT match required
    if (await ollama.isAvailable()) {
      final ollamaName = mapToOllama(modelId);
      final list = await ollama.listModels();
      // Exact match
      if (list.contains(ollamaName)) return true;
      // Also check with tag variations: some Ollama lists include :latest
      // For example, qwen2.5-coder:1.5b vs qwen2.5:1.5b - check size param match
      final targetSize = RegExp(r'(\d+\.?\d*b)').firstMatch(ollamaName)?.group(1);
      final targetFamily = ollamaName.split(':').first.split('-').first;
      if (targetSize != null) {
        for (var m in list) {
          if (m.contains(targetSize) && m.toLowerCase().contains(targetFamily)) {
            // Consider as alternative downloaded (e.g., qwen2.5-coder:1.5b can serve for qwen2.5:1.5b request)
            // But we still require exact for this modelId; alternative handled via fallback, not here
          }
        }
      }
    }
    final path = await getModelPath(modelId);
    return await File(path).exists();
  }

  // Find best Ollama model that is actually downloaded and can handle the request
  // Prefers exact, then same family closest size, then same size any family, then smallest
  Future<String?> findBestAvailableOllamaModel(String requestedId) async {
    if (!await ollama.isAvailable()) return null;
    final list = await ollama.listModels();
    if (list.isEmpty) return null;
    final requestedOllama = mapToOllama(requestedId);
    if (list.contains(requestedOllama)) return requestedOllama;

    // Helper to parse size numeric
    double? parseSize(String s) {
      final m = RegExp(r'(\d+\.?\d*)b').firstMatch(s.toLowerCase());
      if (m == null) return null;
      return double.tryParse(m.group(1)!);
    }

    final reqSize = parseSize(requestedOllama);
    final family = requestedId.split('-').first.toLowerCase(); // qwen or deepseek

    // 2. Same family - find closest size
    final sameFamily = list.where((m) => m.toLowerCase().contains(family)).toList();
    if (sameFamily.isNotEmpty && reqSize != null) {
      String? best;
      double bestDiff = double.infinity;
      for (var m in sameFamily) {
        final sz = parseSize(m);
        if (sz == null) continue;
        final diff = (sz - reqSize).abs();
        // Prefer not too much larger? but closest is good
        if (diff < bestDiff) {
          bestDiff = diff;
          best = m;
        }
      }
      if (best != null) return best;
      // fallback to first family match
      return sameFamily.first;
    }

    // 3. Same size any family
    final sizeStr = RegExp(r'(\d+\.?\d*b)').firstMatch(requestedOllama)?.group(1);
    if (sizeStr != null) {
      for (var m in list) {
        if (m.contains(sizeStr)) return m;
      }
    }

    // 4. Prefer coder if requested is coder
    final isCoder = requestedId.contains('coder');
    if (isCoder) {
      final coder = list.where((m) => m.contains('coder')).toList();
      if (coder.isNotEmpty) return coder.first;
    }
    return list.first;
  }

  // Unified streaming with auto-fallback and auto-pull
  Stream<String> generate({
    required String modelId,
    required String prompt,
    String? systemPrompt,
    List<Map<String, String>>? history, // for chat
    double temperature = 0.7,
  }) async* {
    // If Ollama is reachable, use it (best for desktop free CPU/GPU)
    if (await ollama.isAvailable()) {
      final requestedOllama = mapToOllama(modelId);
      final models = await ollama.listModels();
      String? ollamaModel = requestedOllama;

      // Find best available model if exact not found — silent fallback for best performance
      if (!models.contains(requestedOllama)) {
        final fallback = await findBestAvailableOllamaModel(modelId);
        if (fallback != null) {
          // Silent fallback — use closest available model without showing error to user
          // The UI will show which model is actually used via statusMessage if needed
          ollamaModel = fallback;
        } else if (models.isEmpty) {
          // No models at all — try to auto-pull requested
          try {
            // Note: pull progress is handled via DownloadService in UI, not as chat messages
            await for (final _ in ollama.pullModelWithProgress(requestedOllama)) {}
            ollamaModel = requestedOllama;
          } catch (_) {
            // Let generation attempt and show proper error below
          }
        } else {
          // Fallback to first available while pulling requested in background (silent)
          ollama.pullModelWithProgress(requestedOllama).drain().catchError((_) {});
          ollamaModel = models.first;
        }
      }

      // Now try to generate with chosen ollamaModel, catch 404 and auto-pull+retry once (silent)
      try {
        if (history != null && history.isNotEmpty) {
          final msgs = [...history, {'role': 'user', 'content': prompt}];
          if (systemPrompt != null && systemPrompt.isNotEmpty) {
            msgs.insert(0, {'role': 'system', 'content': systemPrompt});
          }
          yield* ollama.chatStream(model: ollamaModel!, messages: msgs, temperature: temperature);
        } else {
          yield* ollama.generateStream(model: ollamaModel!, prompt: prompt, system: systemPrompt, temperature: temperature);
        }
        return;
      } catch (e) {
        final errStr = e.toString().toLowerCase();
        if (errStr.contains('404') || errStr.contains('not found') || errStr.contains('model') && errStr.contains('not found')) {
          // Silent auto-pull retry
          try {
            await for (final _ in ollama.pullModelWithProgress(ollamaModel!)) {}
            if (history != null && history.isNotEmpty) {
              final msgs = [...history, {'role': 'user', 'content': prompt}];
              if (systemPrompt != null && systemPrompt.isNotEmpty) msgs.insert(0, {'role': 'system', 'content': systemPrompt});
              yield* ollama.chatStream(model: ollamaModel, messages: msgs, temperature: temperature);
            } else {
              yield* ollama.generateStream(model: ollamaModel, prompt: prompt, system: systemPrompt, temperature: temperature);
            }
            return;
          } catch (e2) {
            // If pull fails, try one more fallback to any available model
            final retryFallback = await findBestAvailableOllamaModel(modelId);
            if (retryFallback != null && retryFallback != ollamaModel) {
              try {
                if (history != null && history.isNotEmpty) {
                  final msgs = [...history, {'role': 'user', 'content': prompt}];
                  if (systemPrompt != null && systemPrompt.isNotEmpty) msgs.insert(0, {'role': 'system', 'content': systemPrompt});
                  yield* ollama.chatStream(model: retryFallback, messages: msgs, temperature: temperature);
                } else {
                  yield* ollama.generateStream(model: retryFallback, prompt: prompt, system: systemPrompt, temperature: temperature);
                }
                return;
              } catch (_) {}
            }
            yield 'Sorry — model $ollamaModel is not available and auto-download failed. Try selecting another model that shows ✓ Downloaded in the model panel, or check Ollama: `ollama list` and `ollama pull $ollamaModel`.\nAvailable: ${(await ollama.listModels()).join(", ")}\nError: $e2';
            return;
          }
        } else {
          rethrow;
        }
      }
    }

    // Fallback: If Android native GGUF exists, use llama_cpp_dart
    if (Platform.isAndroid) {
      final path = await getModelPath(modelId);
      final file = File(path);
      if (await file.exists()) {
        // TODO: implement native llama_cpp_dart inference here
        // For now, scaffold streaming via native isolate
        yield '[Native GGUF found at $path]\n';
        yield '[llama_cpp_dart inference not yet wired in this preview build.]\n';
        yield 'To enable on Android, ensure llama_cpp_dart native AAR is bundled and model is loaded via LlamaEngine. See lib/services/llama_service.dart for integration point.\n\n';
        yield 'Falling back to demo response for: "$prompt"\n\n';
        yield _demoResponse(prompt);
        return;
      }
    }

    // No engine available - give helpful instructions + demo
    yield await getStatusMessage();
    yield '\n\n---\nDemo response (offline mock) for prompt: "$prompt"\n\n';
    yield _demoResponse(prompt);
  }

  // Verification: ask the model to verify and correct its own draft before showing to user
  // This runs as a second pass with low temperature to reduce hallucinations
  Future<String> verifyDraft({
    required String modelId,
    required String question,
    required String draft,
    String? pdfContext,
    double temperature = 0.2,
  }) async {
    // If draft is very short or is an error message, don't verify
    if (draft.trim().length < 20 || draft.contains('Sorry — model') || draft.contains('Demo response')) {
      return draft;
    }

    final verifySystem = '''You are a meticulous AI verifier. Your job is to verify the draft answer for errors before showing to user.
- Check for factual errors, hallucinations, logical mistakes, incomplete answers.
- If draft is correct, return it unchanged.
- If errors found, output the CORRECTED answer only, without explaining that you verified.
- Keep same language as draft, be concise, do not add meta-comments like "Verified:".
- If question is about PDF context, ensure answer is grounded in provided PDF excerpt.''';

    String verifyPrompt;
    if (pdfContext != null && pdfContext.isNotEmpty) {
      // For PDF, include relevant context snippet (first 2000 chars) to avoid too long prompt on low PC
      final ctxSnippet = pdfContext.length > 2000 ? pdfContext.substring(0, 2000) + '...' : pdfContext;
      verifyPrompt = '''PDF Context (excerpt):
$ctxSnippet

Question: $question

Draft answer to verify:
$draft

Task: Verify draft against PDF context and general knowledge. If correct, return draft unchanged. If wrong, correct it. Output final answer only:''';
    } else {
      verifyPrompt = '''Question: $question

Draft answer to verify:
$draft

Task: Verify draft for errors. If correct, return unchanged. If errors, correct. Output final answer only:''';
    }

    try {
      // Use a single non-streaming generation for verification to collect full corrected text
      String verified = '';
      await for (final token in generate(
        modelId: modelId,
        prompt: verifyPrompt,
        systemPrompt: verifySystem,
        temperature: temperature,
      )) {
        verified += token;
        // Avoid too long verification (cap at draft length + 50%)
        if (verified.length > draft.length * 1.8 && verified.length > 2000) break;
      }
      final trimmed = verified.trim();
      // If verification returned empty or very short, fallback to draft
      if (trimmed.isEmpty || trimmed.length < 10) return draft;
      // If verified is much shorter than draft and draft was long, maybe verification failed - keep draft
      // Heuristic: if verified is <30% of draft length, keep draft
      if (draft.length > 200 && trimmed.length < draft.length * 0.3) return draft;
      return trimmed;
    } catch (_) {
      return draft;
    }
  }

  String _demoResponse(String prompt) {
    return 'This is a demo offline response. Once you install Ollama (desktop) or download a GGUF (Android), you will get real AI inference for free on your own CPU/GPU.\n\nYour prompt was: "$prompt"\n\nTry: "Explain quantum computing" or paste a PDF and ask "Summarize this document".\n';
  }
}
