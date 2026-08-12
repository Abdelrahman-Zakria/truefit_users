import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_coaches_usecase.dart';
import '../../domain/usecases/get_pt_offers_usecase.dart';
import '../../domain/usecases/buy_pt_package_usecase.dart';
import '../../domain/usecases/schedule_pt_session_usecase.dart';
import '../../domain/usecases/watch_user_bookings_usecase.dart';
import '../../domain/usecases/watch_user_pt_wallet_usecase.dart';
import '../../domain/usecases/watch_coach_availability_usecase.dart';
import '../../domain/usecases/get_group_classes_usecase.dart';
import '../../domain/usecases/book_session_usecase.dart';
import '../../domain/entities/coach_entity.dart';
import '../../domain/entities/group_class_entity.dart';
import '../../domain/entities/pt_offer_entity.dart';
import '../../domain/entities/pt_wallet_entity.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final GetCoachesUseCase getCoachesUseCase;
  final GetPTOffersUseCase getPTOffersUseCase;
  final GetGroupClassesUseCase getGroupClassesUseCase;
  final BuyPTPackageUseCase buyPTPackageUseCase;
  final SchedulePTSessionUseCase schedulePTSessionUseCase;
  final WatchUserBookingsUseCase watchUserBookingsUseCase;
  final WatchUserPTWalletUseCase watchUserPTWalletUseCase;
  final WatchCoachAvailabilityUseCase watchCoachAvailabilityUseCase;
  final BookSessionUseCase bookSessionUseCase;

  StreamSubscription? _bookingsSub;
  StreamSubscription? _walletSub;

  List<CoachEntity> _coaches = [];
  List<GroupClassEntity> _classes = [];
  List<PTOfferEntity> _offers = [];
  List<PTWalletEntity> _wallets = [];
  List<Map<String, dynamic>> _userBookings = [];

  BookingCubit({
    required this.getCoachesUseCase,
    required this.getPTOffersUseCase,
    required this.getGroupClassesUseCase,
    required this.buyPTPackageUseCase,
    required this.schedulePTSessionUseCase,
    required this.watchUserBookingsUseCase,
    required this.watchUserPTWalletUseCase,
    required this.watchCoachAvailabilityUseCase,
    required this.bookSessionUseCase,
  }) : super(BookingInitial());

  Future<void> loadBookingData(int persId) async {
    emit(BookingLoading());
    try {
      _coaches = await getCoachesUseCase();
      _offers = await getPTOffersUseCase();
      _classes = await getGroupClassesUseCase(null);

      await _bookingsSub?.cancel();
      _bookingsSub = watchUserBookingsUseCase(persId).listen((bookings) {
        _userBookings = bookings;
        _emitLoaded();
      });

      await _walletSub?.cancel();
      _walletSub = watchUserPTWalletUseCase(persId).listen((wallets) {
        _wallets = wallets;
        _emitLoaded();
      });
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  void _emitLoaded() {
    emit(BookingLoaded(
      coaches: _coaches,
      groupClasses: _classes,
      ptOffers: _offers,
      userWallets: _wallets,
      userBookings: _userBookings,
    ));
  }

  Stream<List<String>> getCoachAvailability(String coachId, String date) {
    return watchCoachAvailabilityUseCase(WatchCoachAvailabilityParams(coachId: coachId, date: date));
  }

  Future<void> buyPackage(int persId, String coachId, int sessions) async {
    try {
      await buyPTPackageUseCase(BuyPTPackageParams(persId: persId, coachId: coachId, sessions: sessions));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> scheduleSession(int persId, String coachId, String date, String time) async {
    try {
      await schedulePTSessionUseCase(SchedulePTSessionParams(persId: persId, coachId: coachId, date: date, time: time));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> bookGroupClass(int persId, String classId) async {
    try {
      await bookSessionUseCase(BookSessionParams(persId: persId, sessionId: classId));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _bookingsSub?.cancel();
    _walletSub?.cancel();
    return super.close();
  }

  void reset() {
    emit(BookingInitial());
    _bookingsSub?.cancel();
    _walletSub?.cancel();
    _coaches = [];
    _classes = [];
    _offers = [];
    _wallets = [];
    _userBookings = [];
  }
}
