import '../repositories/booking_repository.dart';

class BookSessionParams {
  final int persId;
  final String sessionId;
  BookSessionParams({required this.persId, required this.sessionId});
}

class BookSessionUseCase {
  final BookingRepository repository;

  BookSessionUseCase(this.repository);

  Future<void> call(BookSessionParams params) {
    return repository.bookGroupClass(params.persId, params.sessionId);
  }
}
