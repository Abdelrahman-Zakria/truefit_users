import 'package:equatable/equatable.dart';

class HomeOfferEntity extends Equatable {
  final String id;
  final Map<String, String> tag;
  final Map<String, String> title;
  final Map<String, String> description;
  final String validUntil;
  final Map<String, String> detail;
  final String accentColor;

  const HomeOfferEntity({
    required this.id,
    required this.tag,
    required this.title,
    required this.description,
    required this.validUntil,
    required this.detail,
    required this.accentColor,
  });

  @override
  List<Object?> get props => [id, tag, title, description, validUntil, detail, accentColor];
}
