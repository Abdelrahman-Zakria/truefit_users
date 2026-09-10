import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource localDataSource;

  NotificationRepositoryImpl(this.localDataSource);

  @override
  Future<List<NotificationEntity>> getNotifications() {
    return localDataSource.getNotifications();
  }

  @override
  Future<void> markRead(String id) {
    return localDataSource.markRead(id);
  }

  @override
  Future<void> markAllRead() {
    return localDataSource.markAllRead();
  }
}
