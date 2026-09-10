import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../../../core/widgets/guest_locked_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../subscription/presentation/cubit/subscription_cubit.dart';
import '../../../subscription/presentation/cubit/subscription_state.dart';
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
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, subState) {
        return BlocBuilder<BookingCubit, BookingState>(
          builder: (context, state) {
            final authState = context.watch<AuthCubit>().state;
            final int? persId = authState is Authenticated ? authState.user.persId : null;

            if (state is BookingInitial) {
              if (persId != null) {
                context.read<BookingCubit>().loadBookingData(persId);
              } else {
                // Guests can still load data
                context.read<BookingCubit>().loadBookingData(0); 
              }
            }

            return Scaffold(
              backgroundColor: AppTheme.backgroundBlack,
              body: RefreshIndicator(
                onRefresh: () async {
                  if (persId != null) {
                    await context.read<BookingCubit>().loadBookingData(persId);
                    await context.read<SubscriptionCubit>().loadMembershipPlans(persId: persId);
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
                        const SizedBox(height: 16),
                        if (!widget.isGuest) _buildSubscriptionStatus(subState),
                        const SizedBox(height: 24),
                        if (state is BookingLoaded) ...[
                          _buildMyBookings(state),
                          const SizedBox(height: 24),
                        ],
                        _buildTabs(),
                        const SizedBox(height: 24),
                        _buildBody(context, state, persId, subState),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubscriptionStatus(SubscriptionState state) {
    if (state is SubscriptionPlansLoaded && state.userSubscription != null) {
      final status = state.userSubscription!.status;
      Color statusColor;
      String statusText;
      IconData statusIcon;

      switch (status) {
        case 1: // Active
          statusColor = Colors.green;
          statusText = tr('subActive');
          statusIcon = LucideIcons.checkCircle;
          break;
        case 2: // Pending
          statusColor = Colors.orange;
          statusText = tr('subPending');
          statusIcon = LucideIcons.clock;
          break;
        default: // 0 or other: Ended
          statusColor = Colors.red;
          statusText = tr('subEnded');
          statusIcon = LucideIcons.alertCircle;
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('subscriptionStatus'), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  if (status == 2) 
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(tr('waitingForGymApproval'), style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox();
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

  Widget _buildBody(BuildContext context, BookingState state, int? persId, SubscriptionState subState) {
    if (state is BookingLoading) {
      return const BookingSkeleton();
    }

    if (state is BookingLoaded) {
      return _activeTab == 0 
        ? _buildPTList(context, state, persId, subState) 
        : _buildClassesList(context, state, persId, subState);
    }

    if (state is BookingError) {
      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
    }

    return const SizedBox();
  }

  Widget _buildPTList(BuildContext context, BookingLoaded state, int? persId, SubscriptionState subState) {
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
        ...sortedCoaches.map((c) => _buildCoachCard(context, c, state, persId, subState)),
      ],
    );
  }

  Widget _buildCoachCard(BuildContext context, CoachEntity c, BookingLoaded state, int? persId, SubscriptionState subState) {
    final PTWalletEntity wallet = (state.userWallets as Iterable<PTWalletEntity>).firstWhere((w) => w.coachId == c.id, orElse: () => const PTWalletEntity(persId: 0, coachId: '', total: 0, sessionsLeft: 0));
    final hasSessions = wallet.sessionsLeft > 0;
    
    final hasPendingPayment = state.pendingPayments.any((p) => p['type'] == 'pt' && p['target_id'] == c.id);

    final initials = c.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('').toUpperCase();
    final specialty = c.specialty[widget.lang] ?? c.specialty['en'] ?? '';

    bool isSubActive = false;
    int subStatus = 0;
    if (subState is SubscriptionPlansLoaded && subState.userSubscription != null) {
      subStatus = subState.userSubscription!.status;
      isSubActive = subStatus == 1;
    }

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
              onPressed: hasPendingPayment ? null : () {
                if (hasSessions) {
                  // Only allow scheduling if sub is active
                  if (!isSubActive) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(subStatus == 2 ? tr('waitingForGymApproval') : (tr('subEnded') + ". " + tr('renewNow')))),
                    );
                    return;
                  }
                  _showSheet(PTSchedulingSheet(
                    lang: widget.lang, 
                    coach: c, 
                    persId: persId ?? 0, 
                    onSchedule: (date, time) => context.read<BookingCubit>().scheduleSession(persId ?? 0, c.id, date, time)
                  ));
                } else {
                  _showSheet(PTPackageModal(
                    lang: widget.lang, 
                    coach: c, 
                    offers: state.ptOffers, 
                    onBuy: (sessions) => context.read<BookingCubit>().buyPackage(persId ?? 0, c.id, sessions)
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasPendingPayment ? Colors.orange : AppTheme.primaryRed, 
                disabledBackgroundColor: hasPendingPayment ? Colors.orange.withValues(alpha: 0.2) : const Color(0xFF2A2A2A),
                padding: const EdgeInsets.symmetric(vertical: 12), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              child: Text(
                hasPendingPayment 
                  ? tr('subPending') 
                  : (hasSessions ? tr('scheduleSession') : tr('buyPackage') ?? "Buy Package"), 
                style: TextStyle(color: hasPendingPayment ? Colors.orange : Colors.white, fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesList(BuildContext context, BookingLoaded state, int? persId, SubscriptionState subState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('upcomingClasses'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...state.groupClasses.map((c) => _buildClassCard(context, c, state, persId, subState)),
      ],
    );
  }

  Widget _buildClassCard(BuildContext context, GroupClassEntity c, BookingLoaded state, int? persId, SubscriptionState subState) {
    final isFull = c.spotsLeft == '0';
    final name = c.name[widget.lang] ?? c.name['en'] ?? '';
    final instructor = c.instructor[widget.lang] ?? c.instructor['en'] ?? '';

    final hasPendingPayment = state.pendingPayments.any((p) => p['type'] == 'class' && p['target_id'] == c.id);

    bool isSubActive = false;
    int subStatus = 0;
    if (subState is SubscriptionPlansLoaded && subState.userSubscription != null) {
      subStatus = subState.userSubscription!.status;
      isSubActive = subStatus == 1;
    }

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
              onPressed: (isFull || hasPendingPayment) ? null : () {
                if (!isSubActive) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(subStatus == 2 ? tr('waitingForGymApproval') : (tr('subEnded') + ". " + tr('renewNow')))),
                  );
                  return;
                }
                _showSheet(ClassBookingSheet(
                  classItem: c, 
                  lang: widget.lang, 
                  onBook: (id) => context.read<BookingCubit>().bookGroupClass(persId ?? 0, id)
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasPendingPayment ? Colors.orange : AppTheme.primaryRed, 
                disabledBackgroundColor: hasPendingPayment ? Colors.orange.withValues(alpha: 0.2) : const Color(0xFF2A2A2A), 
                padding: const EdgeInsets.symmetric(vertical: 12), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              child: Text(
                hasPendingPayment ? tr('subPending') : (isFull ? tr('sessionFull') : tr('bookNow')), 
                style: TextStyle(color: hasPendingPayment ? Colors.orange : Colors.white, fontWeight: FontWeight.bold)
              ),
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
