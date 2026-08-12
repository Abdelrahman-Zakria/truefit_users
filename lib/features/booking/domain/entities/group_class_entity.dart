import 'package:equatable/equatable.dart';

class GroupClassEntity extends Equatable {
  final String id;
  final Map<String, String> name;
  final Map<String, String> instructor;
  final String time;
  final String date;
  final String studio;
  final String spotsLeft;
  final String duration;
  final String category;

  const GroupClassEntity({
    required this.id,
    required this.name,
    required this.instructor,
    required this.time,
    required this.date,
    required this.studio,
    required this.spotsLeft,
    required this.duration,
    required this.category,
  });

  @override
  List<Object?> get props => [id, name, instructor, time, date, studio, spotsLeft, duration, category];
}
