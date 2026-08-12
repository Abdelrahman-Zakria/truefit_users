import '../entities/membership_plan_entity.dart';

abstract class SubscriptionRepository {
  Future<List<MembershipPlanEntity>> getMembershipPlans();
  Future<void> subscribe(String planId);
}
