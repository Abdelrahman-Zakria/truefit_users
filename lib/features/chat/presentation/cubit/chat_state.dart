import 'package:equatable/equatable.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatConversationsLoaded extends ChatState {
  final List<ConversationEntity> conversations;
  const ChatConversationsLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class ChatMessagesLoaded extends ChatState {
  final String conversationId;
  final List<MessageEntity> messages;
  final List<ConversationEntity> conversations;
  const ChatMessagesLoaded(this.conversationId, this.messages, this.conversations);

  @override
  List<Object?> get props => [conversationId, messages, conversations];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
