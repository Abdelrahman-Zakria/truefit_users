import { useState, useRef } from "react";
import { Send, User, MoreVertical, Paperclip, Smile, Mic, Square, ChevronLeft } from "lucide-react";
import { useNavigate, useParams } from "react-router";

interface Message {
  id: number;
  sender: "user" | "coach";
  text: string;
  time: string;
  voice?: boolean;
  duration?: string;
}

export const COACHES: Record<string, { name: string; role: string; online: boolean }> = {
  "1": { name: "Coach Sarah Mitchell", role: "Strength & Conditioning", online: true },
  "2": { name: "Coach Marcus Chen", role: "HIIT & Boxing", online: true },
  "3": { name: "Coach Emily Rodriguez", role: "Yoga & Flexibility", online: false },
  "4": { name: "Nutrition Team", role: "Diet & Meal Planning", online: true },
};

const INITIAL_MESSAGES: Record<string, Message[]> = {
  "1": [
    { id: 1, sender: "coach", text: "Hey Alex! How did your morning workout go?", time: "9:30 AM" },
    { id: 2, sender: "user", text: "It was great! Completed all the sets you recommended.", time: "9:32 AM" },
    { id: 3, sender: "coach", text: "Excellent! How are you feeling about the weight progression?", time: "9:33 AM" },
    { id: 4, sender: "user", text: "Feeling good, though the last set was challenging.", time: "9:35 AM" },
    { id: 5, sender: "coach", text: "That's perfect! That means you're at the right intensity. Keep it up and we'll increase the weight next week. 💪", time: "9:36 AM" },
    { id: 6, sender: "user", text: "Sounds good! Should I adjust my diet plan?", time: "9:40 AM" },
    { id: 7, sender: "coach", text: "Your current meal plan is working well. Let's stick with it for another 2 weeks, then reassess based on your next InBody scan.", time: "9:42 AM" },
  ],
  "2": [
    { id: 1, sender: "coach", text: "Ready for tomorrow's HIIT session? We're going full intensity!", time: "Yesterday" },
    { id: 2, sender: "user", text: "Absolutely! I've been resting well.", time: "Yesterday" },
    { id: 3, sender: "coach", text: "Perfect. See you at 7AM sharp. 🔥", time: "Yesterday" },
  ],
  "3": [
    { id: 1, sender: "coach", text: "Don't forget to stretch after every session. Flexibility is key.", time: "Mon" },
    { id: 2, sender: "user", text: "Will do, coach!", time: "Mon" },
  ],
  "4": [
    { id: 1, sender: "coach", text: "Your weekly macros review is ready. Protein is slightly below target.", time: "10:00 AM" },
    { id: 2, sender: "user", text: "How much should I increase it?", time: "10:05 AM" },
    { id: 3, sender: "coach", text: "Aim for an extra 30g of protein daily. Greek yogurt or a shake post-workout should do it.", time: "10:07 AM" },
  ],
};

export function Chat() {
  const { id = "1" } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const coach = COACHES[id] ?? COACHES["1"];

  const [messages, setMessages] = useState<Message[]>(INITIAL_MESSAGES[id] ?? INITIAL_MESSAGES["1"]);
  const [inputValue, setInputValue] = useState("");
  const [isRecording, setIsRecording] = useState(false);
  const recordingTimer = useRef<ReturnType<typeof setInterval> | null>(null);
  const [recordSeconds, setRecordSeconds] = useState(0);

  const now = () =>
    new Date().toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit", hour12: true });

  const handleSend = () => {
    if (!inputValue.trim()) return;
    const msg: Message = { id: Date.now(), sender: "user", text: inputValue, time: now() };
    setMessages((prev) => [...prev, msg]);
    setInputValue("");
    setTimeout(() => {
      setMessages((prev) => [
        ...prev,
        { id: Date.now() + 1, sender: "coach", text: "Got it! I'll review your progress and get back to you shortly. Keep up the great work! 🔥", time: now() },
      ]);
    }, 1500);
  };

  const startRecording = () => {
    setIsRecording(true);
    setRecordSeconds(0);
    recordingTimer.current = setInterval(() => setRecordSeconds((s) => s + 1), 1000);
  };

  const stopRecording = () => {
    if (recordingTimer.current) clearInterval(recordingTimer.current);
    const duration = `0:${String(recordSeconds).padStart(2, "0")}`;
    setIsRecording(false);
    setRecordSeconds(0);
    const msg: Message = {
      id: Date.now(),
      sender: "user",
      text: "Voice message",
      time: now(),
      voice: true,
      duration,
    };
    setMessages((prev) => [...prev, msg]);
    setTimeout(() => {
      setMessages((prev) => [
        ...prev,
        { id: Date.now() + 1, sender: "coach", text: "Received your voice message! Let me listen and get back to you. 🎧", time: now() },
      ]);
    }, 1800);
  };

  const fmtRecord = `0:${String(recordSeconds).padStart(2, "0")}`;

  return (
    <div className="flex flex-col h-[calc(100vh-8rem)]">
      {/* Header */}
      <div className="bg-[#1a1a1a] border-b border-[#2a2a2a] px-4 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <button
              onClick={() => navigate("/chat")}
              className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center mr-1"
            >
              <ChevronLeft className="w-4 h-4 text-gray-300" />
            </button>
            <div className="relative">
              <div className="w-10 h-10 bg-[#dc143c]/20 rounded-full flex items-center justify-center">
                <User className="w-5 h-5 text-[#dc143c]" />
              </div>
              {coach.online && (
                <div className="absolute bottom-0 right-0 w-2.5 h-2.5 bg-green-500 border-2 border-[#1a1a1a] rounded-full" />
              )}
            </div>
            <div>
              <h3 className="text-white text-sm font-medium leading-tight">{coach.name}</h3>
              <p className="text-xs text-gray-400">{coach.online ? "Active now" : coach.role}</p>
            </div>
          </div>
          <button className="w-9 h-9 bg-[#2a2a2a] rounded-full flex items-center justify-center hover:bg-[#3a3a3a] transition-colors">
            <MoreVertical className="w-4 h-4 text-white" />
          </button>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4 bg-[#0a0a0a]">
        <div className="flex justify-center mb-2">
          <div className="bg-[#1a1a1a] px-4 py-1.5 rounded-full border border-[#2a2a2a]">
            <p className="text-xs text-gray-400">Today</p>
          </div>
        </div>

        {messages.map((msg) => (
          <div key={msg.id} className={`flex ${msg.sender === "user" ? "justify-end" : "justify-start"}`}>
            <div className={`flex gap-2 max-w-[78%] ${msg.sender === "user" ? "flex-row-reverse" : ""}`}>
              {msg.sender === "coach" && (
                <div className="w-7 h-7 bg-[#dc143c]/20 rounded-full flex items-center justify-center flex-shrink-0 mt-1">
                  <User className="w-3.5 h-3.5 text-[#dc143c]" />
                </div>
              )}
              <div>
                {msg.voice ? (
                  <div
                    className={`px-4 py-3 rounded-2xl flex items-center gap-3 ${
                      msg.sender === "user"
                        ? "bg-[#dc143c] text-white rounded-tr-sm"
                        : "bg-[#1a1a1a] text-white border border-[#2a2a2a] rounded-tl-sm"
                    }`}
                  >
                    <div className="w-7 h-7 rounded-full bg-white/20 flex items-center justify-center">
                      <Mic className="w-3.5 h-3.5" />
                    </div>
                    <div className="flex items-center gap-1">
                      {[3, 5, 4, 7, 5, 3, 6, 4, 5, 3].map((h, i) => (
                        <div key={i} className="w-0.5 bg-white/60 rounded-full" style={{ height: `${h * 2}px` }} />
                      ))}
                    </div>
                    <span className="text-xs opacity-80">{msg.duration}</span>
                  </div>
                ) : (
                  <div
                    className={`px-4 py-3 rounded-2xl ${
                      msg.sender === "user"
                        ? "bg-[#dc143c] text-white rounded-tr-sm"
                        : "bg-[#1a1a1a] text-white border border-[#2a2a2a] rounded-tl-sm"
                    }`}
                  >
                    <p className="text-sm">{msg.text}</p>
                  </div>
                )}
                <p className={`text-xs text-gray-500 mt-1 ${msg.sender === "user" ? "text-right" : ""}`}>
                  {msg.time}
                </p>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Quick Replies */}
      <div className="px-4 py-2 bg-[#0a0a0a] border-t border-[#1a1a1a]">
        <div className="flex gap-2 overflow-x-auto pb-1 no-scrollbar">
          {["How's my progress?", "Reschedule session", "Diet advice"].map((t) => (
            <button
              key={t}
              onClick={() => setInputValue(t)}
              className="px-3 py-1.5 bg-[#1a1a1a] rounded-full text-xs text-gray-300 hover:bg-[#2a2a2a] transition-colors whitespace-nowrap border border-[#2a2a2a]"
            >
              {t}
            </button>
          ))}
        </div>
      </div>

      {/* Input */}
      <div className="bg-[#1a1a1a] border-t border-[#2a2a2a] px-4 py-3">
        {isRecording ? (
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2 flex-1 bg-[#dc143c]/10 border border-[#dc143c]/40 rounded-full px-4 py-2.5">
              <div className="w-2 h-2 rounded-full bg-[#dc143c] animate-pulse" />
              <span className="text-[#dc143c] text-sm font-medium">Recording… {fmtRecord}</span>
            </div>
            <button
              onClick={stopRecording}
              className="w-10 h-10 bg-[#dc143c] rounded-full flex items-center justify-center hover:bg-[#a00f2c] transition-colors"
            >
              <Square className="w-4 h-4 text-white fill-white" />
            </button>
          </div>
        ) : (
          <div className="flex items-center gap-2">
            <button className="text-gray-400 hover:text-white transition-colors p-1">
              <Paperclip className="w-5 h-5" />
            </button>
            <button
              onMouseDown={startRecording}
              className="text-gray-400 hover:text-[#dc143c] transition-colors p-1"
            >
              <Mic className="w-5 h-5" />
            </button>
            <div className="flex-1 bg-[#2a2a2a] rounded-full flex items-center px-4 py-2">
              <input
                type="text"
                value={inputValue}
                onChange={(e) => setInputValue(e.target.value)}
                onKeyDown={(e) => e.key === "Enter" && handleSend()}
                placeholder="Type a message…"
                className="flex-1 bg-transparent text-white placeholder-gray-500 outline-none text-sm"
              />
              <button className="text-gray-400 hover:text-white transition-colors">
                <Smile className="w-4 h-4" />
              </button>
            </div>
            <button
              onClick={handleSend}
              className="w-10 h-10 bg-[#dc143c] rounded-full flex items-center justify-center hover:bg-[#a00f2c] transition-colors flex-shrink-0"
            >
              <Send className="w-4 h-4 text-white" />
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
