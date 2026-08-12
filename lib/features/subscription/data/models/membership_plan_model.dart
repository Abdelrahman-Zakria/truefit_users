import '../../domain/entities/membership_plan_entity.dart';

class MembershipPlanModel extends MembershipPlanEntity {
  const MembershipPlanModel({
    required super.id,
    required super.name,
    required super.price,
    super.originalPrice,
    required super.features,
    required super.isPopular,
  });

  factory MembershipPlanModel.fromJson(Map<String, dynamic> json) {
    Map<String, String> localizedName = {};
    if (json['name'] is Map) {
      localizedName = Map<String, String>.from(json['name']);
    } else {
      String name = json['Subscription_type_name'] ?? json['name'] ?? 'Unknown';
      localizedName = {'en': name, 'ar': name};
    }

    Map<String, List<String>> localizedFeatures = {};
    if (json['features'] is Map) {
      localizedFeatures = (json['features'] as Map).map(
        (key, value) => MapEntry(key.toString(), List<String>.from(value)),
      );
    } else {
      List<String> features = json['features'] != null ? List<String>.from(json['features']) : [];
      localizedFeatures = {'en': features, 'ar': features};
    }

    return MembershipPlanModel(
      id: (json['Subscription_type_id'] ?? json['id'] ?? '').toString(),
      name: localizedName,
      price: (json['price'] ?? json['Subscription_type_value'] ?? 0).toString(),
      originalPrice: json['originalPrice']?.toString(),
      features: localizedFeatures,
      isPopular: json['isPopular'] ?? false,
    );
  }
}
