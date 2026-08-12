import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? nameAr;
  final String? nameEn;
  final String? phone;
  final String? address;
  final String? birthday;

  const ProfileEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.nameAr,
    this.nameEn,
    this.phone,
    this.address,
    this.birthday,
  });

  @override
  List<Object?> get props => [uid, email, displayName, nameAr, nameEn, phone, address, birthday];
}
