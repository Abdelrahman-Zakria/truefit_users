import '../../domain/entities/user_entity.dart';
import 'user_box_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.persId,
    super.email,
    super.displayName,
    super.nameAr,
    super.nameEn,
    super.phone,
    super.address,
    super.plan,
    super.memberSince,
    super.birthday,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? json['pers_ID']?.toString() ?? '',
      persId: json['persId'] ?? json['pers_ID'],
      email: json['email'] ?? json['E_mail'],
      displayName: json['displayName'] ?? json['pers_NAME_EN'] ?? json['pers_NAME_AR'],
      nameAr: json['nameAr'] ?? json['pers_NAME_AR'],
      nameEn: json['nameEn'] ?? json['pers_NAME_EN'],
      phone: json['phone'] ?? json['Tel_Mobile1'],
      address: json['address'] ?? json['ADDRESS'],
      plan: json['plan'],
      memberSince: json['memberSince'] ?? json['LogTime'],
      birthday: json['birthday'] ?? json['DATE_BIRTH'],
    );
  }

  factory UserModel.fromBox(UserBoxEntity box) {
    return UserModel(
      uid: box.uid,
      persId: box.persId,
      email: box.email,
      nameAr: box.nameAr,
      nameEn: box.nameEn,
      phone: box.phone,
      address: box.address,
      plan: box.plan,
      memberSince: box.memberSince,
      birthday: box.birthday,
    );
  }

  UserBoxEntity toBox() {
    return UserBoxEntity(
      uid: uid,
      persId: persId,
      email: email,
      nameAr: nameAr,
      nameEn: nameEn,
      phone: phone,
      address: address,
      plan: plan,
      memberSince: memberSince,
      birthday: birthday,
    );
  }
}
