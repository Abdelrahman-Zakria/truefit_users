import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetConversationsUseCase getConversationsUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;

  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _messagesSubscription;
  List<ConversationEntity> _cachedConversations = [];

  ChatCubit({
    required this.getConversationsUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
  }) : super(ChatInitial());

  Future<void> loadConversations(int persId) async {
    // Only show loading if we don't have cached data
    if (_cachedConversations.isEmpty) {
      emit(ChatLoading());
    }
    await _conversationsSubscription?.cancel();
    _conversationsSubscription = getConversationsUseCase.call(persId).listen(
      (conversations) {
        _cachedConversations = List.from(conversations);
        emit(ChatConversationsLoaded(_cachedConversations));
      },
      onError: (e) => emit(ChatError(e.toString())),
    );
  }

  Future<void> loadMessages(String conversationId) async {
    // Only show loading if we are switching conversations or don't have messages yet
    final currentState = state;
    bool shouldShowLoading = true;
    if (currentState is ChatMessagesLoaded && currentState.conversationId == conversationId) {
      shouldShowLoading = false;
    }

    if (shouldShowLoading) {
      emit(ChatLoading());
    }

    await _messagesSubscription?.cancel();
    _messagesSubscription = getMessagesUseCase.call(conversationId).listen(
      (messages) {
        emit(ChatMessagesLoaded(conversationId, messages, _cachedConversations));
      },
      onError: (e) => emit(ChatError(e.toString())),
    );
  }

  Future<void> sendMessage(int persId, String conversationId, String text, String senderName) async {
    try {
      await sendMessageUseCase(SendMessageParams(
        persId: persId,
        conversationId: conversationId,
        text: text,
        senderName: senderName,
      ));
      // No need to manually reload, stream listener handles it
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void backToConversations() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    if (_cachedConversations.isNotEmpty) {
      emit(ChatConversationsLoaded(_cachedConversations));
    } else {
      emit(ChatInitial());
    }
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }

  void reset() {
    emit(ChatInitial());
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    _cachedConversations = [];
  }
}
