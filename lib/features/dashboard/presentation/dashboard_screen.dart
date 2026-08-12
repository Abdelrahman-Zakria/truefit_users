import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/intl/translations.dart';
import '../../../core/cubit/lang_cubit.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import '../../home/presentation/screens/home_screen.dart';
import '../../booking/presentation/screens/booking_screen.dart';
import '../../diet/presentation/screens/diet_plan_screen.dart';
import '../../progress/presentation/screens/progress_screen.dart';
import '../../chat/presentation/screens/conversations_screen.dart';
import '../../subscription/presentation/screens/subscription_screen.dart';
import '../../notifications/presentation/screens/notifications_screen.dart';
import '../../profile/presentation/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangCubit>().state;
    final authState = context.watch<AuthCubit>().state;
    final isGuest = authState is GuestAuthenticated;
    final isRtl = lang == 'ar';

    String tr(String key) => Translations.tr(key, lang);

    final List<Widget> screens = [
      HomeScreen(
        isGuest: isGuest,
        lang: lang,
        onJoinNow: () => setState(() => _selectedIndex = 1),
        onNavigate: (index) => setState(() => _selectedIndex = index),
      ),
      SubscriptionScreen(isGuest: isGuest, lang: lang, onJoinNow: () {}),
      BookingScreen(isGuest: isGuest, lang: lang, onJoinNow: () => setState(() => _selectedIndex = 1)),
      DietPlanScreen(isGuest: isGuest, lang: lang, onJoinNow: () => setState(() => _selectedIndex = 1)),
      ProgressScreen(isGuest: isGuest, lang: lang, onJoinNow: () => setState(() => _selectedIndex = 1)),
      ConversationsScreen(isGuest: isGuest, lang: lang, onJoinNow: () => setState(() => _selectedIndex = 1)),
    ];

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundBlack,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(lang: lang))),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: AppTheme.primaryRed.withValues(alpha:0.3)),
                    image: const DecorationImage(image: AssetImage('assets/images/Profile Pic.png'), fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('appName'), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  Text(tr('gymSpa'), style: const TextStyle(color: AppTheme.primaryRed, fontSize: 8, letterSpacing: 2.0)),
                ],
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
              child: Row(
                children: ['en', 'ar'].map((l) {
                  final active = lang == l;
                  return GestureDetector(
                    onTap: () => context.read<LangCubit>().toggle(l),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: active ? AppTheme.primaryRed : Colors.transparent, borderRadius: BorderRadius.circular(20)),
                      child: Text(l.toUpperCase(), style: TextStyle(color: active ? Colors.white : const Color(0xFF6B7280), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 8),
            if (isGuest)
              IconButton(onPressed: () => context.read<AuthCubit>().logout(), icon: const Icon(LucideIcons.user, size: 18, color: Color(0xFF9CA3AF)))
            else
              IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsScreen(lang: lang))), icon: const Icon(LucideIcons.bell, size: 18, color: Color(0xFF9CA3AF))),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: const Color(0xFF1A1A1A), height: 1)),
        ),
        body: Column(
          children: [
            if (isGuest)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppTheme.primaryRed.withValues(alpha:0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr('browsingAsGuest'), style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                    GestureDetector(onTap: () => setState(() => _selectedIndex = 1), child: Text(tr('joinNow'), style: const TextStyle(color: AppTheme.primaryRed, fontSize: 11, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            Expanded(child: screens[_selectedIndex]),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF1A1A1A)))),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xFF111111),
              selectedItemColor: AppTheme.primaryRed,
              unselectedItemColor: const Color(0xFF6B7280),
              selectedLabelStyle: const TextStyle(fontSize: 10),
              unselectedLabelStyle: const TextStyle(fontSize: 10),
              items: [
                BottomNavigationBarItem(icon: const Icon(LucideIcons.house, size: 20), label: tr('home')),
                BottomNavigationBarItem(icon: const Icon(LucideIcons.creditCard, size: 20), label: tr('plan')),
                BottomNavigationBarItem(icon: const Icon(LucideIcons.calendar, size: 20), label: tr('book')),
                BottomNavigationBarItem(icon: const Icon(LucideIcons.apple, size: 20), label: tr('diet')),
                BottomNavigationBarItem(icon: const Icon(LucideIcons.trendingUp, size: 20), label: tr('progress')),
                BottomNavigationBarItem(icon: const Icon(LucideIcons.messageCircle, size: 20), label: tr('chat')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
