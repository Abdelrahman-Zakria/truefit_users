import '../entities/diet_plan_entity.dart';

abstract class DietRepository {
  Stream<DietPlanEntity> watchDietPlan(int persId);
  Future<void> updateWaterIntake(int persId, double amount);
}
