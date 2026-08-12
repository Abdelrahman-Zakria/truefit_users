import 'package:equatable/equatable.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../domain/entities/outdoor_session_entity.dart';
import '../../domain/entities/home_offer_entity.dart';
import '../../domain/entities/home_package_entity.dart';
import '../../domain/entities/activity_stats_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<PromotionEntity> promotions;
  final List<OutdoorSessionEntity> outdoorSessions;
  final List<HomeOfferEntity> offers;
  final List<HomePackageEntity> packages;
  final ActivityStatsEntity activityStats;
  final List<Map<String, dynamic>> upcomingSessions;

  const HomeLoaded({
    required this.promotions,
    required this.outdoorSessions,
    required this.offers,
    required this.packages,
    required this.activityStats,
    required this.upcomingSessions,
  });

  @override
  List<Object?> get props => [promotions, outdoorSessions, offers, packages, activityStats, upcomingSessions];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
