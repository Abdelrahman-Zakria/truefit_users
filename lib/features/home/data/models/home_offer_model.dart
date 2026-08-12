import '../../domain/entities/home_offer_entity.dart';

class HomeOfferModel extends HomeOfferEntity {
  const HomeOfferModel({
    required super.id,
    required super.tag,
    required super.title,
    required super.description,
    required super.validUntil,
    required super.detail,
    required super.accentColor,
  });

  factory HomeOfferModel.fromJson(Map<String, dynamic> json) {
    return HomeOfferModel(
      id: json['id'] ?? '',
      tag: Map<String, String>.from(json['tag'] ?? {}),
      title: Map<String, String>.from(json['title'] ?? {}),
      description: Map<String, String>.from(json['description'] ?? {}),
      validUntil: json['validUntil'] ?? '',
      detail: Map<String, String>.from(json['detail'] ?? {}),
      accentColor: json['accentColor'] ?? '#DC143C',
    );
  }
}
