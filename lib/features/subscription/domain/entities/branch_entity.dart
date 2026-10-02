import 'package:equatable/equatable.dart';

class BranchEntity extends Equatable {
  final String id;
  final String name;
  final String displayName;
  final String address;
  final bool isActive;

  const BranchEntity({
    required this.id,
    required this.name,
    required this.displayName,
    required this.address,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, displayName, address, isActive];
}
