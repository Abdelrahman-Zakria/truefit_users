import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/cubit/lang_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/booking/presentation/cubit/booking_cubit.dart';
import 'features/diet/presentation/cubit/diet_cubit.dart';
import 'features/progress/presentation/cubit/progress_cubit.dart';
import 'features/chat/presentation/cubit/chat_cubit.dart';
import 'features/subscription/presentation/cubit/subscription_cubit.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/pending_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initError;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    initError = "Firebase Error: $e";
  }

  if (initError == null) {
    try {
      await initializeDateFormatting();
      await InjectionContainer.init();
    } catch (e) {
      initError = "Initialization Error: $e";
    }
  }

  if (initError != null) {
    runApp(ErrorApp(error: initError));
  } else {
    runApp(const TrueFitApp());
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 24),
                const Text(
                  "Failed to Start App",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {}, // User can restart app manually
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Please contact support or check Firebase config", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TrueFitApp extends StatelessWidget {
  const TrueFitApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => InjectionContainer.authCubit),
        BlocProvider<ProfileCubit>(create: (context) => InjectionContainer.profileCubit),
        BlocProvider<NotificationsCubit>(create: (context) => InjectionContainer.notificationsCubit..loadNotifications()),
        BlocProvider<HomeCubit>(create: (context) => InjectionContainer.homeCubit..loadHomeData()),
        BlocProvider<BookingCubit>(create: (context) => InjectionContainer.bookingCubit),
        BlocProvider<DietCubit>(create: (context) => InjectionContainer.dietCubit),
        BlocProvider<ProgressCubit>(create: (context) => InjectionContainer.progressCubit),
        BlocProvider<ChatCubit>(create: (context) => InjectionContainer.chatCubit),
        BlocProvider<SubscriptionCubit>(create: (context) => InjectionContainer.subscriptionCubit),
        BlocProvider(create: (context) => LangCubit()),
      ],
      child: BlocBuilder<LangCubit, String>(
        builder: (context, lang) {
          return MaterialApp(
            title: 'TRUE FIT',
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const RootNavigator(),
          );
        },
      ),
    );
  }
}

class RootNavigator extends StatefulWidget {
  const RootNavigator({super.key});

  @override
  State<RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<RootNavigator> {
  bool _showSplash = true;
  bool _showRegister = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().checkAuthStatus();
  }

  void _triggerDataLoading(BuildContext context, int persId) {
    context.read<ProfileCubit>().loadProfile();
    context.read<SubscriptionCubit>().loadMembershipPlans(persId: persId);
    context.read<BookingCubit>().loadBookingData(persId);
    context.read<DietCubit>().loadDietPlan(persId);
    context.read<ProgressCubit>().loadProgressData(persId);
    context.read<ChatCubit>().loadConversations(persId);
    context.read<HomeCubit>().loadHomeData(persId: persId);
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onDone: () => setState(() => _showSplash = false));
    }

    final lang = context.watch<LangCubit>().state;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          TrueFitApp.navigatorKey.currentState?.popUntil((route) => route.isFirst);
        } else if (state is Authenticated) {
          _triggerDataLoading(context, state.user.persId!);
        } else if (state is GuestAuthenticated) {
          context.read<SubscriptionCubit>().loadMembershipPlans();
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthInitial) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is Authenticated || state is GuestAuthenticated) {
            return const DashboardScreen();
          }

          if (state is AuthPending) {
            return PendingScreen(
              lang: lang,
              onSignOut: () => context.read<AuthCubit>().logout(),
            );
          }

          if (_showRegister) {
            return RegisterScreen(
              lang: lang,
              onBackToLogin: () => setState(() => _showRegister = false),
              onRegister: (data) => context.read<AuthCubit>().register(data),
            );
          }

          return LoginScreen(
            onGoRegister: () => setState(() => _showRegister = true),
            onLogin: (email, password) => context.read<AuthCubit>().login(email, password),
            onContinueAsGuest: () => context.read<AuthCubit>().continueAsGuest(),
          );
        },
      ),
    );
  }
}
