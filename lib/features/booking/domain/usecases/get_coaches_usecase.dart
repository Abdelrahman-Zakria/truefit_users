import '../entities/coach_entity.dart';
import '../repositories/booking_repository.dart';

class GetCoachesUseCase {
  final BookingRepository repository;
  GetCoachesUseCase(this.repository);

  Future<List<CoachEntity>> call() => repository.getCoaches();
}
