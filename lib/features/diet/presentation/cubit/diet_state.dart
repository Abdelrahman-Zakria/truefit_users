import 'package:equatable/equatable.dart';
import '../../domain/entities/diet_plan_entity.dart';

abstract class DietState extends Equatable {
  const DietState();

  @override
  List<Object?> get props => [];
}

class DietInitial extends DietState {}

class DietLoading extends DietState {}

class DietLoaded extends DietState {
  final DietPlanEntity dietPlan;
  const DietLoaded(this.dietPlan);

  @override
  List<Object?> get props => [dietPlan];
}

class DietError extends DietState {
  final String message;
  const DietError(this.message);

  @override
  List<Object?> get props => [message];
}
