import '../../../../core/services/objectbox_service.dart';
import '../models/notification_box_entity.dart';
import '../models/notification_model.dart';
import '../../domain/entities/notification_entity.dart';
import 'package:intl/intl.dart';

abstract class NotificationLocalDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markRead(String id);
  Future<void> markAllRead();
  Future<void> saveNotification(NotificationBoxEntity notification);
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final ObjectBoxService _objectBox;

  NotificationLocalDataSourceImpl(this._objectBox);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final boxes = _objectBox.getNotifications();
    return boxes.map((b) {
      final now = DateTime.now();
      final isToday = b.timestamp.year == now.year && b.timestamp.month == now.month && b.timestamp.day == now.day;
      
      return NotificationModel(
        id: b.id.toString(),
        type: _parseType(b.type),
        title: {'en': b.titleEn, 'ar': b.titleAr},
        body: {'en': b.bodyEn, 'ar': b.bodyAr},
        time: DateFormat('hh:mm a').format(b.timestamp),
        read: b.isRead,
        today: isToday,
      );
    }).toList();
  }

  @override
  Future<void> markRead(String id) async {
    final intId = int.tryParse(id);
    if (intId != null) {
      _objectBox.markNotificationRead(intId);
    }
  }

  @override
  Future<void> markAllRead() async {
    _objectBox.markAllNotificationsRead();
  }

  @override
  Future<void> saveNotification(NotificationBoxEntity notification) async {
    _objectBox.saveNotification(notification);
  }

  NotificationType _parseType(String type) {
    switch (type) {
      case 'booking': return NotificationType.booking;
      case 'payment': return NotificationType.payment;
      case 'offer': return NotificationType.offer;
      case 'class': return NotificationType.fitnessClass;
      default: return NotificationType.system;
    }
  }
}
