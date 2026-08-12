import '../../domain/entities/home_package_entity.dart';

class HomePackageModel extends HomePackageEntity {
  const HomePackageModel({
    required super.id,
    required super.name,
    required super.price,
    required super.popular,
    required super.features,
  });

  factory HomePackageModel.fromJson(Map<String, dynamic> json) {
    return HomePackageModel(
      id: json['id'] ?? '',
      name: Map<String, String>.from(json['name'] ?? {}),
      price: (json['price'] as num? ?? 0).toDouble(),
      popular: json['isPopular'] ?? json['popular'] ?? false,
      features: (json['features'] as Map? ?? {}).map((k, v) => MapEntry(k as String, List<String>.from(v))),
    );
  }
}
