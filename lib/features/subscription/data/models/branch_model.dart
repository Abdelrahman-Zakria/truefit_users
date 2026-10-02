import '../../domain/entities/branch_entity.dart';

class BranchModel extends BranchEntity {
  const BranchModel({
    required super.id,
    required super.name,
    required super.displayName,
    required super.address,
    super.isActive = true,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json, String docId) {
    return BranchModel(
      id: docId,
      name: json['name'] ?? 'Unknown',
      displayName: json['display_name'] ?? json['name'] ?? json['name_ar'] ?? json['name_en'] ?? 'Gym Branch',
      address: json['address'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}
