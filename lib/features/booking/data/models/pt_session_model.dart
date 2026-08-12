import '../../domain/entities/pt_session_entity.dart';

class PTSessionModel extends PTSessionEntity {
  const PTSessionModel({
    required super.id,
    required super.trainerName,
    required super.specialty,
    required super.rating,
    super.image,
    required super.availableTimes,
  });

  factory PTSessionModel.fromJson(Map<String, dynamic> json, String docId) {
    Map<String, String> localizedSpecialty = {};
    if (json['title'] is Map) {
      localizedSpecialty = Map<String, String>.from(json['title']);
    } else if (json['specialty'] is Map) {
      localizedSpecialty = Map<String, String>.from(json['specialty']);
    } else {
      String spec = json['title'] ?? json['specialty'] ?? '';
      localizedSpecialty = {'en': spec, 'ar': spec};
    }

    return PTSessionModel(
      id: docId,
      trainerName: json['coach_name'] ?? json['trainerName'] ?? '',
      specialty: localizedSpecialty,
      rating: json['rating']?.toString() ?? '5.0',
      image: json['image'],
      availableTimes: json['availableTimes'] != null 
          ? List<String>.from(json['availableTimes']) 
          : ["${json['date']} ${json['time']}"],
    );
  }
}
