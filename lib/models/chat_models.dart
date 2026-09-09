import 'package:uuid/uuid.dart';

enum MessageRole { user, assistant, system }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final String? modelId;
  final bool isStreaming;

  ChatMessage({
    String? id,
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.modelId,
    this.isStreaming = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? content,
    bool? isStreaming,
  }) =>
      ChatMessage(
        id: id,
        role: role,
        content: content ?? this.content,
        timestamp: timestamp,
        modelId: modelId,
        isStreaming: isStreaming ?? this.isStreaming,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'modelId': modelId,
        'isStreaming': isStreaming,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'],
        role: MessageRole.values.byName(j['role']),
        content: j['content'],
        timestamp: DateTime.parse(j['timestamp']),
        modelId: j['modelId'],
        isStreaming: j['isStreaming'] ?? false,
      );
}

class ChatSession {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  List<ChatMessage> messages;
  String? pdfPath;
  String? pdfText;
  String? modelId;

  ChatSession({
    String? id,
    required this.title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
    this.pdfPath,
    this.pdfText,
    this.modelId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        messages = messages ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'messages': messages.map((e) => e.toJson()).toList(),
        'pdfPath': pdfPath,
        'pdfText': pdfText,
        'modelId': modelId,
      };

  factory ChatSession.fromJson(Map<String, dynamic> j) => ChatSession(
        id: j['id'],
        title: j['title'],
        createdAt: DateTime.parse(j['createdAt']),
        updatedAt: DateTime.parse(j['updatedAt']),
        messages: (j['messages'] as List).map((e) => ChatMessage.fromJson(e)).toList(),
        pdfPath: j['pdfPath'],
        pdfText: j['pdfText'],
        modelId: j['modelId'],
      );

  String get preview => messages.isEmpty ? 'No messages' : messages.last.content.substring(0, messages.last.content.length > 60 ? 60 : messages.last.content.length);
}
