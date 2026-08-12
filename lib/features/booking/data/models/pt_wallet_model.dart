import '../../domain/entities/pt_wallet_entity.dart';

class PTWalletModel extends PTWalletEntity {
  const PTWalletModel({
    required super.persId,
    required super.coachId,
    required super.total,
    required super.sessionsLeft,
  });

  factory PTWalletModel.fromJson(Map<String, dynamic> json) {
    return PTWalletModel(
      persId: json['pers_ID'] ?? 0,
      coachId: json['coach_id'] ?? '',
      total: json['total'] ?? 0,
      sessionsLeft: json['sessions_left'] ?? 0,
    );
  }
}
