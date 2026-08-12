import '../entities/pt_wallet_entity.dart';
import '../repositories/booking_repository.dart';

class WatchUserPTWalletUseCase {
  final BookingRepository repository;
  WatchUserPTWalletUseCase(this.repository);

  Stream<List<PTWalletEntity>> call(int persId) => repository.watchUserPTWallet(persId);
}
