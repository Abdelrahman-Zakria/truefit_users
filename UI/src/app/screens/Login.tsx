import { useState } from "react";
import { Eye, EyeOff, Mail, Lock, X, CheckCircle } from "lucide-react";
import { useAuth } from "../../lib/AuthContext";
import { useLang } from "../../lib/LanguageContext";
import logo from "../../imports/logo-only.jpeg";

function ForgotPasswordModal({ onClose }: { onClose: () => void }) {
  const { tr, dir } = useLang();
  const [email, setEmail] = useState("");
  const [sent, setSent] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSend = async () => {
    if (!email) return;
    setLoading(true);
    await new Promise((r) => setTimeout(r, 1200));
    setLoading(false);
    setSent(true);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm px-6">
      <div dir={dir} className="bg-[#111] w-full max-w-sm rounded-3xl border border-[#2a2a2a] p-6 space-y-5">
        <div className="flex items-center justify-between">
          <h3 className="text-white font-medium">{tr("forgotPasswordTitle")}</h3>
          <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center">
            <X className="w-4 h-4 text-gray-400" />
          </button>
        </div>

        {sent ? (
          <div className="text-center space-y-4 py-4">
            <div className="w-14 h-14 rounded-full bg-green-500/20 flex items-center justify-center mx-auto">
              <CheckCircle className="w-7 h-7 text-green-400" />
            </div>
            <p className="text-white font-medium">{tr("resetEmailSent")}</p>
            <button onClick={onClose} className="w-full bg-[#dc143c] text-white py-3.5 rounded-xl hover:bg-[#a00f2c] transition-colors">
              {tr("backToLogin")}
            </button>
          </div>
        ) : (
          <>
            <p className="text-gray-400 text-sm">{tr("forgotPasswordSub")}</p>
            <div>
              <label className="text-xs text-gray-400 mb-1.5 block">{tr("email")}</label>
              <div className="relative">
                <Mail className="absolute start-4 top-3.5 w-4 h-4 text-gray-500" />
                <input type="email" placeholder="you@example.com" value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl ps-11 pe-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors" />
              </div>
            </div>
            <button onClick={handleSend} disabled={!email || loading}
              className="w-full bg-[#dc143c] text-white py-3.5 rounded-xl hover:bg-[#a00f2c] transition-colors disabled:opacity-50 font-medium">
              {loading
                ? <span className="flex items-center justify-center gap-2"><span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />Sending…</span>
                : tr("sendResetLink")}
            </button>
          </>
        )}
      </div>
    </div>
  );
}

export function Login({ onGoRegister }: { onGoRegister: () => void }) {
  const { login, continueAsGuest, error, clearError } = useAuth();
  const { tr, dir, lang, setLang } = useLang();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPass, setShowPass] = useState(false);
  const [loading, setLoading] = useState(false);
  const [showForgot, setShowForgot] = useState(false);

  const displayError = error === "fillAllFields" ? tr("fillAllFields") : error ?? null;

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try { await login(email, password); } catch { /* error in ctx */ }
    finally { setLoading(false); }
  };

  return (
    <div dir={dir} className="fixed inset-0 bg-[#0a0a0a] flex flex-col overflow-y-auto max-w-md mx-auto">
      {/* Lang toggle */}
      <div className="absolute top-4 end-4 z-10 flex gap-1">
        {(["en", "ar"] as const).map((l) => (
          <button key={l} onClick={() => setLang(l)}
            className={`w-9 h-9 rounded-full text-xs font-bold transition-colors ${lang === l ? "bg-[#dc143c] text-white" : "bg-[#1a1a1a] text-gray-400 border border-[#2a2a2a]"}`}>
            {l.toUpperCase()}
          </button>
        ))}
      </div>

      {/* Hero */}
      <div className="relative bg-gradient-to-b from-[#dc143c]/15 to-transparent pt-14 pb-8 px-6 flex flex-col items-center">
        <div className="w-24 h-24 rounded-2xl overflow-hidden border border-[#dc143c]/30 shadow-lg shadow-[#dc143c]/20 mb-5">
          <img src={logo} alt="True Fit" className="w-full h-full object-cover" />
        </div>
        <h2 className="text-2xl font-light text-white mb-1">{tr("welcomeBack")}</h2>
        <p className="text-gray-400 text-sm">{tr("signInAccount")}</p>
      </div>

      {/* Form */}
      <div className="flex-1 px-6 pt-4 pb-10 space-y-4">
        {displayError && (
          <div className="bg-[#dc143c]/10 border border-[#dc143c]/40 rounded-xl px-4 py-3 flex items-center justify-between">
            <p className="text-sm text-[#dc143c]">{displayError}</p>
            <button onClick={clearError} className="text-[#dc143c] text-xl leading-none ms-2">×</button>
          </div>
        )}

        <form onSubmit={handleLogin} className="space-y-4">
          <div>
            <label className="text-xs text-gray-400 mb-1.5 block">{tr("email")}</label>
            <div className="relative">
              <Mail className="absolute start-4 top-3.5 w-4 h-4 text-gray-500" />
              <input type="email" placeholder="you@example.com" value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl ps-11 pe-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors" />
            </div>
          </div>

          <div>
            <label className="text-xs text-gray-400 mb-1.5 block">{tr("password")}</label>
            <div className="relative">
              <Lock className="absolute start-4 top-3.5 w-4 h-4 text-gray-500" />
              <input type={showPass ? "text" : "password"} placeholder="••••••••" value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl ps-11 pe-11 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors" />
              <button type="button" onClick={() => setShowPass(!showPass)}
                className="absolute end-4 top-3.5 text-gray-500 hover:text-gray-300">
                {showPass ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
          </div>

          <div className="flex justify-end">
            <button type="button" onClick={() => setShowForgot(true)} className="text-sm text-[#dc143c] hover:underline">
              {tr("forgotPassword")}
            </button>
          </div>

          <button type="submit" disabled={loading || !email || !password}
            className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium disabled:opacity-50 disabled:cursor-not-allowed">
            {loading
              ? <span className="flex items-center justify-center gap-2"><span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />{tr("signingIn")}</span>
              : tr("signIn")}
          </button>
        </form>

        <div className="flex items-center gap-3">
          <div className="flex-1 h-px bg-[#2a2a2a]" />
          <span className="text-xs text-gray-500">OR</span>
          <div className="flex-1 h-px bg-[#2a2a2a]" />
        </div>

        <button onClick={continueAsGuest}
          className="w-full border border-[#dc143c]/50 text-[#dc143c] py-4 rounded-xl hover:bg-[#dc143c]/10 transition-colors font-medium">
          {tr("continueAsGuest")}
        </button>
      </div>

      {showForgot && <ForgotPasswordModal onClose={() => setShowForgot(false)} />}
    </div>
  );
}
