import '../entities/group_class_entity.dart';
import '../entities/coach_entity.dart';
import '../entities/pt_offer_entity.dart';
import '../entities/pt_wallet_entity.dart';

abstract class BookingRepository {
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
