import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String text;
  final String time;
  final bool isMe;
  final bool isVoice;
  final String? duration;

  const MessageEntity({
    required this.id,
    required this.text,
    required this.time,
    required this.isMe,
    this.isVoice = false,
    this.duration,
  });

  @override
  List<Object?> get props => [id, text, time, isMe, isVoice, duration];
}
