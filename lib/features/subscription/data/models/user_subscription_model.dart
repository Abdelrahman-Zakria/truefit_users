class UserSubscriptionModel {
  final int smid;
  final int persId;
  final int planId;
  final String fromDate;
  final String toDate;
  final int status;

  UserSubscriptionModel({
    required this.smid,
    required this.persId,
    required this.planId,
    required this.fromDate,
    required this.toDate,
    required this.status,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      smid: json['smid'] ?? 0,
      persId: json['pers_ID'] ?? 0,
      planId: json['Subscription_type_pers_ID'] ?? 0,
      fromDate: json['Subscription_pers_from'] ?? '',
      toDate: json['Subscription_pers_to'] ?? '',
      status: json['Subscription_pers_stat'] ?? 0,
    );
  }
}
