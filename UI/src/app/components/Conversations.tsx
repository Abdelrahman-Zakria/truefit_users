import { useNavigate } from "react-router";
import { User, Search, MessageCircle } from "lucide-react";
import { useState } from "react";
import { COACHES } from "./Chat";
import { useAuth } from "../../lib/AuthContext";
import { useLang } from "../../lib/LanguageContext";
import { GuestLockedTab } from "./GuestLockedTab";

const PREVIEWS: Record<string, { preview: string; time: string; unread: number }> = {
  "1": { preview: "Your current meal plan is working well. Let's stick with it…", time: "9:42 AM", unread: 0 },
  "2": { preview: "Perfect. See you at 7AM sharp. 🔥", time: "Yesterday", unread: 1 },
  "3": { preview: "Don't forget to stretch after every session.", time: "Mon", unread: 0 },
  "4": { preview: "Aim for an extra 30g of protein daily. Greek yogurt…", time: "10:07 AM", unread: 2 },
};

const AVATAR_COLORS: Record<string, string> = {
  "1": "bg-[#dc143c]/20",
  "2": "bg-purple-500/20",
  "3": "bg-blue-500/20",
  "4": "bg-green-500/20",
};

const AVATAR_TEXT_COLORS: Record<string, string> = {
  "1": "text-[#dc143c]",
  "2": "text-purple-400",
  "3": "text-blue-400",
  "4": "text-green-400",
};

export function Conversations() {
  const { mode } = useAuth();
  const { tr } = useLang();
  const navigate = useNavigate();
  const [query, setQuery] = useState("");

  if (mode === "guest") return <GuestLockedTab icon={<MessageCircle className="w-12 h-12 text-gray-600" />} featureKey={tr("lockChat")} />;

  const entries = Object.entries(COACHES).filter(([, c]) =>
    c.name.toLowerCase().includes(query.toLowerCase()) ||
    c.role.toLowerCase().includes(query.toLowerCase())
  );

  return (
    <div className="flex flex-col h-full">
      {/* Header */}
      <div className="px-6 pt-6 pb-4">
        <h2 className="text-2xl mb-1">Messages</h2>
        <p className="text-gray-400 text-sm">Your coaching team</p>
      </div>

      {/* Search */}
      <div className="px-6 mb-4">
        <div className="flex items-center gap-3 bg-[#1a1a1a] rounded-xl px-4 py-3 border border-[#2a2a2a]">
          <Search className="w-4 h-4 text-gray-500 flex-shrink-0" />
          <input
            type="text"
            placeholder="Search conversations…"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="flex-1 bg-transparent text-white placeholder-gray-500 outline-none text-sm"
          />
        </div>
      </div>

      {/* List */}
      <div className="flex-1 overflow-y-auto px-4 space-y-1">
        {entries.map(([id, coach]) => {
          const meta = PREVIEWS[id];
          return (
            <button
              key={id}
              onClick={() => navigate(`/chat/${id}`)}
              className="w-full flex items-center gap-4 px-3 py-4 rounded-2xl hover:bg-[#1a1a1a] transition-colors text-left"
            >
              {/* Avatar */}
              <div className="relative flex-shrink-0">
                <div className={`w-13 h-13 w-12 h-12 rounded-full ${AVATAR_COLORS[id]} flex items-center justify-center`}>
                  <User className={`w-6 h-6 ${AVATAR_TEXT_COLORS[id]}`} />
                </div>
                {coach.online && (
                  <div className="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-[#0a0a0a] rounded-full" />
                )}
              </div>

              {/* Content */}
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between mb-0.5">
                  <span className={`font-medium text-sm truncate ${meta.unread > 0 ? "text-white" : "text-gray-200"}`}>
                    {coach.name}
                  </span>
                  <span className="text-xs text-gray-500 ml-2 flex-shrink-0">{meta.time}</span>
                </div>
                <div className="flex items-center justify-between">
                  <p className={`text-xs truncate pr-2 ${meta.unread > 0 ? "text-gray-300" : "text-gray-500"}`}>
                    {meta.preview}
                  </p>
                  {meta.unread > 0 && (
                    <span className="flex-shrink-0 w-5 h-5 rounded-full bg-[#dc143c] text-white text-xs flex items-center justify-center font-semibold">
                      {meta.unread}
                    </span>
                  )}
                </div>
                <p className="text-xs text-gray-600 mt-0.5">{coach.role}</p>
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
}
