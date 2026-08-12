import '../../../../core/usecases/usecase.dart';
import '../entities/promotion_entity.dart';
import '../entities/outdoor_session_entity.dart';
import '../entities/home_offer_entity.dart';
import '../entities/home_package_entity.dart';
import '../entities/activity_stats_entity.dart';
import '../repositories/home_repository.dart';

class HomeData {
  final List<PromotionEntity> promotions;
  final List<OutdoorSessionEntity> outdoorSessions;
  final List<HomeOfferEntity> offers;
  final List<HomePackageEntity> packages;
  final ActivityStatsEntity activityStats;
  final List<Map<String, dynamic>> upcomingSessions;

  HomeData({
    required this.promotions,
    required this.outdoorSessions,
    required this.offers,
    required this.packages,
    required this.activityStats,
    required this.upcomingSessions,
  });
}

class HomeDataParams {
  final int? persId;
  HomeDataParams({this.persId});
}

class GetHomeDataUseCase implements UseCase<HomeData, HomeDataParams> {
  final HomeRepository repository;

  GetHomeDataUseCase(this.repository);

  @override
  Future<HomeData> call(HomeDataParams params) async {
    final results = await Future.wait([
      repository.getPromotions(),
      repository.getOutdoorSessions(),
      repository.getOffers(),
      repository.getPackages(),
      repository.getActivityStats(params.persId),
      repository.getUpcomingSessions(params.persId),
    ]);

    return HomeData(
      promotions: results[0] as List<PromotionEntity>,
      outdoorSessions: results[1] as List<OutdoorSessionEntity>,
      offers: results[2] as List<HomeOfferEntity>,
      packages: results[3] as List<HomePackageEntity>,
      activityStats: results[4] as ActivityStatsEntity,
      upcomingSessions: results[5] as List<Map<String, dynamic>>,
    );
  }
}
