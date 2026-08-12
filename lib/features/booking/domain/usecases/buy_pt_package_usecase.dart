import '../repositories/booking_repository.dart';

class BuyPTPackageParams {
  final int persId;
  final String coachId;
  final int sessions;
  BuyPTPackageParams({required this.persId, required this.coachId, required this.sessions});
}

class BuyPTPackageUseCase {
  final BookingRepository repository;
  BuyPTPackageUseCase(this.repository);

  Future<void> call(BuyPTPackageParams params) => 
      repository.buyPTPackage(params.persId, params.coachId, params.sessions);
}
