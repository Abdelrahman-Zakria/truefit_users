import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../../booking/presentation/cubit/booking_cubit.dart';
import '../../../booking/presentation/cubit/booking_state.dart';
import '../../../booking/domain/entities/coach_entity.dart';
import '../../../booking/domain/entities/group_class_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import 'banner_carousel.dart';
import 'barcode_view.dart';

class MemberHomeView extends StatefulWidget {
  final String lang;
  final String firstName;
  final String memberId;
  final List<PromotionEntity> promotions;
  final Function(int) onNavigate;

  const MemberHomeView({
    super.key,
    required this.lang,
    required this.firstName,
    required this.memberId,
    required this.promotions,
    required this.onNavigate,
  });

  @override
  State<MemberHomeView> createState() => _MemberHomeViewState();
}

class _MemberHomeViewState extends State<MemberHomeView> {
  bool _showBarcode = false;

  String tr(String key) => Translations.tr(key, widget.lang);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.lang == 'ar' ? "مرحباً بعودتك،" : "Welcome back,", style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text('${widget.firstName} 👋', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        BannerCarousel(promotions: widget.promotions, lang: widget.lang),
        _buildCheckInCard(),
        _buildActivityStats(),
        _buildUpcomingSessions(),
        _buildQuickAccess(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCheckInCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFDC143C), Color(0xFFA00F2C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('quickCheckIn'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: Text(tr('premiumElite'), style: const TextStyle(color: Colors.white, fontSize: 10))),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => setState(() => _showBarcode = !_showBarcode),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.qrCode, color: AppTheme.primaryRed, size: 20),
                  const SizedBox(width: 12),
                  Text(_showBarcode ? tr('hideBarcode') : tr('showBarcode'), style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          ),
          if (_showBarcode) ...[
            BarcodeView(memberId: widget.memberId),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityStats() {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        int sessionsCount = 0;
        double sessionsPct = 0.0;
        double hoursPct = 0.0;
        double workoutPct = 0.0;
        int hours = 0;
        int workouts = 0;

        if (state is BookingLoaded) {
          final now = DateTime.now();
          final currentMonthStr = DateFormat('yyyy-MM').format(now);
          
          final pastSessions = state.userBookings.where((b) {
            final bDate = b['date'] as String?;
            if (bDate == null || !bDate.startsWith(currentMonthStr)) return false;
            
            try {
              final sessionDateTime = DateTime.parse(bDate);
              // Count if date is today or in the past
              return sessionDateTime.isBefore(now);
            } catch (_) { return false; }
          }).toList();

          sessionsCount = pastSessions.length;
          hours = sessionsCount; // 1 hour per session
          workouts = sessionsCount * 6; // 6 workouts per session

          const sessionGoal = 12;
          const hourGoal = 12;
          const workoutGoal = 72;

          sessionsPct = (sessionsCount / sessionGoal).clamp(0.0, 1.0);
          hoursPct = (hours / hourGoal).clamp(0.0, 1.0);
          workoutPct = (workouts / workoutGoal).clamp(0.0, 1.0);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.lang == 'ar' ? "نشاطك هذا الشهر" : "This Month's Activity", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(DateFormat('MMM yyyy', widget.lang).format(DateTime.now()), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatRing(workouts, tr('workouts'), workoutPct, AppTheme.primaryRed, LucideIcons.dumbbell),
                  _buildStatRing(hours, tr('hours'), hoursPct, Colors.purple, LucideIcons.clock),
                  _buildStatRing(sessionsCount, tr('sessions'), sessionsPct, Colors.green, LucideIcons.user),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRing(int val, String label, double pct, Color color, IconData icon) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(width: 56, height: 56, child: CircularProgressIndicator(value: pct, strokeWidth: 6, color: color, backgroundColor: const Color(0xFF2A2A2A), strokeCap: StrokeCap.round)),
            Icon(icon, color: color, size: 16),
          ],
        ),
        const SizedBox(height: 12),
        Text('$val', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildUpcomingSessions() {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final authState = context.watch<AuthCubit>().state;
        final int? persId = authState is Authenticated ? authState.user.persId : null;

        if (state is BookingInitial && persId != null) {
          context.read<BookingCubit>().loadBookingData(persId);
        }

        final bool isLoading = state is BookingInitial || state is BookingLoading;
        final bool isError = state is BookingError;
        final List<Map<String, dynamic>> sessions = (state is BookingLoaded) 
            ? state.userBookings.take(2).toList() 
            : [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.lang == 'ar' ? "جلساتك القادمة" : "Upcoming Sessions", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  if (sessions.isNotEmpty)
                    GestureDetector(onTap: () => widget.onNavigate(2), child: Text(tr('seeAll'), style: const TextStyle(color: AppTheme.primaryRed, fontSize: 12, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            if (isLoading)
              _buildPlaceholderBox(tr('loading'))
            else if (isError)
              _buildPlaceholderBox(tr('errorLoading'))
            else if (sessions.isEmpty)
              _buildPlaceholderBox(tr('upcomingBookingsPlaceholder'))
            else
              ...sessions.map((s) => _buildSessionItem(s, state as BookingLoaded)),
          ],
        );
      },
    );
  }

  Widget _buildPlaceholderBox(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
    );
  }

  Widget _buildSessionItem(Map<String, dynamic> s, BookingLoaded state) {
    final isClass = s['type'] == 'class';
    String name = "";
    String coach = "";
    String loc = "";
    String time = "";
    String date = "";

    if (isClass) {
      final classItem = (state.groupClasses as Iterable<GroupClassEntity>).firstWhere((c) => c.id == s['target_id'], orElse: () => state.groupClasses.first);
      name = classItem.name[widget.lang] ?? classItem.name['en'] ?? "Class";
      coach = classItem.instructor[widget.lang] ?? classItem.instructor['en'] ?? "Instructor";
      loc = classItem.studio;
      time = classItem.time;
      date = classItem.date;
    } else {
      final coachEntity = (state.coaches as Iterable<CoachEntity>).firstWhere((c) => c.id == s['coach_id'], orElse: () => state.coaches.first);
      name = widget.lang == 'ar' ? "جلسة تدريب شخصي" : "PT Session";
      coach = coachEntity.name;
      loc = widget.lang == 'ar' ? "قاعة التدريب" : "Training Floor";
      time = s['time'] ?? "";
      date = s['date'] ?? "";
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(isClass ? LucideIcons.users : LucideIcons.user, color: AppTheme.primaryRed, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                Text('$coach · $loc', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 16), child: Text(tr('quickAccess'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildQuickAccessItem(LucideIcons.calendar, widget.lang == 'ar' ? "احجز جلسة" : "Book Session", widget.lang == 'ar' ? "PT أو فصل جماعي" : "PT or Group Class", AppTheme.primaryRed, 2),
            _buildQuickAccessItem(LucideIcons.trendingUp, widget.lang == 'ar' ? "تقدمي" : "My Progress", widget.lang == 'ar' ? "تحليل InBody" : "InBody analysis", Colors.purple, 4),
            _buildQuickAccessItem(LucideIcons.flame, widget.lang == 'ar' ? "نظامي الغذائي" : "My Diet", widget.lang == 'ar' ? "وجبات اليوم" : "Today's meals", Colors.orange, 3),
            _buildQuickAccessItem(LucideIcons.messageCircle, widget.lang == 'ar' ? "مدربي" : "My Coach", widget.lang == 'ar' ? "تواصل الآن" : "Chat now", Colors.green, 5),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem(IconData icon, String title, String sub, Color color, int index) {
    return GestureDetector(
      onTap: () => widget.onNavigate(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF0A0A0A), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
