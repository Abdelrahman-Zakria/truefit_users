import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markRead(String id);
  Future<void> markAllRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final List<NotificationModel> _notifs = List.from(INITIAL_NOTIFS_MODELS);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _notifs;
  }

  @override
  Future<void> markRead(String id) async {
    final index = _notifs.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifs[index] = NotificationModel(
        id: _notifs[index].id,
        type: _notifs[index].type,
        title: _notifs[index].title,
        body: _notifs[index].body,
        time: _notifs[index].time,
        read: true,
        today: _notifs[index].today,
      );
    }
  }

  @override
  Future<void> markAllRead() async {
    for (var i = 0; i < _notifs.length; i++) {
      _notifs[i] = NotificationModel(
        id: _notifs[i].id,
        type: _notifs[i].type,
        title: _notifs[i].title,
        body: _notifs[i].body,
        time: _notifs[i].time,
        read: true,
        today: _notifs[i].today,
      );
    }
  }
}
