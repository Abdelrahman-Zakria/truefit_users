import '../../domain/entities/membership_plan_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;

  SubscriptionRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<MembershipPlanEntity>> getMembershipPlans() {
    return remoteDataSource.getMembershipPlans();
  }

  @override
  Future<void> subscribe(String planId) {
    return remoteDataSource.subscribe(planId);
  }
}
