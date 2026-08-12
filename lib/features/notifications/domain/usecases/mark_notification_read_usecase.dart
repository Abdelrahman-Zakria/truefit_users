import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class MarkNotificationReadUseCase implements UseCase<void, String> {
  final NotificationRepository repository;

  MarkNotificationReadUseCase(this.repository);

  @override
  Future<void> call(String params) {
    return repository.markRead(params);
  }
}
