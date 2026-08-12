import '../entities/diet_plan_entity.dart';
import '../repositories/diet_repository.dart';

class GetDietPlanUseCase {
  final DietRepository repository;

  GetDietPlanUseCase(this.repository);

  Stream<DietPlanEntity> call(int persId) {
    return repository.watchDietPlan(persId);
  }
}
