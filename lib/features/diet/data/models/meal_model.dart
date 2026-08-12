import '../../domain/entities/meal_entity.dart';

class MealModel extends MealEntity {
  const MealModel({
    required super.id,
    required super.time,
    required super.title,
    required super.items,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fats,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      items: (json['items'] as List?)?.map((e) => e.toString()).toList() ?? [],
      calories: (json['calories'] as num? ?? 0).toInt(),
      protein: (json['protein'] as num? ?? 0).toInt(),
      carbs: (json['carbs'] as num? ?? 0).toInt(),
      fats: (json['fats'] as num? ?? 0).toInt(),
    );
  }
}
