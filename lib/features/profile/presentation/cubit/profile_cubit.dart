import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileCubit({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final profile = await getProfileUseCase(NoParams());
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile(ProfileEntity profile) async {
    final currentState = state;
    ProfileEntity? oldProfile;
    if (currentState is ProfileLoaded) {
      oldProfile = currentState.profile;
    }

    emit(ProfileLoading());
    try {
      await updateProfileUseCase(profile);
      emit(ProfileUpdateSuccess());
      emit(ProfileLoaded(profile));
    } catch (e) {
      if (oldProfile != null) {
        emit(ProfileLoaded(oldProfile));
      }
      emit(ProfileError(e.toString()));
    }
  }

  void reset() {
    emit(ProfileInitial());
  }
}
