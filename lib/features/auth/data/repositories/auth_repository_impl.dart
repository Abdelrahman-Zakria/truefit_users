import '../../../../core/di/injection_container.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> login(String email, String password) async {
    final user = await remoteDataSource.login(email, password);
    // Save to ObjectBox
    InjectionContainer.objectBoxService.saveUser(user.toBox());
    return user;
  }

  @override
  Future<void> register(Map<String, dynamic> data) {
    return remoteDataSource.register(data);
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    InjectionContainer.objectBoxService.clearUser();
  }

  @override
  Future<void> continueAsGuest() {
    return remoteDataSource.continueAsGuest();
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    final userBox = InjectionContainer.objectBoxService.getUser();
    if (userBox != null) {
      return Future.value(UserModel.fromBox(userBox));
    }
    return Future.value(null);
  }
}
