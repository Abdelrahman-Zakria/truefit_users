import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Stream<List<MessageEntity>> call(String conversationId) {
    return repository.watchMessages(conversationId);
  }
}
