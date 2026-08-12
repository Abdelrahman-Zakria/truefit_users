import { Outlet, Link, useLocation, useNavigate } from "react-router";
import { Home, CreditCard, Calendar, Apple, TrendingUp, MessageCircle, Bell, User } from "lucide-react";
import { useAuth } from "../../lib/AuthContext";
import { useLang } from "../../lib/LanguageContext";
import { useAppContext } from "../../lib/AppContext";
import logo from "../../imports/logo-only.jpeg";

export function Layout() {
  const location = useLocation();
  const { mode, user } = useAuth();
  const { tr, dir, lang, setLang } = useLang();
  const navigate = useNavigate();

  const navItems = [
    { path: "/", icon: Home, label: tr("home") },
    { path: "/subscription", icon: CreditCard, label: tr("plan") },
    { path: "/booking", icon: Calendar, label: tr("book") },
    { path: "/diet", icon: Apple, label: tr("diet") },
    { path: "/progress", icon: TrendingUp, label: tr("progress") },
    { path: "/chat", icon: MessageCircle, label: tr("chat") },
  ];

  const initials = user?.displayName?.split(" ").map((w) => w[0]).join("").toUpperCase().slice(0, 2) ?? "TF";
  const { triggerRegistration } = useAppContext();

  return (
    <div dir={dir} className="min-h-screen bg-[#0a0a0a] text-white flex flex-col max-w-md mx-auto relative">
      {/* Header */}
      <header className="bg-[#0a0a0a] border-b border-[#1a1a1a] px-4 py-3 flex items-center justify-between sticky top-0 z-30">
        <Link to="/" className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl overflow-hidden border border-[#dc143c]/30">
            <img src={logo} alt="True Fit" className="w-full h-full object-cover" />
          </div>
          <div className="leading-tight">
            <p className="text-white font-semibold text-sm tracking-wider">TRUE FIT</p>
            <p className="text-[#dc143c] text-[9px] tracking-widest">GYM & SPA</p>
          </div>
        </Link>

        <div className="flex items-center gap-2">
          {/* Language switcher */}
          <div className="flex gap-1 bg-[#1a1a1a] rounded-full p-0.5 border border-[#2a2a2a]">
            {(["en", "ar"] as const).map((l) => (
              <button key={l} onClick={() => setLang(l)}
                className={`px-3 py-1 rounded-full text-xs font-bold transition-all ${lang === l ? "bg-[#dc143c] text-white" : "text-gray-500"}`}>
                {l.toUpperCase()}
              </button>
            ))}
          </div>

          {mode === "member" ? (
            <div className="flex items-center gap-2">
              <button onClick={() => navigate("/notifications")}
                className="relative w-9 h-9 rounded-full bg-[#1a1a1a] border border-[#2a2a2a] flex items-center justify-center hover:border-[#dc143c]/40 transition-colors">
                <Bell className="w-4 h-4 text-gray-400" />
                <span className="absolute top-1 end-1 w-2 h-2 bg-[#dc143c] rounded-full" />
              </button>
              <button onClick={() => navigate("/profile")}
                className="w-9 h-9 rounded-full bg-gradient-to-br from-[#dc143c] to-[#a00f2c] flex items-center justify-center hover:opacity-90 transition-opacity">
                <span className="text-white text-xs font-bold">{initials}</span>
              </button>
            </div>
          ) : (
            <button onClick={() => navigate("/")}
              className="flex items-center gap-1.5 bg-[#1a1a1a] border border-[#2a2a2a] rounded-full px-3 py-1.5 hover:border-[#dc143c]/40 transition-colors">
              <User className="w-3.5 h-3.5 text-gray-400" />
              <span className="text-xs text-gray-400">{tr("signIn")}</span>
            </button>
          )}
        </div>
      </header>

      {/* Guest banner */}
      {mode === "guest" && (
        <div className="bg-[#dc143c]/10 border-b border-[#dc143c]/20 px-4 py-2 flex items-center justify-between">
          <p className="text-xs text-gray-400">{tr("browsingAsGuest")}</p>
          <button onClick={() => triggerRegistration()} className="text-xs text-[#dc143c] font-semibold">{tr("joinNow")}</button>
        </div>
      )}

      <main className="flex-1 overflow-y-auto pb-20">
        <Outlet />
      </main>

      {/* Bottom nav */}
      <nav className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-md bg-[#111] border-t border-[#1a1a1a] z-30">
        <div className="flex justify-around items-center px-1 py-2">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = item.path === "/" ? location.pathname === "/" : location.pathname.startsWith(item.path);
            return (
              <Link key={item.path} to={item.path}
                className={`flex flex-col items-center gap-0.5 px-2 py-1.5 rounded-xl transition-colors min-w-0 ${isActive ? "text-[#dc143c]" : "text-gray-500 hover:text-white"}`}>
                <Icon className="w-5 h-5 flex-shrink-0" />
                <span className="text-[10px] truncate">{item.label}</span>
              </Link>
            );
          })}
        </div>
      </nav>
    </div>
  );
}
