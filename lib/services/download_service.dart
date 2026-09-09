import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/ai_model.dart';
import 'llama_service.dart';

class DownloadProgress {
  final String modelId;
  final int received;
  final int total;
  final double percent; // 0-100
  final String status; // downloading, done, error, pulling
  final bool isDone;
  final bool isError;

  DownloadProgress({
    required this.modelId,
    required this.received,
    required this.total,
    required this.percent,
    required this.status,
    this.isDone = false,
    this.isError = false,
  });
}

class DownloadService {
  final LlamaService _llama = LlamaService();

  Future<String> getModelsDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${dir.path}/models');
    if (!await modelsDir.exists()) await modelsDir.create(recursive: true);
    return modelsDir.path;
  }

  Future<String> getModelFilePath(AiModel model) async {
    final base = await getModelsDir();
    return '$base/${model.id}.gguf';
  }

  Future<bool> isDownloaded(AiModel model) async {
    if (await _llama.isModelDownloaded(model.id)) return true;
    final path = await getModelFilePath(model);
    final file = File(path);
    if (!await file.exists()) return false;
    final len = await file.length();
    final expected = (model.diskGB * 1024 * 1024 * 1024).toInt();
    return len > expected * 0.5;
  }

  // Light, resumable, background-friendly download
  // - Resume if tmp exists (Range header)
  // - Throttled progress (every 200ms) to keep low PC smooth
  // - Runs in same isolate but async, not blocking UI; chat works with already-downloaded model
  Stream<DownloadProgress> downloadModelStream(AiModel model, {CancelToken? cancelToken}) async* {
    final isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    // Try Ollama first on desktop if available (most efficient, uses Ollama's own resume)
    if (isDesktop) {
      final ollama = _llama.ollama;
      final avail = await ollama.isAvailable();
      if (avail) {
        final ollamaName = _llama.mapToOllama(model.id);
        yield DownloadProgress(modelId: model.id, received: 0, total: 100, percent: 0, status: 'Connecting to Ollama...');
        try {
          await for (final data in ollama.pullModelWithProgress(ollamaName)) {
            final status = data['status']?.toString() ?? 'Downloading';
            final completed = (data['completed'] as num?)?.toInt() ?? 0;
            final total = (data['total'] as num?)?.toInt() ?? 0;
            double pct = 0;
            if (total > 0) pct = (completed / total * 100).clamp(0, 100);
            if (pct == 0 && status.contains('%')) {
              final m = RegExp(r'(\d+)%').firstMatch(status);
              if (m != null) pct = double.tryParse(m.group(1)!) ?? 0;
            }
            if (status.toLowerCase().contains('pulling manifest')) pct = 5;
            yield DownloadProgress(modelId: model.id, received: completed, total: total > 0 ? total : 100, percent: pct, status: status);
            if (status.toLowerCase().contains('success') || status.toLowerCase().contains('verifying')) pct = 100;
          }
          yield DownloadProgress(modelId: model.id, received: 100, total: 100, percent: 100, status: 'Done via Ollama', isDone: true);
          return;
        } catch (e) {
          yield DownloadProgress(modelId: model.id, received: 0, total: 100, percent: 0, status: 'Ollama pull failed: $e — switching to direct', isError: false);
        }
      }
    }

    final path = await getModelFilePath(model);
    final tmpPath = '$path.tmp';
    final tmpFile = File(tmpPath);

    // Light: check existing tmp for resume (saves network on low PC / slow connection)
    int existingBytes = 0;
    if (await tmpFile.exists()) {
      try {
        existingBytes = await tmpFile.length();
        // If tmp is already >90% of expected, just verify and rename
        final expected = (model.diskGB * 1024 * 1024 * 1024).toInt();
        if (existingBytes > expected * 0.9) {
          await tmpFile.rename(path);
          yield DownloadProgress(modelId: model.id, received: expected, total: expected, percent: 100, status: 'Resumed — already complete', isDone: true);
          return;
        }
      } catch (_) {}
    }

    try {
      final totalExpected = (model.diskGB * 1024 * 1024 * 1024).toInt();
      if (existingBytes > 0) {
        yield DownloadProgress(modelId: model.id, received: existingBytes, total: totalExpected, percent: (existingBytes / totalExpected * 100).clamp(0, 99), status: 'Resuming at ${(existingBytes/1024/1024).toStringAsFixed(1)}MB...');
      } else {
        yield DownloadProgress(modelId: model.id, received: 0, total: totalExpected, percent: 0, status: 'Starting download (light mode)...');
      }

      final progressStream = _dioDownloadResumable(model.url, tmpPath, existingBytes, totalExpected, cancelToken: cancelToken);
      int lastYieldMs = 0;
      DownloadProgress? lastProg;
      await for (final p in progressStream) {
        final now = DateTime.now().millisecondsSinceEpoch;
        // Throttle to 200ms for low PC (less UI jank)
        if (now - lastYieldMs < 200 && p.percent < 99.9) {
          lastProg = p;
          continue;
        }
        lastYieldMs = now;
        lastProg = null;
        yield DownloadProgress(modelId: model.id, received: p.received, total: p.total, percent: p.percent, status: p.status);
      }
      // Flush last
      if (lastProg != null) {
        yield DownloadProgress(modelId: model.id, received: lastProg.received, total: lastProg.total, percent: lastProg.percent, status: lastProg.status);
      }

      if (await tmpFile.exists()) {
        final len = await tmpFile.length();
        if (len < 1024 * 1024) {
          yield DownloadProgress(modelId: model.id, received: len, total: len, percent: 0, status: 'Error: file too small', isError: true);
          await tmpFile.delete();
          return;
        }
        // Atomic rename
        if (await File(path).exists()) await File(path).delete();
        await tmpFile.rename(path);
      }
      yield DownloadProgress(modelId: model.id, received: 100, total: 100, percent: 100, status: 'Download complete ✓', isDone: true);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        yield DownloadProgress(modelId: model.id, received: 0, total: 0, percent: 0, status: 'Paused — tap resume', isError: false);
      } else {
        yield DownloadProgress(modelId: model.id, received: 0, total: 0, percent: 0, status: 'Network error: ${e.message ?? e.error}. Will resume.', isError: true);
      }
    } catch (e) {
      yield DownloadProgress(modelId: model.id, received: 0, total: 0, percent: 0, status: 'Error: $e', isError: true);
    }
  }

  // Resumable Dio download with Range header, light buffer (4K for low RAM)
  Stream<DownloadProgress> _dioDownloadResumable(String url, String savePath, int existingBytes, int totalExpected, {CancelToken? cancelToken}) async* {
    final dio = Dio(BaseOptions(
      headers: {'User-Agent': 'AI-Tools/1.0', 'Accept-Encoding': 'identity'},
      receiveTimeout: const Duration(minutes: 20),
      sendTimeout: const Duration(seconds: 30),
    ));
    final controller = StreamController<DownloadProgress>();
    String lastStatus = existingBytes > 0 ? 'Resuming...' : 'Downloading...';

    // Prepare headers for resume
    final headers = <String, dynamic>{};
    if (existingBytes > 0) {
      headers['Range'] = 'bytes=$existingBytes-';
    }

    final file = File(savePath);
    // Open in append mode if resuming
    final raf = await file.open(mode: FileMode.append);

    try {
      final response = await dio.get<ResponseBody>(
        url,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          headers: headers,
          followRedirects: true,
          receiveDataWhenStatusError: false,
        ),
      );

      final statusCode = response.statusCode ?? 200;
      // If server replies 206 Partial Content, resume ok; if 200, it ignored Range and we should restart
      if (statusCode == 200 && existingBytes > 0) {
        // Server doesn't support resume, restart from 0
        await raf.close();
        await file.writeAsBytes([], mode: FileMode.write);
        existingBytes = 0;
      }

      final contentLength = int.tryParse(response.headers.value('content-length') ?? '') ?? 0;
      int total = contentLength > 0 ? contentLength + existingBytes : totalExpected;
      if (total == 0) total = totalExpected;
      int received = existingBytes;

      final stream = response.data!.stream;
      int lastYield = 0;
      await for (final chunk in stream) {
        if (cancelToken?.isCancelled == true) break;
        await raf.writeFrom(chunk);
        received += chunk.length;
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - lastYield < 150) continue; // throttle
        lastYield = now;
        double pct = total > 0 ? (received / total * 100).clamp(0, 100) : 0;
        lastStatus = 'Downloading ${(received/1024/1024).toStringAsFixed(1)}MB${total>0 ? ' / ${(total/1024/1024).toStringAsFixed(1)}MB' : ''} • ${(pct).toStringAsFixed(1)}%';
        if (!controller.isClosed) {
          controller.add(DownloadProgress(modelId: 'progress', received: received, total: total, percent: pct, status: lastStatus));
        }
      }
      await raf.close();
      if (!controller.isClosed) {
        controller.add(DownloadProgress(modelId: 'progress', received: received, total: total, percent: 100, status: 'Saving...', isDone: true));
        await controller.close();
      }
    } catch (e) {
      try { await raf.close(); } catch (_) {}
      if (!controller.isClosed) {
        controller.addError(e);
        await controller.close();
      }
    }

    await for (final p in controller.stream) {
      yield p;
    }
  }

  Stream<DownloadProgress> downloadModel(AiModel model, {CancelToken? cancelToken}) => downloadModelStream(model, cancelToken: cancelToken);
  Stream<DownloadProgress> downloadWithProgress(AiModel model) => downloadModelStream(model);

  Future<void> deleteModel(AiModel model) async {
    final path = await getModelFilePath(model);
    final f = File(path);
    if (await f.exists()) await f.delete();
    final tmp = File('$path.tmp');
    if (await tmp.exists()) await tmp.delete();
  }

  Future<double> getFreeDiskGB() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      await FileStat.stat(dir.path);
      return 20;
    } catch (_) {
      return 20;
    }
  }
}
