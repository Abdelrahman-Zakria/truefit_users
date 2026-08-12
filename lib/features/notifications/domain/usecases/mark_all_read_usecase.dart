import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class MarkAllReadUseCase implements UseCase<void, NoParams> {
  final NotificationRepository repository;

  MarkAllReadUseCase(this.repository);

  @override
  Future<void> call(NoParams params) {
    return repository.markAllRead();
  }
}
