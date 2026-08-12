import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../../domain/entities/coach_entity.dart';
import '../../domain/entities/group_class_entity.dart';

class UpcomingBookingsScreen extends StatelessWidget {
  final String lang;
  const UpcomingBookingsScreen({super.key, required this.lang});

  String tr(String key) => Translations.tr(key, lang);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(lang == 'ar' ? LucideIcons.chevronRight : LucideIcons.chevronLeft, color: Colors.white),
        ),
        title: Text(tr('myUpcomingBookings'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if (state is BookingLoaded) {
            final bookings = state.userBookings;
            if (bookings.isEmpty) {
              return Center(child: Text(tr('noUpcomingBookings') ?? "No upcoming sessions", style: const TextStyle(color: Colors.grey)));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final b = bookings[index];
                final isPT = b['type'] == 'pt';
                return _buildBookingCard(context, b, isPT, state);
              },
            );
          }
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Map<String, dynamic> b, bool isPT, BookingLoaded state) {
    String title = "";
    String subtitle = "";
    String displayDate = "";
    String displayTime = "";
    
    if (isPT) {
      final coach = (state.coaches as Iterable<CoachEntity>).firstWhere((c) => c.id == b['coach_id'], orElse: () => state.coaches.first);
      title = "PT Session";
      subtitle = "with ${coach.name}";
      displayDate = b['date'] ?? "";
      displayTime = b['time'] ?? "";
    } else {
      final classItem = (state.groupClasses as Iterable<GroupClassEntity>).firstWhere((c) => c.id == b['target_id'], orElse: () => state.groupClasses.first);
      final instructor = classItem.instructor[lang] ?? classItem.instructor['en'] ?? '';
      title = classItem.name[lang] ?? classItem.name['en'] ?? "Class";
      subtitle = "with $instructor";
      displayDate = classItem.date;
      displayTime = classItem.time;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(isPT ? LucideIcons.user : LucideIcons.users, color: AppTheme.primaryRed, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(displayTime.isNotEmpty ? displayTime : '—', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Text(displayDate.isNotEmpty ? displayDate : '—', style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
