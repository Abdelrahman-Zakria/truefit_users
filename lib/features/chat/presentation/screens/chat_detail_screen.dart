import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';

class ChatDetailScreen extends StatefulWidget {
  final ConversationEntity conversation;
  final String lang;

  const ChatDetailScreen({super.key, required this.conversation, required this.lang});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _timer;
  List<MessageEntity> _lastMessages = [];

  String tr(String key) => Translations.tr(key, widget.lang);

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context.read<ChatCubit>().loadMessages(widget.conversation.id, authState.user.persId!);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordSeconds++;
      });
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() {
      _isRecording = false;
    });
    // In a real app, send the audio file here
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context.read<ChatCubit>().loadMessages(widget.conversation.id, authState.user.persId!);
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<ChatCubit>().backToConversations();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(child: _buildMessages()),
            _buildQuickReplies(),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.chevronLeft, color: Colors.grey), 
        onPressed: () {
          context.read<ChatCubit>().backToConversations();
          Navigator.pop(context);
        }
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: const Icon(LucideIcons.user, color: AppTheme.primaryRed, size: 20),
              ),
              if (widget.conversation.isOnline)
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF1A1A1A), width: 2))),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.conversation.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              Text(widget.conversation.isOnline ? (widget.lang == 'ar' ? "متصل الآن" : "Active now") : widget.conversation.role, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(LucideIcons.moreVertical, color: Colors.white, size: 20), onPressed: () {}),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMessages() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state is ChatMessagesLoaded && state.conversationId == widget.conversation.id) {
          _lastMessages = state.messages;
        }

        if (state is ChatLoading && _lastMessages.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
        }

        if (_lastMessages.isNotEmpty) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            reverse: true, // Standard chat behavior: newest at bottom
            itemCount: _lastMessages.length + 1, // +1 for "Today" header
            itemBuilder: (context, index) {
              // In a reversed list, higher index is at the top
              if (index == _lastMessages.length) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
                    child: Text(widget.lang == 'ar' ? "اليوم" : "Today", style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                );
              }
              return _buildMessageGroup(_lastMessages[index]);
            },
          );
        }

        if (state is ChatError) {
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildMessageGroup(MessageEntity m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: m.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!m.isMe) ...[
            Container(
              width: 28, height: 28,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(LucideIcons.user, color: AppTheme.primaryRed, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: m.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildMessageBubble(m),
                const SizedBox(height: 4),
                Text(m.time, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageEntity m) {
    if (m.isVoice) return _buildVoiceBubble(m);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      decoration: BoxDecoration(
        color: m.isMe ? AppTheme.primaryRed : const Color(0xFF1A1A1A),
        border: m.isMe ? null : Border.all(color: const Color(0xFF2A2A2A)),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(m.isMe ? 20 : 4),
          bottomRight: Radius.circular(m.isMe ? 4 : 20),
        ),
      ),
      child: Text(m.text, style: const TextStyle(color: Colors.white, fontSize: 14)),
    );
  }

  Widget _buildVoiceBubble(MessageEntity m) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      decoration: BoxDecoration(
        color: m.isMe ? AppTheme.primaryRed : const Color(0xFF1A1A1A),
        border: m.isMe ? null : Border.all(color: const Color(0xFF2A2A2A)),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(m.isMe ? 20 : 4),
          bottomRight: Radius.circular(m.isMe ? 4 : 20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(LucideIcons.mic, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 12),
          _buildWaveform(),
          const SizedBox(width: 12),
          Text(m.duration ?? "0:00", style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return Row(
      children: List.generate(10, (index) {
        final heights = [3, 5, 4, 7, 5, 3, 6, 4, 5, 3];
        return Container(
          margin: const EdgeInsets.only(right: 2),
          width: 2, height: heights[index].toDouble() * 2,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(1)),
        );
      }),
    );
  }

  Widget _buildQuickReplies() {
    final replies = [
      widget.lang == 'ar' ? "كيف هو تقدمي؟" : "How's my progress?",
      widget.lang == 'ar' ? "تعديل موعد الجلسة" : "Reschedule session",
      widget.lang == 'ar' ? "نصيحة غذائية" : "Diet advice",
    ];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: replies.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) => ActionChip(
          label: Text(replies[index], style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 12)),
          backgroundColor: const Color(0xFF1A1A1A),
          side: const BorderSide(color: Color(0xFF2A2A2A)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: () => _controller.text = replies[index],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(color: Color(0xFF1A1A1A), border: Border(top: BorderSide(color: Color(0xFF2A2A2A)))),
      child: _isRecording ? _buildRecordingInput() : _buildTextInput(),
    );
  }

  Widget _buildTextInput() {
    return Row(
      children: [
        IconButton(icon: const Icon(LucideIcons.paperclip, color: Colors.grey, size: 20), onPressed: () {}),
        IconButton(
          icon: const Icon(LucideIcons.mic, color: Colors.grey, size: 20), 
          onPressed: _startRecording,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(hintText: tr('typeAMessage'), hintStyle: const TextStyle(color: Color(0xFF6B7280)), border: InputBorder.none),
                  ),
                ),
                const Icon(LucideIcons.smile, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            if (_controller.text.trim().isNotEmpty) {
              final authState = context.read<AuthCubit>().state;
              if (authState is Authenticated) {
                final user = authState.user;
                final userName = widget.lang == 'en' 
                    ? (user.nameEn ?? user.displayName ?? "User")
                    : (user.nameAr ?? user.displayName ?? "User");
                
                context.read<ChatCubit>().sendMessage(
                  user.persId!, 
                  widget.conversation.id, 
                  _controller.text,
                  userName,
                );
                _controller.clear();
              }
            }
          },
          child: Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle),
            child: const Icon(LucideIcons.send, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingInput() {
    final minutes = _recordSeconds ~/ 60;
    final seconds = _recordSeconds % 60;
    final fmtTime = "$minutes:${seconds.toString().padLeft(2, '0')}";

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.4))),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Text(widget.lang == 'ar' ? "جاري التسجيل..." : "Recording… $fmtTime", style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _stopRecording,
          child: Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle),
            child: const Icon(LucideIcons.square, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }
}
