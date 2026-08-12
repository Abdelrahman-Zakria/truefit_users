import 'package:equatable/equatable.dart';

class ActivityStatsEntity extends Equatable {
  final int workouts;
  final double workoutPct;
  final int hours;
  final double hoursPct;
  final int sessions;
  final double sessionsPct;

  const ActivityStatsEntity({
    required this.workouts,
    required this.workoutPct,
    required this.hours,
    required this.hoursPct,
    required this.sessions,
    required this.sessionsPct,
  });

  @override
  List<Object?> get props => [workouts, workoutPct, hours, hoursPct, sessions, sessionsPct];
}
