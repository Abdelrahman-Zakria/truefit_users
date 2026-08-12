import '../../../../core/usecases/usecase.dart';
import '../entities/membership_plan_entity.dart';
import '../repositories/subscription_repository.dart';

class GetMembershipPlansUseCase implements UseCase<List<MembershipPlanEntity>, NoParams> {
  final SubscriptionRepository repository;

  GetMembershipPlansUseCase(this.repository);

  @override
  Future<List<MembershipPlanEntity>> call(NoParams params) {
    return repository.getMembershipPlans();
  }
}
