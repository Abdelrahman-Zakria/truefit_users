import 'package:equatable/equatable.dart';

class PTWalletEntity extends Equatable {
  final int persId;
  final String coachId;
  final int total;
  final int sessionsLeft;

  const PTWalletEntity({
    required this.persId,
    required this.coachId,
    required this.total,
    required this.sessionsLeft,
  });

  @override
  List<Object?> get props => [persId, coachId, total, sessionsLeft];
}
