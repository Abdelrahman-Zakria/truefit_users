import '../entities/conversation_entity.dart';
import '../repositories/chat_repository.dart';

class GetConversationsUseCase {
  final ChatRepository repository;

  GetConversationsUseCase(this.repository);

  Stream<List<ConversationEntity>> call(int persId) {
    return repository.watchConversations(persId);
  }
}
