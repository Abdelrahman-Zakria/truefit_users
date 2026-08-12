import '../../domain/entities/coach_entity.dart';

class CoachModel extends CoachEntity {
  const CoachModel({
    required super.id,
    required super.name,
    required super.specialty,
    required super.rating,
    super.image,
    required super.bio,
  });

  factory CoachModel.fromJson(Map<String, dynamic> json, String docId) {
    return CoachModel(
      id: docId,
      name: json['name'] ?? '',
      specialty: Map<String, String>.from(json['specialty'] ?? {}),
      rating: (json['rating'] ?? 5.0).toString(),
      image: json['image'],
      bio: Map<String, String>.from(json['bio'] ?? {}),
    );
  }
}
