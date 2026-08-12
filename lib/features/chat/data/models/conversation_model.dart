import '../../domain/entities/conversation_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.name,
    required super.role,
    super.lastMessage,
    super.time,
    super.image,
    required super.isOnline,
    super.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    String? timeStr;
    if (json['updated_at'] is Timestamp) {
      final dt = (json['updated_at'] as Timestamp).toDate();
      timeStr = "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    }

    return ConversationModel(
      id: (json['id'] ?? '').toString(),
      name: (json['coach_name'] ?? json['name'] ?? '').toString(),
      role: (json['coach_role'] ?? json['role'] ?? '').toString(),
      lastMessage: json['last_message']?.toString() ?? json['lastMessage']?.toString(),
      time: timeStr ?? json['time']?.toString(),
      image: json['image']?.toString(),
      isOnline: json['is_online'] ?? json['isOnline'] ?? false,
      unreadCount: (json['unread_count'] ?? json['unreadCount'] ?? 0 as num).toInt(),
    );
  }
}
