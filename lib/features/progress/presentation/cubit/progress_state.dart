import 'package:equatable/equatable.dart';
import '../../domain/entities/inbody_scan_entity.dart';

abstract class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {}

class ProgressLoading extends ProgressState {}

class ProgressLoaded extends ProgressState {
  final InBodyScanEntity latestScan;
  final List<InBodyScanEntity> allScans;
  const ProgressLoaded(this.latestScan, this.allScans);

  @override
  List<Object?> get props => [latestScan, allScans];
}

class ProgressError extends ProgressState {
  final String message;
  const ProgressError(this.message);

  @override
  List<Object?> get props => [message];
}
