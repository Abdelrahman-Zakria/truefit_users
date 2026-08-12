import '../repositories/booking_repository.dart';

class WatchUserBookingsUseCase {
  final BookingRepository repository;
  WatchUserBookingsUseCase(this.repository);

  Stream<List<Map<String, dynamic>>> call(int persId) => repository.watchUserBookings(persId);
}
