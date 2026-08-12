import '../../../../core/usecases/usecase.dart';
import '../repositories/diet_repository.dart';

class UpdateWaterIntakeParams {
  final int persId;
  final double amount;

  UpdateWaterIntakeParams({required this.persId, required this.amount});
}

class UpdateWaterIntakeUseCase implements UseCase<void, UpdateWaterIntakeParams> {
  final DietRepository repository;

  UpdateWaterIntakeUseCase(this.repository);

  @override
  Future<void> call(UpdateWaterIntakeParams params) {
    return repository.updateWaterIntake(params.persId, params.amount);
  }
}
