import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
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

    final userData = querySnapshot.docs.first.data();
    final dateBirth = userData['DATE_BIRTH'] as String?;

    if (dateBirth == null) {
      throw Exception('Invalid user data: missing birthday');
    }

    // 2. Format DATE_BIRTH to DDMMYYYY
    // Assuming format is YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS
    try {
      final dateTime = DateTime.parse(dateBirth);
      final expectedPassword = DateFormat('ddMMyyyy').format(dateTime);

      if (expectedPassword != password) {
        throw Exception('Incorrect password');
      }
    } catch (e) {
      throw Exception('Error parsing user data: $e');
    }

    final user = UserModel.fromJson(userData);
    
    // Print user data for debugging
    print('--- User Logged In ---');
    print('Name (AR): ${user.nameAr}');
    print('Name (EN): ${user.nameEn}');
    print('Phone: ${user.phone}');
    print('Birthday: ${user.birthday}');
    print('PersID: ${user.persId}');
    print('----------------------');

    return user;
  }

  @override
  Future<void> register(Map<String, dynamic> data) async {
    // Not implemented for legacy users
    throw UnimplementedError('Registration is handled by the Admin system.');
  }

  @override
  Future<void> logout() async {
    // Implement if using Firebase Auth, otherwise just clear local session
  }

  @override
  Future<void> continueAsGuest() async {
    // Mock for now
  }
}
