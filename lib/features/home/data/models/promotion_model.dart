import '../../domain/entities/promotion_entity.dart';

class PromotionModel extends PromotionEntity {
  const PromotionModel({
    required super.id,
    required super.tag,
    required super.title,
    required super.description,
    required super.cta,
    required super.badge,
    required super.bgColors,
    super.targetRoute,
    super.imageUrl,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'] ?? '',
      tag: json['tag'] ?? '',
      title: Map<String, String>.from(json['title'] ?? {}),
      description: Map<String, String>.from(json['description'] ?? {}),
      cta: Map<String, String>.from(json['cta'] ?? {}),
      badge: json['badge'] ?? '',
      bgColors: (json['bgColors'] as List? ?? []).map((c) => (c as num).toInt()).toList(),
      targetRoute: json['targetRoute'],
      imageUrl: json['imageUrl'],
    );
  }
}
