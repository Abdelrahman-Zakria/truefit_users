import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeeder {
  static Future<void> seedHomeData() async {
    final firestore = FirebaseFirestore.instance;

    // 1. Promotions (Banners) - Supports both text and images
    final promotions = [
      {
        "id": "b1",
        "bgColors": [0xFFDC143C, 0xFFA00F2C, 0xFF6B0018],
        "tag": "summerTag",
        "title": {
          "en": "Summer Body Challenge",
          "ar": "تحدي جسم الصيف"
        },
        "description": {
          "en": "8-week transformation program. Join now.",
          "ar": "برنامج تحول لمدة 8 أسابيع. انضم الآن."
        },
        "cta": {
          "en": "joinNow",
          "ar": "انضم الآن"
        },
        "badge": "🔥",
        "targetRoute": "/booking",
        "imageUrl": null, // Optional image
      },
      {
        "id": "b2",
        "bgColors": [0xFF1E1B4B, 0xFF312E81, 0xFF4338CA],
        "tag": "newFacilityTag",
        "title": {
          "en": "Spa & Recovery Zone Open",
          "ar": "افتتاح منطقة السبا والاستشفاء"
        },
        "description": {
          "en": "Ice baths · Sauna · Deep-tissue massage",
          "ar": "حمامات ثلج · ساونا · تدليك للأنسجة العميقة"
        },
        "cta": {
          "en": "explore",
          "ar": "استكشف"
        },
        "badge": "💆",
        "imageUrl": "https://images.unsplash.com/photo-1544161515-4ab6ce6db874?q=80\u0026w=1000", // Fixed image URL
      },
      {
        "id": "b3",
        "bgColors": [0xFF064E3B, 0xFF065F46, 0xFF047857],
        "tag": "nutritionTag",
        "title": {
          "en": "Free Nutrition Consultation",
          "ar": "استشارة تغذية مجانية"
        },
        "description": {
          "en": "Book your session with our certified dietitian.",
          "ar": "احجز جلستك مع أخصائي التغذية المعتمد لدينا."
        },
        "cta": {
          "en": "bookFree",
          "ar": "احجز مجاناً"
        },
        "badge": "🥗",
        "targetRoute": "/diet",
        "imageUrl": null,
      },
    ];

    for (var p in promotions) {
      await firestore.collection('promotions').doc(p['id'] as String).set(p);
    }

    // 2. Outdoor Sessions
    final outdoorSessions = [
      {
        "id": "os1",
        "title": {"en": "Morning Beach Yoga", "ar": "يوغا الشاطئ الصباحية"},
        "instructor": {"en": "Emily Rodriguez", "ar": "إيميلي رودريغيز"},
        "location": {"en": "Cairo Corniche", "ar": "كورنيش القاهرة"},
        "date": "Fri, Jul 11",
        "time": "7:00 AM",
        "duration": "60 min",
        "spots": 8,
        "totalSpots": 15,
        "price": 150,
        "about": {
          "en": "Start your Friday morning with an energising beach yoga session. Suitable for all levels. Bring your mat and water.",
          "ar": "ابدأ صباح جمعتك بجلسة يوغا منعشة. مناسبة لجميع المستويات. أحضر حصيرتك وماءك."
        },
      },
      {
        "id": "os2",
        "title": {"en": "Park HIIT Circuit", "ar": "تمرين HIIT في الحديقة"},
        "instructor": {"en": "Marcus Chen", "ar": "ماركوس تشن"},
        "location": {"en": "Al-Azhar Park", "ar": "حديقة الأزهر"},
        "date": "Sat, Jul 12",
        "time": "6:30 AM",
        "duration": "45 min",
        "spots": 3,
        "totalSpots": 12,
        "price": 200,
        "about": {
          "en": "High-intensity interval training in the fresh air of Al-Azhar park. No equipment needed — just your energy.",
          "ar": "تمرين عالي الكثافة في الهواء الطلق بحديقة الأزهر. لا تحتاج معدات — فقط طاقتك."
        },
      },
    ];

    for (var s in outdoorSessions) {
      await firestore.collection('outdoor_sessions').doc(s['id'] as String).set(s);
    }

    // 3. Offers
    final offers = [
      {
        "id": "of1",
        "tag": {"en": "SUMMER SPECIAL", "ar": "عرض الصيف"},
        "title": {"en": "20% Off PT Sessions", "ar": "خصم 20% على جلسات التدريب"},
        "description": {"en": "Book 5 sessions and save big on personal training.", "ar": "احجز 5 جلسات ووفر الكثير على التدريب الشخصي."},
        "validUntil": "Jul 31, 2026",
        "detail": {
          "en": "Book any 5 PT sessions within the same month and automatically receive a 20% discount on the total package price.",
          "ar": "احجز 5 جلسات تدريب شخصي خلال نفس الشهر واحصل تلقائياً على خصم 20%."
        },
        "accentColor": "#dc143c",
      },
    ];

    for (var o in offers) {
      await firestore.collection('home_offers').doc(o['id'] as String).set(o);
    }

    await seedSubscriptionData();
    await seedBookingData();
    await seedGroupClasses();
    
    print('--- Home Data Seeded Successfully ---');
  }

  static Future<void> seedBookingData() async {
    final firestore = FirebaseFirestore.instance;

    // 1. Coaches
    final coaches = [
      {
        "id": "coach1",
        "name": "Omar Mizo",
        "specialty": {"en": "Bodybuilding & Strength", "ar": "كمال الأجسام والقوة"},
        "rating": 5,
        "image": null,
        "bio": {"en": "Certified trainer with 5 years experience.", "ar": "مدرب معتمد بخبرة 10 سنوات."}
      },
      {
        "id": "coach2",
        "name": "Mostafa Mohamed",
        "specialty": {"en": "Yoga & Flexibility", "ar": "اليوغا والمرونة"},
        "rating": 4.8,
        "image": null,
        "bio": {"en": "Expert in Hatha and Vinyasa Yoga.", "ar": "خبيرة في يوغا الهاثا وفينياسا."}
      }
    ];

    for (var coach in coaches) {
      await firestore.collection('Gym_Coaches').doc(coach['id'] as String).set(coach);
    }

    // 2. PT Offers
    final ptOffers = [
      {"id": "pt8", "sessions": 8, "price": 800},
      {"id": "pt12", "sessions": 12, "price": 1000},
      {"id": "pt18", "sessions": 18, "price": 1500}
    ];

    for (var offer in ptOffers) {
      await firestore.collection('Gym_PT_Offers').doc(offer['id'] as String).set(offer);
    }

    // 3. Coach Schedules (Sample)
    final schedule = {
      "coach_id": "coach1",
      "date": "2026-07-21",
      "available_slots": ["7:00 AM", "9:00 AM", "11:00 AM", "3:00 PM", "5:00 PM"]
    };
    await firestore.collection('Coach_Schedules').add(schedule);
    
    print('--- Booking Data Seeded Successfully ---');
  }

  static Future<void> seedSubscriptionData() async {
    // ... existing code ...
  }

  static Future<void> seedGroupClasses() async {
    final firestore = FirebaseFirestore.instance;

    final groupClasses = [
      {
        "class_id": "gc_1",
        "name": {
          "en": "Morning HIIT",
          "ar": "هايت الصباح"
        },
        "coach_id": "coach1",
        "coach_name": {
          "en": "Omar Mizo",
          "ar": "عمر ميزو"
        },
        "time": "7:00 AM",
        "date": "Every Monday",
        "capacity": 20,
        "booked": 15,
        "studio": "Studio A",
        "category": "HIIT",
        "duration": "45 min"
      },
      {
        "class_id": "gc_2",
        "name": {
          "en": "Yoga Flow",
          "ar": "يوغا الاسترخاء"
        },
        "coach_id": "coach2",
        "coach_name": {
          "en": "Mostafa Mohamed",
          "ar": "مصطفى محمد"
        },
        "time": "6:00 PM",
        "date": "Every Wednesday",
        "capacity": 15,
        "booked": 12,
        "studio": "Zen Zone",
        "category": "Yoga",
        "duration": "60 min"
      }
    ];

    for (var gc in groupClasses) {
      await firestore.collection('Gym_Group_Classes').doc(gc['class_id'] as String).set(gc);
    }

    print('--- Group Classes Seeded Successfully ---');
  }
}
