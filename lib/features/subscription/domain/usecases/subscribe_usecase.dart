import '../../../../core/usecases/usecase.dart';
import '../repositories/subscription_repository.dart';

class SubscribeUseCase implements UseCase<void, String> {
  final SubscriptionRepository repository;

  SubscribeUseCase(this.repository);

  @override
  Future<void> call(String params) {
    return repository.subscribe(params);
  }
}
