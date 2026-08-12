import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inbody_scan_model.dart';

abstract class ProgressRemoteDataSource {
  Stream<List<InBodyScanModel>> watchScanHistory(int persId);
  Future<void> bookInBodyScan({
    required int persId,
    required String memberName,
    required String date,
    required String time,
  });
}

class ProgressRemoteDataSourceImpl implements ProgressRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<InBodyScanModel>> watchScanHistory(int persId) {
    return _firestore
        .collection('Gym_Progress_InBody')
        .where('member_id', isEqualTo: persId)
        .snapshots()
        .map((snapshot) {
          final scans = snapshot.docs
              .map((doc) => InBodyScanModel.fromJson(doc.data()))
              .toList();

          // Sort by date ascending for history/charts
          scans.sort((a, b) => a.date.compareTo(b.date));
          return scans;
        });
  }

  @override
  Future<void> bookInBodyScan({
    required int persId,
    required String memberName,
    required String date,
    required String time,
  }) async {
    await _firestore.collection('Inbody_Scan_booking').add({
      'member_id': persId,
      'member_name': memberName,
      'date': date,
      'time': time,
      'status': 'confirmed',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
