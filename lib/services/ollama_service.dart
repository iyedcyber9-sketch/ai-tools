import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service that talks to local Ollama ( http://localhost:11434 )
/// Used for desktop (Windows/Linux) where Ollama is easiest to install.
/// For Android we use llama_cpp_dart directly.
class OllamaService {
  final String baseUrl;
  OllamaService({this.baseUrl = 'http://localhost:11434'});

  Future<bool> isAvailable() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/tags')).timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> listModels() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/tags'));
      if (res.statusCode != 200) return [];
      final data = json.decode(res.body);
      final models = data['models'] as List?;
      if (models == null) return [];
      return models.map((e) => e['name'].toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Stream<String> generateStream({
    required String model, // e.g. "deepseek-coder:1.3b" or "qwen2.5:1.5b"
    required String prompt,
    String? system,
    double temperature = 0.7,
    int numPredict = 2048,
  }) async* {
    final uri = Uri.parse('$baseUrl/api/generate');
    final body = json.encode({
      'model': model,
      'prompt': prompt,
      'system': system,
      'stream': true,
      'options': {'temperature': temperature, 'num_predict': numPredict}
    });

    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = body;

    final streamed = await request.send();
    if (streamed.statusCode != 200) {
      final err = await streamed.stream.bytesToString();
      throw Exception('Ollama error ${streamed.statusCode}: $err. Make sure model "$model" is pulled: ollama pull $model');
    }

    await for (final chunk in streamed.stream.transform(utf8.decoder).transform(const LineSplitter())) {
      if (chunk.trim().isEmpty) continue;
      try {
        final data = json.decode(chunk);
        if (data['response'] != null) {
          yield data['response'] as String;
        }
        if (data['done'] == true) break;
        if (data['error'] != null) throw Exception(data['error']);
      } catch (_) {
        // ignore malformed lines
      }
    }
  }

  // Chat endpoint with history (Ollama chat)
  Stream<String> chatStream({
    required String model,
    required List<Map<String, String>> messages, // [{role, content}]
    double temperature = 0.7,
  }) async* {
    final uri = Uri.parse('$baseUrl/api/chat');
    final body = json.encode({
      'model': model,
      'messages': messages,
      'stream': true,
      'options': {'temperature': temperature}
    });
    final req = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = body;
    final streamed = await req.send();
    if (streamed.statusCode != 200) {
      final err = await streamed.stream.bytesToString();
      throw Exception('Ollama chat error ${streamed.statusCode}: $err');
    }
    await for (final chunk in streamed.stream.transform(utf8.decoder).transform(const LineSplitter())) {
      if (chunk.trim().isEmpty) continue;
      try {
        final data = json.decode(chunk);
        final msg = data['message'];
        if (msg != null && msg['content'] != null) yield msg['content'] as String;
        if (data['done'] == true) break;
        if (data['error'] != null) throw Exception(data['error']);
      } catch (_) {}
    }
  }

  Future<void> pullModel(String model, void Function(String) onLog) async {
    final uri = Uri.parse('$baseUrl/api/pull');
    final body = json.encode({'name': model, 'stream': true});
    final req = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = body;
    final streamed = await req.send();
    await for (final chunk in streamed.stream.transform(utf8.decoder).transform(const LineSplitter())) {
      if (chunk.trim().isEmpty) continue;
      try {
        final data = json.decode(chunk);
        if (data['status'] != null) onLog(data['status']);
        if (data['error'] != null) throw Exception(data['error']);
      } catch (_) {}
    }
  }

  // Pull with progress stream for auto-download UI
  Stream<Map<String, dynamic>> pullModelWithProgress(String model) async* {
    final uri = Uri.parse('$baseUrl/api/pull');
    final body = json.encode({'name': model, 'stream': true});
    final req = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = body;
    final streamed = await req.send();
    if (streamed.statusCode != 200) {
      final err = await streamed.stream.bytesToString();
      throw Exception('Ollama pull failed ${streamed.statusCode}: $err');
    }
    await for (final chunk in streamed.stream.transform(utf8.decoder).transform(const LineSplitter())) {
      if (chunk.trim().isEmpty) continue;
      try {
        final data = json.decode(chunk) as Map<String, dynamic>;
        if (data['error'] != null) throw Exception(data['error']);
        yield data;
      } catch (e) {
        if (e.toString().contains('Exception')) rethrow;
      }
    }
  }
}
