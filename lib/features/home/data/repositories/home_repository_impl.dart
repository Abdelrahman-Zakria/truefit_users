import '../../domain/entities/promotion_entity.dart';
import '../../domain/entities/outdoor_session_entity.dart';
import '../../domain/entities/home_offer_entity.dart';
import '../../domain/entities/home_package_entity.dart';
import '../../domain/entities/activity_stats_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<PromotionEntity>> getPromotions() {
    return remoteDataSource.getPromotions();
  }

  @override
  Future<List<OutdoorSessionEntity>> getOutdoorSessions() {
    return remoteDataSource.getOutdoorSessions();
  }

  @override
  Future<List<HomeOfferEntity>> getOffers() {
    return remoteDataSource.getOffers();
  }

  @override
  Future<List<HomePackageEntity>> getPackages() {
    return remoteDataSource.getPackages();
  }

  @override
  Future<ActivityStatsEntity> getActivityStats(int? persId) {
    return remoteDataSource.getActivityStats(persId);
  }

  @override
  Future<List<Map<String, dynamic>>> getUpcomingSessions(int? persId) {
    return remoteDataSource.getUpcomingSessions(persId);
  }
}
