import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.uid,
    super.email,
    super.displayName,
    super.nameAr,
    super.nameEn,
    super.phone,
    super.address,
    super.birthday,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      nameAr: json['nameAr'],
      nameEn: json['nameEn'],
      phone: json['phone'],
      address: json['address'],
      birthday: json['birthday'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'phone': phone,
      'address': address,
      'birthday': birthday,
    };
  }

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      phone: entity.phone,
      address: entity.address,
      birthday: entity.birthday,
    );
  }
}
