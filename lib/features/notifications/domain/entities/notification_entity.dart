import 'package:equatable/equatable.dart';

enum NotificationType { booking, payment, offer, system, fitnessClass }

class NotificationEntity extends Equatable {
  final String id;
  final NotificationType type;
  final Map<String, String> title;
  final Map<String, String> body;
  final String time;
  final bool read;
  final bool today;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.read,
    required this.today,
  });

  NotificationEntity copyWith({bool? read}) {
    return NotificationEntity(
      id: id,
      type: type,
      title: title,
      body: body,
      time: time,
      read: read ?? this.read,
      today: today,
    );
  }

  @override
  List<Object?> get props => [id, type, title, body, time, read, today];
}
