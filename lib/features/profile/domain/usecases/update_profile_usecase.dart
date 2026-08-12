import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase implements UseCase<void, ProfileEntity> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<void> call(ProfileEntity params) {
    return repository.updateProfile(params);
  }
}
