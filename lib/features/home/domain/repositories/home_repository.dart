import '../entities/promotion_entity.dart';
import '../entities/outdoor_session_entity.dart';
import '../entities/home_offer_entity.dart';
import '../entities/home_package_entity.dart';
import '../entities/activity_stats_entity.dart';

abstract class HomeRepository {
  Future<List<PromotionEntity>> getPromotions();
  Future<List<OutdoorSessionEntity>> getOutdoorSessions();
  Future<List<HomeOfferEntity>> getOffers();
  Future<List<HomePackageEntity>> getPackages();
  Future<ActivityStatsEntity> getActivityStats(int? persId);
  Future<List<Map<String, dynamic>>> getUpcomingSessions(int? persId);
}
