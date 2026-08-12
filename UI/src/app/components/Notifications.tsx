import { useState } from "react";
import { Check, Dumbbell, CreditCard, Tag, Calendar, Bell, ChevronLeft } from "lucide-react";
import { useNavigate } from "react-router";
import { useLang } from "../../lib/LanguageContext";

interface Notification {
  id: string;
  type: "booking" | "payment" | "offer" | "system" | "class";
  title: { en: string; ar: string };
  body: { en: string; ar: string };
  time: string;
  read: boolean;
  today: boolean;
}

const INITIAL_NOTIFS: Notification[] = [
  {
    id: "n1", type: "booking", read: false, today: true, time: "9:42 AM",
    title: { en: "Session Confirmed", ar: "تم تأكيد الجلسة" },
    body: { en: "Your PT session with Sarah Mitchell is confirmed for Wed, Jul 16 at 10:00 AM.", ar: "تم تأكيد جلسة التدريب مع سارة ميتشيل ليوم الأربعاء 16 يوليو الساعة 10 صباحاً." },
  },
  {
    id: "n2", type: "offer", read: false, today: true, time: "8:15 AM",
    title: { en: "New Offer Available", ar: "عرض جديد متاح" },
    body: { en: "Summer special: 20% off all PT sessions this week only. Tap to claim.", ar: "عرض الصيف: خصم 20% على جميع جلسات التدريب هذا الأسبوع فقط. اضغط للمطالبة." },
  },
  {
    id: "n3", type: "class", read: false, today: true, time: "7:00 AM",
    title: { en: "Class Reminder", ar: "تذكير بالفصل" },
    body: { en: "Morning HIIT starts in 30 minutes — Studio A. Don't forget your water bottle!", ar: "يبدأ HIIT الصباحي خلال 30 دقيقة — الاستوديو A. لا تنسَ زجاجة الماء!" },
  },
  {
    id: "n4", type: "payment", read: true, today: false, time: "Yesterday",
    title: { en: "Payment Successful", ar: "تمت عملية الدفع" },
    body: { en: "Your monthly subscription (Premium Elite) has been renewed. 2,999 LE charged to Visa •••• 4242.", ar: "تم تجديد اشتراكك الشهري (بريميوم إيليت). تم خصم 2,999 جنيه من فيزا •••• 4242." },
  },
  {
    id: "n5", type: "system", read: true, today: false, time: "Yesterday",
    title: { en: "InBody Scan Ready", ar: "نتائج InBody جاهزة" },
    body: { en: "Your monthly InBody scan results are ready. Check your Progress tab to view the full report.", ar: "نتائج فحص InBody الشهري جاهزة. تحقق من تبويب التقدم لعرض التقرير الكامل." },
  },
  {
    id: "n6", type: "booking", read: true, today: false, time: "Mon",
    title: { en: "Booking Cancelled", ar: "تم إلغاء الحجز" },
    body: { en: "Your Power Yoga class on Tue, Jul 2 was cancelled by the instructor. A new session has been scheduled.", ar: "تم إلغاء فصل يوغا الطاقة يوم الثلاثاء 2 يوليو من قبل المدرب. تم جدولة جلسة جديدة." },
  },
  {
    id: "n7", type: "offer", read: true, today: false, time: "Sun",
    title: { en: "Refer a Friend Bonus", ar: "مكافأة إحالة الصديق" },
    body: { en: "You earned a free month! Your friend Ahmed just signed up using your referral link.", ar: "حصلت على شهر مجاني! انضم صديقك أحمد باستخدام رابط إحالتك." },
  },
];

const TYPE_ICONS: Record<Notification["type"], JSX.Element> = {
  booking: <Calendar className="w-5 h-5 text-[#dc143c]" />,
  payment: <CreditCard className="w-5 h-5 text-green-400" />,
  offer: <Tag className="w-5 h-5 text-yellow-400" />,
  system: <Dumbbell className="w-5 h-5 text-purple-400" />,
  class: <Dumbbell className="w-5 h-5 text-blue-400" />,
};

const TYPE_BG: Record<Notification["type"], string> = {
  booking: "bg-[#dc143c]/20",
  payment: "bg-green-500/20",
  offer: "bg-yellow-500/20",
  system: "bg-purple-500/20",
  class: "bg-blue-500/20",
};

export function Notifications() {
  const { tr, lang, dir } = useLang();
  const navigate = useNavigate();
  const [notifs, setNotifs] = useState(INITIAL_NOTIFS);

  const markAllRead = () => setNotifs((prev) => prev.map((n) => ({ ...n, read: true })));
  const markRead = (id: string) => setNotifs((prev) => prev.map((n) => n.id === id ? { ...n, read: true } : n));

  const todayItems = notifs.filter((n) => n.today);
  const earlierItems = notifs.filter((n) => !n.today);
  const unreadCount = notifs.filter((n) => !n.read).length;

  return (
    <div dir={dir} className="pb-8">
      {/* Header */}
      <div className="sticky top-0 bg-[#0a0a0a] z-10 px-5 pt-5 pb-4 border-b border-[#1a1a1a]">
        <div className="flex items-center gap-3 mb-3">
          <button onClick={() => navigate(-1)}
            className="w-9 h-9 rounded-xl bg-[#1a1a1a] border border-[#2a2a2a] flex items-center justify-center hover:border-[#dc143c]/40 transition-colors">
            <ChevronLeft className="w-5 h-5 text-gray-400 rtl:rotate-180" />
          </button>
          <h2 className="text-xl text-white font-semibold flex-1">{tr("notifications")}</h2>
          {unreadCount > 0 && (
            <span className="text-xs bg-[#dc143c] text-white px-2 py-0.5 rounded-full">{unreadCount}</span>
          )}
        </div>
        {unreadCount > 0 && (
          <button onClick={markAllRead} className="text-xs text-[#dc143c] hover:underline font-medium">
            {tr("markAllRead")}
          </button>
        )}
      </div>

      {notifs.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 gap-4">
          <div className="w-16 h-16 rounded-full bg-[#1a1a1a] flex items-center justify-center">
            <Bell className="w-7 h-7 text-gray-600" />
          </div>
          <p className="text-white font-medium">{tr("noNotifications")}</p>
          <p className="text-gray-500 text-sm">{tr("noNotificationsSub")}</p>
        </div>
      ) : (
        <div>
          {todayItems.length > 0 && (
            <div>
              <p className="text-xs text-gray-500 uppercase tracking-widest px-5 pt-5 pb-2">{tr("today")}</p>
              <div className="space-y-px">
                {todayItems.map((n) => (
                  <button key={n.id} onClick={() => markRead(n.id)}
                    className={`w-full text-start flex items-start gap-3 px-5 py-4 hover:bg-[#1a1a1a] transition-colors ${!n.read ? "bg-[#dc143c]/5" : ""}`}>
                    <div className={`w-10 h-10 rounded-xl ${TYPE_BG[n.type]} flex items-center justify-center flex-shrink-0 mt-0.5`}>
                      {TYPE_ICONS[n.type]}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-2 mb-0.5">
                        <p className={`text-sm font-medium truncate ${!n.read ? "text-white" : "text-gray-300"}`}>{n.title[lang]}</p>
                        <span className="text-xs text-gray-500 flex-shrink-0">{n.time}</span>
                      </div>
                      <p className="text-xs text-gray-400 leading-relaxed line-clamp-2">{n.body[lang]}</p>
                    </div>
                    {!n.read && <div className="w-2 h-2 rounded-full bg-[#dc143c] mt-2 flex-shrink-0" />}
                  </button>
                ))}
              </div>
            </div>
          )}

          {earlierItems.length > 0 && (
            <div>
              <p className="text-xs text-gray-500 uppercase tracking-widest px-5 pt-5 pb-2">{tr("earlier")}</p>
              <div className="space-y-px">
                {earlierItems.map((n) => (
                  <button key={n.id} onClick={() => markRead(n.id)}
                    className="w-full text-start flex items-start gap-3 px-5 py-4 hover:bg-[#1a1a1a] transition-colors">
                    <div className={`w-10 h-10 rounded-xl ${TYPE_BG[n.type]} flex items-center justify-center flex-shrink-0 mt-0.5`}>
                      {TYPE_ICONS[n.type]}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-2 mb-0.5">
                        <p className="text-sm text-gray-400 truncate">{n.title[lang]}</p>
                        <span className="text-xs text-gray-600 flex-shrink-0">{n.time}</span>
                      </div>
                      <p className="text-xs text-gray-500 leading-relaxed line-clamp-2">{n.body[lang]}</p>
                    </div>
                    {!n.read && <div className="w-2 h-2 rounded-full bg-[#dc143c] mt-2 flex-shrink-0" />}
                  </button>
                ))}
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
