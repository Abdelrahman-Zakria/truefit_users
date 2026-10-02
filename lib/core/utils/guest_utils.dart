import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/lang_cubit.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/screens/register_screen.dart';

void openGuestRegistration(BuildContext context, {String? planId}) {
  final lang = context.read<LangCubit>().state;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (routeContext) => RegisterScreen(
        lang: lang,
        initialPlanId: planId,
        onBackToLogin: () => Navigator.pop(routeContext),
        onRegister: (data) async {
          await routeContext.read<AuthCubit>().register(data);
          if (routeContext.mounted && Navigator.canPop(routeContext)) {
            Navigator.pop(routeContext);
          }
        },
      ),
    ),
  );
}
