import { useState } from "react";
import { Eye, EyeOff, Mail, Lock, User, ChevronLeft } from "lucide-react";
import { useAuth } from "../../lib/AuthContext";
import { useLang } from "../../lib/LanguageContext";
import logo from "../../imports/logo-only.jpeg";

export function Register({ onGoLogin }: { onGoLogin: () => void }) {
  const { register, error, clearError } = useAuth();
  const { tr, dir, lang, setLang } = useLang();
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [showPass, setShowPass] = useState(false);
  const [loading, setLoading] = useState(false);
  const [localError, setLocalError] = useState<string | null>(null);

  const displayError = localError || (error === "fillAllFields" ? tr("fillAllFields") : error ?? null);

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setLocalError(null);
    if (password !== confirm) { setLocalError(tr("passwordMatch")); return; }
    if (password.length < 6) { setLocalError(tr("passwordLength")); return; }
    setLoading(true);
    try { await register(name, email, password); } catch { /* error in ctx */ }
    finally { setLoading(false); }
  };

  return (
    <div dir={dir} className="fixed inset-0 bg-[#0a0a0a] flex flex-col overflow-y-auto max-w-md mx-auto">
      {/* Top bar */}
      <div className="flex items-center justify-between px-4 pt-4">
        <button onClick={() => { clearError(); onGoLogin(); }}
          className="w-9 h-9 rounded-full bg-[#1a1a1a] border border-[#2a2a2a] flex items-center justify-center">
          <ChevronLeft className="w-5 h-5 text-gray-300 rtl:rotate-180" />
        </button>
        <div className="flex gap-1">
          {(["en","ar"] as const).map((l) => (
            <button key={l} onClick={() => setLang(l)}
              className={`w-9 h-9 rounded-full text-xs font-bold transition-colors ${lang===l?"bg-[#dc143c] text-white":"bg-[#1a1a1a] text-gray-400 border border-[#2a2a2a]"}`}>
              {l.toUpperCase()}
            </button>
          ))}
        </div>
      </div>

      {/* Hero */}
      <div className="flex flex-col items-center pt-6 pb-6 px-6">
        <div className="w-20 h-20 rounded-2xl overflow-hidden border border-[#dc143c]/30 shadow-lg shadow-[#dc143c]/20 mb-4">
          <img src={logo} alt="True Fit" className="w-full h-full object-cover" />
        </div>
        <h2 className="text-2xl font-light text-white mb-1">{tr("createAccount")}</h2>
        <p className="text-gray-400 text-sm">{tr("joinToday")}</p>
      </div>

      <div className="flex-1 px-6 pb-10 space-y-4">
        {displayError && (
          <div className="bg-[#dc143c]/10 border border-[#dc143c]/40 rounded-xl px-4 py-3 flex items-center justify-between">
            <p className="text-sm text-[#dc143c]">{displayError}</p>
            <button onClick={() => { setLocalError(null); clearError(); }} className="text-[#dc143c] text-xl leading-none ms-2">×</button>
          </div>
        )}

        <form onSubmit={handleRegister} className="space-y-4">
          {[
            { label: tr("fullName"), val: name, set: setName, type: "text", icon: <User className="w-4 h-4" />, ph: "Alex Johnson" },
            { label: tr("email"), val: email, set: setEmail, type: "email", icon: <Mail className="w-4 h-4" />, ph: "you@example.com" },
          ].map(({ label, val, set, type, icon, ph }) => (
            <div key={label}>
              <label className="text-xs text-gray-400 mb-1.5 block">{label}</label>
              <div className="relative">
                <span className="absolute start-4 top-3.5 text-gray-500">{icon}</span>
                <input type={type} placeholder={ph} value={val} onChange={(e) => set(e.target.value)}
                  className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl ps-11 pe-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors" />
              </div>
            </div>
          ))}

          {[
            { label: tr("password"), val: password, set: setPassword, ph: "Min. 6 characters" },
            { label: tr("confirmPassword"), val: confirm, set: setConfirm, ph: "Repeat password" },
          ].map(({ label, val, set, ph }) => (
            <div key={label}>
              <label className="text-xs text-gray-400 mb-1.5 block">{label}</label>
              <div className="relative">
                <Lock className="absolute start-4 top-3.5 w-4 h-4 text-gray-500" />
                <input type={showPass ? "text" : "password"} placeholder={ph} value={val} onChange={(e) => set(e.target.value)}
                  className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl ps-11 pe-11 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors" />
                <button type="button" onClick={() => setShowPass(!showPass)}
                  className="absolute end-4 top-3.5 text-gray-500 hover:text-gray-300">
                  {showPass ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>
          ))}

          <p className="text-xs text-gray-500">
            {tr("agreeTerms")}{" "}
            <span className="text-[#dc143c]">{tr("terms")}</span>{" "}{tr("and")}{" "}
            <span className="text-[#dc143c]">{tr("privacy")}</span>.
          </p>

          <button type="submit" disabled={loading || !name || !email || !password || !confirm}
            className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium disabled:opacity-50 disabled:cursor-not-allowed">
            {loading
              ? <span className="flex items-center justify-center gap-2"><span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />{tr("creatingAccount")}</span>
              : tr("createAccount")}
          </button>
        </form>

        <p className="text-center text-gray-400 text-sm">
          {tr("alreadyHaveAccount")}{" "}
          <button onClick={() => { clearError(); onGoLogin(); }} className="text-[#dc143c] hover:underline font-medium">{tr("signIn")}</button>
        </p>
      </div>
    </div>
  );
}
