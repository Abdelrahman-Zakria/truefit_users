import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/group_class_model.dart';
import '../models/coach_model.dart';
import '../models/pt_offer_model.dart';
import '../models/pt_wallet_model.dart';
import '../../domain/entities/pt_wallet_entity.dart';
import '../../domain/entities/coach_entity.dart';
import '../../domain/entities/group_class_entity.dart';
import '../../domain/entities/pt_offer_entity.dart';

abstract class BookingRemoteDataSource {
  Future<List<CoachEntity>> getCoaches();
  Future<List<PTOfferEntity>> getPTOffers();
  Stream<List<PTWalletEntity>> watchUserPTWallet(int persId);
  Stream<List<String>> watchCoachAvailability(String coachId, String date);
  
  Future<List<GroupClassEntity>> getGroupClasses();
  Future<void> bookGroupClass(int persId, String classId);
  
  Future<void> buyPTPackage(int persId, String coachId, int sessions);
  Future<void> schedulePTSession(int persId, String coachId, String date, String time);
  
  Stream<List<Map<String, dynamic>>> watchUserBookings(int persId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<CoachEntity>> getCoaches() async {
    final snapshot = await _firestore.collection('Gym_Coaches').get();
    return snapshot.docs.map<CoachEntity>((doc) => CoachModel.fromJson(doc.data(), doc.id)).toList();
  }

  @override
  Future<List<PTOfferEntity>> getPTOffers() async {
    final snapshot = await _firestore.collection('Gym_PT_Offers').get();
    return snapshot.docs.map<PTOfferEntity>((doc) => PTOfferModel.fromJson(doc.data(), doc.id)).toList();
  }

  @override
  Stream<List<PTWalletEntity>> watchUserPTWallet(int persId) {
    return _firestore
        .collection('User_PT_Wallet')
        .where('pers_ID', isEqualTo: persId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map<PTWalletEntity>((doc) => PTWalletModel.fromJson(doc.data())).toList());
  }

  @override
  Stream<List<String>> watchCoachAvailability(String coachId, String date) {
    // Get day name (Mon, Tue, etc.) from "2026-07-21"
    final dateTime = DateTime.parse(date);
    final dayName = DateFormat('E').format(dateTime);

    return _firestore
        .collection('Coaches_Shifts')
        .where('coachId', isEqualTo: coachId)
        .where('day', isEqualTo: dayName)
        .where('isOff', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return [];

          final data = snapshot.docs.first.data();
          final startStr = data['startTime'] as String? ?? '';
          final endStr = data['endTime'] as String? ?? '';
          
          if (startStr.isEmpty || endStr.isEmpty) return [];

          return _generateHourlySlots(startStr, endStr);
        });
  }

  List<String> _generateHourlySlots(String start, String end) {
    final List<String> slots = [];
    try {
      final format = DateFormat('h:mm a');
      DateTime startTime = format.parse(start);
      DateTime endTime = format.parse(end);

      // Handle cases where endTime is midnight (e.g., 12:00 AM) of the next day relative to startTime
      if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
        endTime = endTime.add(const Duration(days: 1));
      }

      DateTime current = startTime;
      while (current.isBefore(endTime)) {
        slots.add(format.format(current));
        current = current.add(const Duration(hours: 1));
      }
    } catch (e) {
      print('DEBUG: Error generating hourly slots: $e');
    }
    return slots;
  }

  @override
  Future<List<GroupClassEntity>> getGroupClasses() async {
    final snapshot = await _firestore.collection('Gym_Group_Classes').get();
    return snapshot.docs.map<GroupClassEntity>((doc) => GroupClassModel.fromJson(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> bookGroupClass(int persId, String classId) async {
    await _firestore.collection('User_Bookings').add({
      'pers_ID': persId,
      'type': 'class',
      'target_id': classId,
      'status': 'confirmed',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> buyPTPackage(int persId, String coachId, int sessions) async {
    final walletRef = _firestore.collection('User_PT_Wallet').doc('${persId}_$coachId');
    final doc = await walletRef.get();
    
    if (doc.exists) {
      await walletRef.update({
        'total': FieldValue.increment(sessions),
        'sessions_left': FieldValue.increment(sessions),
      });
    } else {
      await walletRef.set({
        'pers_ID': persId,
        'coach_id': coachId,
        'total': sessions,
        'sessions_left': sessions,
      });
    }
  }

  @override
  Future<void> schedulePTSession(int persId, String coachId, String date, String time) async {
    final batch = _firestore.batch();
    
    // 1. Add Booking
    final bookingRef = _firestore.collection('User_Bookings').doc();
    batch.set(bookingRef, {
      'pers_ID': persId,
      'type': 'pt',
      'coach_id': coachId,
      'date': date,
      'time': time,
      'status': 'confirmed',
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    // 2. Decrement Wallet
    final walletRef = _firestore.collection('User_PT_Wallet').doc('${persId}_$coachId');
    batch.update(walletRef, {'sessions_left': FieldValue.increment(-1)});
    
    // 3. Remove from coach schedule (Simplified)
    // In a real app, you'd find the schedule doc and filter the array
    
    await batch.commit();
  }

  @override
  Stream<List<Map<String, dynamic>>> watchUserBookings(int persId) {
    return _firestore
        .collection('User_Bookings')
        .where('pers_ID', isEqualTo: persId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }
}
