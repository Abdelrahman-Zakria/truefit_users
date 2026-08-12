import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationsScreen extends StatelessWidget {
  final String lang;

  const NotificationsScreen({super.key, required this.lang});

  String tr(String key) => Translations.tr(key, lang);

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return LucideIcons.calendar;
      case NotificationType.payment:
        return LucideIcons.creditCard;
      case NotificationType.offer:
        return LucideIcons.tag;
      case NotificationType.system:
        return LucideIcons.dumbbell;
      case NotificationType.fitnessClass:
        return LucideIcons.dumbbell;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return const Color(0xFFDC143C);
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.offer:
        return Colors.yellow;
      case NotificationType.system:
        return Colors.purple;
      case NotificationType.fitnessClass:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        int unreadCount = 0;
        List<NotificationEntity> todayItems = [];
        List<NotificationEntity> earlierItems = [];

        if (state is NotificationsLoaded) {
          unreadCount = state.notifications.where((n) => !n.read).length;
          todayItems = state.notifications.where((n) => n.today).toList();
          earlierItems = state.notifications.where((n) => !n.today).toList();
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundBlack,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, unreadCount),
                Expanded(
                  child: _buildBody(context, state, todayItems, earlierItems),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, NotificationsState state, List<NotificationEntity> today, List<NotificationEntity> earlier) {
    if (state is NotificationsLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
    }

    if (state is NotificationsLoaded) {
      if (state.notifications.isEmpty) {
        return _buildEmptyState();
      }
      return _buildList(context, today, earlier);
    }

    if (state is NotificationsError) {
      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
    }

    return const SizedBox();
  }

  Widget _buildHeader(BuildContext context, int unreadCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: const Icon(LucideIcons.chevronLeft, color: Colors.grey, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tr('notifications'),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.read<NotificationsCubit>().markAllRead(),
              child: Text(
                tr('markAllRead'),
                style: const TextStyle(color: AppTheme.primaryRed, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(color: Color(0xFF1A1A1A), shape: BoxShape.circle),
            child: const Icon(LucideIcons.bell, color: Color(0xFF4B5563), size: 28),
          ),
          const SizedBox(height: 16),
          Text(tr('noNotifications'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(tr('noNotificationsSub'), style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<NotificationEntity> today, List<NotificationEntity> earlier) {
    return ListView(
      children: [
        if (today.isNotEmpty) ...[
          _buildSectionHeader(tr('today')),
          ...today.map((n) => _buildNotificationTile(context, n)),
        ],
        if (earlier.isNotEmpty) ...[
          _buildSectionHeader(tr('earlier')),
          ...earlier.map((n) => _buildNotificationTile(context, n)),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, NotificationEntity n) {
    final color = _getTypeColor(n.type);
    return InkWell(
      onTap: () => context.read<NotificationsCubit>().markRead(n.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: n.read ? Colors.transparent : AppTheme.primaryRed.withValues(alpha:0.05),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getTypeIcon(n.type), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          n.title[lang] ?? n.title['en']!,
                          style: TextStyle(
                            color: n.read ? const Color(0xFFD1D5DB) : Colors.white,
                            fontSize: 14,
                            fontWeight: n.read ? FontWeight.w500 : FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        n.time,
                        style: TextStyle(color: n.read ? const Color(0xFF4B5563) : const Color(0xFF6B7280), fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.body[lang] ?? n.body['en']!,
                    style: TextStyle(
                      color: n.read ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!n.read)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4, left: 8),
                decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
