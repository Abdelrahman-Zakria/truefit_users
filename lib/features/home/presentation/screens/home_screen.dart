import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/guest_home_view.dart';
import '../widgets/member_home_view.dart';
import '../widgets/home_skeleton.dart';

class HomeScreen extends StatelessWidget {
  final bool isGuest;
  final String lang;
  final VoidCallback onJoinNow;
  final Function(int) onNavigate;

  const HomeScreen({
    super.key,
    required this.isGuest,
    required this.lang,
    required this.onJoinNow,
    required this.onNavigate,
  });

  String tr(String key) => Translations.tr(key, lang);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeInitial) {
          final authState = context.read<AuthCubit>().state;
          if (authState is Authenticated) {
            context.read<HomeCubit>().loadHomeData(persId: authState.user.persId);
          } else {
            context.read<HomeCubit>().loadHomeData();
          }
          return HomeSkeleton(isGuest: isGuest);
        }

        if (state is HomeLoading) {
          return HomeSkeleton(isGuest: isGuest);
        }

        if (state is HomeLoaded) {
          String userName = "User";
          String memberId = "";
          final authState = context.read<AuthCubit>().state;
          if (authState is Authenticated) {
            final user = authState.user;
            memberId = user.persId?.toString() ?? "";
            if (lang == 'en') {
              userName = (user.nameEn != null && user.nameEn!.isNotEmpty) ? user.nameEn! : (user.nameAr ?? "User");
            } else {
              userName = (user.nameAr != null && user.nameAr!.isNotEmpty) ? user.nameAr! : (user.nameEn ?? "User");
            }
          }

          return Scaffold(
            backgroundColor: AppTheme.backgroundBlack,
            body: RefreshIndicator(
              onRefresh: () {
                final authState = context.read<AuthCubit>().state;
                if (authState is Authenticated) {
                  return context.read<HomeCubit>().loadHomeData(persId: authState.user.persId);
                }
                return context.read<HomeCubit>().loadHomeData();
              },
              color: AppTheme.primaryRed,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: isGuest 
                  ? GuestHomeView(
                      lang: lang,
                      promotions: state.promotions,
                      outdoorSessions: state.outdoorSessions,
                      offers: state.offers,
                      packages: state.packages,
                      onJoinNow: onJoinNow,
                    )
                  : MemberHomeView(
                      lang: lang,
                      firstName: userName,
                      memberId: memberId,
                      promotions: state.promotions,
                      onNavigate: onNavigate,
                    ),
              ),
            ),
          );
        }

        if (state is HomeError) {
          return Scaffold(backgroundColor: AppTheme.backgroundBlack, body: Center(child: Text(state.message, style: const TextStyle(color: Colors.red))));
        }

        return const SizedBox();
      },
    );
  }
}
