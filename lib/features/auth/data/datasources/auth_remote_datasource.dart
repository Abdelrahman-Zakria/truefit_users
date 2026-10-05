import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String phoneNumber, String password);
  Future<void> register(Map<String, dynamic> data);
  Future<void> logout();
  Future<void> continueAsGuest();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserModel> login(String phoneNumber, String password) async {
    // 1. Query Gym_pers by Tel_Mobile1 (Phone Number)
    final querySnapshot = await _firestore
        .collection('Gym_pers')
        .where('Tel_Mobile1', isEqualTo: phoneNumber)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('User not found');
    }

    final docRef = querySnapshot.docs.first.reference;
    final userData = querySnapshot.docs.first.data();
    final dateBirth = userData['DATE_BIRTH'] as String?;

    if (dateBirth == null) {
      throw Exception('Invalid user data: missing birthday');
    }

    // 2. Format DATE_BIRTH to DDMMYYYY for password check
    try {
      final dateTime = DateTime.parse(dateBirth);
      final expectedPassword = DateFormat('ddMMyyyy').format(dateTime);

      if (expectedPassword != password) {
        throw Exception('Incorrect password');
      }
    } catch (e) {
      if (!e.toString().contains('Incorrect password')) {
        throw Exception('Error parsing user data: $e');
      } else {
        rethrow;
      }
    }

    final user = UserModel.fromJson(userData);

    // 3. Update FCM token in Gym_pers on login safely
    try {
      final fcmToken = await InjectionContainer.notificationService.getFCMToken();
      if (fcmToken != null) {
        await docRef.update({
          'fcm_token': fcmToken,
          'fcmToken': fcmToken,
        });
      }
    } catch (e) {
      print('Failed to update FCM token on login: $e');
    }

    // 4. Check if member subscription is still pending receptionist approval
    final int persId = user.persId ?? 0;
    if (persId != 0) {
      // Check if user has an active subscription in Gym_Subscription_pers
      final activeSub = await _firestore
          .collection('Gym_Subscription_pers')
          .where('pers_ID', isEqualTo: persId)
          .where('Subscription_pers_stat', isEqualTo: 1)
          .limit(1)
          .get();

      if (activeSub.docs.isEmpty) {
        // Check if there is a pending payment in Pending_Payments
        final pendingPayment = await _firestore
            .collection('Pending_Payments')
            .where('pers_ID', isEqualTo: persId)
            .where('status', isEqualTo: 'pending')
            .limit(1)
            .get();

        if (pendingPayment.docs.isNotEmpty || userData['status'] == 'pending') {
          throw Exception('PENDING: Your registration/subscription is pending approval.');
        }
      }
    }

    return user;
  }

  @override
  Future<void> register(Map<String, dynamic> data) async {
    final name = (data['name'] ?? data['nameEn'] ?? 'New Member').toString().trim();
    final phone = (data['phone'] ?? '').toString().trim();
    final email = (data['email'] ?? '').toString().trim();
    final address = (data['address'] ?? '').toString().trim();
    String birthday = (data['birthday'] ?? '').toString().trim();
    final branchId = data['branchId']?.toString();
    final branchName = data['branchName']?.toString();

    if (phone.isEmpty) {
      throw Exception('Phone number is required');
    }

    // Standardize birthday format for password verification
    if (birthday.isEmpty) {
      birthday = '2000-01-01';
    } else {
      try {
        final parsed = DateTime.parse(birthday);
        birthday = DateFormat('yyyy-MM-dd').format(parsed);
      } catch (_) {
        birthday = '2000-01-01';
      }
    }

    // Get current FCM token safely
    String? fcmToken;
    try {
      fcmToken = await InjectionContainer.notificationService.getFCMToken();
    } catch (e) {
      print('Failed to get FCM token during registration: $e');
    }

    // Check if phone number already registered
    final existingUserQuery = await _firestore
        .collection('Gym_pers')
        .where('Tel_Mobile1', isEqualTo: phone)
        .limit(1)
        .get();

    int persId;
    if (existingUserQuery.docs.isNotEmpty) {
      final docRef = existingUserQuery.docs.first.reference;
      final existingDoc = existingUserQuery.docs.first.data();
      final idRaw = existingDoc['pers_ID'];
      if (idRaw is int) {
        persId = idRaw;
      } else {
        persId = int.tryParse(idRaw.toString()) ?? (DateTime.now().millisecondsSinceEpoch % 100000000);
      }

      if (fcmToken != null) {
        await docRef.update({
          'fcm_token': fcmToken,
          'fcmToken': fcmToken,
        });
      }
    } else {
      persId = DateTime.now().millisecondsSinceEpoch % 100000000;

      final gymPersData = {
        'pers_ID': persId,
        'pers_NAME_EN': name,
        'pers_NAME_AR': name,
        'Tel_Mobile1': phone,
        'E_mail': email,
        'ADDRESS': address,
        'DATE_BIRTH': birthday,
        'branch_id': branchId,
        'branch_name': branchName,
        'status': 'pending',
        'fcm_token': fcmToken,
        'fcmToken': fcmToken,
        'LogTime': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('Gym_pers').doc(persId.toString()).set(gymPersData);
    }

    // Create Pending Subscription Payment request for receptionist approval
    final planId = data['planId'] ?? data['target_id'];
    final planName = data['planName'] ?? data['package'] ?? 'Membership';
    final amount = (data['amount'] is num) ? (data['amount'] as num).toDouble() : double.tryParse(data['amount']?.toString() ?? '0') ?? 0.0;
    final paymentMethod = data['paymentMethod'] ?? data['payment_method'] ?? 'cash';
    final screenshotUrl = data['screenshotUrl'] ?? data['screenshot_url'];

    await _firestore.collection('Pending_Payments').add({
      'pers_ID': persId,
      'user_email': email,
      'member_name': name,
      'type': 'plan',
      'target_id': planId?.toString() ?? '0',
      'package': planName.toString(),
      'amount': amount,
      'payment_method': paymentMethod.toString(),
      'screenshot_url': screenshotUrl,
      'branch_id': branchId,
      'branch_name': branchName,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> logout() async {
    // Clear session if needed
  }

  @override
  Future<void> continueAsGuest() async {
    // Guest session
  }
}
