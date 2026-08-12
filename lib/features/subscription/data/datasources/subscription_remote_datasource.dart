import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/membership_plan_model.dart';
import '../models/user_subscription_model.dart';
import '../../domain/entities/membership_plan_entity.dart';

abstract class SubscriptionRemoteDataSource {
  Future<List<MembershipPlanEntity>> getMembershipPlans();
  Future<UserSubscriptionModel?> getUserActiveSubscription(int persId);
  Future<MembershipPlanEntity?> getPlanById(int planId);
  Future<void> subscribe(String planId);
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<MembershipPlanEntity>> getMembershipPlans() async {
    // Fetch from the new offers collection
    final querySnapshot = await _firestore.collection('Gym_Subscription_offers').get();
    return querySnapshot.docs
        .map<MembershipPlanEntity>((doc) => MembershipPlanModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<UserSubscriptionModel?> getUserActiveSubscription(int persId) async {
    // We fetch all subscriptions for this user and sort in-memory 
    // to avoid requiring a composite index in Firestore.
    final querySnapshot = await _firestore
        .collection('Gym_Subscription_pers')
        .where('pers_ID', isEqualTo: persId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    final subscriptions = querySnapshot.docs
        .map((doc) => UserSubscriptionModel.fromJson(doc.data()))
        .toList();

    // Sort by toDate descending
    subscriptions.sort((a, b) => b.toDate.compareTo(a.toDate));

    return subscriptions.first;
  }

  @override
  Future<MembershipPlanEntity?> getPlanById(int planId) async {
    final querySnapshot = await _firestore
        .collection('Gym_Subscription_types')
        .where('Subscription_type_id', isEqualTo: planId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    return MembershipPlanModel.fromJson(querySnapshot.docs.first.data());
  }

  @override
  Future<void> subscribe(String planId) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
