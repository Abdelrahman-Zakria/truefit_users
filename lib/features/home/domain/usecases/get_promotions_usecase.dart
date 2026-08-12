import '../../../../core/usecases/usecase.dart';
import '../entities/promotion_entity.dart';
import '../repositories/home_repository.dart';

class GetPromotionsUseCase implements UseCase<List<PromotionEntity>, NoParams> {
  final HomeRepository repository;

  GetPromotionsUseCase(this.repository);

  @override
  Future<List<PromotionEntity>> call(NoParams params) {
    return repository.getPromotions();
  }
}
