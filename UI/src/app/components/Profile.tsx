import { useState } from "react";
import { ChevronRight, User, Phone, MapPin, Calendar, LogOut, Trash2, Bell, Globe, Shield, HelpCircle, Check, Edit3, X, Mail, MessageCircle, ExternalLink, Lock, Eye, EyeOff } from "lucide-react";
import { useNavigate } from "react-router";
import { useAuth } from "../../lib/AuthContext";
import { useLang } from "../../lib/LanguageContext";

// ─── Avatar ──────────────────────────────────────────────────────────────────

function Avatar({ name, size = 64 }: { name: string; size?: number }) {
  const initials = name.split(" ").map((w) => w[0]).join("").toUpperCase().slice(0, 2);
  return (
    <div className="rounded-full bg-gradient-to-br from-[#dc143c] to-[#a00f2c] flex items-center justify-center flex-shrink-0"
      style={{ width: size, height: size }}>
      <span className="text-white font-bold" style={{ fontSize: size * 0.35 }}>{initials || "TF"}</span>
    </div>
  );
}

// ─── Toggle switch ────────────────────────────────────────────────────────────

function Toggle({ on, onToggle }: { on: boolean; onToggle: () => void }) {
  return (
    <button onClick={onToggle}
      className={`w-11 h-6 rounded-full relative transition-colors flex-shrink-0 ${on ? "bg-[#dc143c]" : "bg-[#3a3a3a]"}`}>
      <div className={`absolute top-0.5 w-5 h-5 bg-white rounded-full transition-all shadow-sm ${on ? "start-[22px]" : "start-0.5"}`} />
    </button>
  );
}

// ─── Edit Profile sheet ───────────────────────────────────────────────────────

function EditProfileSheet({ onClose }: { onClose: () => void }) {
  const { user, updateProfile } = useAuth();
  const { tr, dir } = useLang();
  const [name, setName] = useState(user?.displayName ?? "");
  const [email, setEmail] = useState(user?.email ?? "");
  const [phone, setPhone] = useState(user?.phone ?? "");
  const [address, setAddress] = useState(user?.address ?? "");
  const [saved, setSaved] = useState(false);

  const handleSave = () => {
    updateProfile({ displayName: name, email, phone, address });
    setSaved(true);
    setTimeout(onClose, 900);
  };

  const fields = [
    { label: tr("fullName"), value: name, set: setName, type: "text", icon: <User className="w-4 h-4" /> },
    { label: tr("email"), value: email, set: setEmail, type: "email", icon: <Mail className="w-4 h-4" /> },
    { label: tr("phone"), value: phone, set: setPhone, type: "tel", icon: <Phone className="w-4 h-4" /> },
    { label: tr("address"), value: address, set: setAddress, type: "text", icon: <MapPin className="w-4 h-4" /> },
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/75 backdrop-blur-sm">
      <div dir={dir} className="bg-[#111] w-full max-w-md rounded-t-3xl border-t border-x border-[#2a2a2a] max-h-[88vh] overflow-y-auto">
        <div className="flex justify-center pt-3"><div className="w-10 h-1 rounded-full bg-[#3a3a3a]" /></div>
        <div className="flex items-center justify-between px-5 py-4 border-b border-[#2a2a2a]">
          <h3 className="font-medium text-white">{tr("editProfile")}</h3>
          <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center">
            <X className="w-4 h-4 text-gray-400" />
          </button>
        </div>
        <div className="px-5 py-5 space-y-4">
          {saved && (
            <div className="bg-green-500/20 border border-green-500/40 rounded-xl p-3 flex items-center gap-2">
              <Check className="w-4 h-4 text-green-400" />
              <span className="text-green-400 text-sm">{tr("profileUpdated")}</span>
            </div>
          )}
          {fields.map(({ label, value, set, type, icon }) => (
            <div key={label}>
              <label className="text-xs text-gray-400 mb-1.5 block">{label}</label>
              <div className="relative">
                <span className="absolute start-4 top-3.5 text-gray-500">{icon}</span>
                <input type={type} value={value} onChange={(e) => set(e.target.value)}
                  className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl ps-11 pe-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors" />
              </div>
            </div>
          ))}
          <button onClick={handleSave} disabled={!name.trim()}
            className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium disabled:opacity-50">
            {tr("saveChanges")}
          </button>
        </div>
        <div className="h-6" />
      </div>
    </div>
  );
}

// ─── Help Center sheet ────────────────────────────────────────────────────────

function HelpSheet({ onClose }: { onClose: () => void }) {
  const { tr, dir, lang } = useLang();
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
      <div dir={dir} className="bg-[#111] w-full max-w-md rounded-t-3xl border-t border-x border-[#2a2a2a] max-h-[85vh] overflow-y-auto">
        <div className="flex justify-center pt-3"><div className="w-10 h-1 rounded-full bg-[#3a3a3a]" /></div>
        <div className="flex items-center justify-between px-5 py-4 border-b border-[#2a2a2a]">
          <h3 className="font-medium text-white">{tr("helpCenter")}</h3>
          <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center">
            <X className="w-4 h-4 text-gray-400" />
          </button>
        </div>
        <div className="px-5 py-5 space-y-4">
          {/* Contact details */}
          <div className="bg-[#1a1a1a] rounded-xl border border-[#2a2a2a] overflow-hidden">
            {[
              { icon: <Mail className="w-4 h-4 text-[#dc143c]" />, label: lang === "ar" ? "البريد الإلكتروني" : "Email", val: tr("supportEmail") },
              { icon: <Phone className="w-4 h-4 text-[#dc143c]" />, label: lang === "ar" ? "الهاتف" : "Phone", val: tr("supportPhone") },
              { icon: <Calendar className="w-4 h-4 text-[#dc143c]" />, label: lang === "ar" ? "ساعات العمل" : "Hours", val: tr("supportHours") },
            ].map(({ icon, label, val }, i, arr) => (
              <div key={label} className={`flex items-center gap-3 px-4 py-3.5 ${i < arr.length - 1 ? "border-b border-[#2a2a2a]" : ""}`}>
                {icon}
                <div>
                  <p className="text-xs text-gray-500">{label}</p>
                  <p className="text-white text-sm">{val}</p>
                </div>
              </div>
            ))}
          </div>

          {sent ? (
            <div className="text-center py-4 space-y-3">
              <div className="w-12 h-12 rounded-full bg-green-500/20 flex items-center justify-center mx-auto">
                <Check className="w-6 h-6 text-green-400" />
              </div>
              <p className="text-white font-medium">{tr("messageSent")}</p>
            </div>
          ) : (
            <>
              <div>
                <label className="text-xs text-gray-400 mb-1.5 block">{lang === "ar" ? "أرسل لنا رسالة" : "Send us a message"}</label>
                <textarea rows={4} placeholder={tr("yourMessage")} value={msg}
                  onChange={(e) => setMsg(e.target.value)}
                  className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors resize-none" />
              </div>
              <button onClick={handleSend} disabled={!msg.trim() || loading}
                className="w-full bg-[#dc143c] text-white py-3.5 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium disabled:opacity-50 flex items-center justify-center gap-2">
                {loading
                  ? <><span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />{lang === "ar" ? "جاري الإرسال..." : "Sending…"}</>
                  : <><MessageCircle className="w-4 h-4" />{tr("sendMessage")}</>}
              </button>
            </>
          )}
        </div>
        <div className="h-6" />
      </div>
    </div>
  );
}

// ─── Privacy Policy sheet ─────────────────────────────────────────────────────

function PrivacySheet({ onClose }: { onClose: () => void }) {
  const { dir, lang } = useLang();
  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/75 backdrop-blur-sm">
      <div dir={dir} className="bg-[#111] w-full max-w-md rounded-t-3xl border-t border-x border-[#2a2a2a] max-h-[85vh] overflow-y-auto">
        <div className="flex justify-center pt-3"><div className="w-10 h-1 rounded-full bg-[#3a3a3a]" /></div>
        <div className="flex items-center justify-between px-5 py-4 border-b border-[#2a2a2a]">
          <h3 className="font-medium text-white">{lang === "ar" ? "سياسة الخصوصية" : "Privacy Policy"}</h3>
          <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center">
            <X className="w-4 h-4 text-gray-400" />
          </button>
        </div>
        <div className="px-5 py-5 space-y-4 text-sm text-gray-300 leading-relaxed">
          {lang === "ar" ? (
            <>
              <p className="text-white font-medium">آخر تحديث: يوليو 2026</p>
              <p>تلتزم True Fit Gym & Spa بحماية خصوصيتك. تشرح هذه السياسة كيفية جمع بياناتك واستخدامها وحمايتها.</p>
              <p className="font-medium text-white">البيانات التي نجمعها</p>
              <p>نجمع الاسم ورقم الهاتف والعنوان وتاريخ الميلاد وبيانات الحضور والنشاط الرياضي داخل الصالة.</p>
              <p className="font-medium text-white">كيف نستخدم البيانات</p>
              <p>تُستخدم بياناتك لإدارة عضويتك وتحسين خدماتنا وإرسال العروض ذات الصلة فقط.</p>
              <p className="font-medium text-white">حقوقك</p>
              <p>يحق لك طلب الاطلاع على بياناتك أو تعديلها أو حذفها في أي وقت عبر التواصل مع فريق الدعم.</p>
            </>
          ) : (
            <>
              <p className="text-white font-medium">Last updated: July 2026</p>
              <p>True Fit Gym & Spa is committed to protecting your privacy. This policy explains how we collect, use, and safeguard your information.</p>
              <p className="font-medium text-white">Data We Collect</p>
              <p>We collect your name, phone number, address, date of birth, attendance records, and in-gym activity data.</p>
              <p className="font-medium text-white">How We Use Your Data</p>
              <p>Your data is used to manage your membership, improve our services, and send you relevant offers only.</p>
              <p className="font-medium text-white">Your Rights</p>
              <p>You may request to view, correct, or delete your data at any time by contacting our support team.</p>
            </>
          )}
        </div>
        <div className="h-6" />
      </div>
    </div>
  );
}

// ─── Delete confirm ───────────────────────────────────────────────────────────

function DeleteConfirmSheet({ onClose, onConfirm }: { onClose: () => void; onConfirm: () => void }) {
  const { tr, dir, lang } = useLang();
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm px-6">
      <div dir={dir} className="bg-[#111] w-full max-w-sm rounded-3xl border border-[#2a2a2a] p-6 space-y-4">
        <div className="w-12 h-12 rounded-full bg-red-500/20 flex items-center justify-center mx-auto">
          <Trash2 className="w-6 h-6 text-red-400" />
        </div>
        <h3 className="text-white text-center font-medium text-lg">{lang === "ar" ? "حذف الحساب؟" : "Delete Account?"}</h3>
        <p className="text-gray-400 text-sm text-center">{lang === "ar" ? "هذا الإجراء لا يمكن التراجع عنه." : "This action cannot be undone. All your data will be permanently deleted."}</p>
        <div className="flex gap-3">
          <button onClick={onClose} className="flex-1 py-3 rounded-xl bg-[#2a2a2a] text-gray-300 hover:bg-[#3a3a3a] transition-colors">{tr("cancelEdit")}</button>
          <button onClick={onConfirm} className="flex-1 py-3 rounded-xl bg-red-600 text-white hover:bg-red-700 transition-colors">{lang === "ar" ? "احذف" : "Delete"}</button>
        </div>
      </div>
    </div>
  );
}

// ─── Change Password sheet ────────────────────────────────────────────────────

function ChangePasswordSheet({ onClose }: { onClose: () => void }) {
  const { dir, lang } = useLang();
  const [current, setCurrent] = useState("");
  const [next, setNext] = useState("");
  const [confirm, setConfirm] = useState("");
  const [showCurrent, setShowCurrent] = useState(false);
  const [showNext, setShowNext] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [loading, setLoading] = useState(false);
  const [done, setDone] = useState(false);
  const [error, setError] = useState("");

  const label = {
    title: lang === "ar" ? "تغيير كلمة المرور" : "Change Password",
    currentPw: lang === "ar" ? "كلمة المرور الحالية" : "Current Password",
    newPw: lang === "ar" ? "كلمة المرور الجديدة" : "New Password",
    confirmPw: lang === "ar" ? "تأكيد كلمة المرور" : "Confirm New Password",
    update: lang === "ar" ? "تحديث كلمة المرور" : "Update Password",
    mismatch: lang === "ar" ? "كلمتا المرور غير متطابقتين" : "Passwords do not match",
    tooshort: lang === "ar" ? "يجب أن تكون 8 أحرف على الأقل" : "Must be at least 8 characters",
    wrongcurrent: lang === "ar" ? "كلمة المرور الحالية غير صحيحة" : "Current password is incorrect",
    updated: lang === "ar" ? "تم تحديث كلمة المرور بنجاح" : "Password updated successfully",
    done: lang === "ar" ? "تم" : "Done",
  };

  const handleSubmit = async () => {
    setError("");
    if (next.length < 8) { setError(label.tooshort); return; }
    if (next !== confirm) { setError(label.mismatch); return; }
    if (current !== "password123") { setError(label.wrongcurrent); return; } // mock check
    setLoading(true);
    await new Promise((r) => setTimeout(r, 1200));
    setLoading(false);
    setDone(true);
  };

  const canSubmit = current.length > 0 && next.length > 0 && confirm.length > 0;

  const PwField = ({
    label: lbl, value, setValue, show, toggle,
  }: { label: string; value: string; setValue: (v: string) => void; show: boolean; toggle: () => void }) => (
    <div>
      <label className="text-xs text-gray-400 mb-1.5 block">{lbl}</label>
      <div className="relative">
        <Lock className="absolute start-4 top-3.5 w-4 h-4 text-gray-500" />
        <input
          type={show ? "text" : "password"}
          value={value}
          onChange={(e) => setValue(e.target.value)}
          className="w-full bg-[#1a1a1a] border border-[#2a2a2a] rounded-xl ps-11 pe-11 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-[#dc143c] transition-colors"
        />
        <button type="button" onClick={toggle} className="absolute end-4 top-3.5 text-gray-500 hover:text-gray-300">
          {show ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
        </button>
      </div>
    </div>
  );

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/75 backdrop-blur-sm">
      <div dir={dir} className="bg-[#111] w-full max-w-md rounded-t-3xl border-t border-x border-[#2a2a2a] max-h-[90vh] overflow-y-auto">
        <div className="flex justify-center pt-3"><div className="w-10 h-1 rounded-full bg-[#3a3a3a]" /></div>
        <div className="flex items-center justify-between px-5 py-4 border-b border-[#2a2a2a]">
          <h3 className="font-medium text-white">{label.title}</h3>
          <button onClick={onClose} className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center">
            <X className="w-4 h-4 text-gray-400" />
          </button>
        </div>

        <div className="px-5 py-5 space-y-4">
          {done ? (
            <div className="text-center py-6 space-y-4">
              <div className="w-16 h-16 rounded-full bg-green-500/20 flex items-center justify-center mx-auto">
                <Check className="w-8 h-8 text-green-400" />
              </div>
              <p className="text-white font-medium">{label.updated}</p>
              <button onClick={onClose} className="w-full bg-[#dc143c] text-white py-3.5 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium">
                {label.done}
              </button>
            </div>
          ) : (
            <>
              <PwField label={label.currentPw} value={current} setValue={setCurrent} show={showCurrent} toggle={() => setShowCurrent(!showCurrent)} />

              <div className="border-t border-[#2a2a2a]" />

              <PwField label={label.newPw} value={next} setValue={setNext} show={showNext} toggle={() => setShowNext(!showNext)} />
              <PwField label={label.confirmPw} value={confirm} setValue={setConfirm} show={showConfirm} toggle={() => setShowConfirm(!showConfirm)} />

              {/* Strength indicator */}
              {next.length > 0 && (
                <div className="space-y-1">
                  <div className="flex gap-1">
                    {[1, 2, 3, 4].map((n) => {
                      const strength = next.length >= 12 && /[A-Z]/.test(next) && /[0-9]/.test(next) && /[^a-zA-Z0-9]/.test(next) ? 4
                        : next.length >= 10 && /[A-Z]/.test(next) && /[0-9]/.test(next) ? 3
                        : next.length >= 8 ? 2 : 1;
                      return <div key={n} className={`h-1 flex-1 rounded-full transition-colors ${n <= strength ? (strength >= 4 ? "bg-green-500" : strength === 3 ? "bg-yellow-400" : strength === 2 ? "bg-orange-400" : "bg-red-500") : "bg-[#2a2a2a]"}`} />;
                    })}
                  </div>
                  <p className="text-xs text-gray-500">
                    {next.length < 8 ? (lang === "ar" ? "ضعيفة" : "Weak")
                      : next.length >= 10 && /[A-Z]/.test(next) && /[0-9]/.test(next) ? (lang === "ar" ? "قوية" : "Strong")
                      : (lang === "ar" ? "متوسطة" : "Fair")}
                  </p>
                </div>
              )}

              {error && (
                <p className="text-red-400 text-sm bg-red-500/10 border border-red-500/20 rounded-xl px-4 py-2.5">{error}</p>
              )}

              <button onClick={handleSubmit} disabled={!canSubmit || loading}
                className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium disabled:opacity-40 flex items-center justify-center gap-2">
                {loading
                  ? <><span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />{lang === "ar" ? "جاري التحديث..." : "Updating…"}</>
                  : label.update}
              </button>
            </>
          )}
        </div>
        <div className="h-6" />
      </div>
    </div>
  );
}

// ─── Profile screen ───────────────────────────────────────────────────────────

export function Profile() {
  const { user, logout } = useAuth();
  const { tr, dir, lang, setLang } = useLang();
  const navigate = useNavigate();
  const [showEdit, setShowEdit] = useState(false);
  const [showDelete, setShowDelete] = useState(false);
  const [showHelp, setShowHelp] = useState(false);
  const [showPrivacy, setShowPrivacy] = useState(false);
  const [showChangePw, setShowChangePw] = useState(false);
  const [notifs, setNotifs] = useState(true);

  const displayName = user?.displayName ?? (lang === "ar" ? "عضو" : "Member");

  const handleLogout = async () => { await logout(); navigate("/"); };
  const handleDeleteConfirm = async () => { await logout(); };

  return (
    <div dir={dir} className="pb-10">
      {/* ── Profile header ── */}
      <div className="bg-gradient-to-b from-[#dc143c]/15 to-transparent px-5 pt-6 pb-6">
        <div className="flex items-center gap-4 mb-3">
          <Avatar name={displayName} size={72} />
          <div className="flex-1 min-w-0">
            <h2 className="text-xl text-white font-semibold truncate">{displayName}</h2>
            {user?.email && <p className="text-gray-400 text-sm truncate">{user.email}</p>}
            {user?.plan && (
              <span className="inline-block mt-1 text-xs bg-[#dc143c]/20 text-[#dc143c] px-2 py-0.5 rounded-full border border-[#dc143c]/30">
                {user.plan}
              </span>
            )}
          </div>
          <button onClick={() => setShowEdit(true)}
            className="w-10 h-10 rounded-xl bg-[#1a1a1a] border border-[#2a2a2a] flex items-center justify-center flex-shrink-0 hover:border-[#dc143c]/40 transition-colors">
            <Edit3 className="w-4 h-4 text-gray-400" />
          </button>
        </div>
        {user?.memberSince && (
          <div className="flex items-center gap-2 text-xs text-gray-500">
            <Calendar className="w-3.5 h-3.5" />
            <span>{tr("memberSince")} {user.memberSince}</span>
          </div>
        )}
      </div>

      {/* ── Personal details ── */}
      <div className="px-4 pt-2">
        <p className="text-xs text-gray-500 uppercase tracking-widest mb-3 px-1">{tr("personalDetails")}</p>
        <div className="bg-[#1a1a1a] rounded-2xl border border-[#2a2a2a] overflow-hidden">
          {[
            { icon: <User className="w-4 h-4" />, label: tr("fullName"), value: user?.displayName ?? "—" },
            { icon: <Mail className="w-4 h-4" />, label: tr("email"), value: user?.email || "—" },
            { icon: <Phone className="w-4 h-4" />, label: tr("phone"), value: user?.phone ?? "—" },
            { icon: <MapPin className="w-4 h-4" />, label: tr("address"), value: user?.address ?? "—" },
            { icon: <Calendar className="w-4 h-4" />, label: tr("birthday"), value: user?.birthday ?? "—" },
          ].map(({ icon, label, value }, i, arr) => (
            <div key={label} className={`flex items-center gap-3 px-4 py-3.5 ${i < arr.length - 1 ? "border-b border-[#2a2a2a]" : ""}`}>
              <span className="text-[#dc143c]">{icon}</span>
              <div className="flex-1 min-w-0">
                <p className="text-xs text-gray-500">{label}</p>
                <p className="text-white text-sm truncate">{value}</p>
              </div>
              {i === 0 && (
                <button onClick={() => setShowEdit(true)} className="text-xs text-[#dc143c] hover:underline flex-shrink-0">
                  {tr("editProfile")}
                </button>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* ── Preferences ── */}
      <div className="px-4 pt-5">
        <p className="text-xs text-gray-500 uppercase tracking-widest mb-3 px-1">{tr("accountSettings")}</p>
        <div className="bg-[#1a1a1a] rounded-2xl border border-[#2a2a2a] overflow-hidden">

          {/* Push Notifications */}
          <div className="flex items-center gap-3 px-4 py-3.5 border-b border-[#2a2a2a]">
            <Bell className="w-5 h-5 text-blue-400 flex-shrink-0" />
            <span className="flex-1 text-sm text-white">{tr("pushNotifications")}</span>
            <Toggle on={notifs} onToggle={() => setNotifs(!notifs)} />
          </div>

          {/* Language */}
          <div className="flex items-center gap-3 px-4 py-3.5 border-b border-[#2a2a2a]">
            <Globe className="w-5 h-5 text-purple-400 flex-shrink-0" />
            <span className="flex-1 text-sm text-white">{tr("language")}</span>
            <div className="flex gap-1 bg-[#0a0a0a] rounded-full p-0.5 border border-[#2a2a2a]">
              {(["en", "ar"] as const).map((l) => (
                <button key={l} onClick={() => setLang(l)}
                  className={`px-3 py-1 rounded-full text-xs font-bold transition-all ${lang === l ? "bg-[#dc143c] text-white" : "text-gray-500 hover:text-gray-300"}`}>
                  {l.toUpperCase()}
                </button>
              ))}
            </div>
          </div>

          {/* Change Password */}
          <button onClick={() => setShowChangePw(true)}
            className="w-full flex items-center gap-3 px-4 py-3.5 hover:bg-[#2a2a2a]/50 transition-colors border-b border-[#2a2a2a]">
            <Lock className="w-5 h-5 text-orange-400 flex-shrink-0" />
            <span className="flex-1 text-start text-sm text-white">{lang === "ar" ? "تغيير كلمة المرور" : "Change Password"}</span>
            <ChevronRight className="w-4 h-4 text-gray-600 rtl:rotate-180" />
          </button>

          {/* Privacy Policy */}
          <button onClick={() => setShowPrivacy(true)}
            className="w-full flex items-center gap-3 px-4 py-3.5 hover:bg-[#2a2a2a]/50 transition-colors border-b border-[#2a2a2a]">
            <Shield className="w-5 h-5 text-green-400 flex-shrink-0" />
            <span className="flex-1 text-start text-sm text-white">{tr("privacyPolicy")}</span>
            <ExternalLink className="w-4 h-4 text-gray-600" />
          </button>

          {/* Help Center */}
          <button onClick={() => setShowHelp(true)}
            className="w-full flex items-center gap-3 px-4 py-3.5 hover:bg-[#2a2a2a]/50 transition-colors">
            <HelpCircle className="w-5 h-5 text-yellow-400 flex-shrink-0" />
            <span className="flex-1 text-start text-sm text-white">{tr("helpCenter")}</span>
            <ChevronRight className="w-4 h-4 text-gray-600 rtl:rotate-180" />
          </button>
        </div>
      </div>

      {/* ── Notifications shortcut ── */}
      <div className="px-4 pt-3">
        <button onClick={() => navigate("/notifications")}
          className="w-full flex items-center gap-3 px-4 py-3.5 bg-[#1a1a1a] rounded-2xl border border-[#2a2a2a] hover:border-[#dc143c]/30 transition-colors">
          <Bell className="w-5 h-5 text-[#dc143c] flex-shrink-0" />
          <span className="flex-1 text-start text-sm text-white">{tr("notifications")}</span>
          <ChevronRight className="w-4 h-4 text-gray-600 rtl:rotate-180" />
        </button>
      </div>

      {/* ── Actions ── */}
      <div className="px-4 pt-5 space-y-3">
        <button onClick={handleLogout}
          className="w-full flex items-center justify-center gap-2 py-4 rounded-xl bg-[#1a1a1a] border border-[#2a2a2a] text-[#dc143c] hover:bg-[#dc143c]/10 transition-colors font-medium">
          <LogOut className="w-4 h-4" />{tr("logOut")}
        </button>
        <button onClick={() => setShowDelete(true)}
          className="w-full flex items-center justify-center gap-2 py-3.5 rounded-xl border border-red-900/40 text-red-500 hover:bg-red-900/10 transition-colors text-sm">
          <Trash2 className="w-4 h-4" />{tr("deleteAccount")}
        </button>
      </div>

      {/* ── Sheets ── */}
      {showEdit     && <EditProfileSheet    onClose={() => setShowEdit(false)} />}
      {showHelp     && <HelpSheet           onClose={() => setShowHelp(false)} />}
      {showPrivacy  && <PrivacySheet        onClose={() => setShowPrivacy(false)} />}
      {showChangePw && <ChangePasswordSheet onClose={() => setShowChangePw(false)} />}
      {showDelete   && <DeleteConfirmSheet  onClose={() => setShowDelete(false)} onConfirm={handleDeleteConfirm} />}
    </div>
  );
}
