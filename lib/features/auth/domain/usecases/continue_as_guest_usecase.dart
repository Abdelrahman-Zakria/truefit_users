import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ContinueAsGuestUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  ContinueAsGuestUseCase(this.repository);

  @override
  Future<void> call(NoParams params) {
    return repository.continueAsGuest();
  }
}
