import '../entities/inbody_scan_entity.dart';

abstract class ProgressRepository {
  Stream<List<InBodyScanEntity>> watchScanHistory(int persId);
  Future<void> bookInBodyScan({
    required int persId,
    required String memberName,
    required String date,
    required String time,
  });
}
