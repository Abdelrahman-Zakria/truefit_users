import 'package:equatable/equatable.dart';
import '../../domain/entities/membership_plan_entity.dart';
import '../../data/models/user_subscription_model.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionPlansLoaded extends SubscriptionState {
  final List<MembershipPlanEntity> plans;
  final MembershipPlanEntity? activePlan;
  final UserSubscriptionModel? userSubscription;

  const SubscriptionPlansLoaded(this.plans, {this.activePlan, this.userSubscription});

  @override
  List<Object?> get props => [plans, activePlan, userSubscription];
}

class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

class SubscriptionSuccess extends SubscriptionState {}
