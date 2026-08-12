import '../../domain/entities/group_class_entity.dart';
import '../../domain/entities/coach_entity.dart';
import '../../domain/entities/pt_offer_entity.dart';
import '../../domain/entities/pt_wallet_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CoachEntity>> getCoaches() {
    return remoteDataSource.getCoaches();
  }

  @override
  Future<List<PTOfferEntity>> getPTOffers() {
    return remoteDataSource.getPTOffers();
  }

  @override
  Stream<List<PTWalletEntity>> watchUserPTWallet(int persId) {
    return remoteDataSource.watchUserPTWallet(persId);
  }

  @override
  Stream<List<String>> watchCoachAvailability(String coachId, String date) {
    return remoteDataSource.watchCoachAvailability(coachId, date);
  }

  @override
  Future<List<GroupClassEntity>> getGroupClasses() {
    return remoteDataSource.getGroupClasses();
  }

  @override
  Future<void> bookGroupClass(int persId, String classId) {
    return remoteDataSource.bookGroupClass(persId, classId);
  }

  @override
  Future<void> buyPTPackage(int persId, String coachId, int sessions) {
    return remoteDataSource.buyPTPackage(persId, coachId, sessions);
  }

  @override
  Future<void> schedulePTSession(int persId, String coachId, String date, String time) {
    return remoteDataSource.schedulePTSession(persId, coachId, date, time);
  }

  @override
  Stream<List<Map<String, dynamic>>> watchUserBookings(int persId) {
    return remoteDataSource.watchUserBookings(persId);
  }
}
