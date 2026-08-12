import 'package:equatable/equatable.dart';

class OutdoorSessionEntity extends Equatable {
  final String id;
  final Map<String, String> title;
  final Map<String, String> instructor;
  final Map<String, String> location;
  final String date;
  final String time;
  final String duration;
  final int spots;
  final int totalSpots;
  final double price;
  final Map<String, String> about;

  const OutdoorSessionEntity({
    required this.id,
    required this.title,
    required this.instructor,
    required this.location,
    required this.date,
    required this.time,
    required this.duration,
    required this.spots,
    required this.totalSpots,
    required this.price,
    required this.about,
  });

  @override
  List<Object?> get props => [id, title, instructor, location, date, time, duration, spots, totalSpots, price, about];
}
