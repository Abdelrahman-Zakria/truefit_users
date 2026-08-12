import { Lock, ArrowRight } from "lucide-react";
import { useLang } from "../../lib/LanguageContext";
import { useAppContext } from "../../lib/AppContext";
import { ReactNode } from "react";

interface Props {
  icon: ReactNode;
  featureKey: string;
}

export function GuestLockedTab({ icon, featureKey }: Props) {
  const { tr, dir } = useLang();
  const { triggerRegistration } = useAppContext();

  return (
    <div dir={dir} className="flex flex-col items-center justify-center min-h-[60vh] px-8 text-center">
      {/* Blurred icon background */}
      <div className="relative mb-8">
        <div className="w-28 h-28 rounded-full bg-[#1a1a1a] border border-[#2a2a2a] flex items-center justify-center opacity-30">
          {icon}
        </div>
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="w-14 h-14 rounded-full bg-[#0a0a0a] border-2 border-[#dc143c]/50 flex items-center justify-center shadow-lg shadow-[#dc143c]/20">
            <Lock className="w-6 h-6 text-[#dc143c]" />
          </div>
        </div>
      </div>

      <h3 className="text-xl text-white mb-2">{tr("featureLocked")}</h3>
      <p className="text-gray-400 text-sm leading-relaxed mb-2">{featureKey}</p>
      <p className="text-gray-600 text-xs mb-8">{tr("featureLockedDesc")}</p>

      <button
        onClick={() => triggerRegistration()}
        className="bg-[#dc143c] text-white px-8 py-3.5 rounded-xl flex items-center gap-2 hover:bg-[#a00f2c] transition-colors font-medium"
      >
        {tr("viewPackages")} <ArrowRight className="w-4 h-4 rtl:rotate-180" />
      </button>
    </div>
  );
}
