import '../../domain/entities/message_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.text,
    required super.time,
    required super.isMe,
    super.isVoice = false,
    super.duration,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, String docId) {
    String timeStr = '0:00';
    if (json['created_at'] is Timestamp) {
      final dt = (json['created_at'] as Timestamp).toDate();
      timeStr = "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    }

    return MessageModel(
      id: docId,
      text: (json['text'] ?? '').toString(),
      time: (json['time'] ?? timeStr).toString(),
      isMe: json['is_me'] ?? json['isMe'] ?? true,
      isVoice: json['isVoice'] ?? json['is_voice'] ?? false,
      duration: json['duration']?.toString(),
    );
  }
}
