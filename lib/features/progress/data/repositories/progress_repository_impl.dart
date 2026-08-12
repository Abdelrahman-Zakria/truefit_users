import '../../domain/entities/inbody_scan_entity.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_remote_datasource.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressRemoteDataSource remoteDataSource;

  ProgressRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<InBodyScanEntity>> watchScanHistory(int persId) {
    return remoteDataSource.watchScanHistory(persId).map((list) => list.cast<InBodyScanEntity>());
  }

  @override
  Future<void> bookInBodyScan({
    required int persId,
    required String memberName,
    required String date,
    required String time,
  }) {
    return remoteDataSource.bookInBodyScan(
      persId: persId,
      memberName: memberName,
      date: date,
      time: time,
    );
  }
}
