import 'package:objectbox/objectbox.dart';

@Entity()
class UserBoxEntity {
  @Id()
  int id = 0;

  @Unique()
  String uid;
  
  int? persId;
  String? email;
  String? nameAr;
  String? nameEn;
  String? phone;
  String? address;
  String? plan;
  String? memberSince;
  String? birthday;

  UserBoxEntity({
    required this.uid,
    this.persId,
    this.email,
    this.nameAr,
    this.nameEn,
    this.phone,
    this.address,
    this.plan,
    this.memberSince,
    this.birthday,
  });
}
