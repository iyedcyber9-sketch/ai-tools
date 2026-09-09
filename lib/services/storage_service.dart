import 'dart:convert';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/chat_models.dart';

class StorageService {
  static const String chatBoxName = 'chat_sessions';
  static const String settingsBoxName = 'settings';

  late Box _chatBox;
  late Box _settingsBox;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _chatBox = await Hive.openBox(chatBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
    _initialized = true;
  }

  // Chat sessions
  List<ChatSession> getAllSessions() {
    final out = <ChatSession>[];
    for (var key in _chatBox.keys) {
      final raw = _chatBox.get(key);
      if (raw is String) {
        try {
          final j = json.decode(raw) as Map<String, dynamic>;
          out.add(ChatSession.fromJson(j));
        } catch (_) {}
      }
    }
    out.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return out;
  }

  Future<void> saveSession(ChatSession session) async {
    session.updatedAt = DateTime.now();
    await _chatBox.put(session.id, json.encode(session.toJson()));
  }

  Future<void> deleteSession(String id) async {
    await _chatBox.delete(id);
  }

  Future<void> clearAll() async {
    await _chatBox.clear();
  }

  ChatSession? getSession(String id) {
    final raw = _chatBox.get(id);
    if (raw is String) {
      try {
        return ChatSession.fromJson(json.decode(raw));
      } catch (_) {}
    }
    return null;
  }

  // Settings
  String? getSelectedModelId() => _settingsBox.get('selectedModelId') as String?;
  Future<void> setSelectedModelId(String id) async => await _settingsBox.put('selectedModelId', id);

  bool getShowAllModels() => _settingsBox.get('showAllModels', defaultValue: false) as bool;
  Future<void> setShowAllModels(bool v) async => await _settingsBox.put('showAllModels', v);

  bool getUseGpu() => _settingsBox.get('useGpu', defaultValue: true) as bool;
  Future<void> setUseGpu(bool v) async => await _settingsBox.put('useGpu', v);

  double getTemperature() => (_settingsBox.get('temperature', defaultValue: 0.7) as num).toDouble();
  Future<void> setTemperature(double v) async => await _settingsBox.put('temperature', v);

  String? getOllamaUrl() => _settingsBox.get('ollamaUrl') as String?;
  Future<void> setOllamaUrl(String url) async => await _settingsBox.put('ollamaUrl', url);

  bool getHasDoneAutoSetup() => _settingsBox.get('hasDoneAutoSetup', defaultValue: false) as bool;
  Future<void> setHasDoneAutoSetup(bool v) async => await _settingsBox.put('hasDoneAutoSetup', v);

  bool getAutoDownloadEnabled() => _settingsBox.get('autoDownloadEnabled', defaultValue: true) as bool;
  Future<void> setAutoDownloadEnabled(bool v) async => await _settingsBox.put('autoDownloadEnabled', v);

  bool getLowPcMode() => _settingsBox.get('lowPcMode', defaultValue: false) as bool;
  Future<void> setLowPcMode(bool v) async => await _settingsBox.put('lowPcMode', v);

  bool getVerifyResponses() => _settingsBox.get('verifyResponses', defaultValue: true) as bool;
  Future<void> setVerifyResponses(bool v) async => await _settingsBox.put('verifyResponses', v);
}
