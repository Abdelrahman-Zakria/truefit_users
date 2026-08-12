import '../repositories/booking_repository.dart';

class WatchCoachAvailabilityParams {
  final String coachId;
  final String date;
  WatchCoachAvailabilityParams({required this.coachId, required this.date});
}

class WatchCoachAvailabilityUseCase {
  final BookingRepository repository;
  WatchCoachAvailabilityUseCase(this.repository);

  Stream<List<String>> call(WatchCoachAvailabilityParams params) => 
      repository.watchCoachAvailability(params.coachId, params.date);
}
