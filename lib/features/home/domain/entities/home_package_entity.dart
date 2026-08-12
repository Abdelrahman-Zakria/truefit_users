import 'package:equatable/equatable.dart';

class HomePackageEntity extends Equatable {
  final String id;
  final Map<String, String> name;
  final double price;
  final bool popular;
  final Map<String, List<String>> features;

  const HomePackageEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.popular,
    required this.features,
  });

  @override
  List<Object?> get props => [id, name, price, popular, features];
}
