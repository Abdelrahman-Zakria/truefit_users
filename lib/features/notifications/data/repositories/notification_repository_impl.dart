import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<NotificationEntity>> getNotifications() {
    return remoteDataSource.getNotifications();
  }

  @override
  Future<void> markRead(String id) {
    return remoteDataSource.markRead(id);
  }

  @override
  Future<void> markAllRead() {
    return remoteDataSource.markAllRead();
  }
}
