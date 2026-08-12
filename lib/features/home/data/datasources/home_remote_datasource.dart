import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promotion_model.dart';
import '../models/outdoor_session_model.dart';
import '../models/home_offer_model.dart';
import '../models/home_package_model.dart';
import '../../domain/entities/activity_stats_entity.dart';

abstract class HomeRemoteDataSource {
  Future<List<PromotionModel>> getPromotions();
  Future<List<OutdoorSessionModel>> getOutdoorSessions();
  Future<List<HomeOfferModel>> getOffers();
  Future<List<HomePackageModel>> getPackages();
  Future<ActivityStatsEntity> getActivityStats(int? persId);
  Future<List<Map<String, dynamic>>> getUpcomingSessions(int? persId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<PromotionModel>> getPromotions() async {
    try {
      final snapshot = await _firestore.collection('promotions').get();
      return snapshot.docs.map((doc) => PromotionModel.fromJson(doc.data())).toList();
    } catch (e, stack) {
      print('DEBUG: Error in getPromotions: $e');
      print('DEBUG: Stacktrace: $stack');
      rethrow;
    }
  }

  @override
  Future<List<OutdoorSessionModel>> getOutdoorSessions() async {
    try {
      final snapshot = await _firestore.collection('outdoor_sessions').get();
      return snapshot.docs.map((doc) => OutdoorSessionModel.fromJson(doc.data())).toList();
    } catch (e, stack) {
      print('DEBUG: Error in getOutdoorSessions: $e');
      print('DEBUG: Stacktrace: $stack');
      rethrow;
    }
  }

  @override
  Future<List<HomeOfferModel>> getOffers() async {
    try {
      final snapshot = await _firestore.collection('home_offers').get();
      return snapshot.docs.map((doc) => HomeOfferModel.fromJson(doc.data())).toList();
    } catch (e, stack) {
      print('DEBUG: Error in getOffers: $e');
      print('DEBUG: Stacktrace: $stack');
      rethrow;
    }
  }

  @override
  Future<List<HomePackageModel>> getPackages() async {
    try {
      final snapshot = await _firestore.collection('Gym_Subscription_offers').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        print('DEBUG: Parsing package doc: ${doc.id}');
        
        // Safely parse name map
        final name = Map<String, String>.from(data['name'] ?? {});
        
        // Safely parse features map (handling List<dynamic> to List<String>)
        final featuresRaw = data['features'] as Map? ?? {};
        final features = featuresRaw.map(
          (key, value) => MapEntry(
            key.toString(), 
            List<String>.from(value as Iterable)
          ),
        );

        return HomePackageModel(
          id: doc.id,
          name: name,
          price: (data['price'] as num? ?? 0).toDouble(),
          popular: data['isPopular'] ?? false,
          features: features,
        );
      }).toList();
    } catch (e, stack) {
      print('DEBUG: Error in getPackages: $e');
      print('DEBUG: Stacktrace: $stack');
      rethrow;
    }
  }

  @override
  Future<ActivityStatsEntity> getActivityStats(int? persId) async {
    if (persId == null) return const ActivityStatsEntity(workouts: 0, workoutPct: 0, hours: 0, hoursPct: 0, sessions: 0, sessionsPct: 0);

    // This is now calculated in the UI using BookingCubit for real-time consistency
    return const ActivityStatsEntity(workouts: 0, workoutPct: 0, hours: 0, hoursPct: 0, sessions: 0, sessionsPct: 0);
  }

  @override
  Future<List<Map<String, dynamic>>> getUpcomingSessions(int? persId) async {
    // This is now handled by BookingCubit in the UI for real-time consistency
    return [];
  }
}
