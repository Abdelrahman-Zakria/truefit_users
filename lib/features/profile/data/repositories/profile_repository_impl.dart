import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ProfileEntity> getProfile() {
    return remoteDataSource.getProfile();
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) {
    return remoteDataSource.updateProfile(ProfileModel.fromEntity(profile));
  }
}
