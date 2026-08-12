import '../../domain/entities/pt_offer_entity.dart';

class PTOfferModel extends PTOfferEntity {
  const PTOfferModel({
    required super.id,
    required super.sessions,
    required super.price,
  });

  factory PTOfferModel.fromJson(Map<String, dynamic> json, String docId) {
    return PTOfferModel(
      id: docId,
      sessions: json['sessions'] ?? 0,
      price: (json['price'] as num? ?? 0).toDouble(),
    );
  }
}
