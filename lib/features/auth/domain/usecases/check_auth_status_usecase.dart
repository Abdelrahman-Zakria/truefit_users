import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase implements UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  @override
  Future<UserEntity?> call(NoParams params) {
    return repository.getCurrentUser();
  }
}
