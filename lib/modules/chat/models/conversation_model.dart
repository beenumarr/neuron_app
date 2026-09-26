import 'chat_message_model.dart';

class ConversationModel {
  final String id;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessageModel> messages;

  ConversationModel({
    required this.id,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
  });

  String get displayTitle {
    if (title != null && title!.trim().isNotEmpty) {
      return title!.trim();
    }
    if (messages.isNotEmpty) {
      final firstUserMsg = messages.firstWhere(
        (m) => m.isUser,
        orElse: () => messages.first,
      );
      final text = firstUserMsg.content.trim();
      if (text.isNotEmpty) {
        return text.length > 32 ? '${text.substring(0, 32)}…' : text;
      }
    }
    return 'Consultation';
  }

  ConversationModel copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ChatMessageModel>? messages,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    List<ChatMessageModel> msgs = [];
    if (json['messages'] is List) {
      msgs = (json['messages'] as List)
          .map((m) => ChatMessageModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }

    return ConversationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      messages: msgs,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (title != null) 'title': title,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };
}
