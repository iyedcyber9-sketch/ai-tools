import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/ai_model.dart';

class ModelRegistry {
  List<AiModel> _models = [];
  bool _loaded = false;

  List<AiModel> get models => _models;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final jsonStr = await rootBundle.loadString('assets/models.json');
    final List decoded = json.decode(jsonStr);
    _models = decoded.map((e) => AiModel.fromJson(e)).toList();
    _loaded = true;
  }

  AiModel? findById(String id) {
    try {
      return _models.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  List<AiModel> byFamily(String family) => _models.where((m) => m.family == family).toList();

  List<String> get families => _models.map((e) => e.family).toSet().toList();
}
