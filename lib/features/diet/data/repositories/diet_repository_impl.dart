import '../../domain/entities/diet_plan_entity.dart';
import '../../domain/repositories/diet_repository.dart';
import '../datasources/diet_remote_datasource.dart';

class DietRepositoryImpl implements DietRepository {
  final DietRemoteDataSource remoteDataSource;

  DietRepositoryImpl(this.remoteDataSource);

  @override
  Stream<DietPlanEntity> watchDietPlan(int persId) {
    return remoteDataSource.watchDietPlan(persId);
  }

  @override
  Future<void> updateWaterIntake(int persId, double amount) {
    return remoteDataSource.updateWaterIntake(persId, amount);
  }
}
