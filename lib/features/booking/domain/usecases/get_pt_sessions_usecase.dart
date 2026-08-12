import '../entities/pt_wallet_entity.dart';
import '../repositories/booking_repository.dart';

class GetPTSessionsUseCase {
  final BookingRepository repository;

  GetPTSessionsUseCase(this.repository);

  Stream<List<PTWalletEntity>> call(int persId) {
    return repository.watchUserPTWallet(persId);
  }
}
