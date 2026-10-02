import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/membership_plan_model.dart';
import '../models/user_subscription_model.dart';
import '../models/branch_model.dart';
import '../../domain/entities/membership_plan_entity.dart';
import '../../domain/entities/branch_entity.dart';

abstract class SubscriptionRemoteDataSource {
  Future<List<MembershipPlanEntity>> getMembershipPlans();
  Future<List<BranchEntity>> getBranches();
  Future<UserSubscriptionModel?> getUserActiveSubscription(int persId);
  Future<MembershipPlanEntity?> getPlanById(int planId);
  Future<void> subscribe(String planId);
  Future<void> requestSubscriptionPayment({
    required int persId,
    required String userEmail,
    required String memberName,
    required String planId,
    required String planName,
    required double amount,
    required String method,
    String? screenshotUrl,
    String? branchId,
    String? branchName,
  });
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
  Future<List<BranchEntity>> getBranches() async {
    try {
      final querySnapshot = await _firestore.collection('branches').get();
      if (querySnapshot.docs.isEmpty) {
        return const [
          BranchEntity(
            id: 'main_branch',
            name: 'Main Branch',
            displayName: 'True Fit Main Branch',
            address: 'Cairo, Egypt',
            isActive: true,
          ),
        ];
      }
      final branches = querySnapshot.docs
          .map((doc) => BranchModel.fromJson(doc.data(), doc.id))
          .where((b) => b.isActive)
          .toList();

      if (branches.isEmpty) {
        return const [
          BranchEntity(
            id: 'main_branch',
            name: 'Main Branch',
            displayName: 'True Fit Main Branch',
            address: 'Cairo, Egypt',
            isActive: true,
          ),
        ];
      }
      return branches;
    } catch (_) {
      return const [
        BranchEntity(
          id: 'main_branch',
          name: 'Main Branch',
          displayName: 'True Fit Main Branch',
          address: 'Cairo, Egypt',
          isActive: true,
        ),
      ];
    }
  }

  @override
  Future<UserSubscriptionModel?> getUserActiveSubscription(int persId) async {
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

  @override
  Future<void> requestSubscriptionPayment({
    required int persId,
    required String userEmail,
    required String memberName,
    required String planId,
    required String planName,
    required double amount,
    required String method,
    String? screenshotUrl,
    String? branchId,
    String? branchName,
  }) async {
    await _firestore.collection('Pending_Payments').add({
      'pers_ID': persId,
      'user_email': userEmail,
      'member_name': memberName,
      'type': 'plan',
      'target_id': planId,
      'package': planName,
      'amount': amount,
      'payment_method': method,
      'screenshot_url': screenshotUrl,
      'branch_id': branchId,
      'branch_name': branchName,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
