import '../entities/membership_plan_entity.dart';
import '../entities/branch_entity.dart';

abstract class SubscriptionRepository {
  Future<List<MembershipPlanEntity>> getMembershipPlans();
  Future<List<BranchEntity>> getBranches();
  Future<void> subscribe(String planId);
}
