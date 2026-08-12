import 'package:equatable/equatable.dart';

class PTOfferEntity extends Equatable {
  final String id;
  final int sessions;
  final double price;

  const PTOfferEntity({
    required this.id,
    required this.sessions,
    required this.price,
  });

  @override
  List<Object?> get props => [id, sessions, price];
}
