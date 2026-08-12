import 'package:equatable/equatable.dart';

class MembershipPlanEntity extends Equatable {
  final String id;
  final Map<String, String> name;
  final String price;
  final String? originalPrice;
  final Map<String, List<String>> features;
  final bool isPopular;

  const MembershipPlanEntity({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.features,
    required this.isPopular,
  });

  @override
  List<Object?> get props => [id, name, price, originalPrice, features, isPopular];
}
