import 'package:objectbox/objectbox.dart';

@Entity()
class NotificationBoxEntity {
  @Id()
  int id = 0;
  
  final String titleEn;
  final String titleAr;
  final String bodyEn;
  final String bodyAr;
  final String type; // booking, payment, offer, system
  final DateTime timestamp;
  bool isRead;

  NotificationBoxEntity({
    this.id = 0,
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}
