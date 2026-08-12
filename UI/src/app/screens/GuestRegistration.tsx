import { useState } from "react";
import { ChevronLeft, ChevronRight, Check, User, Phone, MapPin, Calendar, CreditCard, Shield, Mail, Lock, Eye, EyeOff, X } from "lucide-react";
import { useAuth } from "../../lib/AuthContext";
import { useLang } from "../../lib/LanguageContext";
import logo from "../../imports/logo-only.jpeg";

type Step = "info" | "plan" | "payment";

interface FormData {
  name: string;
  email: string;
  password: string;
  phone: string;
  address: string;
  birthday: string;
}

interface Plan {
  id: string;
  name: { en: string; ar: string };
  price: number;
  popular: boolean;
  features: { en: string[]; ar: string[] };
}

const PLANS: Plan[] = [
  {
    id: "Basic",
    name: { en: "Basic", ar: "أساسية" },
    price: 1499,
    popular: false,
    features: {
      en: ["Gym access (off-peak hours)", "2 group classes per week", "Locker access"],
      ar: ["دخول الصالة (ساعات غير الذروة)", "فصلان جماعيان أسبوعياً", "دخول الخزانات"],
    },
  },
  {
    id: "Standard",
    name: { en: "Standard", ar: "قياسية" },
    price: 2199,
    popular: true,
    features: {
      en: ["24/7 gym access", "Unlimited group classes", "Quarterly InBody scan", "Nutrition consultation"],
      ar: ["دخول الصالة 24/7", "فصول جماعية غير محدودة", "فحص InBody ربع سنوي", "استشارة تغذية"],
    },
  },
  {
    id: "Premium Elite",
    name: { en: "Premium Elite", ar: "بريميوم إيليت" },
    price: 2999,
    popular: false,
    features: {
      en: ["Unlimited gym access", "All group classes", "Monthly InBody scan", "Personalized meal plans", "Priority PT booking", "Spa access"],
      ar: ["دخول غير محدود للصالة", "جميع الفصول الجماعية", "فحص InBody شهري", "خطط وجبات شخصية", "أولوية حجز المدرب الشخصي", "دخول السبا"],
    },
  },
];

const DURATIONS = [
  { months: 1, discount: 0 },
  { months: 3, discount: 5 },
  { months: 6, discount: 10 },
  { months: 12, discount: 20 },
];

const STEPS: Step[] = ["info", "plan", "payment"];

const STEP_LABELS: Record<Step, { en: string; ar: string }> = {
  info: { en: "Your Info", ar: "بياناتك" },
  plan: { en: "Choose Plan", ar: "الباقة" },
  payment: { en: "Payment", ar: "الدفع" },
};

function StepIndicator({ current }: { current: Step }) {
  const { lang } = useLang();
  const idx = STEPS.indexOf(current);
  return (
    <div className="flex items-center justify-center mb-6">
      {STEPS.map((s, i) => (
        <div key={s} className="flex items-center">
          <div className="flex flex-col items-center">
            <div className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold transition-all ${i < idx ? "bg-[#dc143c] text-white" : i === idx ? "bg-[#dc143c] text-white ring-4 ring-[#dc143c]/25" : "bg-[#2a2a2a] text-gray-500"}`}>
              {i < idx ? <Check className="w-4 h-4" /> : i + 1}
            </div>
            <span className={`text-[10px] mt-1 ${i === idx ? "text-white" : "text-gray-600"}`}>{STEP_LABELS[s][lang]}</span>
          </div>
          {i < STEPS.length - 1 && (
            <div className={`h-px w-10 mb-4 mx-1 ${i < idx ? "bg-[#dc143c]" : "bg-[#2a2a2a]"}`} />
          )}
        </div>
      ))}
    </div>
  );
}

function InfoStep({ data, onChange, onNext }: {
  data: FormData;
  onChange: (d: Partial<FormData>) => void;
  onNext: () => void;
}) {
  const { tr, dir, lang } = useLang();
  const [showPass, setShowPass] = useState(false);

  const valid = data.name.trim() && data.email.trim() && data.password.length >= 6
    && data.phone.trim() && data.address.trim() && data.birthday;

  return (
    <div dir={dir} className="space-y-4">
      <div>
        <h3 className="text-xl text-white mb-1">{tr("personalInfo")}</h3>
        <p className="text-gray-400 text-sm">{lang === "ar" ? "أدخل بياناتك الشخصية للمتابعة" : "Fill in your details to continue"}</p>
      </div>

      {/* Name */}
      <div>
        <label className="text-xs text-gray-400 mb-1.5 block">{tr("fullName")}</label>
        <div className="relative">
          <User className="absolute start-4 top-3.5 w-4 h-4 text-gray-500" />
          <input type="text" placeholder={lang === "ar" ? "أحمد محمد" : "John Doe"}
            value={data.name} onChange={(e) => onChange({ name: e.target.value })}
            className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl ps-11 pe-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors" />
        </div>
      </div>

      {/* Email */}
      <div>
        <label className="text-xs text-gray-400 mb-1.5 block">{tr("email")}</label>
        <div className="relative">
          <Mail className="absolute start-4 top-3.5 w-4 h-4 text-gray-500" />
          <input type="email" placeholder="you@example.com"
            value={data.email} onChange={(e) => onChange({ email: e.target.value })}
            className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl ps-11 pe-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors" />
        </div>
      </div>

      {/* Password */}
      <div>
        <label className="text-xs text-gray-400 mb-1.5 block">{tr("password")}</label>
        <div className="relative">
          <Lock className="absolute start-4 top-3.5 w-4 h-4 text-gray-500" />
          <input type={showPass ? "text" : "password"} placeholder="Min. 6 characters"
            value={data.password} onChange={(e) => onChange({ password: e.target.value })}
            className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl ps-11 pe-11 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors" />
          <button type="button" onClick={() => setShowPass(!showPass)}
            className="absolute end-4 top-3.5 text-gray-500 hover:text-gray-300">
            {showPass ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
          </button>
        </div>
        {data.password.length > 0 && data.password.length < 6 && (
          <p className="text-xs text-red-400 mt-1">{lang === "ar" ? "كلمة المرور يجب أن تكون 6 أحرف على الأقل" : "Password must be at least 6 characters"}</p>
        )}
      </div>

      {/* Phone */}
      <div>
        <label className="text-xs text-gray-400 mb-1.5 block">{tr("phone")}</label>
        <div className="relative">
          <Phone className="absolute start-4 top-3.5 w-4 h-4 text-gray-500" />
          <input type="tel" placeholder={tr("phoneHint")}
            value={data.phone} onChange={(e) => onChange({ phone: e.target.value })}
            className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl ps-11 pe-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors" />
        </div>
      </div>

      {/* Address */}
      <div>
        <label className="text-xs text-gray-400 mb-1.5 block">{tr("address")}</label>
        <div className="relative">
          <MapPin className="absolute start-4 top-3.5 w-4 h-4 text-gray-500" />
          <input type="text" placeholder={tr("addressHint")}
            value={data.address} onChange={(e) => onChange({ address: e.target.value })}
            className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl ps-11 pe-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors" />
        </div>
      </div>

      {/* Birthday */}
      <div>
        <label className="text-xs text-gray-400 mb-1.5 block">{tr("birthday")}</label>
        <div className="relative">
          <Calendar className="absolute start-4 top-3.5 w-4 h-4 text-gray-500" />
          <input type="date"
            value={data.birthday} onChange={(e) => onChange({ birthday: e.target.value })}
            className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl ps-11 pe-4 py-3.5 text-white focus:outline-none focus:border-[#dc143c] transition-colors" />
        </div>
      </div>

      <button onClick={onNext} disabled={!valid}
        className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium disabled:opacity-40 disabled:cursor-not-allowed flex items-center justify-center gap-2 mt-2">
        {tr("nextStep")} <ChevronRight className="w-4 h-4 rtl:rotate-180" />
      </button>
    </div>
  );
}

function PlanStep({ onNext, onBack, selectedPlan, setSelectedPlan, selectedDuration, setSelectedDuration }: {
  onNext: () => void; onBack: () => void;
  selectedPlan: Plan | null; setSelectedPlan: (p: Plan) => void;
  selectedDuration: typeof DURATIONS[0]; setSelectedDuration: (d: typeof DURATIONS[0]) => void;
}) {
  const { tr, dir, lang } = useLang();
  const total = selectedPlan
    ? Math.round(selectedPlan.price * selectedDuration.months * (1 - selectedDuration.discount / 100))
    : 0;

  return (
    <div dir={dir} className="space-y-5">
      <div>
        <h3 className="text-xl text-white mb-1">{tr("choosePlanStep")}</h3>
        <p className="text-gray-400 text-sm">{lang === "ar" ? "اختر الباقة المناسبة لأهدافك" : "Pick the plan that fits your goals"}</p>
      </div>

      <div className="space-y-3">
        {PLANS.map((plan) => (
          <button key={plan.id} onClick={() => setSelectedPlan(plan)}
            className={`w-full text-start rounded-xl p-4 border transition-all ${selectedPlan?.id === plan.id ? "border-[#dc143c] bg-[#dc143c]/10" : "border-[#2a2a2a] bg-[#1a1a1a] hover:border-[#dc143c]/40"}`}>
            <div className="flex items-center justify-between mb-2">
              <div className="flex items-center gap-2">
                <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center flex-shrink-0 transition-colors ${selectedPlan?.id === plan.id ? "border-[#dc143c] bg-[#dc143c]" : "border-[#3a3a3a]"}`}>
                  {selectedPlan?.id === plan.id && <Check className="w-3 h-3 text-white" />}
                </div>
                <span className="text-white font-medium">{plan.name[lang]}</span>
                {plan.popular && <span className="text-xs bg-[#dc143c] text-white px-1.5 py-0.5 rounded-full">{tr("mostPopular")}</span>}
              </div>
              <span className="text-[#dc143c] font-semibold text-sm">{plan.price.toLocaleString()} <span className="text-gray-500 text-xs">LE{tr("perMonth")}</span></span>
            </div>
            <div className="space-y-1 ps-7">
              {plan.features[lang].slice(0, 3).map((f) => (
                <p key={f} className="text-xs text-gray-400 flex items-center gap-1"><Check className="w-3 h-3 text-[#dc143c]" />{f}</p>
              ))}
              {plan.features[lang].length > 3 && (
                <p className="text-xs text-gray-600">+{plan.features[lang].length - 3} {lang === "ar" ? "مزايا" : "more"}</p>
              )}
            </div>
          </button>
        ))}
      </div>

      <div>
        <p className="text-sm text-gray-400 mb-2">{tr("selectDuration")}</p>
        <div className="grid grid-cols-4 gap-2">
          {DURATIONS.map((d) => (
            <button key={d.months} onClick={() => setSelectedDuration(d)}
              className={`py-2.5 rounded-xl text-xs transition-all ${selectedDuration.months === d.months ? "bg-[#dc143c] text-white" : "bg-[#1a1a1a] border border-[#2a2a2a] text-gray-400 hover:border-[#dc143c]/40"}`}>
              <div className="font-medium">{d.months}mo</div>
              {d.discount > 0 && <div className="opacity-80">-{d.discount}%</div>}
            </button>
          ))}
        </div>
      </div>

      {selectedPlan && (
        <div className="bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a] flex justify-between items-center">
          <span className="text-gray-400 text-sm">{tr("totalDue")}</span>
          <span className="text-white text-xl font-semibold">{total.toLocaleString()} LE</span>
        </div>
      )}

      <div className="flex gap-3">
        <button onClick={onBack}
          className="w-12 h-12 rounded-xl bg-[#1a1a1a] border border-[#2a2a2a] flex items-center justify-center flex-shrink-0 hover:border-[#dc143c]/40 transition-colors">
          <ChevronLeft className="w-5 h-5 text-gray-400 rtl:rotate-180" />
        </button>
        <button onClick={onNext} disabled={!selectedPlan}
          className="flex-1 bg-[#dc143c] text-white py-3.5 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium disabled:opacity-40 disabled:cursor-not-allowed flex items-center justify-center gap-2">
          {tr("nextStep")} <ChevronRight className="w-4 h-4 rtl:rotate-180" />
        </button>
      </div>
    </div>
  );
}

function PaymentStep({ plan, duration, onBack, onPay }: {
  plan: Plan; duration: typeof DURATIONS[0]; onBack: () => void; onPay: () => void;
}) {
  const { tr, dir, lang } = useLang();
  const [cardName, setCardName] = useState("");
  const [cardNum, setCardNum] = useState("");
  const [expiry, setExpiry] = useState("");
  const [cvv, setCvv] = useState("");
  const [loading, setLoading] = useState(false);

  const total = Math.round(plan.price * duration.months * (1 - duration.discount / 100));

  const formatCard = (v: string) => v.replace(/\D/g, "").slice(0, 16).replace(/(.{4})/g, "$1 ").trim();
  const formatExpiry = (v: string) => {
    const c = v.replace(/\D/g, "").slice(0, 4);
    return c.length >= 3 ? c.slice(0, 2) + "/" + c.slice(2) : c;
  };

  const valid = cardName.trim() && cardNum.length >= 19 && expiry.length >= 5 && cvv.length >= 3;

  const handlePay = async () => {
    if (!valid) return;
    setLoading(true);
    await new Promise((r) => setTimeout(r, 1400));
    setLoading(false);
    onPay();
  };

  return (
    <div dir={dir} className="space-y-5">
      <div>
        <h3 className="text-xl text-white mb-1">{tr("paymentStep")}</h3>
        <p className="text-gray-400 text-sm">{lang === "ar" ? "أدخل بيانات بطاقتك لإتمام التسجيل" : "Enter card details to complete registration"}</p>
      </div>

      <div className="bg-[#dc143c]/10 border border-[#dc143c]/30 rounded-xl p-4 flex items-center justify-between">
        <div>
          <p className="text-white font-medium text-sm">{plan.name[lang]}</p>
          <p className="text-gray-400 text-xs">{duration.months} {lang === "ar" ? "شهر" : "month(s)"}{duration.discount > 0 ? ` · ${duration.discount}% off` : ""}</p>
        </div>
        <span className="text-[#dc143c] font-bold text-lg">{total.toLocaleString()} LE</span>
      </div>

      <div className="space-y-4">
        <div>
          <label className="text-xs text-gray-400 mb-1.5 block">{tr("cardName")}</label>
          <input type="text" placeholder={lang === "ar" ? "الاسم كما يظهر على البطاقة" : "John Doe"}
            value={cardName} onChange={(e) => setCardName(e.target.value)}
            className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl px-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors" />
        </div>
        <div>
          <label className="text-xs text-gray-400 mb-1.5 block">{tr("cardNumber")}</label>
          <div className="relative">
            <input type="text" placeholder="1234 5678 9012 3456"
              value={cardNum} onChange={(e) => setCardNum(formatCard(e.target.value))}
              className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl px-4 pe-12 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors" />
            <CreditCard className="absolute end-4 top-3.5 w-5 h-5 text-gray-600" />
          </div>
        </div>
        <div className="grid grid-cols-2 gap-3">
          <div>
            <label className="text-xs text-gray-400 mb-1.5 block">{tr("expiry")}</label>
            <input type="text" placeholder="MM/YY"
              value={expiry} onChange={(e) => setExpiry(formatExpiry(e.target.value))}
              className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl px-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors" />
          </div>
          <div>
            <label className="text-xs text-gray-400 mb-1.5 block">{tr("cvv")}</label>
            <input type="text" placeholder="123"
              value={cvv} onChange={(e) => setCvv(e.target.value.replace(/\D/g, "").slice(0, 3))}
              className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl px-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors" />
          </div>
        </div>
      </div>

      <div className="flex items-center gap-2 bg-[#1a1a1a] rounded-xl p-3 border border-[#2a2a2a]">
        <Shield className="w-4 h-4 text-green-400 flex-shrink-0" />
        <p className="text-xs text-gray-400">{tr("securePayment")}</p>
      </div>

      <div className="flex gap-3">
        <button onClick={onBack} disabled={loading}
          className="w-12 h-12 rounded-xl bg-[#1a1a1a] border border-[#2a2a2a] flex items-center justify-center flex-shrink-0 hover:border-[#dc143c]/40 transition-colors disabled:opacity-40">
          <ChevronLeft className="w-5 h-5 text-gray-400 rtl:rotate-180" />
        </button>
        <button onClick={handlePay} disabled={!valid || loading}
          className="flex-1 bg-[#dc143c] text-white py-3.5 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium disabled:opacity-40 disabled:cursor-not-allowed">
          {loading
            ? <span className="flex items-center justify-center gap-2"><span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />{tr("processingPayment")}</span>
            : `${lang === "ar" ? "ادفع" : "Pay"} ${total.toLocaleString()} LE`}
        </button>
      </div>
    </div>
  );
}

export function GuestRegistration({ onClose, preSelectedPlanId }: { onClose: () => void; preSelectedPlanId?: string }) {
  const { guestSubscribe } = useAuth();
  const { tr, dir, lang, setLang } = useLang();

  const [step, setStep] = useState<Step>("info");
  const [formData, setFormData] = useState<FormData>({ name: "", email: "", password: "", phone: "", address: "", birthday: "" });

  const defaultPlan = preSelectedPlanId ? PLANS.find((p) => p.id === preSelectedPlanId) ?? null : null;
  const [selectedPlan, setSelectedPlan] = useState<Plan | null>(defaultPlan);
  const [selectedDuration, setSelectedDuration] = useState(DURATIONS[0]);

  const handleComplete = () => {
    if (!selectedPlan) return;
    guestSubscribe({
      name: formData.name,
      phone: formData.phone,
      address: formData.address,
      birthday: formData.birthday,
      plan: selectedPlan.name.en,
    });
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/80 backdrop-blur-sm">
      <div dir={dir} className="bg-[#0a0a0a] w-full max-w-md rounded-t-3xl border-t border-x border-[#2a2a2a] max-h-[95vh] flex flex-col">
        {/* Handle + header */}
        <div className="flex-shrink-0">
          <div className="flex justify-center pt-3"><div className="w-10 h-1 rounded-full bg-[#3a3a3a]" /></div>
          <div className="flex items-center justify-between px-5 py-4 border-b border-[#2a2a2a]">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-lg overflow-hidden border border-[#dc143c]/30">
                <img src={logo} alt="TF" className="w-full h-full object-cover" />
              </div>
              <div>
                <p className="text-white text-sm font-semibold">{tr("guestRegTitle")}</p>
                <p className="text-[#dc143c] text-[10px] tracking-wide">TRUE FIT GYM & SPA</p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              {/* Lang toggle */}
              <div className="flex gap-1 bg-[#1a1a1a] rounded-full p-0.5 border border-[#2a2a2a]">
                {(["en", "ar"] as const).map((l) => (
                  <button key={l} onClick={() => setLang(l)}
                    className={`w-7 h-7 rounded-full text-[10px] font-bold transition-all ${lang === l ? "bg-[#dc143c] text-white" : "text-gray-500"}`}>
                    {l.toUpperCase()}
                  </button>
                ))}
              </div>
              <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center">
                <X className="w-4 h-4 text-gray-400" />
              </button>
            </div>
          </div>
        </div>

        {/* Scrollable body */}
        <div className="flex-1 overflow-y-auto px-5 pt-5 pb-8">
          <StepIndicator current={step} />

          {step === "info" && (
            <InfoStep
              data={formData}
              onChange={(d) => setFormData((prev) => ({ ...prev, ...d }))}
              onNext={() => setStep("plan")}
            />
          )}
          {step === "plan" && (
            <PlanStep
              onNext={() => setStep("payment")}
              onBack={() => setStep("info")}
              selectedPlan={selectedPlan}
              setSelectedPlan={setSelectedPlan}
              selectedDuration={selectedDuration}
              setSelectedDuration={setSelectedDuration}
            />
          )}
          {step === "payment" && selectedPlan && (
            <PaymentStep
              plan={selectedPlan}
              duration={selectedDuration}
              onBack={() => setStep("plan")}
              onPay={handleComplete}
            />
          )}
        </div>
      </div>
    </div>
  );
}
