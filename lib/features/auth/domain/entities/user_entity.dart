import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final int? persId;
  final String? email;
  final String? displayName;
  final String? nameAr;
  final String? nameEn;
  final String? phone;
  final String? address;
  final String? plan;
  final String? memberSince;
  final String? birthday;

  const UserEntity({
    required this.uid,
    this.persId,
    this.email,
    this.displayName,
    this.nameAr,
    this.nameEn,
    this.phone,
    this.address,
    this.plan,
    this.memberSince,
    this.birthday,
  });

  @override
  List<Object?> get props => [
        uid,
        persId,
        email,
        displayName,
        nameAr,
        nameEn,
        phone,
        address,
        plan,
        memberSince,
        birthday,
      ];
}
