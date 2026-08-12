import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<void, Map<String, dynamic>> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<void> call(Map<String, dynamic> params) {
    return repository.register(params);
  }
}
