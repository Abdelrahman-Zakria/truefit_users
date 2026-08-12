import { useState } from "react";
import { Clock, CheckCircle, MessageCircle, X, Send } from "lucide-react";
import { useAuth } from "../../lib/AuthContext";
import { useLang } from "../../lib/LanguageContext";
import logo from "../../imports/logo-only.jpeg";

function SupportSheet({ onClose }: { onClose: () => void }) {
  const { tr, dir } = useLang();
  const [msg, setMsg] = useState("");
  const [sent, setSent] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSend = async () => {
    if (!msg.trim()) return;
    setLoading(true);
    await new Promise((r) => setTimeout(r, 1000));
    setLoading(false);
    setSent(true);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/75 backdrop-blur-sm">
      <div dir={dir} className="bg-[#111] w-full max-w-md rounded-t-3xl border-t border-x border-[#2a2a2a] max-h-[80vh] overflow-y-auto">
        <div className="flex justify-center pt-3"><div className="w-10 h-1 rounded-full bg-[#3a3a3a]" /></div>
        <div className="flex items-center justify-between px-5 py-4 border-b border-[#2a2a2a]">
          <h3 className="font-medium text-white">{tr("supportTitle")}</h3>
          <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center">
            <X className="w-4 h-4 text-gray-400" />
          </button>
        </div>
        <div className="px-5 py-5 space-y-4">
          {sent ? (
            <div className="text-center py-6 space-y-4">
              <div className="w-14 h-14 rounded-full bg-green-500/20 flex items-center justify-center mx-auto">
                <CheckCircle className="w-7 h-7 text-green-400" />
              </div>
              <p className="text-white font-medium">{tr("messageSent")}</p>
              <button onClick={onClose} className="w-full bg-[#dc143c] text-white py-3.5 rounded-xl">OK</button>
            </div>
          ) : (
            <>
              <div className="bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a] space-y-3">
                {[
                  { label: tr("supportEmail"), val: tr("supportEmail") },
                  { label: tr("supportPhone"), val: tr("supportPhone") },
                  { label: tr("supportHours"), val: tr("supportHours") },
                ].map(({ label, val }) => (
                  <div key={label} className="flex justify-between text-sm">
                    <span className="text-gray-400">{label.includes("@") || label.includes("+") || label.includes("–") ? (label.includes("@") ? "Email" : label.includes("+") ? "Phone" : "Hours") : label}</span>
                    <span className="text-white font-medium">{val}</span>
                  </div>
                ))}
              </div>
              <div>
                <label className="text-xs text-gray-400 mb-1.5 block">{tr("yourMessage")}</label>
                <textarea rows={4} placeholder={tr("yourMessage")} value={msg}
                  onChange={(e) => setMsg(e.target.value)}
                  className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors resize-none" />
              </div>
              <button onClick={handleSend} disabled={!msg.trim() || loading}
                className="w-full bg-[#dc143c] text-white py-3.5 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium disabled:opacity-50 flex items-center justify-center gap-2">
                {loading
                  ? <span className="flex items-center gap-2"><span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />Sending…</span>
                  : <><Send className="w-4 h-4" />{tr("sendMessage")}</>}
              </button>
            </>
          )}
        </div>
        <div className="h-6" />
      </div>
    </div>
  );
}

export function Pending() {
  const { user, approveMembership, logout } = useAuth();
  const { tr, dir, lang, setLang } = useLang();
  const [showSupport, setShowSupport] = useState(false);

  return (
    <div dir={dir} className="fixed inset-0 bg-[#0a0a0a] flex flex-col items-center justify-center px-6 max-w-md mx-auto overflow-y-auto py-10">
      {/* Lang toggle */}
      <div className="absolute top-4 end-4 flex gap-1">
        {(["en", "ar"] as const).map((l) => (
          <button key={l} onClick={() => setLang(l)}
            className={`w-9 h-9 rounded-full text-xs font-bold transition-colors ${lang === l ? "bg-[#dc143c] text-white" : "bg-[#1a1a1a] text-gray-400 border border-[#2a2a2a]"}`}>
            {l.toUpperCase()}
          </button>
        ))}
      </div>

      {/* Logo */}
      <div className="w-20 h-20 rounded-2xl overflow-hidden border border-[#dc143c]/30 shadow-lg shadow-[#dc143c]/20 mb-8">
        <img src={logo} alt="True Fit" className="w-full h-full object-cover" />
      </div>

      {/* Animated clock */}
      <div className="relative mb-6">
        <div className="w-24 h-24 rounded-full bg-[#dc143c]/10 border border-[#dc143c]/30 flex items-center justify-center">
          <Clock className="w-10 h-10 text-[#dc143c]" style={{ animation: "spin 4s linear infinite" }} />
        </div>
        <div className="absolute -bottom-1 -end-1 w-8 h-8 rounded-full bg-yellow-500/20 border border-yellow-500/40 flex items-center justify-center">
          <span className="text-yellow-400 text-xs font-bold">!</span>
        </div>
      </div>

      <h2 className="text-2xl font-light text-white mb-2 text-center">{tr("pendingTitle")}</h2>
      <p className="text-[#dc143c] font-medium mb-4 text-center">{tr("pendingSubtitle")}</p>

      <div className="bg-[#1a1a1a] border border-[#2a2a2a] rounded-2xl p-5 w-full mb-6 text-center space-y-3">
        {user && (
          <p className="text-gray-400 text-sm">
            <span className="text-white font-medium">{user.displayName}</span>
            {user.phone && <> · <span className="text-gray-400">{user.phone}</span></>}
          </p>
        )}
        <p className="text-gray-300 text-sm leading-relaxed">{tr("pendingMessage")}</p>
        <div className="flex items-center justify-center gap-2 text-gray-500 text-xs">
          <CheckCircle className="w-3.5 h-3.5 text-green-500" />
          {tr("pendingNote")}
        </div>
      </div>

      {/* Steps */}
      <div className="w-full space-y-2 mb-8">
        {[
          { step: "1", label: lang === "ar" ? "تقديم الطلب" : "Application submitted", done: true },
          { step: "2", label: lang === "ar" ? "مراجعة الإدارة" : "Admin review", done: false },
          { step: "3", label: lang === "ar" ? "تفعيل العضوية" : "Membership activated", done: false },
        ].map(({ step, label, done }) => (
          <div key={step} className="flex items-center gap-3">
            <div className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0 ${done ? "bg-green-500 text-white" : "bg-[#1a1a1a] border border-[#2a2a2a] text-gray-500"}`}>
              {done ? "✓" : step}
            </div>
            <span className={`text-sm ${done ? "text-white" : "text-gray-500"}`}>{label}</span>
          </div>
        ))}
      </div>

      <button onClick={() => setShowSupport(true)}
        className="w-full flex items-center justify-center gap-2 border border-[#2a2a2a] text-gray-300 py-3.5 rounded-xl hover:border-[#dc143c]/40 hover:text-white transition-colors mb-3">
        <MessageCircle className="w-4 h-4" />
        {tr("contactSupport")}
      </button>

      {/* Dev helper */}
      <button onClick={approveMembership}
        className="w-full bg-[#dc143c] text-white py-3.5 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium">
        {tr("simulateApproval")}
      </button>

      <button onClick={logout} className="mt-4 text-sm text-gray-600 hover:text-gray-400 transition-colors">
        {tr("signOut")}
      </button>

      {showSupport && <SupportSheet onClose={() => setShowSupport(false)} />}

      <style>{`@keyframes spin { from{transform:rotate(0deg)} to{transform:rotate(360deg)} }`}</style>
    </div>
  );
}
