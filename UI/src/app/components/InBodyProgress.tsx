import { useState } from "react";
import { TrendingUp, TrendingDown, Activity, Scale, X, Calendar, Clock, Check } from "lucide-react";
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, RadarChart, PolarGrid, PolarAngleAxis, PolarRadiusAxis, Radar } from "recharts";
import { useAuth } from "../../lib/AuthContext";
import { useLang } from "../../lib/LanguageContext";
import { GuestLockedTab } from "./GuestLockedTab";

// ─── Scan slots ───────────────────────────────────────────────────────────────

const SCAN_SLOTS = [
  { date: "Mon, Jul 14", times: ["09:00 AM", "10:00 AM", "11:00 AM", "02:00 PM"] },
  { date: "Tue, Jul 15", times: ["09:00 AM", "11:00 AM", "03:00 PM", "04:00 PM"] },
  { date: "Wed, Jul 16", times: ["10:00 AM", "01:00 PM", "02:00 PM", "05:00 PM"] },
  { date: "Thu, Jul 17", times: ["09:00 AM", "10:00 AM", "04:00 PM"] },
];

function BookScanSheet({ onClose }: { onClose: () => void }) {
  const { dir, lang } = useLang();
  const [selectedDate, setSelectedDate] = useState(0);
  const [selectedTime, setSelectedTime] = useState<string | null>(null);
  const [booked, setBooked] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleConfirm = async () => {
    if (!selectedTime) return;
    setLoading(true);
    await new Promise((r) => setTimeout(r, 1100));
    setLoading(false);
    setBooked(true);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/70 backdrop-blur-sm">
      <div dir={dir} className="bg-[#111111] w-full max-w-md rounded-t-3xl border-t border-x border-[#2a2a2a] max-h-[92vh] overflow-y-auto">
        <div className="flex justify-center pt-3 pb-1">
          <div className="w-10 h-1 rounded-full bg-[#3a3a3a]" />
        </div>

        {/* Header */}
        <div className="flex items-center justify-between px-5 py-4 border-b border-[#2a2a2a]">
          <div>
            <h3 className="font-semibold text-white">{lang === "ar" ? "حجز فحص InBody" : "Book InBody Scan"}</h3>
            <p className="text-xs text-gray-400 mt-0.5">{lang === "ar" ? "تحليل تكوين الجسم" : "Body composition analysis"}</p>
          </div>
          <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center">
            <X className="w-4 h-4 text-gray-400" />
          </button>
        </div>

        <div className="px-5 py-5 space-y-5">
          {booked ? (
            <div className="text-center py-6 space-y-4">
              <div className="w-16 h-16 rounded-full bg-[#dc143c]/20 flex items-center justify-center mx-auto">
                <Check className="w-8 h-8 text-[#dc143c]" />
              </div>
              <div>
                <h4 className="text-white font-semibold text-lg">{lang === "ar" ? "تم الحجز!" : "Scan Booked!"}</h4>
                <p className="text-gray-400 text-sm mt-1">
                  {SCAN_SLOTS[selectedDate].date} · {selectedTime}
                </p>
                <p className="text-gray-500 text-xs mt-2">
                  {lang === "ar" ? "سنرسل لك تذكيراً قبل الموعد" : "We'll send you a reminder before your appointment"}
                </p>
              </div>
              <button onClick={onClose} className="w-full bg-[#dc143c] text-white py-3.5 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium">
                {lang === "ar" ? "تم" : "Done"}
              </button>
            </div>
          ) : (
            <>
              {/* Duration & price info */}
              <div className="bg-[#dc143c]/10 border border-[#dc143c]/25 rounded-xl px-4 py-3 flex items-center gap-3">
                <Activity className="w-5 h-5 text-[#dc143c] flex-shrink-0" />
                <div>
                  <p className="text-white text-sm font-medium">{lang === "ar" ? "فحص InBody 970" : "InBody 970 Scan"}</p>
                  <p className="text-gray-400 text-xs">{lang === "ar" ? "15 دقيقة · مجاني للأعضاء" : "15 min · Free for members"}</p>
                </div>
              </div>

              {/* Date picker */}
              <div>
                <div className="flex items-center gap-2 mb-3">
                  <Calendar className="w-4 h-4 text-gray-400" />
                  <span className="text-sm text-gray-400">{lang === "ar" ? "اختر التاريخ" : "Select Date"}</span>
                </div>
                <div className="flex gap-2 overflow-x-auto pb-1 -mx-1 px-1">
                  {SCAN_SLOTS.map((slot, i) => {
                    const [day, rest] = slot.date.split(", ");
                    return (
                      <button key={i} onClick={() => { setSelectedDate(i); setSelectedTime(null); }}
                        className={`flex-shrink-0 flex flex-col items-center px-4 py-3 rounded-xl border transition-all ${selectedDate === i ? "bg-[#dc143c] border-[#dc143c] text-white" : "bg-[#1a1a1a] border-[#2a2a2a] text-gray-400 hover:border-[#dc143c]/40"}`}>
                        <span className="text-xs font-medium">{day}</span>
                        <span className="text-sm mt-0.5">{rest}</span>
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Time picker */}
              <div>
                <div className="flex items-center gap-2 mb-3">
                  <Clock className="w-4 h-4 text-gray-400" />
                  <span className="text-sm text-gray-400">{lang === "ar" ? "اختر الوقت" : "Select Time"}</span>
                </div>
                <div className="grid grid-cols-3 gap-2">
                  {SCAN_SLOTS[selectedDate].times.map((time) => (
                    <button key={time} onClick={() => setSelectedTime(time)}
                      className={`py-2.5 rounded-xl border text-sm transition-all ${selectedTime === time ? "bg-[#dc143c] border-[#dc143c] text-white" : "bg-[#1a1a1a] border-[#2a2a2a] text-gray-300 hover:border-[#dc143c]/40"}`}>
                      {time}
                    </button>
                  ))}
                </div>
              </div>

              {/* Summary */}
              {selectedTime && (
                <div className="bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl px-4 py-3 text-sm">
                  <div className="flex justify-between">
                    <span className="text-gray-400">{lang === "ar" ? "التاريخ" : "Date"}</span>
                    <span className="text-white">{SCAN_SLOTS[selectedDate].date}</span>
                  </div>
                  <div className="flex justify-between mt-2">
                    <span className="text-gray-400">{lang === "ar" ? "الوقت" : "Time"}</span>
                    <span className="text-white">{selectedTime}</span>
                  </div>
                </div>
              )}

              <button onClick={handleConfirm} disabled={!selectedTime || loading}
                className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium disabled:opacity-40 flex items-center justify-center gap-2">
                {loading
                  ? <><span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />{lang === "ar" ? "جاري الحجز..." : "Booking…"}</>
                  : lang === "ar" ? "تأكيد الحجز" : "Confirm Booking"}
              </button>
            </>
          )}
        </div>
        <div className="h-6" />
      </div>
    </div>
  );
}

export function InBodyProgress() {
  const { mode } = useAuth();
  const { tr } = useLang();
  const [showScanSheet, setShowScanSheet] = useState(false);
  if (mode === "guest") return <GuestLockedTab icon={<TrendingUp className="w-12 h-12 text-gray-600" />} featureKey={tr("lockProgress")} />;
  const weightData = [
    { month: "Jan", weight: 84.0 },
    { month: "Feb", weight: 83.0 },
    { month: "Mar", weight: 81.6 },
    { month: "Apr", weight: 80.7 },
    { month: "May", weight: 79.8 },
    { month: "Jun", weight: 79.0 },
  ];

  const bodyFatData = [
    { month: "Jan", fat: 22.0 },
    { month: "Feb", fat: 20.5 },
    { month: "Mar", fat: 19.0 },
    { month: "Apr", fat: 17.5 },
    { month: "May", fat: 16.2 },
    { month: "Jun", fat: 15.0 },
  ];

  const muscleMassData = [
    { month: "Jan", muscle: 64.4 },
    { month: "Feb", muscle: 65.3 },
    { month: "Mar", muscle: 66.2 },
    { month: "Apr", muscle: 67.1 },
    { month: "May", muscle: 68.0 },
    { month: "Jun", muscle: 68.9 },
  ];

  const bodyComposition = [
    { subject: "Muscle", current: 87, ideal: 90 },
    { subject: "Body Fat", current: 15, ideal: 12 },
    { subject: "Hydration", current: 62, ideal: 65 },
    { subject: "Bone Mass", current: 88, ideal: 85 },
    { subject: "Protein", current: 85, ideal: 88 },
  ];

  const tooltipStyle = {
    contentStyle: {
      backgroundColor: "#1a1a1a",
      border: "1px solid #2a2a2a",
      borderRadius: "8px",
      color: "#fff",
    },
  };

  return (
    <div className="p-6 space-y-6 pb-24">
      <div>
        <h2 className="text-2xl mb-2">InBody Progress</h2>
        <p className="text-gray-400">Track your body composition</p>
      </div>

      {/* Latest Scan Summary */}
      <div className="bg-gradient-to-br from-[#dc143c] to-[#a00f2c] rounded-2xl p-6 relative overflow-hidden">
        <div className="absolute top-0 right-0 w-40 h-40 bg-white/10 rounded-full -mr-20 -mt-20" />
        <div className="absolute bottom-0 left-0 w-32 h-32 bg-white/5 rounded-full -ml-16 -mb-16" />
        <div className="relative z-10">
          <p className="text-white/80 text-sm mb-1">LATEST SCAN</p>
          <h3 className="text-2xl mb-4">June 28, 2026</h3>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <p className="text-white/80 text-sm mb-1">Body Weight</p>
              <div className="flex items-end gap-2">
                <p className="text-3xl">79.0</p>
                <p className="text-lg mb-1">kg</p>
              </div>
              <div className="flex items-center gap-1 text-sm text-white/90 mt-1">
                <TrendingDown className="w-4 h-4" />
                <span>-0.8 kg</span>
              </div>
            </div>
            <div>
              <p className="text-white/80 text-sm mb-1">Body Fat</p>
              <div className="flex items-end gap-2">
                <p className="text-3xl">15.0</p>
                <p className="text-lg mb-1">%</p>
              </div>
              <div className="flex items-center gap-1 text-sm text-white/90 mt-1">
                <TrendingDown className="w-4 h-4" />
                <span>-1.2%</span>
              </div>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4 mt-4">
            <div>
              <p className="text-white/80 text-sm mb-1">Muscle Mass</p>
              <div className="flex items-end gap-2">
                <p className="text-3xl">68.9</p>
                <p className="text-lg mb-1">kg</p>
              </div>
              <div className="flex items-center gap-1 text-sm text-white/90 mt-1">
                <TrendingUp className="w-4 h-4" />
                <span>+0.9 kg</span>
              </div>
            </div>
            <div>
              <p className="text-white/80 text-sm mb-1">BMI</p>
              <div className="flex items-end gap-2">
                <p className="text-3xl">23.2</p>
              </div>
              <div className="flex items-center gap-1 text-sm text-white/90 mt-1">
                <span>Normal Range</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-3 gap-3">
        <div className="bg-[#1a1a1a] rounded-xl p-4 text-center border border-[#2a2a2a]">
          <Scale className="w-6 h-6 text-[#dc143c] mx-auto mb-2" />
          <p className="text-2xl mb-1">-5</p>
          <p className="text-gray-400 text-xs">Weight Lost (kg)</p>
        </div>
        <div className="bg-[#1a1a1a] rounded-xl p-4 text-center border border-[#2a2a2a]">
          <Activity className="w-6 h-6 text-[#dc143c] mx-auto mb-2" />
          <p className="text-2xl mb-1">+4.5</p>
          <p className="text-gray-400 text-xs">Muscle Gain (kg)</p>
        </div>
        <div className="bg-[#1a1a1a] rounded-xl p-4 text-center border border-[#2a2a2a]">
          <TrendingDown className="w-6 h-6 text-[#dc143c] mx-auto mb-2" />
          <p className="text-2xl mb-1">-7%</p>
          <p className="text-gray-400 text-xs">Body Fat</p>
        </div>
      </div>

      {/* Weight Progress Chart */}
      <div className="bg-[#1a1a1a] rounded-xl p-5 border border-[#2a2a2a]">
        <h3 className="text-lg mb-4">Weight Trend</h3>
        <ResponsiveContainer width="100%" height={200}>
          <LineChart data={weightData}>
            <CartesianGrid strokeDasharray="3 3" stroke="#2a2a2a" />
            <XAxis dataKey="month" stroke="#666" style={{ fontSize: "12px" }} />
            <YAxis stroke="#666" style={{ fontSize: "12px" }} domain={[77, 86]} unit=" kg" />
            <Tooltip {...tooltipStyle} formatter={(v: number) => [`${v} kg`, "Weight"]} />
            <Line type="monotone" dataKey="weight" stroke="#dc143c" strokeWidth={3} dot={{ fill: "#dc143c", r: 5 }} activeDot={{ r: 7 }} />
          </LineChart>
        </ResponsiveContainer>
      </div>

      {/* Body Fat Chart */}
      <div className="bg-[#1a1a1a] rounded-xl p-5 border border-[#2a2a2a]">
        <h3 className="text-lg mb-4">Body Fat Percentage</h3>
        <ResponsiveContainer width="100%" height={200}>
          <LineChart data={bodyFatData}>
            <CartesianGrid strokeDasharray="3 3" stroke="#2a2a2a" />
            <XAxis dataKey="month" stroke="#666" style={{ fontSize: "12px" }} />
            <YAxis stroke="#666" style={{ fontSize: "12px" }} domain={[14, 23]} unit="%" />
            <Tooltip {...tooltipStyle} formatter={(v: number) => [`${v}%`, "Body Fat"]} />
            <Line type="monotone" dataKey="fat" stroke="#dc143c" strokeWidth={3} dot={{ fill: "#dc143c", r: 5 }} activeDot={{ r: 7 }} />
          </LineChart>
        </ResponsiveContainer>
      </div>

      {/* Muscle Mass Chart */}
      <div className="bg-[#1a1a1a] rounded-xl p-5 border border-[#2a2a2a]">
        <h3 className="text-lg mb-4">Muscle Mass Growth</h3>
        <ResponsiveContainer width="100%" height={200}>
          <BarChart data={muscleMassData}>
            <CartesianGrid strokeDasharray="3 3" stroke="#2a2a2a" />
            <XAxis dataKey="month" stroke="#666" style={{ fontSize: "12px" }} />
            <YAxis stroke="#666" style={{ fontSize: "12px" }} domain={[63, 71]} unit=" kg" />
            <Tooltip {...tooltipStyle} formatter={(v: number) => [`${v} kg`, "Muscle Mass"]} />
            <Bar dataKey="muscle" fill="#dc143c" radius={[8, 8, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>

      {/* Body Composition Radar */}
      <div className="bg-[#1a1a1a] rounded-xl p-5 border border-[#2a2a2a]">
        <h3 className="text-lg mb-4">Body Composition Analysis</h3>
        <ResponsiveContainer width="100%" height={280}>
          <RadarChart data={bodyComposition}>
            <PolarGrid stroke="#2a2a2a" />
            <PolarAngleAxis dataKey="subject" stroke="#666" style={{ fontSize: "12px" }} />
            <PolarRadiusAxis stroke="#666" domain={[0, 100]} />
            <Radar name="Current" dataKey="current" stroke="#dc143c" fill="#dc143c" fillOpacity={0.3} />
            <Radar name="Ideal" dataKey="ideal" stroke="#666" fill="#666" fillOpacity={0.1} />
            <Tooltip {...tooltipStyle} />
          </RadarChart>
        </ResponsiveContainer>
        <div className="flex justify-center gap-6 mt-2">
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 bg-[#dc143c] rounded-full" />
            <span className="text-sm text-gray-400">Current</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 bg-[#666] rounded-full" />
            <span className="text-sm text-gray-400">Ideal</span>
          </div>
        </div>
      </div>

      {/* Next Scan */}
      <div className="bg-[#dc143c]/10 border border-[#dc143c]/30 rounded-xl p-4">
        <h4 className="text-white mb-2">Next InBody Scan</h4>
        <p className="text-sm text-gray-300 mb-3">
          Schedule your next body composition scan to track progress
        </p>
        <button onClick={() => setShowScanSheet(true)} className="w-full bg-[#dc143c] text-white py-3 rounded-lg hover:bg-[#a00f2c] transition-colors">
          Book Next Scan
        </button>
      </div>

      {showScanSheet && <BookScanSheet onClose={() => setShowScanSheet(false)} />}
    </div>
  );
}
