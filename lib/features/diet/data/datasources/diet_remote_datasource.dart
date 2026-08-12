import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diet_plan_model.dart';

abstract class DietRemoteDataSource {
  Stream<DietPlanModel> watchDietPlan(int persId);
  Future<void> updateWaterIntake(int persId, double amount);
}

class DietRemoteDataSourceImpl implements DietRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<DietPlanModel> watchDietPlan(int persId) {
    // Listen to the document in Gym_Diet_Plans named by persId
    return _firestore
        .collection('Gym_Diet_Plans')
        .doc(persId.toString())
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) {
            throw Exception('No diet plan found');
          }
          return DietPlanModel.fromJson(doc.data()!);
        });
  }

  @override
  Future<void> updateWaterIntake(int persId, double amount) async {
    await _firestore
        .collection('Gym_Diet_Plans')
        .doc(persId.toString())
        .update({
          'current_water': amount,
        });
  }
}
