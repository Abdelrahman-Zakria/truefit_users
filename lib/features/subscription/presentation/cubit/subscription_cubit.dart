import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/membership_plan_entity.dart';
import '../../domain/entities/branch_entity.dart';
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
      final SubscriptionRemoteDataSource remote = (getMembershipPlansUseCase.repository as SubscriptionRepositoryImpl).remoteDataSource;
      final branches = await remote.getBranches();
      
      MembershipPlanEntity? activePlan;
      UserSubscriptionModel? userSub;

      if (persId != null && persId != 0) {
        userSub = await remote.getUserActiveSubscription(persId);
        if (userSub != null) {
          final planModel = await remote.getPlanById(userSub.planId);
          if (planModel != null) {
            activePlan = planModel;
          }
        }
      }

      await Future.delayed(const Duration(milliseconds: 100));
      emit(SubscriptionPlansLoaded(plans, branches: branches, activePlan: activePlan, userSubscription: userSub));
    } catch (e, stack) {
      print('DEBUG: Error in loadMembershipPlans: $e');
      print('DEBUG: Stacktrace: $stack');
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<List<BranchEntity>> getBranches() async {
    try {
      final SubscriptionRemoteDataSource remote = (getMembershipPlansUseCase.repository as SubscriptionRepositoryImpl).remoteDataSource;
      return await remote.getBranches();
    } catch (_) {
      return const [
        BranchEntity(
          id: 'main_branch',
          name: 'Main Branch',
          displayName: 'True Fit Main Branch',
          address: 'Cairo, Egypt',
          isActive: true,
        ),
      ];
    }
  }

  Future<void> subscribe(String planId) async {
    emit(SubscriptionLoading());
    try {
      await subscribeUseCase(planId);
      emit(SubscriptionSuccess());
      loadMembershipPlans();
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> requestPayment({
    required int persId,
    required String email,
    required String memberName,
    required String planId,
    required String planName,
    required double amount,
    required String method,
    String? screenshotUrl,
    String? branchId,
    String? branchName,
  }) async {
    emit(SubscriptionLoading());
    try {
      final SubscriptionRemoteDataSource remote = (getMembershipPlansUseCase.repository as SubscriptionRepositoryImpl).remoteDataSource;
      await remote.requestSubscriptionPayment(
        persId: persId,
        userEmail: email,
        memberName: memberName,
        planId: planId,
        planName: planName,
        amount: amount,
        method: method,
        screenshotUrl: screenshotUrl,
        branchId: branchId,
        branchName: branchName,
      );
      emit(SubscriptionSuccess());
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  void reset() {
    emit(SubscriptionInitial());
  }
}
