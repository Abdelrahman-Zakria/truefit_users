import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/continue_as_guest_usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final ContinueAsGuestUseCase continueAsGuestUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.continueAsGuestUseCase,
    required this.checkAuthStatusUseCase,
  }) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    final user = await checkAuthStatusUseCase(NoParams());
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase(LoginParams(email: email, password: password));
      emit(Authenticated(user));
    } catch (e) {
      if (e.toString().contains('PENDING')) {
        emit(AuthPending());
      } else {
        emit(AuthError(e.toString()));
      }
    }
  }

  Future<void> continueAsGuest() async {
    emit(AuthLoading());
    try {
      await continueAsGuestUseCase(NoParams());
      emit(GuestAuthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    emit(AuthLoading());
    try {
      await registerUseCase(data);
      emit(AuthPending());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase(NoParams());
      InjectionContainer.clearAllData();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void reset() {
    emit(AuthInitial());
  }
}
