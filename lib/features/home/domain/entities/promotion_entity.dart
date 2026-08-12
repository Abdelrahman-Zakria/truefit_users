import 'package:equatable/equatable.dart';

class PromotionEntity extends Equatable {
  final String id;
  final String tag;
  final Map<String, String> title;
  final Map<String, String> description;
  final Map<String, String> cta;
  final String badge;
  final List<int> bgColors;
  final String? targetRoute;
  final String? imageUrl;

  const PromotionEntity({
    required this.id,
    required this.tag,
    required this.title,
    required this.description,
    required this.cta,
    required this.badge,
    required this.bgColors,
    this.targetRoute,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, tag, title, description, cta, badge, bgColors, targetRoute, imageUrl];
}
