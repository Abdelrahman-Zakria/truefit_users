import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String id;
  final String name;
  final String role;
  final String? lastMessage;
  final String? time;
  final String? image;
  final bool isOnline;
  final int unreadCount;

  const ConversationEntity({
    required this.id,
    required this.name,
    required this.role,
    this.lastMessage,
    this.time,
    this.image,
    required this.isOnline,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [id, name, role, lastMessage, time, image, isOnline, unreadCount];
}
