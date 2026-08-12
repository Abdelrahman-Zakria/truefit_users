import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<ConversationEntity>> watchConversations(int persId) {
    return remoteDataSource.watchConversations(persId);
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String conversationId) {
    return remoteDataSource.watchMessages(conversationId);
  }

  @override
  Future<void> sendMessage(int persId, String conversationId, String text, String senderName) {
    return remoteDataSource.sendMessage(persId, conversationId, text, senderName);
  }
}
