import '../entities/pt_offer_entity.dart';
import '../repositories/booking_repository.dart';

class GetPTOffersUseCase {
  final BookingRepository repository;
  GetPTOffersUseCase(this.repository);

  Future<List<PTOfferEntity>> call() => repository.getPTOffers();
}
