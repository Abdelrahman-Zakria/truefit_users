import 'package:equatable/equatable.dart';
import '../../domain/entities/group_class_entity.dart';
import '../../domain/entities/coach_entity.dart';
import '../../domain/entities/pt_offer_entity.dart';
import '../../domain/entities/pt_wallet_entity.dart';

abstract class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}
class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<CoachEntity> coaches;
  final List<GroupClassEntity> groupClasses;
  final List<PTOfferEntity> ptOffers;
  final List<PTWalletEntity> userWallets;
  final List<Map<String, dynamic>> userBookings;

  const BookingLoaded({
    required this.coaches,
    required this.groupClasses,
    required this.ptOffers,
    required this.userWallets,
    required this.userBookings,
  });

  @override
  List<Object?> get props => [coaches, groupClasses, ptOffers, userWallets, userBookings];
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);
  @override
  List<Object?> get props => [message];
}

class BookingSuccess extends BookingState {}
