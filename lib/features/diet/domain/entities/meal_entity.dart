import 'package:equatable/equatable.dart';

class MealEntity extends Equatable {
  final String id;
  final String time;
  final String title;
  final List<String> items;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;

  const MealEntity({
    required this.id,
    required this.time,
    required this.title,
    required this.items,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  @override
  List<Object?> get props => [id, time, title, items, calories, protein, carbs, fats];
}
