import 'dart:convert';

class AiModel {
  final String id;
  final String name;
  final String family; // qwen | deepseek
  final String params;
  final String quant;
  final double ramRequiredGB;
  final double vramRequiredGB;
  final double diskGB;
  final int contextLength;
  final String description;
  final String hfRepo;
  final String hfFile;
  final String url;
  final List<String> capabilities;

  AiModel({
    required this.id,
    required this.name,
    required this.family,
    required this.params,
    required this.quant,
    required this.ramRequiredGB,
    required this.vramRequiredGB,
    required this.diskGB,
    required this.contextLength,
    required this.description,
    required this.hfRepo,
    required this.hfFile,
    required this.url,
    required this.capabilities,
  });

  factory AiModel.fromJson(Map<String, dynamic> json) => AiModel(
        id: json['id'],
        name: json['name'],
        family: json['family'],
        params: json['params'],
        quant: json['quant'],
        ramRequiredGB: (json['ramRequiredGB'] as num).toDouble(),
        vramRequiredGB: (json['vramRequiredGB'] as num).toDouble(),
        diskGB: (json['diskGB'] as num).toDouble(),
        contextLength: json['contextLength'],
        description: json['description'],
        hfRepo: json['hfRepo'],
        hfFile: json['hfFile'],
        url: json['url'],
        capabilities: List<String>.from(json['capabilities']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'family': family,
        'params': params,
        'quant': quant,
        'ramRequiredGB': ramRequiredGB,
        'vramRequiredGB': vramRequiredGB,
        'diskGB': diskGB,
        'contextLength': contextLength,
        'description': description,
        'hfRepo': hfRepo,
        'hfFile': hfFile,
        'url': url,
        'capabilities': capabilities,
      };

  String get displaySize => '${params} • ${quant} • ${diskGB.toStringAsFixed(1)}GB';

  static List<AiModel> listFromJson(String str) =>
      List<AiModel>.from(json.decode(str).map((x) => AiModel.fromJson(x)));
}
