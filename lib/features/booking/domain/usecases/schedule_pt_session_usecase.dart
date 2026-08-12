import '../repositories/booking_repository.dart';

class SchedulePTSessionParams {
  final int persId;
  final String coachId;
  final String date;
  final String time;
  SchedulePTSessionParams({required this.persId, required this.coachId, required this.date, required this.time});
}

class SchedulePTSessionUseCase {
  final BookingRepository repository;
  SchedulePTSessionUseCase(this.repository);

  Future<void> call(SchedulePTSessionParams params) => 
      repository.schedulePTSession(params.persId, params.coachId, params.date, params.time);
}
