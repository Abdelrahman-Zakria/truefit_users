import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.body,
    required super.time,
    required super.read,
    required super.today,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: NotificationType.values.firstWhere((e) => e.name == json['type']),
      title: Map<String, String>.from(json['title']),
      body: Map<String, String>.from(json['body']),
      time: json['time'],
      read: json['read'],
      today: json['today'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'body': body,
      'time': time,
      'read': read,
      'today': today,
    };
  }
}

final List<NotificationModel> INITIAL_NOTIFS_MODELS = [
  NotificationModel(
    id: "n1", type: NotificationType.booking, read: false, today: true, time: "9:42 AM",
    title: { "en": "Session Confirmed", "ar": "تم تأكيد الجلسة" },
    body: { "en": "Your PT session with Sarah Mitchell is confirmed for Wed, Jul 16 at 10:00 AM.", "ar": "تم تأكيد جلسة التدريب مع سارة ميتشيل ليوم الأربعاء 16 يوليو الساعة 10 صباحاً." },
  ),
  NotificationModel(
    id: "n2", type: NotificationType.offer, read: false, today: true, time: "8:15 AM",
    title: { "en": "New Offer Available", "ar": "عرض جديد متاح" },
    body: { "en": "Summer special: 20% off all PT sessions this week only. Tap to claim.", "ar": "عرض الصيف: خصم 20% على جميع جلسات التدريب هذا الأسبوع فقط. اضغط للمطالبة." },
  ),
  NotificationModel(
    id: "n3", type: NotificationType.fitnessClass, read: false, today: true, time: "7:00 AM",
    title: { "en": "Class Reminder", "ar": "تذكير بالفصل" },
    body: { "en": "Morning HIIT starts in 30 minutes — Studio A. Don't forget your water bottle!", "ar": "يبدأ HIIT الصباحي خلال 30 دقيقة — الاستوديو A. لا تنسَ زجاجة الماء!" },
  ),
  NotificationModel(
    id: "n4", type: NotificationType.payment, read: true, today: false, time: "Yesterday",
    title: { "en": "Payment Successful", "ar": "تمت عملية الدفع" },
    body: { "en": "Your monthly subscription (Premium Elite) has been renewed. 2,999 LE charged to Visa •••• 4242.", "ar": "تم تجديد اشتراكك الشهري (بريميوم إيليت). تم خصم 2,999 جنيه من فيزا •••• 4242." },
  ),
  NotificationModel(
    id: "n5", type: NotificationType.system, read: true, today: false, time: "Yesterday",
    title: { "en": "InBody Scan Ready", "ar": "نتائج InBody جاهزة" },
    body: { "en": "Your monthly InBody scan results are ready. Check your Progress tab to view the full report.", "ar": "نتائج فحص InBody الشهري جاهزة. تحقق من تبويب التقدم لعرض التقرير الكامل." },
  ),
  NotificationModel(
    id: "n6", type: NotificationType.booking, read: true, today: false, time: "Mon",
    title: { "en": "Booking Cancelled", "ar": "تم إلغاء الحجز" },
    body: { "en": "Your Power Yoga class on Tue, Jul 2 was cancelled by the instructor. A new session has been scheduled.", "ar": "تم إلغاء فصل يوغا الطاقة يوم الثلاثاء 2 يوليو من قبل المدرب. تم جدولة جلسة جديدة." },
  ),
  NotificationModel(
    id: "n7", type: NotificationType.offer, read: true, today: false, time: "Sun",
    title: { "en": "Refer a Friend Bonus", "ar": "مكافأة إحالة الصديق" },
    body: { "en": "You earned a free month! Your friend Ahmed just signed up using your referral link.", "ar": "حصلت على شهر مجاني! انضم صديقك أحمد باستخدام رابط إحالتك." },
  ),
];
