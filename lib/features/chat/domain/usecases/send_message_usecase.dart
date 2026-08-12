import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class SendMessageParams {
  final int persId;
  final String conversationId;
  final String text;
  final String senderName;

  SendMessageParams({
    required this.persId,
    required this.conversationId,
    required this.text,
    required this.senderName,
  });
}

class SendMessageUseCase implements UseCase<void, SendMessageParams> {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<void> call(SendMessageParams params) {
    return repository.sendMessage(
      params.persId,
      params.conversationId,
      params.text,
      params.senderName,
    );
  }
}
