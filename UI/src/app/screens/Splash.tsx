import { useEffect } from "react";
import logo from "../../imports/logo-only.jpeg";

export function Splash({ onDone }: { onDone: () => void }) {
  useEffect(() => {
    const t = setTimeout(onDone, 2400);
    return () => clearTimeout(t);
  }, [onDone]);

  return (
    <div className="fixed inset-0 bg-[#0a0a0a] flex flex-col items-center justify-center">
      {/* Pulse rings */}
      <div className="relative flex items-center justify-center mb-10">
        <div
          className="absolute w-52 h-52 rounded-full border border-[#dc143c]/10"
          style={{ animation: "ping 2.2s ease-out infinite" }}
        />
        <div className="absolute w-40 h-40 rounded-full border border-[#dc143c]/15" />
        <div className="w-28 h-28 rounded-full overflow-hidden border-2 border-[#dc143c]/30 shadow-lg shadow-[#dc143c]/20">
          <img src={logo} alt="True Fit" className="w-full h-full object-cover" />
        </div>
      </div>

      <p className="text-gray-500 text-xs tracking-[0.3em] uppercase mt-2">Premium Fitness</p>

      {/* Loading bar */}
      <div className="absolute bottom-14 w-36 h-0.5 bg-[#1a1a1a] rounded-full overflow-hidden">
        <div
          className="h-full bg-[#dc143c] rounded-full"
          style={{ animation: "splashFill 2.2s ease-in-out forwards" }}
        />
      </div>

      <style>{`
        @keyframes splashFill { from { width:0% } to { width:100% } }
        @keyframes ping {
          0%   { transform: scale(1); opacity: 0.6; }
          75%, 100% { transform: scale(1.4); opacity: 0; }
        }
      `}</style>
    </div>
  );
}
