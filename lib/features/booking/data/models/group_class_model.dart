import '../../domain/entities/group_class_entity.dart';

class GroupClassModel extends GroupClassEntity {
  const GroupClassModel({
    required super.id,
    required super.name,
    required super.instructor,
    required super.time,
    required super.date,
    required super.studio,
    required super.spotsLeft,
    required super.duration,
    required super.category,
  });

  factory GroupClassModel.fromJson(Map<String, dynamic> json, String docId) {
    Map<String, String> localizedName = {};
    if (json['name'] is Map) {
      localizedName = Map<String, String>.from(json['name']);
    } else {
      String name = json['name']?.toString() ?? '';
      localizedName = {'en': name, 'ar': name};
    }

    Map<String, String> localizedInstructor = {};
    if (json['coach_name'] is Map) {
      localizedInstructor = Map<String, String>.from(json['coach_name']);
    } else if (json['instructor'] is Map) {
      localizedInstructor = Map<String, String>.from(json['instructor']);
    } else {
      String name = (json['coach_name'] ?? json['instructor'] ?? '').toString();
      localizedInstructor = {'en': name, 'ar': name};
    }

    return GroupClassModel(
      id: docId,
      name: localizedName,
      instructor: localizedInstructor,
      time: json['time'] ?? '',
      date: json['date'] ?? '',
      studio: json['studio'] ?? '',
      spotsLeft: (json['capacity'] != null && json['booked'] != null) 
          ? (json['capacity'] - json['booked']).toString() 
          : (json['spotsLeft']?.toString() ?? '0'),
      duration: json['duration'] ?? '60 min',
      category: json['category'] ?? '',
    );
  }
}
