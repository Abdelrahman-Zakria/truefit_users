import { useState, useEffect, useRef } from "react";
import {
  QrCode, Dumbbell, Users, Clock, Calendar, MapPin, X,
  Check, Star, Lock, ArrowRight, Tag, ChevronLeft, ChevronRight,
  Flame, TrendingUp, Bell, User,
} from "lucide-react";
import { useNavigate } from "react-router";
import { useAuth } from "../../lib/AuthContext";
import { useLang } from "../../lib/LanguageContext";
import { useAppContext } from "../../lib/AppContext";
import logo from "../../imports/logo-only.jpeg";

// ─── Ad Banners ───────────────────────────────────────────────────────────────

const AD_BANNERS = [
  {
    id: "b1",
    bg: "from-[#dc143c] via-[#a00f2c] to-[#6b0018]",
    tag:   { en: "LIMITED OFFER", ar: "عرض محدود" },
    title: { en: "Summer Body\nChallenge", ar: "تحدي جسم\nالصيف" },
    sub:   { en: "8-week transformation program. Join now.", ar: "برنامج تحول 8 أسابيع. انضم الآن." },
    cta:   { en: "Join Now", ar: "انضم الآن" },
    badge: "🔥",
  },
  {
    id: "b2",
    bg: "from-[#1e1b4b] via-[#312e81] to-[#4338ca]",
    tag:   { en: "NEW FACILITY", ar: "منشأة جديدة" },
    title: { en: "Spa & Recovery\nZone Open", ar: "منطقة السبا\nوالتعافي" },
    sub:   { en: "Ice baths · Sauna · Deep-tissue massage", ar: "حمامات الثلج · الساونا · تدليك عميق" },
    cta:   { en: "Explore", ar: "استكشف" },
    badge: "💆",
  },
  {
    id: "b3",
    bg: "from-[#064e3b] via-[#065f46] to-[#047857]",
    tag:   { en: "NUTRITION", ar: "تغذية" },
    title: { en: "Free Nutrition\nConsultation", ar: "استشارة تغذية\nمجانية" },
    sub:   { en: "Book your session with our certified dietitian.", ar: "احجز جلستك مع أخصائي التغذية المعتمد." },
    cta:   { en: "Book Free", ar: "احجز مجاناً" },
    badge: "🥗",
  },
  {
    id: "b4",
    bg: "from-[#78350f] via-[#92400e] to-[#b45309]",
    tag:   { en: "MEMBERS ONLY", ar: "للأعضاء فقط" },
    title: { en: "10 PT Sessions\nBundle Deal", ar: "حزمة 10 جلسات\nتدريب شخصي" },
    sub:   { en: "Save 25% when you book 10 sessions upfront.", ar: "وفر 25% عند حجز 10 جلسات مسبقاً." },
    cta:   { en: "Get Bundle", ar: "احصل على الحزمة" },
    badge: "💪",
  },
  {
    id: "b5",
    bg: "from-[#1e3a5f] via-[#1e40af] to-[#2563eb]",
    tag:   { en: "CHALLENGE", ar: "تحدي" },
    title: { en: "30-Day Plank\nChallenge", ar: "تحدي البلانك\n30 يوماً" },
    sub:   { en: "Track progress daily. Top finishers win prizes.", ar: "تابع تقدمك يومياً. الفائزون يحصلون على جوائز." },
    cta:   { en: "Join Challenge", ar: "انضم للتحدي" },
    badge: "🏆",
  },
];

// ─── Banner Carousel ──────────────────────────────────────────────────────────

function BannerCarousel() {
  const { lang } = useLang();
  const navigate = useNavigate();
  const { mode } = useAuth();
  const { triggerRegistration } = useAppContext();
  const [active, setActive] = useState(0);
  const [paused, setPaused] = useState(false);
  const touchStartX = useRef(0);
  const total = AD_BANNERS.length;

  useEffect(() => {
    if (paused) return;
    const t = setInterval(() => setActive((i) => (i + 1) % total), 4000);
    return () => clearInterval(t);
  }, [paused, total]);

  const prev = () => { setPaused(true); setActive((i) => (i - 1 + total) % total); };
  const next = () => { setPaused(true); setActive((i) => (i + 1) % total); };

  const banner = AD_BANNERS[active];

  // Handle banner button clicks
  const handleBannerClick = () => {
    const id = banner.id;
    
    // For guests, trigger registration modal for member-only offers
    if (mode === "guest" && (id === "b1" || id === "b4")) {
      triggerRegistration();
      return;
    }

    // Navigate based on banner ID
    switch (id) {
      case "b1": // Summer Body Challenge - Go to booking
        navigate("/booking");
        break;
      case "b2": // Spa & Recovery - Stay on home to explore
        window.scrollTo({ top: 0, behavior: "smooth" });
        break;
      case "b3": // Free Nutrition Consultation - Go to diet plan
        navigate("/diet");
        break;
      case "b4": // 10 PT Sessions Bundle - Go to booking
        navigate("/booking");
        break;
      case "b5": // 30-Day Plank Challenge - Go to booking
        navigate("/booking");
        break;
      default:
        break;
    }
  };

  return (
    <div className="relative overflow-hidden"
      onTouchStart={(e) => { touchStartX.current = e.touches[0].clientX; }}
      onTouchEnd={(e) => {
        const dx = e.changedTouches[0].clientX - touchStartX.current;
        if (dx > 40) prev();
        else if (dx < -40) next();
      }}
    >
      {/* Banner card */}
      <div className={`bg-gradient-to-br ${banner.bg} px-5 pt-5 pb-7 relative overflow-hidden min-h-[170px]`}>
        {/* Decorative circles */}
        <div className="absolute -top-10 -end-10 w-36 h-36 bg-white/5 rounded-full" />
        <div className="absolute -bottom-8 -start-8 w-24 h-24 bg-white/5 rounded-full" />

        {/* Content */}
        <div className="relative z-10">
          <div className="flex items-start justify-between mb-2">
            <span className="text-xs bg-white/20 text-white px-2 py-0.5 rounded-full tracking-wide">
              {banner.tag[lang]}
            </span>
            <span className="text-2xl">{banner.badge}</span>
          </div>
          <h3 className="text-2xl font-bold text-white leading-tight mb-2 whitespace-pre-line">
            {banner.title[lang]}
          </h3>
          <p className="text-white/70 text-xs mb-4">{banner.sub[lang]}</p>
          <button 
            onClick={handleBannerClick}
            className="bg-white/20 hover:bg-white/30 text-white text-sm px-4 py-2 rounded-xl transition-colors border border-white/30 backdrop-blur-sm"
          >
            {banner.cta[lang]}
          </button>
        </div>

        {/* Slide index */}
        <div className="absolute bottom-3 end-4 text-xs text-white/40">
          {active + 1}/{total}
        </div>
      </div>

      {/* Dots */}
      <div className="flex justify-center gap-1.5 mt-3 mb-1">
        {AD_BANNERS.map((_, i) => (
          <button key={i} onClick={() => { setPaused(true); setActive(i); }}
            className={`h-1.5 rounded-full transition-all ${i === active ? "w-6 bg-[#dc143c]" : "w-1.5 bg-[#2a2a2a]"}`} />
        ))}
      </div>
    </div>
  );
}

// ─── Data ─────────────────────────────────────────────────────────────────────

const OUTDOOR_SESSIONS = [
  { id: "os1", title: { en: "Morning Beach Yoga", ar: "يوغا الشاطئ الصباحية" }, instructor: { en: "Emily Rodriguez", ar: "إيميلي رودريغيز" }, location: { en: "Cairo Corniche", ar: "كورنيش القاهرة" }, date: "Fri, Jul 11", time: "7:00 AM", duration: "60 min", spots: 8, totalSpots: 15, price: 150, about: { en: "Start your Friday morning with an energising beach yoga session. Suitable for all levels. Bring your mat and water.", ar: "ابدأ صباح جمعتك بجلسة يوغا منعشة. مناسبة لجميع المستويات. أحضر حصيرتك وماءك." } },
  { id: "os2", title: { en: "Park HIIT Circuit", ar: "تمرين HIIT في الحديقة" }, instructor: { en: "Marcus Chen", ar: "ماركوس تشن" }, location: { en: "Al-Azhar Park", ar: "حديقة الأزهر" }, date: "Sat, Jul 12", time: "6:30 AM", duration: "45 min", spots: 3, totalSpots: 12, price: 200, about: { en: "High-intensity interval training in the fresh air of Al-Azhar park. No equipment needed — just your energy.", ar: "تمرين عالي الكثافة في الهواء الطلق بحديقة الأزهر. لا تحتاج معدات — فقط طاقتك." } },
  { id: "os3", title: { en: "Sunset Bootcamp", ar: "بوتكامب وقت الغروب" }, instructor: { en: "Sarah Mitchell", ar: "سارة ميتشيل" }, location: { en: "Maadi Corniche", ar: "كورنيش المعادي" }, date: "Sun, Jul 13", time: "5:30 PM", duration: "50 min", spots: 6, totalSpots: 10, price: 180, about: { en: "Functional fitness meets the golden hour. Full-body bootcamp as the sun sets over the Nile.", ar: "لياقة وظيفية مع ساعة الذهب. تمرين شامل للجسم عند غروب الشمس." } },
  { id: "os4", title: { en: "Kids Active Hour", ar: "ساعة النشاط للأطفال" }, instructor: { en: "Nutrition Team", ar: "فريق التغذية" }, location: { en: "Shooting Club", ar: "نادي الصيد" }, date: "Fri, Jul 11", time: "10:00 AM", duration: "60 min", spots: 10, totalSpots: 20, price: 0, about: { en: "Fun and safe movement for children ages 5-12. Games, agility drills, and team activities.", ar: "حركة ممتعة وآمنة للأطفال من 5-12 سنة. ألعاب وتمارين رشاقة وأنشطة جماعية." } },
];

const OFFERS = [
  { id: "of1", tag: { en: "SUMMER SPECIAL", ar: "عرض الصيف" }, title: { en: "20% Off PT Sessions", ar: "خصم 20% على جلسات التدريب" }, desc: { en: "Book 5 sessions and save big on personal training.", ar: "احجز 5 جلسات ووفر الكثير على التدريب الشخصي." }, validUntil: "Jul 31, 2026", detail: { en: "Book any 5 PT sessions within the same month and automatically receive a 20% discount on the total package price. Applicable to all trainers.", ar: "احجز 5 جلسات تدريب شخصي خلال نفس الشهر واحصل تلقائياً على خصم 20% على إجمالي الحزمة." }, accent: "#dc143c" },
  { id: "of2", tag: { en: "NEW CLASS", ar: "فصل جديد" }, title: { en: "HIIT Bootcamp — Free Trial", ar: "بوتكامب HIIT — تجربة مجانية" }, desc: { en: "Try our new high-intensity bootcamp for free this week.", ar: "جرّب بوتكامب HIIT الجديد مجاناً هذا الأسبوع." }, validUntil: "Jul 14, 2026", detail: { en: "First session free for new members. Classes run every Monday and Friday at 7PM in Studio A. Limited spots.", ar: "الجلسة الأولى مجانية للأعضاء الجدد. الفصول كل اثنين وجمعة الساعة 7 مساءً في الاستوديو أ." }, accent: "#7c3aed" },
  { id: "of3", tag: { en: "REFERRAL", ar: "إحالة صديق" }, title: { en: "Bring a Friend — Get 1 Free Month", ar: "أحضر صديقاً — شهر مجاني" }, desc: { en: "Refer a friend and both of you get a free month.", ar: "أحل صديقاً وكلاكما يحصل على شهر مجاني." }, validUntil: "Aug 31, 2026", detail: { en: "When your referred friend signs up for any plan, both you and your friend get a free month automatically.", ar: "عندما يشترك صديقك في أي خطة، يحصل كلاكما على شهر مجاني مضاف تلقائياً." }, accent: "#059669" },
];

const PACKAGES = [
  { id: "pk1", name: { en: "Basic", ar: "أساسية" }, price: 1499, popular: false, features: { en: ["Gym access (off-peak hours)", "2 group classes per week", "Locker access"], ar: ["دخول الصالة (ساعات غير الذروة)", "فصلان جماعيان أسبوعياً", "دخول الخزانات"] } },
  { id: "pk2", name: { en: "Standard", ar: "قياسية" }, price: 2199, popular: true, features: { en: ["24/7 gym access", "Unlimited group classes", "Quarterly InBody scan", "Nutrition consultation"], ar: ["دخول الصالة 24/7", "فصول جماعية غير محدودة", "فحص InBody ربع سنوي", "استشارة تغذية"] } },
  { id: "pk3", name: { en: "Premium Elite", ar: "بريميوم إيليت" }, price: 2999, popular: false, features: { en: ["Unlimited gym access", "All group classes", "Monthly InBody scan", "Personalized meal plans", "Priority PT booking", "Spa access"], ar: ["دخول غير محدود للصالة", "جميع الفصول الجماعية", "فحص InBody شهري", "خطط وجبات شخصية", "أولوية حجز المدرب الشخصي", "دخول السبا"] } },
];

// ─── Session Detail Modal ─────────────────────────────────────────────────────

function SessionDetailModal({ session, onClose, onBook }: { session: typeof OUTDOOR_SESSIONS[0]; onClose: () => void; onBook: () => void }) {
  const { tr, lang, dir } = useLang();
  const isFull = session.spots === 0;
  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/75 backdrop-blur-sm">
      <div dir={dir} className="bg-[#111] w-full max-w-md rounded-t-3xl border-t border-x border-[#2a2a2a] max-h-[88vh] overflow-y-auto">
        <div className="flex justify-center pt-3"><div className="w-10 h-1 rounded-full bg-[#3a3a3a]" /></div>
        <div className="flex items-center justify-between px-5 py-4 border-b border-[#2a2a2a]">
          <h3 className="font-medium text-white">{tr("sessionDetails")}</h3>
          <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center"><X className="w-4 h-4 text-gray-400" /></button>
        </div>
        <div className="px-5 py-5 space-y-5">
          <div>
            <div className="flex flex-wrap gap-2 mb-2">
              <span className="text-xs bg-[#dc143c]/20 text-[#dc143c] px-2 py-0.5 rounded-full">{tr("noMembershipRequired")}</span>
              {isFull && <span className="text-xs bg-gray-500/20 text-gray-400 px-2 py-0.5 rounded-full">{tr("sessionFull")}</span>}
            </div>
            <h2 className="text-xl text-white mb-1">{session.title[lang]}</h2>
            <p className="text-gray-400 text-sm">{tr("instructor")}: {session.instructor[lang]}</p>
          </div>
          <div className="grid grid-cols-2 gap-3">
            {[
              { icon: <MapPin className="w-4 h-4" />, label: tr("location"), val: session.location[lang] },
              { icon: <Calendar className="w-4 h-4" />, label: tr("date"), val: session.date },
              { icon: <Clock className="w-4 h-4" />, label: tr("time"), val: session.time },
              { icon: <Clock className="w-4 h-4" />, label: tr("duration"), val: session.duration },
              { icon: <Users className="w-4 h-4" />, label: tr("capacity"), val: `${session.spots} ${tr("spotsLeft")}` },
              { icon: <Tag className="w-4 h-4" />, label: tr("price"), val: session.price === 0 ? tr("free") : `${session.price} LE` },
            ].map(({ icon, label, val }) => (
              <div key={label} className="bg-[#1a1a1a] rounded-xl p-3 border border-[#2a2a2a]">
                <div className="flex items-center gap-1.5 text-[#dc143c] mb-1">{icon}<span className="text-xs text-gray-400">{label}</span></div>
                <p className="text-white text-sm font-medium">{val}</p>
              </div>
            ))}
          </div>
          <div>
            <h4 className="text-sm text-gray-400 mb-2">{tr("aboutSession")}</h4>
            <p className="text-gray-300 text-sm leading-relaxed">{session.about[lang]}</p>
          </div>
          <button onClick={isFull ? undefined : onBook} disabled={isFull}
            className={`w-full py-4 rounded-xl font-medium transition-colors ${isFull ? "bg-[#2a2a2a] text-gray-500 cursor-not-allowed" : "bg-[#dc143c] text-white hover:bg-[#a00f2c]"}`}>
            {isFull ? tr("sessionFull") : tr("joinSession")}
          </button>
        </div>
        <div className="h-6" />
      </div>
    </div>
  );
}

// ─── Package Detail Modal ─────────────────────────────────────────────────────

function PackageDetailModal({ pkg, onClose, onSubscribe }: { pkg: typeof PACKAGES[0]; onClose: () => void; onSubscribe: () => void }) {
  const { tr, lang, dir } = useLang();
  const [months, setMonths] = useState(1);
  const discounts: Record<number, number> = { 1: 0, 3: 5, 6: 10, 12: 20 };
  const total = Math.round(pkg.price * months * (1 - discounts[months] / 100));
  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/75 backdrop-blur-sm">
      <div dir={dir} className="bg-[#111] w-full max-w-md rounded-t-3xl border-t border-x border-[#2a2a2a] max-h-[90vh] overflow-y-auto">
        <div className="flex justify-center pt-3"><div className="w-10 h-1 rounded-full bg-[#3a3a3a]" /></div>
        <div className="flex items-center justify-between px-5 py-4 border-b border-[#2a2a2a]">
          <h3 className="font-medium text-white">{tr("packageDetails")}</h3>
          <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center"><X className="w-4 h-4 text-gray-400" /></button>
        </div>
        <div className="px-5 py-5 space-y-5">
          <div className="bg-gradient-to-br from-[#dc143c] to-[#a00f2c] rounded-2xl p-5">
            {pkg.popular && <span className="text-xs bg-white/20 text-white px-2 py-0.5 rounded-full">{tr("mostPopular")}</span>}
            <h2 className="text-2xl mt-2 mb-1">{pkg.name[lang]}</h2>
            <p className="text-3xl font-light">{pkg.price.toLocaleString()} <span className="text-base">LE{tr("perMonth")}</span></p>
          </div>
          <div>
            <h4 className="text-sm text-gray-400 mb-3">{tr("whatsIncluded")}</h4>
            <div className="space-y-2">
              {pkg.features[lang].map((f: string) => (
                <div key={f} className="flex items-center gap-2">
                  <div className="w-5 h-5 rounded-full bg-[#dc143c]/20 flex items-center justify-center flex-shrink-0"><Check className="w-3 h-3 text-[#dc143c]" /></div>
                  <span className="text-sm text-gray-300">{f}</span>
                </div>
              ))}
            </div>
          </div>
          <div>
            <h4 className="text-sm text-gray-400 mb-3">{tr("selectDuration")}</h4>
            <div className="grid grid-cols-4 gap-2">
              {[1, 3, 6, 12].map((m) => (
                <button key={m} onClick={() => setMonths(m)}
                  className={`py-3 rounded-xl text-sm transition-all ${months === m ? "bg-[#dc143c] text-white" : "bg-[#1a1a1a] border border-[#2a2a2a] text-gray-300"}`}>
                  <div className="font-medium">{m}mo</div>
                  {discounts[m] > 0 && <div className="text-xs opacity-80">-{discounts[m]}%</div>}
                </button>
              ))}
            </div>
          </div>
          <div className="bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a] flex justify-between items-center">
            <span className="text-gray-400 text-sm">Total</span>
            <span className="text-white text-xl font-semibold">{total.toLocaleString()} LE</span>
          </div>
          <button onClick={onSubscribe} className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium">
            {tr("subscribeNow")}
          </button>
        </div>
        <div className="h-6" />
      </div>
    </div>
  );
}

// ─── Offer Detail Modal ───────────────────────────────────────────────────────

function OfferDetailModal({ offer, onClose }: { offer: typeof OFFERS[0]; onClose: () => void }) {
  const { tr, lang, dir } = useLang();
  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/75 backdrop-blur-sm">
      <div dir={dir} className="bg-[#111] w-full max-w-md rounded-t-3xl border-t border-x border-[#2a2a2a] max-h-[80vh] overflow-y-auto">
        <div className="flex justify-center pt-3"><div className="w-10 h-1 rounded-full bg-[#3a3a3a]" /></div>
        <div className="flex items-center justify-between px-5 py-4 border-b border-[#2a2a2a]">
          <h3 className="font-medium text-white">{tr("offerDetails")}</h3>
          <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center"><X className="w-4 h-4 text-gray-400" /></button>
        </div>
        <div className="px-5 py-5 space-y-4">
          <div className="rounded-2xl p-5 border" style={{ borderColor: offer.accent + "40", background: offer.accent + "15" }}>
            <span className="text-xs px-2 py-0.5 rounded-full text-white" style={{ background: offer.accent }}>{offer.tag[lang]}</span>
            <h2 className="text-xl text-white mt-3 mb-1">{offer.title[lang]}</h2>
            <p className="text-gray-300 text-sm">{offer.desc[lang]}</p>
          </div>
          <p className="text-gray-300 text-sm leading-relaxed">{offer.detail[lang]}</p>
          <div className="flex items-center gap-2 text-sm text-gray-400">
            <Calendar className="w-4 h-4" />
            <span>{tr("validUntil")}: <span className="text-white">{offer.validUntil}</span></span>
          </div>
          <p className="text-xs text-gray-600">{tr("termsApply")}</p>
          <button onClick={onClose} className="w-full py-4 rounded-xl font-medium text-white" style={{ background: offer.accent }}>
            {tr("claimOffer")}
          </button>
        </div>
        <div className="h-6" />
      </div>
    </div>
  );
}

// ─── Booked Confirmation ──────────────────────────────────────────────────────

function BookedModal({ session, onClose }: { session: typeof OUTDOOR_SESSIONS[0]; onClose: () => void }) {
  const { lang, dir } = useLang();
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm px-6">
      <div dir={dir} className="bg-[#111] w-full max-w-sm rounded-3xl border border-[#2a2a2a] p-6 text-center space-y-4">
        <div className="w-16 h-16 rounded-full bg-[#dc143c]/20 flex items-center justify-center mx-auto">
          <div className="w-12 h-12 rounded-full bg-[#dc143c] flex items-center justify-center">
            <Check className="w-6 h-6 text-white" />
          </div>
        </div>
        <h3 className="text-xl text-white">{lang === "ar" ? "تم الحجز!" : "You're In!"}</h3>
        <p className="text-gray-400 text-sm">{session.title[lang]}<br />{session.date} · {session.time}</p>
        <button onClick={onClose} className="w-full bg-[#dc143c] text-white py-3.5 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium">
          {lang === "ar" ? "تم" : "Done"}
        </button>
      </div>
    </div>
  );
}

// ─── Guest Home ───────────────────────────────────────────────────────────────

function GuestHome() {
  const { tr, lang, dir } = useLang();
  const navigate = useNavigate();
  const { triggerRegistration } = useAppContext();
  const [selectedSession, setSelectedSession] = useState<typeof OUTDOOR_SESSIONS[0] | null>(null);
  const [selectedPackage, setSelectedPackage] = useState<typeof PACKAGES[0] | null>(null);
  const [selectedOffer, setSelectedOffer] = useState<typeof OFFERS[0] | null>(null);
  const [bookedSession, setBookedSession] = useState<typeof OUTDOOR_SESSIONS[0] | null>(null);

  return (
    <div dir={dir} className="pb-8 space-y-0">
      {/* Hero */}
      <div className="bg-gradient-to-br from-[#dc143c] to-[#7a0a1e] px-5 pt-5 pb-7 relative overflow-hidden">
        <div className="absolute -top-10 -end-10 w-40 h-40 bg-white/5 rounded-full" />
        <div className="absolute -bottom-8 -start-8 w-28 h-28 bg-white/5 rounded-full" />
        <div className="relative z-10 flex items-start gap-4">
          <div className="w-14 h-14 rounded-2xl overflow-hidden border border-white/20 flex-shrink-0">
            <img src={logo} alt="TF" className="w-full h-full object-cover" />
          </div>
          <div>
            <p className="text-white/60 text-xs uppercase tracking-widest">{tr("welcomeTo")}</p>
            <h2 className="text-2xl font-bold text-white">TRUE FIT <span className="text-sm font-normal opacity-70">GYM & SPA</span></h2>
            <p className="text-white/70 text-xs mt-0.5">{tr("premiumFitness")}</p>
          </div>
        </div>
        <button onClick={() => triggerRegistration()}
          className="mt-4 bg-white text-[#dc143c] px-5 py-2.5 rounded-xl text-sm font-semibold flex items-center gap-2 w-fit hover:bg-gray-100 transition-colors">
          {tr("viewMemberships")} <ArrowRight className="w-4 h-4 rtl:rotate-180" />
        </button>
      </div>

      {/* ── In-App Ad Banners ── */}
      <div className="pt-4 px-4">
        <div className="flex items-center justify-between mb-3">
          <h3 className="text-base font-semibold text-white">{lang === "ar" ? "العروض والإعلانات" : "Promotions & Ads"}</h3>
        </div>
        <div className="rounded-2xl overflow-hidden border border-[#2a2a2a]">
          <BannerCarousel />
        </div>
      </div>

      {/* Guest notice */}
      <div className="px-4 pt-4">
        <div className="bg-[#1a1a1a] border border-[#dc143c]/30 rounded-2xl p-4 flex items-start gap-3">
          <div className="w-9 h-9 rounded-full bg-[#dc143c]/20 flex items-center justify-center flex-shrink-0 mt-0.5">
            <Lock className="w-4 h-4 text-[#dc143c]" />
          </div>
          <div>
            <p className="text-white text-sm font-medium mb-0.5">{tr("guestBannerTitle")}</p>
            <p className="text-gray-400 text-xs">{tr("guestBannerSub")}</p>
          </div>
        </div>
      </div>

      {/* Offers */}
      <div className="px-4 pt-5">
        <h3 className="text-base font-semibold text-white mb-3">{tr("offers")}</h3>
        <div className="space-y-3">
          {OFFERS.map((offer) => (
            <button key={offer.id} onClick={() => setSelectedOffer(offer)}
              className="w-full text-start bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a] hover:border-[#dc143c]/40 transition-colors active:scale-[0.99]">
              <span className="text-xs px-2 py-0.5 rounded-full text-white" style={{ background: offer.accent }}>{offer.tag[lang]}</span>
              <h4 className="text-white font-medium mt-2 mb-1 text-sm">{offer.title[lang]}</h4>
              <p className="text-gray-400 text-xs">{offer.desc[lang]}</p>
              <div className="flex items-center gap-1 text-[#dc143c] text-xs mt-2 font-medium">
                {tr("learnMore")} <ChevronRight className="w-3 h-3 rtl:rotate-180" />
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Packages */}
      <div className="px-4 pt-5">
        <h3 className="text-base font-semibold text-white mb-3">{tr("packages")}</h3>
        <div className="space-y-3">
          {PACKAGES.map((pkg, i) => (
            <button key={pkg.id} onClick={() => setSelectedPackage(pkg)}
              className={`w-full text-start rounded-xl p-4 border transition-colors active:scale-[0.99] ${pkg.popular ? "bg-gradient-to-br from-[#dc143c]/20 to-[#dc143c]/5 border-[#dc143c]/40" : "bg-[#1a1a1a] border-[#2a2a2a] hover:border-[#dc143c]/30"}`}>
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <h4 className="text-white font-medium text-sm">{pkg.name[lang]}</h4>
                  {pkg.popular && <span className="text-xs bg-[#dc143c] text-white px-1.5 py-0.5 rounded-full">{tr("mostPopular")}</span>}
                </div>
                <span className="text-[#dc143c] font-semibold text-sm">{pkg.price.toLocaleString()} <span className="text-xs text-gray-500">LE{tr("perMonth")}</span></span>
              </div>
              <div className="space-y-1">
                {pkg.features[lang].slice(0, 2).map((f: string) => (
                  <div key={f} className="flex items-center gap-1.5 text-xs text-gray-400"><Check className="w-3 h-3 text-[#dc143c]" />{f}</div>
                ))}
                {pkg.features[lang].length > 2 && <p className="text-xs text-gray-600">+{pkg.features[lang].length - 2} {lang === "ar" ? "مزايا أخرى" : "more"}</p>}
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Outdoor Sessions */}
      <div className="px-4 pt-5">
        <h3 className="text-base font-semibold text-white mb-1">{tr("outdoorSessions")}</h3>
        <p className="text-xs text-gray-500 mb-3">{tr("availableForAll")}</p>
        <div className="space-y-3">
          {OUTDOOR_SESSIONS.map((s) => {
            const isFull = s.spots === 0;
            return (
              <button key={s.id} onClick={() => setSelectedSession(s)}
                className="w-full text-start bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a] hover:border-[#dc143c]/30 transition-colors active:scale-[0.99]">
                <div className="flex items-start justify-between mb-2">
                  <div>
                    <h4 className="text-white font-medium text-sm mb-0.5">{s.title[lang]}</h4>
                    <p className="text-xs text-gray-400">{s.instructor[lang]}</p>
                  </div>
                  <span className={`text-xs px-2 py-0.5 rounded-full flex-shrink-0 ${isFull ? "bg-gray-500/20 text-gray-400" : "bg-green-500/20 text-green-400"}`}>
                    {isFull ? tr("full") : `${s.spots} ${tr("spotsLeft")}`}
                  </span>
                </div>
                <div className="flex items-center gap-3 text-xs text-gray-500">
                  <span className="flex items-center gap-1"><MapPin className="w-3 h-3" />{s.location[lang]}</span>
                  <span className="flex items-center gap-1"><Clock className="w-3 h-3" />{s.time}</span>
                  <span className="text-[#dc143c] font-semibold">{s.price === 0 ? tr("free") : `${s.price} LE`}</span>
                </div>
              </button>
            );
          })}
        </div>
      </div>

      {/* Why Join */}
      <div className="px-4 pt-5">
        <div className="bg-[#1a1a1a] rounded-2xl p-5 border border-[#2a2a2a]">
          <h3 className="text-base font-semibold text-white mb-4">{tr("whyJoin")}</h3>
          {([tr("reason1"), tr("reason2"), tr("reason3"), tr("reason4")] as string[]).map((r) => (
            <div key={r} className="flex items-center gap-2 mb-2.5 last:mb-0">
              <Star className="w-4 h-4 text-[#dc143c] flex-shrink-0" />
              <span className="text-sm text-gray-300">{r}</span>
            </div>
          ))}
        </div>
      </div>

      {selectedSession && <SessionDetailModal session={selectedSession} onClose={() => setSelectedSession(null)} onBook={() => { setBookedSession(selectedSession); setSelectedSession(null); }} />}
      {selectedPackage && <PackageDetailModal pkg={selectedPackage} onClose={() => setSelectedPackage(null)} onSubscribe={() => { setSelectedPackage(null); triggerRegistration(selectedPackage.id); }} />}
      {selectedOffer && <OfferDetailModal offer={selectedOffer} onClose={() => setSelectedOffer(null)} />}
      {bookedSession && <BookedModal session={bookedSession} onClose={() => setBookedSession(null)} />}
    </div>
  );
}

// ─── Member Home ──────────────────────────────────────────────────────────────

const UPCOMING_BOOKINGS = [
  { id: "ub1", type: "class" as const, name: { en: "Morning HIIT", ar: "هايت الصباح" }, coach: { en: "Marcus Chen", ar: "ماركوس تشن" }, date: "Mon, Jul 14", time: "7:00 AM", location: { en: "Studio A", ar: "الاستوديو A" } },
  { id: "ub2", type: "pt" as const, name: { en: "PT Session", ar: "جلسة تدريب شخصي" }, coach: { en: "Sarah Mitchell", ar: "سارة ميتشيل" }, date: "Wed, Jul 16", time: "10:00 AM", location: { en: "Training Floor", ar: "قاعة التدريب" } },
];

function ActivityRing({ pct, color, size = 56 }: { pct: number; color: string; size?: number }) {
  const r = (size - 8) / 2;
  const circ = 2 * Math.PI * r;
  return (
    <svg width={size} height={size}>
      <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke="#2a2a2a" strokeWidth={6} />
      <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke={color} strokeWidth={6}
        strokeDasharray={`${circ * pct / 100} ${circ}`} strokeLinecap="round"
        transform={`rotate(-90 ${size / 2} ${size / 2})`} />
    </svg>
  );
}

function MemberHome() {
  const { tr, lang, dir } = useLang();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [showBarcode, setShowBarcode] = useState(false);
  const [selectedOffer, setSelectedOffer] = useState<typeof OFFERS[0] | null>(null);

  const firstName = user?.displayName?.split(" ")[0] ?? (lang === "ar" ? "عضو" : "Member");

  return (
    <div dir={dir} className="pb-8 space-y-0">
      {/* Header greeting */}
      <div className="px-5 pt-5 pb-4 flex items-center justify-between">
        <div>
          <p className="text-gray-400 text-xs mb-0.5">{lang === "ar" ? "مرحباً بعودتك،" : "Welcome back,"}</p>
          <h2 className="text-2xl font-semibold text-white">{firstName} 👋</h2>
        </div>
      </div>

      {/* ── In-App Ad Banners ── */}
      <div className="px-4 mb-1">
        <div className="rounded-2xl overflow-hidden border border-[#2a2a2a]">
          <BannerCarousel />
        </div>
      </div>

      {/* Check-in */}
      <div className="px-4 pt-4">
        <div className="bg-gradient-to-br from-[#dc143c] to-[#a00f2c] rounded-2xl p-5 relative overflow-hidden">
          <div className="absolute -top-8 -end-8 w-28 h-28 bg-white/10 rounded-full" />
          <div className="relative z-10">
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-base font-medium">{tr("quickCheckIn")}</h3>
              <span className="text-xs bg-white/20 px-2 py-0.5 rounded-full">Premium Elite</span>
            </div>
            <button onClick={() => setShowBarcode(!showBarcode)}
              className="bg-white text-[#dc143c] px-5 py-2.5 rounded-xl flex items-center gap-2 hover:bg-gray-100 transition-colors font-medium text-sm">
              <QrCode className="w-4 h-4" />
              {showBarcode ? tr("hideBarcode") : tr("showBarcode")}
            </button>
            {showBarcode && (
              <div className="mt-4 bg-white rounded-xl p-4 flex flex-col items-center">
                <svg width="180" height="72" viewBox="0 0 180 72">
                  {[5,10,14,21,25,31,36,40,47,51,56,62,66,73,78,82,88,93,100,104,110,115,119,126,131,135,141,146,153,157,163,168,172].map((x, i) => (
                    <rect key={i} x={x} y="4" width={[3,2,5,2,4,3,2,5,2,3,4,2,5,3,2,4,3,5,2,4,3,2,5,3,2,4,3,5,2,4,3,2,5][i]} height="64" fill="#000" />
                  ))}
                </svg>
                <p className="text-black text-xs mt-2 font-mono tracking-wider">{tr("memberId")}: TF-2024-8471</p>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Activity rings + stats */}
      <div className="px-4 pt-4">
        <div className="bg-[#1a1a1a] rounded-2xl p-4 border border-[#2a2a2a]">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-sm font-medium text-white">{lang === "ar" ? "نشاطك هذا الشهر" : "This Month's Activity"}</h3>
            <span className="text-xs text-gray-500">Jul 2026</span>
          </div>
          <div className="flex items-center justify-around">
            {[
              { label: lang === "ar" ? "تمرين" : "Workouts", val: 24, pct: 80, color: "#dc143c", icon: <Dumbbell className="w-4 h-4" /> },
              { label: lang === "ar" ? "ساعة" : "Hours", val: 18, pct: 60, color: "#7c3aed", icon: <Clock className="w-4 h-4" /> },
              { label: lang === "ar" ? "جلسات" : "Sessions", val: 8, pct: 65, color: "#059669", icon: <User className="w-4 h-4" /> },
            ].map(({ label, val, pct, color, icon }) => (
              <div key={label} className="flex flex-col items-center gap-1">
                <div className="relative">
                  <ActivityRing pct={pct} color={color} />
                  <div className="absolute inset-0 flex items-center justify-center" style={{ color }}>{icon}</div>
                </div>
                <p className="text-white text-lg font-semibold leading-none">{val}</p>
                <p className="text-gray-500 text-xs">{label}</p>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Upcoming sessions */}
      <div className="px-4 pt-4">
        <div className="flex items-center justify-between mb-3">
          <h3 className="text-base font-semibold text-white">{lang === "ar" ? "جلساتك القادمة" : "Upcoming Sessions"}</h3>
          <button onClick={() => navigate("/booking")} className="text-xs text-[#dc143c] font-medium">{tr("seeAll")}</button>
        </div>
        <div className="space-y-2.5">
          {UPCOMING_BOOKINGS.map((b) => (
            <button key={b.id} onClick={() => navigate("/booking")}
              className="w-full text-start bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a] hover:border-[#dc143c]/30 transition-colors flex items-center gap-3 active:scale-[0.99]">
              <div className="w-10 h-10 rounded-xl bg-[#dc143c]/20 flex items-center justify-center flex-shrink-0">
                {b.type === "class" ? <Users className="w-5 h-5 text-[#dc143c]" /> : <User className="w-5 h-5 text-[#dc143c]" />}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-white text-sm font-medium truncate">{b.name[lang]}</p>
                <p className="text-gray-400 text-xs truncate">{b.coach[lang]} · {b.location[lang]}</p>
              </div>
              <div className="text-end flex-shrink-0">
                <p className="text-white text-xs font-medium">{b.time}</p>
                <p className="text-gray-500 text-xs">{b.date}</p>
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Quick actions */}
      <div className="px-4 pt-4">
        <h3 className="text-base font-semibold text-white mb-3">{tr("quickAccess")}</h3>
        <div className="grid grid-cols-2 gap-3">
          {[
            { icon: <Calendar className="w-5 h-5 text-[#dc143c]" />, label: lang === "ar" ? "احجز جلسة" : "Book Session", sub: lang === "ar" ? "PT أو فصل جماعي" : "PT or Group Class", path: "/booking" },
            { icon: <TrendingUp className="w-5 h-5 text-purple-400" />, label: lang === "ar" ? "تقدمي" : "My Progress", sub: lang === "ar" ? "تحليل InBody" : "InBody analysis", path: "/progress" },
            { icon: <Flame className="w-5 h-5 text-orange-400" />, label: lang === "ar" ? "نظامي الغذائي" : "My Diet", sub: lang === "ar" ? "وجبات اليوم" : "Today's meals", path: "/diet" },
            { icon: <Users className="w-5 h-5 text-green-400" />, label: lang === "ar" ? "مدربي" : "My Coach", sub: lang === "ar" ? "تواصل الآن" : "Chat now", path: "/chat" },
          ].map(({ icon, label, sub, path }) => (
            <button key={label} onClick={() => navigate(path)}
              className="bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a] hover:border-[#dc143c]/30 transition-colors text-start active:scale-[0.98]">
              <div className="w-9 h-9 bg-[#0a0a0a] rounded-lg flex items-center justify-center mb-3">{icon}</div>
              <p className="text-white text-sm font-medium">{label}</p>
              <p className="text-gray-500 text-xs mt-0.5">{sub}</p>
            </button>
          ))}
        </div>
      </div>

      {/* Promotions */}
      <div className="px-4 pt-5">
        <h3 className="text-base font-semibold text-white mb-3">{tr("promotions")}</h3>
        <div className="space-y-3">
          {OFFERS.map((offer) => (
            <button key={offer.id} onClick={() => setSelectedOffer(offer)}
              className="w-full text-start bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a] hover:border-[#dc143c]/40 transition-colors active:scale-[0.99]">
              <span className="text-xs px-2 py-0.5 rounded-full text-white" style={{ background: offer.accent }}>{offer.tag[lang]}</span>
              <h4 className="text-white font-medium mt-2 mb-1 text-sm">{offer.title[lang]}</h4>
              <p className="text-gray-400 text-xs">{offer.desc[lang]}</p>
            </button>
          ))}
        </div>
      </div>

      {selectedOffer && <OfferDetailModal offer={selectedOffer} onClose={() => setSelectedOffer(null)} />}
    </div>
  );
}

// ─── Root Export ──────────────────────────────────────────────────────────────

export function Home() {
  const { mode } = useAuth();
  return mode === "member" ? <MemberHome /> : <GuestHome />;
}