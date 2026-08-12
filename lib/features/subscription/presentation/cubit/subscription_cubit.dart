import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/membership_plan_entity.dart';
import '../../data/models/user_subscription_model.dart';
import '../../data/datasources/subscription_remote_datasource.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/usecases/get_membership_plans_usecase.dart';
import '../../domain/usecases/subscribe_usecase.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final GetMembershipPlansUseCase getMembershipPlansUseCase;
  final SubscribeUseCase subscribeUseCase;

  SubscriptionCubit({
    required this.getMembershipPlansUseCase,
    required this.subscribeUseCase,
  }) : super(SubscriptionInitial());

  Future<void> loadMembershipPlans({int? persId}) async {
    print('DEBUG: loadMembershipPlans called with persId: $persId');
    emit(SubscriptionLoading());
    try {
      final plans = await getMembershipPlansUseCase(NoParams());
      print('DEBUG: Plans fetched from usecase: ${plans.length}');
      
      MembershipPlanEntity? activePlan;
      UserSubscriptionModel? userSub;

      if (persId != null) {
        print('DEBUG: Fetching active sub for $persId');
        // This logic should ideally be in a use case, but for speed wiring:
        final SubscriptionRemoteDataSource remote = (getMembershipPlansUseCase.repository as SubscriptionRepositoryImpl).remoteDataSource;
        userSub = await remote.getUserActiveSubscription(persId);
        if (userSub != null) {
          print('DEBUG: Found sub: ${userSub.planId}');
          final planModel = await remote.getPlanById(userSub.planId);
          if (planModel != null) {
            activePlan = planModel;
          }
        }
      }

      print('DEBUG: Emitting SubscriptionPlansLoaded');
      // Force a slight delay to ensure UI is ready to receive state
      await Future.delayed(const Duration(milliseconds: 100));
      emit(SubscriptionPlansLoaded(plans, activePlan: activePlan, userSubscription: userSub));
    } catch (e, stack) {
      print('DEBUG: Error in loadMembershipPlans: $e');
      print('DEBUG: Stacktrace: $stack');
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> subscribe(String planId) async {
    emit(SubscriptionLoading());
    try {
      await subscribeUseCase(planId);
      emit(SubscriptionSuccess());
      loadMembershipPlans(); // Reload
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  void reset() {
    emit(SubscriptionInitial());
  }
}
