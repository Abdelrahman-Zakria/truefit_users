import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../../../core/widgets/guest_locked_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../../domain/entities/conversation_entity.dart';
import '../widgets/chat_skeleton.dart';
import 'chat_detail_screen.dart';

class ConversationsScreen extends StatefulWidget {
  final bool isGuest;
  final String lang;
  final VoidCallback onJoinNow;

  const ConversationsScreen({
    super.key,
    required this.isGuest,
    required this.lang,
    required this.onJoinNow,
  });

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  String tr(String key) => Translations.tr(key, widget.lang);

  @override
  Widget build(BuildContext context) {
    if (widget.isGuest) {
      return GuestLockedView(
        icon: LucideIcons.messageCircle,
        featureKey: tr('lockChat'),
        onJoinNow: widget.onJoinNow,
        lang: widget.lang,
      );
    }

    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final authState = context.watch<AuthCubit>().state;
        final int? persId = authState is Authenticated ? authState.user.persId : null;

        if (state is ChatInitial && persId != null) {
          context.read<ChatCubit>().loadConversations(persId);
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundBlack,
          body: RefreshIndicator(
            onRefresh: () async {
              if (persId != null) {
                await context.read<ChatCubit>().loadConversations(persId);
              }
            },
            color: AppTheme.primaryRed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildSearchBox(),
                Expanded(
                  child: _buildBody(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('messages'), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(widget.lang == 'ar' ? "فريق التدريب الخاص بك" : "Your coaching team", style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _query = val),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          icon: const Icon(LucideIcons.search, color: Color(0xFF6B7280), size: 18),
          hintText: widget.lang == 'ar' ? "البحث في المحادثات..." : "Search conversations…",
          hintStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ChatState state) {
    if (state is ChatLoading) {
      return const ChatSkeleton();
    }

    List<ConversationEntity> conversations = [];
    if (state is ChatConversationsLoaded) {
      conversations = state.conversations;
    } else if (state is ChatMessagesLoaded) {
      conversations = state.conversations;
    }

    if (conversations.isNotEmpty) {
      final filtered = conversations.where((c) => 
        c.name.toLowerCase().contains(_query.toLowerCase()) || 
        c.role.toLowerCase().contains(_query.toLowerCase())
      ).toList();

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: filtered.length,
        separatorBuilder: (context, index) => const SizedBox(height: 4),
        itemBuilder: (context, index) => _buildConversationTile(context, filtered[index]),
      );
    }

    if (state is ChatError) {
      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
    }

    return const SizedBox();
  }

  Widget _buildConversationTile(BuildContext context, ConversationEntity c) {
    final Map<String, Color> avatarColors = {
      "1": const Color(0xFFDC143C).withValues(alpha: 0.2),
      "2": Colors.purple.withValues(alpha: 0.2),
      "3": Colors.blue.withValues(alpha: 0.2),
      "4": Colors.green.withValues(alpha: 0.2),
    };
    final Map<String, Color> iconColors = {
      "1": const Color(0xFFDC143C),
      "2": Colors.purple.shade400,
      "3": Colors.blue.shade400,
      "4": Colors.green.shade400,
    };

    return InkWell(
      onTap: () {
        context.read<ChatCubit>().loadMessages(c.id);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailScreen(conversation: c, lang: widget.lang)));
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: avatarColors[c.id] ?? const Color(0xFF2A2A2A),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.user, color: iconColors[c.id] ?? Colors.grey, size: 24),
                ),
                if (c.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0A0A0A), width: 2.5)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c.name, style: TextStyle(color: c.unreadCount > 0 ? Colors.white : const Color(0xFFE5E7EB), fontSize: 15, fontWeight: FontWeight.bold)),
                      if (c.time != null) Text(c.time!, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          c.lastMessage ?? "", 
                          style: TextStyle(color: c.unreadCount > 0 ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280), fontSize: 13), 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis
                        ),
                      ),
                      if (c.unreadCount > 0)
                        Container(
                          width: 20, height: 20,
                          decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle),
                          child: Center(child: Text('${c.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(c.role, style: const TextStyle(color: Color(0xFF4B5563), fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
