import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Stream<List<ConversationEntity>> watchConversations(int persId);
  Stream<List<MessageEntity>> watchMessages(String conversationId, int persId);
  Future<void> sendMessage(int persId, String conversationId, String text, String senderName);
}
