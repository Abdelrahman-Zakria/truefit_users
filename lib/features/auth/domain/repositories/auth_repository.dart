import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<void> register(Map<String, dynamic> data);
  Future<void> logout();
  Future<void> continueAsGuest();
  Future<UserEntity?> getCurrentUser();
}
