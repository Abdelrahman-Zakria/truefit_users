import '../../domain/entities/diet_plan_entity.dart';
import 'meal_model.dart';

class DietPlanModel extends DietPlanEntity {
  const DietPlanModel({
    required super.totalCalories,
    required super.waterGoal,
    required super.currentWater,
    required super.meals,
    required super.proteinGoal,
    required super.carbsGoal,
    required super.fatsGoal,
  });

  factory DietPlanModel.fromJson(Map<String, dynamic> json) {
    return DietPlanModel(
      totalCalories: (json['total_calories'] ?? json['totalCalories'] ?? '0').toString(),
      waterGoal: (json['water_goal'] ?? json['waterGoal'] ?? '0').toString(),
      currentWater: (json['current_water'] ?? json['currentWater'] ?? 0.0 as num).toDouble(),
      meals: (json['meals'] as List?)?.map((m) => MealModel.fromJson(Map<String, dynamic>.from(m))).toList() ?? [],
      proteinGoal: (json['protein_goal'] ?? json['proteinGoal'] ?? '0g').toString(),
      carbsGoal: (json['carbs_goal'] ?? json['carbsGoal'] ?? '0g').toString(),
      fatsGoal: (json['fats_goal'] ?? json['fatsGoal'] ?? '0g').toString(),
    );
  }
}
