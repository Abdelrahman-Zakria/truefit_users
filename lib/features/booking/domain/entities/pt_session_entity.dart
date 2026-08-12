import 'package:equatable/equatable.dart';

class PTSessionEntity extends Equatable {
  final String id;
  final String trainerName;
  final Map<String, String> specialty;
  final String rating;
  final String? image;
  final List<String> availableTimes;

  const PTSessionEntity({
    required this.id,
    required this.trainerName,
    required this.specialty,
    required this.rating,
    this.image,
    required this.availableTimes,
  });

  @override
  List<Object?> get props => [id, trainerName, specialty, rating, image, availableTimes];
}
