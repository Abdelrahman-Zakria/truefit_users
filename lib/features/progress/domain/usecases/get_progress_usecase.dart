import '../entities/inbody_scan_entity.dart';
import '../repositories/progress_repository.dart';

class GetProgressUseCase {
  final ProgressRepository repository;

  GetProgressUseCase(this.repository);

  Stream<List<InBodyScanEntity>> call(int persId) {
    return repository.watchScanHistory(persId);
  }
}
