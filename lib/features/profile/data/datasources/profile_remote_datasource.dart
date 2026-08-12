import '../../../../core/di/injection_container.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<void> updateProfile(ProfileModel profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<ProfileModel> getProfile() async {
    final userBox = InjectionContainer.objectBoxService.getUser();
    if (userBox != null) {
      final user = UserModel.fromBox(userBox);
      return ProfileModel(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName, // This already has fallback logic
        nameAr: user.nameAr,
        nameEn: user.nameEn,
        phone: user.phone,
        address: user.address,
        birthday: user.birthday,
      );
    }
    
    // Fallback/Guest
    return const ProfileModel(
      uid: 'guest',
      displayName: 'Guest User',
    );
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    // In a real app, update remote then local
    await Future.delayed(const Duration(milliseconds: 800));
  }
}
