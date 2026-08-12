import '../../domain/entities/outdoor_session_entity.dart';

class OutdoorSessionModel extends OutdoorSessionEntity {
  const OutdoorSessionModel({
    required super.id,
    required super.title,
    required super.instructor,
    required super.location,
    required super.date,
    required super.time,
    required super.duration,
    required super.spots,
    required super.totalSpots,
    required super.price,
    required super.about,
  });

  factory OutdoorSessionModel.fromJson(Map<String, dynamic> json) {
    return OutdoorSessionModel(
      id: json['id'],
      title: Map<String, String>.from(json['title']),
      instructor: Map<String, String>.from(json['instructor']),
      location: Map<String, String>.from(json['location']),
      date: json['date'],
      time: json['time'],
      duration: json['duration'],
      spots: json['spots'],
      totalSpots: json['totalSpots'],
      price: (json['price'] as num).toDouble(),
      about: Map<String, String>.from(json['about']),
    );
  }
}
