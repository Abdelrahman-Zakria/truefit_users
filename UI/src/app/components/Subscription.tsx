import { useState } from "react";
import { Check, Calendar, CreditCard, AlertCircle, X, ChevronRight, ChevronLeft, Zap } from "lucide-react";
import { useAuth } from "../../lib/AuthContext";
import { useLang } from "../../lib/LanguageContext";
import { useAppContext } from "../../lib/AppContext";

type RenewStep = "plan" | "duration" | "payment" | "success";

interface Plan {
  id: string;
  name: string;
  price: number;
  features: string[];
}

const PLANS: Plan[] = [
  {
    id: "basic",
    name: "Basic",
    price: 1499,
    features: ["Gym access (off-peak hours)", "2 group classes per week"],
  },
  {
    id: "standard",
    name: "Standard",
    price: 2199,
    features: ["24/7 gym access", "Unlimited group classes", "Quarterly InBody scan"],
  },
  {
    id: "elite",
    name: "Premium Elite",
    price: 2999,
    features: [
      "Unlimited gym access",
      "All group classes included",
      "Monthly InBody scan",
      "Personalized meal plans",
      "Priority booking",
    ],
  },
];

const DURATIONS = [
  { months: 1, label: "1 Month", discount: 0 },
  { months: 3, label: "3 Months", discount: 5 },
  { months: 6, label: "6 Months", discount: 10 },
  { months: 12, label: "12 Months", discount: 20 },
];

function RenewalModal({ onClose, initialPlan }: { onClose: () => void; initialPlan?: Plan | null }) {
  const [step, setStep] = useState<RenewStep>("plan");
  const [selectedPlan, setSelectedPlan] = useState<Plan>(initialPlan ?? PLANS[2]);
  const [selectedDuration, setSelectedDuration] = useState(DURATIONS[0]);
  const [cardNumber, setCardNumber] = useState("");
  const [expiry, setExpiry] = useState("");
  const [cvv, setCvv] = useState("");
  const [cardName, setCardName] = useState("");

  const discountedPrice = selectedPlan.price * (1 - selectedDuration.discount / 100);
  const total = discountedPrice * selectedDuration.months;

  const formatCard = (val: string) =>
    val.replace(/\D/g, "").slice(0, 16).replace(/(.{4})/g, "$1 ").trim();

  const formatExpiry = (val: string) => {
    const cleaned = val.replace(/\D/g, "").slice(0, 4);
    return cleaned.length >= 3 ? cleaned.slice(0, 2) + "/" + cleaned.slice(2) : cleaned;
  };

  const stepIndex = { plan: 0, duration: 1, payment: 2, success: 3 };
  const currentIndex = stepIndex[step];

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/70 backdrop-blur-sm">
      <div className="bg-[#111111] w-full max-w-md rounded-t-3xl border-t border-x border-[#2a2a2a] max-h-[92vh] overflow-y-auto">
        {/* Handle */}
        <div className="flex justify-center pt-3 pb-1">
          <div className="w-10 h-1 rounded-full bg-[#3a3a3a]" />
        </div>

        {step !== "success" && (
          <div className="flex items-center justify-between px-6 py-4 border-b border-[#2a2a2a]">
            <div className="flex items-center gap-3">
              {currentIndex > 0 && (
                <button
                  onClick={() => {
                    const steps: RenewStep[] = ["plan", "duration", "payment"];
                    setStep(steps[currentIndex - 1]);
                  }}
                  className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center"
                >
                  <ChevronLeft className="w-4 h-4" />
                </button>
              )}
              <div>
                <p className="text-xs text-gray-400">Step {currentIndex + 1} of 3</p>
                <h3 className="text-white font-medium">
                  {step === "plan" && "Choose Plan"}
                  {step === "duration" && "Select Duration"}
                  {step === "payment" && "Payment Details"}
                </h3>
              </div>
            </div>
            <button
              onClick={onClose}
              className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center"
            >
              <X className="w-4 h-4 text-gray-400" />
            </button>
          </div>
        )}

        <div className="px-6 py-5">
          {/* Step 1: Plan */}
          {step === "plan" && (
            <div className="space-y-4">
              <p className="text-gray-400 text-sm">Select the plan you want to renew with.</p>
              <div className="space-y-3">
                {PLANS.map((plan) => (
                  <button
                    key={plan.id}
                    onClick={() => setSelectedPlan(plan)}
                    className={`w-full text-left rounded-xl p-4 border transition-all ${
                      selectedPlan.id === plan.id
                        ? "border-[#dc143c] bg-[#dc143c]/10"
                        : "border-[#2a2a2a] bg-[#1a1a1a] hover:border-[#dc143c]/40"
                    }`}
                  >
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex items-center gap-2">
                        <div
                          className={`w-5 h-5 rounded-full border-2 flex items-center justify-center transition-colors ${
                            selectedPlan.id === plan.id
                              ? "border-[#dc143c] bg-[#dc143c]"
                              : "border-[#3a3a3a]"
                          }`}
                        >
                          {selectedPlan.id === plan.id && (
                            <Check className="w-3 h-3 text-white" />
                          )}
                        </div>
                        <span className="text-white font-medium">{plan.name}</span>
                        {plan.id === "elite" && (
                          <span className="text-xs bg-[#dc143c] text-white px-2 py-0.5 rounded-full">
                            Current
                          </span>
                        )}
                      </div>
                      <span className="text-[#dc143c] font-semibold">
                        {plan.price.toLocaleString()} LE
                        <span className="text-xs text-gray-400">/mo</span>
                      </span>
                    </div>
                    <div className="space-y-1 pl-7">
                      {plan.features.slice(0, 2).map((f) => (
                        <p key={f} className="text-xs text-gray-400 flex items-center gap-1">
                          <Check className="w-3 h-3 text-[#dc143c]" /> {f}
                        </p>
                      ))}
                      {plan.features.length > 2 && (
                        <p className="text-xs text-gray-500">
                          +{plan.features.length - 2} more
                        </p>
                      )}
                    </div>
                  </button>
                ))}
              </div>
              <button
                onClick={() => setStep("duration")}
                className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium flex items-center justify-center gap-2"
              >
                Continue <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          )}

          {/* Step 2: Duration */}
          {step === "duration" && (
            <div className="space-y-4">
              <p className="text-gray-400 text-sm">
                Longer commitments save you more.
              </p>
              <div className="space-y-3">
                {DURATIONS.map((d) => {
                  const discounted = selectedPlan.price * (1 - d.discount / 100);
                  return (
                    <button
                      key={d.months}
                      onClick={() => setSelectedDuration(d)}
                      className={`w-full text-left rounded-xl p-4 border transition-all ${
                        selectedDuration.months === d.months
                          ? "border-[#dc143c] bg-[#dc143c]/10"
                          : "border-[#2a2a2a] bg-[#1a1a1a] hover:border-[#dc143c]/40"
                      }`}
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <div
                            className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${
                              selectedDuration.months === d.months
                                ? "border-[#dc143c] bg-[#dc143c]"
                                : "border-[#3a3a3a]"
                            }`}
                          >
                            {selectedDuration.months === d.months && (
                              <Check className="w-3 h-3 text-white" />
                            )}
                          </div>
                          <div>
                            <p className="text-white font-medium">{d.label}</p>
                            {d.discount > 0 && (
                              <p className="text-xs text-green-400">Save {d.discount}%</p>
                            )}
                          </div>
                        </div>
                        <div className="text-right">
                          <p className="text-white font-semibold">
                            {(discounted * d.months).toLocaleString("en-EG", { maximumFractionDigits: 0 })} LE
                          </p>
                          {d.discount > 0 && (
                            <p className="text-xs text-gray-500 line-through">
                              {(selectedPlan.price * d.months).toLocaleString()} LE
                            </p>
                          )}
                        </div>
                      </div>
                    </button>
                  );
                })}
              </div>

              <div className="bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a]">
                <div className="flex justify-between text-sm text-gray-400 mb-1">
                  <span>{selectedPlan.name}</span>
                  <span>{selectedPlan.price.toLocaleString()} LE/mo</span>
                </div>
                {selectedDuration.discount > 0 && (
                  <div className="flex justify-between text-sm text-green-400 mb-1">
                    <span>Discount ({selectedDuration.discount}%)</span>
                    <span>
                      -{((selectedPlan.price * selectedDuration.discount) / 100).toLocaleString("en-EG", { maximumFractionDigits: 0 })} LE/mo
                    </span>
                  </div>
                )}
                <div className="flex justify-between font-semibold text-white border-t border-[#2a2a2a] pt-2 mt-2">
                  <span>Total</span>
                  <span>{total.toLocaleString("en-EG", { maximumFractionDigits: 0 })} LE</span>
                </div>
              </div>

              <button
                onClick={() => setStep("payment")}
                className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium flex items-center justify-center gap-2"
              >
                Continue to Payment <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          )}

          {/* Step 3: Payment */}
          {step === "payment" && (
            <div className="space-y-5">
              <p className="text-gray-400 text-sm">Enter your payment details to complete renewal.</p>

              {/* Summary pill */}
              <div className="bg-[#dc143c]/10 border border-[#dc143c]/30 rounded-xl p-3 flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Zap className="w-4 h-4 text-[#dc143c]" />
                  <span className="text-sm text-white">{selectedPlan.name}</span>
                  <span className="text-xs text-gray-400">· {selectedDuration.label}</span>
                </div>
                <span className="text-[#dc143c] font-semibold">{total.toLocaleString("en-EG", { maximumFractionDigits: 0 })} LE</span>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="text-xs text-gray-400 mb-1.5 block">Name on Card</label>
                  <input
                    type="text"
                    placeholder="John Doe"
                    value={cardName}
                    onChange={(e) => setCardName(e.target.value)}
                    className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors"
                  />
                </div>
                <div>
                  <label className="text-xs text-gray-400 mb-1.5 block">Card Number</label>
                  <div className="relative">
                    <input
                      type="text"
                      placeholder="1234 5678 9012 3456"
                      value={cardNumber}
                      onChange={(e) => setCardNumber(formatCard(e.target.value))}
                      className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors pr-12"
                    />
                    <CreditCard className="absolute right-4 top-3.5 w-5 h-5 text-gray-600" />
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="text-xs text-gray-400 mb-1.5 block">Expiry</label>
                    <input
                      type="text"
                      placeholder="MM/YY"
                      value={expiry}
                      onChange={(e) => setExpiry(formatExpiry(e.target.value))}
                      className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors"
                    />
                  </div>
                  <div>
                    <label className="text-xs text-gray-400 mb-1.5 block">CVV</label>
                    <input
                      type="text"
                      placeholder="123"
                      value={cvv}
                      onChange={(e) => setCvv(e.target.value.replace(/\D/g, "").slice(0, 3))}
                      className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors"
                    />
                  </div>
                </div>
              </div>

              <div className="bg-[#1a1a1a] rounded-xl p-3 flex items-center gap-2 border border-[#2a2a2a]">
                <div className="w-1.5 h-1.5 rounded-full bg-green-400" />
                <p className="text-xs text-gray-400">Payments are encrypted and secure</p>
              </div>

              <button
                onClick={() => setStep("success")}
                disabled={!cardName || cardNumber.length < 19 || expiry.length < 5 || cvv.length < 3}
                className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium disabled:opacity-40 disabled:cursor-not-allowed"
              >
                Pay {total.toLocaleString("en-EG", { maximumFractionDigits: 0 })} LE
              </button>
            </div>
          )}

          {/* Step 4: Success */}
          {step === "success" && (
            <div className="py-8 flex flex-col items-center text-center space-y-5">
              <div className="w-20 h-20 rounded-full bg-[#dc143c]/20 flex items-center justify-center">
                <div className="w-14 h-14 rounded-full bg-[#dc143c] flex items-center justify-center">
                  <Check className="w-8 h-8 text-white" />
                </div>
              </div>
              <div>
                <h3 className="text-2xl text-white mb-2">All Set!</h3>
                <p className="text-gray-400 text-sm">
                  Your <span className="text-white">{selectedPlan.name}</span> membership has been
                  renewed for <span className="text-white">{selectedDuration.label}</span>.
                </p>
              </div>
              <div className="w-full bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a] space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-gray-400">Plan</span>
                  <span className="text-white">{selectedPlan.name}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Duration</span>
                  <span className="text-white">{selectedDuration.label}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Amount charged</span>
                  <span className="text-white">{total.toLocaleString("en-EG", { maximumFractionDigits: 0 })} LE</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Next renewal</span>
                  <span className="text-white">
                    {new Date(
                      new Date().setMonth(new Date().getMonth() + selectedDuration.months)
                    ).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })}
                  </span>
                </div>
              </div>
              <button
                onClick={onClose}
                className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium"
              >
                Done
              </button>
            </div>
          )}
        </div>
        <div className="h-6" />
      </div>
    </div>
  );
}

function GuestSubscription() {
  const { tr, lang, dir } = useLang();
  const { triggerRegistration } = useAppContext();
  const [selectedPlan, setSelectedPlan] = useState<Plan | null>(null);
  const [step, setStep] = useState<"list" | "confirm">("list");

  const GUEST_PLANS: Plan[] = [
    { id: "basic", name: lang === "ar" ? "أساسية" : "Basic", price: 1499, features: lang === "ar" ? ["دخول الصالة (ساعات غير الذروة)","فصلان جماعيان أسبوعياً"] : ["Gym access (off-peak hours)","2 group classes per week"] },
    { id: "standard", name: lang === "ar" ? "قياسية" : "Standard", price: 2199, features: lang === "ar" ? ["دخول الصالة 24/7","فصول جماعية غير محدودة","فحص InBody ربع سنوي"] : ["24/7 gym access","Unlimited group classes","Quarterly InBody scan"] },
    { id: "elite", name: lang === "ar" ? "بريميوم إيليت" : "Premium Elite", price: 2999, features: lang === "ar" ? ["دخول غير محدود للصالة","جميع الفصول الجماعية مشمولة","فحص InBody شهري","خطط وجبات شخصية","أولوية الحجز"] : ["Unlimited gym access","All group classes","Monthly InBody scan","Personalized meal plans","Priority booking"] },
  ];

  if (step === "confirm" && selectedPlan) {
    return (
      <div dir={dir} className="p-5 space-y-5">
        <button onClick={() => setStep("list")} className="flex items-center gap-2 text-gray-400 hover:text-white text-sm mb-2">
          <ChevronLeft className="w-4 h-4 rtl:rotate-180" />{tr("back")}
        </button>
        <div className="bg-gradient-to-br from-[#dc143c] to-[#a00f2c] rounded-2xl p-5">
          <h3 className="text-xl mb-1">{selectedPlan.name}</h3>
          <p className="text-3xl font-light">{selectedPlan.price.toLocaleString()} <span className="text-base">LE/mo</span></p>
        </div>
        <div className="bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a] space-y-2">
          {selectedPlan.features.map((f) => (
            <div key={f} className="flex items-center gap-2 text-sm text-gray-300"><Check className="w-4 h-4 text-[#dc143c]" />{f}</div>
          ))}
        </div>
        <div className="bg-[#dc143c]/10 border border-[#dc143c]/30 rounded-xl p-4 text-sm text-gray-300">
          {lang === "ar" ? "بعد الاشتراك سيراجع فريقنا طلبك ويفعّل حسابك خلال 24 ساعة." : "After subscribing, our team will review your application and activate your account within 24 hours."}
        </div>
        <button onClick={() => { triggerRegistration(selectedPlan?.id); }} className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium">
          {tr("subscribeNow")}
        </button>
      </div>
    );
  }

  return (
    <div dir={dir} className="p-5 space-y-6">
      <div>
        <h2 className="text-2xl mb-1">{tr("choosePlan")}</h2>
        <p className="text-gray-400 text-sm">{lang === "ar" ? "اختر الباقة المناسبة لأهدافك" : "Choose the plan that fits your goals"}</p>
      </div>
      <div className="space-y-4">
        {GUEST_PLANS.map((plan, i) => (
          <div key={plan.id} className={`rounded-2xl p-5 border ${i===1?"bg-gradient-to-br from-[#dc143c]/15 to-transparent border-[#dc143c]/40":"bg-[#1a1a1a] border-[#2a2a2a]"}`}>
            <div className="flex items-start justify-between mb-3">
              <div>
                {i===1 && <span className="text-xs bg-[#dc143c] text-white px-2 py-0.5 rounded-full mb-2 inline-block">{tr("mostPopular")}</span>}
                <h3 className="text-xl text-white">{plan.name}</h3>
                <p className="text-2xl text-[#dc143c] mt-1">{plan.price.toLocaleString()} <span className="text-sm text-gray-400">LE/mo</span></p>
              </div>
            </div>
            <div className="space-y-1.5 mb-4">
              {plan.features.map((f) => (<div key={f} className="flex items-center gap-2 text-sm text-gray-400"><Check className="w-3.5 h-3.5 text-[#dc143c]" />{f}</div>))}
            </div>
            <button onClick={() => triggerRegistration(plan.id)}
              className={`w-full py-3 rounded-xl text-sm font-medium transition-colors ${i===1?"bg-[#dc143c] text-white hover:bg-[#a00f2c]":"border border-[#dc143c] text-[#dc143c] hover:bg-[#dc143c] hover:text-white"}`}>
              {tr("subscribeNow")}
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}

export function Subscription() {
  const { mode } = useAuth();
  const [showRenewal, setShowRenewal] = useState(false);
  const [initialPlan, setInitialPlan] = useState<Plan | null>(null);

  const openRenewal = (plan?: Plan) => {
    setInitialPlan(plan ?? null);
    setShowRenewal(true);
  };

  if (mode === "guest") return <GuestSubscription />;

  return (
    <>
      <div className="p-6 space-y-6">
        <div>
          <h2 className="text-2xl mb-2">Your Membership</h2>
          <p className="text-gray-400">Manage your subscription plan</p>
        </div>

        {/* Current Plan Card */}
        <div className="bg-gradient-to-br from-[#dc143c] to-[#a00f2c] rounded-2xl p-6 relative overflow-hidden">
          <div className="absolute top-0 right-0 w-40 h-40 bg-white/10 rounded-full -mr-20 -mt-20" />
          <div className="absolute bottom-0 left-0 w-32 h-32 bg-white/5 rounded-full -ml-16 -mb-16" />
          <div className="relative z-10">
            <div className="flex items-start justify-between mb-4">
              <div>
                <p className="text-white/80 text-sm mb-1">CURRENT PLAN</p>
                <h3 className="text-2xl">Premium Elite</h3>
              </div>
              <div className="bg-white/20 px-3 py-1 rounded-full">
                <p className="text-sm">Active</p>
              </div>
            </div>
            <div className="space-y-2 mb-6">
              {[
                "Unlimited gym access",
                "All group classes included",
                "Monthly InBody scan",
                "Personalized meal plans",
                "Priority booking",
              ].map((f) => (
                <div key={f} className="flex items-center gap-2 text-white/90">
                  <Check className="w-4 h-4" />
                  <span className="text-sm">{f}</span>
                </div>
              ))}
            </div>
            <div className="flex items-center justify-between pt-4 border-t border-white/20">
              <div>
                <p className="text-white/80 text-sm">Monthly Payment</p>
                <p className="text-3xl">2,999 <span className="text-lg">LE/mo</span></p>
              </div>
            </div>
          </div>
        </div>

        {/* Billing Info */}
        <div className="bg-[#1a1a1a] rounded-xl p-5 border border-[#2a2a2a] space-y-4">
          <h3 className="text-lg">Billing Information</h3>
          <div className="flex items-center justify-between py-3 border-b border-[#2a2a2a]">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-[#dc143c]/20 rounded-lg flex items-center justify-center">
                <Calendar className="w-5 h-5 text-[#dc143c]" />
              </div>
              <div>
                <p className="text-sm text-gray-400">Next billing date</p>
                <p className="text-white">July 28, 2026</p>
              </div>
            </div>
          </div>
          <div className="flex items-center justify-between py-3 border-b border-[#2a2a2a]">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-[#dc143c]/20 rounded-lg flex items-center justify-center">
                <CreditCard className="w-5 h-5 text-[#dc143c]" />
              </div>
              <div>
                <p className="text-sm text-gray-400">Payment method</p>
                <p className="text-white">Visa •••• 4242</p>
              </div>
            </div>
            <button onClick={() => openRenewal()} className="text-[#dc143c] text-sm hover:underline">Update</button>
          </div>
          <div className="flex items-center justify-between py-3">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-green-500/20 rounded-lg flex items-center justify-center">
                <Check className="w-5 h-5 text-green-500" />
              </div>
              <div>
                <p className="text-sm text-gray-400">Auto-renewal</p>
                <p className="text-white">Enabled</p>
              </div>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input type="checkbox" className="sr-only peer" defaultChecked />
              <div className="w-11 h-6 bg-[#2a2a2a] peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#dc143c]" />
            </label>
          </div>
        </div>

        {/* Renew Button */}
        <button
          onClick={() => openRenewal()}
          className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium"
        >
          Renew Subscription Now
        </button>

        {/* Other Plans */}
        <div className="space-y-3">
          <h3 className="text-lg">Other Plans</h3>
          <div className="bg-[#1a1a1a] rounded-xl p-5 border border-[#2a2a2a]">
            <div className="flex items-start justify-between mb-3">
              <div>
                <h4 className="text-lg mb-1">Basic</h4>
                <p className="text-2xl text-[#dc143c]">1,499 <span className="text-sm text-gray-400">LE/mo</span></p>
              </div>
            </div>
            <div className="space-y-2 mb-4">
              {["Gym access (off-peak hours)", "2 group classes per week"].map((f) => (
                <div key={f} className="flex items-center gap-2 text-gray-400 text-sm">
                  <Check className="w-4 h-4" /><span>{f}</span>
                </div>
              ))}
            </div>
            <button
              onClick={() => openRenewal(PLANS[0])}
              className="w-full bg-transparent border border-[#dc143c] text-[#dc143c] py-2 rounded-lg text-sm hover:bg-[#dc143c] hover:text-white transition-colors"
            >
              Downgrade to Basic
            </button>
          </div>

          <div className="bg-[#1a1a1a] rounded-xl p-5 border border-[#2a2a2a]">
            <div className="flex items-start justify-between mb-3">
              <div>
                <h4 className="text-lg mb-1">Standard</h4>
                <p className="text-2xl text-[#dc143c]">2,199 <span className="text-sm text-gray-400">LE/mo</span></p>
              </div>
            </div>
            <div className="space-y-2 mb-4">
              {["24/7 gym access", "Unlimited group classes", "Quarterly InBody scan"].map((f) => (
                <div key={f} className="flex items-center gap-2 text-gray-400 text-sm">
                  <Check className="w-4 h-4" /><span>{f}</span>
                </div>
              ))}
            </div>
            <button
              onClick={() => openRenewal(PLANS[1])}
              className="w-full bg-transparent border border-[#dc143c] text-[#dc143c] py-2 rounded-lg text-sm hover:bg-[#dc143c] hover:text-white transition-colors"
            >
              Downgrade to Standard
            </button>
          </div>
        </div>

        {/* Cancel Notice */}
        <div className="bg-[#dc143c]/10 border border-[#dc143c]/30 rounded-xl p-4 flex gap-3">
          <AlertCircle className="w-5 h-5 text-[#dc143c] flex-shrink-0 mt-0.5" />
          <div>
            <p className="text-sm mb-2">
              Need to pause or cancel? Contact our support team and we'll help you find the best solution.
            </p>
            <button onClick={() => setShowRenewal(true)} className="text-sm text-[#dc143c] underline hover:no-underline">
              Contact Support
            </button>
          </div>
        </div>
      </div>

      {showRenewal && <RenewalModal onClose={() => setShowRenewal(false)} initialPlan={initialPlan} />}
    </>
  );
}
