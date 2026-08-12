import 'package:equatable/equatable.dart';

class CoachEntity extends Equatable {
  final String id;
  final String name;
  final Map<String, String> specialty;
  final String rating;
  final String? image;
  final Map<String, String> bio;

  const CoachEntity({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    this.image,
    required this.bio,
  });

  @override
  List<Object?> get props => [id, name, specialty, rating, image, bio];
}
