import 'package:equatable/equatable.dart';
import 'meal_entity.dart';

class DietPlanEntity extends Equatable {
  final String totalCalories;
  final String waterGoal;
  final double currentWater;
  final List<MealEntity> meals;
  final String proteinGoal;
  final String carbsGoal;
  final String fatsGoal;

  const DietPlanEntity({
    required this.totalCalories,
    required this.waterGoal,
    required this.currentWater,
    required this.meals,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatsGoal,
  });

  DietPlanEntity copyWith({double? currentWater}) {
    return DietPlanEntity(
      totalCalories: totalCalories,
      waterGoal: waterGoal,
      currentWater: currentWater ?? this.currentWater,
      meals: meals,
      proteinGoal: proteinGoal,
      carbsGoal: carbsGoal,
      fatsGoal: fatsGoal,
    );
  }

  @override
  List<Object?> get props => [totalCalories, waterGoal, currentWater, meals, proteinGoal, carbsGoal, fatsGoal];
}
