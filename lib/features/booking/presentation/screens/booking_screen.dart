import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../../../core/widgets/guest_locked_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../../domain/entities/pt_wallet_entity.dart';
import '../../domain/entities/coach_entity.dart';
import '../../domain/entities/group_class_entity.dart';
import '../widgets/booking_sheets.dart';
import '../widgets/pt_package_modal.dart';
import '../widgets/pt_scheduling_sheet.dart';
import 'upcoming_bookings_screen.dart';
import '../widgets/booking_skeleton.dart';

class BookingScreen extends StatefulWidget {
  final bool isGuest;
  final String lang;
  final VoidCallback onJoinNow;

  const BookingScreen({
    super.key,
    required this.isGuest,
    required this.lang,
    required this.onJoinNow,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _activeTab = 0; // 0: PT, 1: Classes

  String tr(String key) => Translations.tr(key, widget.lang);

  void _showSheet(Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => sheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGuest) {
      return GuestLockedView(
        icon: LucideIcons.calendar,
        featureKey: tr('lockBooking'),
        onJoinNow: widget.onJoinNow,
        lang: widget.lang,
      );
    }

    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final authState = context.watch<AuthCubit>().state;
        final int? persId = authState is Authenticated ? authState.user.persId : null;

        if (state is BookingInitial && persId != null) {
          context.read<BookingCubit>().loadBookingData(persId);
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundBlack,
          body: RefreshIndicator(
            onRefresh: () async {
              if (persId != null) {
                await context.read<BookingCubit>().loadBookingData(persId);
              }
            },
            color: AppTheme.primaryRed,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    if (state is BookingLoaded) ...[
                      _buildMyBookings(state),
                      const SizedBox(height: 24),
                    ],
                    _buildTabs(),
                    const SizedBox(height: 24),
                    _buildBody(context, state, persId),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('bookSessions'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(tr('scheduleWorkouts'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Row(
        children: [
          Expanded(child: _buildTabButton(0, tr('personalTraining'), LucideIcons.user)),
          Expanded(child: _buildTabButton(1, tr('groupClasses'), LucideIcons.users)),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final active = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryRed : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? Colors.white : Colors.grey, size: 16),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: active ? Colors.white : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BookingState state, int? persId) {
    if (state is BookingLoading) {
      return const BookingSkeleton();
    }

    if (state is BookingLoaded) {
      return _activeTab == 0 
        ? _buildPTList(context, state, persId) 
        : _buildClassesList(context, state, persId);
    }

    if (state is BookingError) {
      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
    }

    return const SizedBox();
  }

  Widget _buildPTList(BuildContext context, BookingLoaded state, int? persId) {
    // Sort coaches: those with active sessions first
    final sortedCoaches = List<CoachEntity>.from(state.coaches);
    sortedCoaches.sort((a, b) {
      final aHasSessions = state.userWallets.any((w) => w.coachId == a.id && w.sessionsLeft > 0);
      final bHasSessions = state.userWallets.any((w) => w.coachId == b.id && w.sessionsLeft > 0);
      
      if (aHasSessions && !bHasSessions) return -1;
      if (!aHasSessions && bHasSessions) return 1;
      return 0;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('availableTrainers'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...sortedCoaches.map((c) => _buildCoachCard(context, c, state, persId)),
      ],
    );
  }

  Widget _buildCoachCard(BuildContext context, CoachEntity c, BookingLoaded state, int? persId) {
    final PTWalletEntity wallet = (state.userWallets as Iterable<PTWalletEntity>).firstWhere((w) => w.coachId == c.id, orElse: () => const PTWalletEntity(persId: 0, coachId: '', total: 0, sessionsLeft: 0));
    final hasSessions = wallet.sessionsLeft > 0;
    final initials = c.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('').toUpperCase();
    final specialty = c.specialty[widget.lang] ?? c.specialty['en'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Center(child: Text(initials, style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(specialty, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              if (hasSessions)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text("${wallet.sessionsLeft} ${tr('left')}", style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: persId == null ? null : () {
                if (hasSessions) {
                  _showSheet(PTSchedulingSheet(
                    lang: widget.lang, 
                    coach: c, 
                    persId: persId, 
                    onSchedule: (date, time) => context.read<BookingCubit>().scheduleSession(persId, c.id, date, time)
                  ));
                } else {
                  _showSheet(PTPackageModal(
                    lang: widget.lang, 
                    coach: c, 
                    offers: state.ptOffers, 
                    onBuy: (sessions) => context.read<BookingCubit>().buyPackage(persId, c.id, sessions)
                  ));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(hasSessions ? tr('scheduleSession') : tr('buyPackage') ?? "Buy Package", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesList(BuildContext context, BookingLoaded state, int? persId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('upcomingClasses'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...state.groupClasses.map((c) => _buildClassCard(context, c, persId)),
      ],
    );
  }

  Widget _buildClassCard(BuildContext context, GroupClassEntity c, int? persId) {
    final isFull = c.spotsLeft == '0';
    final name = c.name[widget.lang] ?? c.name['en'] ?? '';
    final instructor = c.instructor[widget.lang] ?? c.instructor['en'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.clock, color: Colors.grey, size: 14),
                        const SizedBox(width: 6),
                        Text("${c.date} ${tr('at')} ${c.time}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("${tr('with')} $instructor", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: (isFull ? Colors.grey : Colors.green).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(isFull ? tr('full') : "${c.spotsLeft} ${tr('spotsLeft')}", style: TextStyle(color: isFull ? Colors.grey : Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (isFull || persId == null) ? null : () => _showSheet(ClassBookingSheet(
                classItem: c, 
                lang: widget.lang, 
                onBook: (id) => context.read<BookingCubit>().bookGroupClass(persId, id)
              )),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, disabledBackgroundColor: const Color(0xFF2A2A2A), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(isFull ? tr('sessionFull') : tr('bookNow'), style: TextStyle(color: isFull ? Colors.grey : Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyBookings(BookingLoaded state) {
    final recentBookings = state.userBookings.take(2).toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UpcomingBookingsScreen(lang: widget.lang))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('myUpcomingBookings'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const Icon(LucideIcons.chevronRight, color: Colors.grey, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (recentBookings.isEmpty) 
            Text(tr('noUpcomingBookings') ?? "No upcoming sessions", style: const TextStyle(color: Colors.grey, fontSize: 12))
          else
            ...recentBookings.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMyBookingItem(b, state),
            )),
        ],
      ),
    );
  }

  Widget _buildMyBookingItem(Map<String, dynamic> b, BookingLoaded state) {
    final isPT = b['type'] == 'pt';
    String title = "";
    String displayDate = "";
    String displayTime = "";

    if (isPT) {
      final coach = (state.coaches as Iterable<CoachEntity>).firstWhere((c) => c.id == b['coach_id'], orElse: () => state.coaches.first);
      title = "PT Session with ${coach.name}";
      displayDate = b['date'] ?? "";
      displayTime = b['time'] ?? "";
    } else {
      final classItem = (state.groupClasses as Iterable<GroupClassEntity>).firstWhere((c) => c.id == b['target_id'], orElse: () => state.groupClasses.first);
      title = classItem.name[widget.lang] ?? classItem.name['en'] ?? "Class";
      displayDate = classItem.date;
      displayTime = classItem.time;
    }

    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(isPT ? LucideIcons.user : LucideIcons.users, color: AppTheme.primaryRed, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text("$displayDate at $displayTime", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
