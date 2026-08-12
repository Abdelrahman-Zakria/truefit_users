import { useState } from "react";
import { User, Users, Clock, MapPin, ChevronRight, X, Check, Calendar, ChevronLeft } from "lucide-react";
import { useAuth } from "../../lib/AuthContext";
import { useLang } from "../../lib/LanguageContext";
import { GuestLockedTab } from "./GuestLockedTab";

type Tab = "pt" | "classes";
type BookingStep = "datetime" | "confirm" | "success";

interface PTSession {
  id: number;
  trainer: string;
  specialty: string;
  duration: string;
  available: boolean;
  avatar: string;
}

interface ClassItem {
  id: number;
  name: string;
  instructor: string;
  date: string;
  time: string;
  duration: string;
  capacity: string;
  spotsLeft: number;
  location: string;
}

const PT_SESSIONS: PTSession[] = [
  { id: 1, trainer: "Sarah Mitchell", specialty: "Strength & Conditioning", duration: "60 min", available: true, avatar: "SM" },
  { id: 2, trainer: "Marcus Chen", specialty: "HIIT & Boxing", duration: "60 min", available: true, avatar: "MC" },
  { id: 3, trainer: "Emily Rodriguez", specialty: "Yoga & Flexibility", duration: "45 min", available: true, avatar: "ER" },
  { id: 4, trainer: "David Kumar", specialty: "Powerlifting", duration: "60 min", available: false, avatar: "DK" },
];

const CLASSES: ClassItem[] = [
  { id: 1, name: "Morning HIIT", instructor: "Marcus Chen", date: "Mon, Jul 1", time: "7:00 AM", duration: "45 min", capacity: "8/12", spotsLeft: 4, location: "Studio A" },
  { id: 2, name: "Spin Class", instructor: "Jessica Park", date: "Mon, Jul 1", time: "6:00 PM", duration: "50 min", capacity: "15/20", spotsLeft: 5, location: "Cycling Room" },
  { id: 3, name: "Power Yoga", instructor: "Emily Rodriguez", date: "Tue, Jul 2", time: "10:00 AM", duration: "60 min", capacity: "10/15", spotsLeft: 5, location: "Studio B" },
  { id: 4, name: "Boxing Fundamentals", instructor: "Marcus Chen", date: "Wed, Jul 3", time: "7:00 PM", duration: "55 min", capacity: "6/10", spotsLeft: 4, location: "Boxing Zone" },
  { id: 5, name: "Pilates Core", instructor: "Sarah Mitchell", date: "Thu, Jul 4", time: "9:30 AM", duration: "45 min", capacity: "12/12", spotsLeft: 0, location: "Studio A" },
];

const WEEK_DAYS = [
  { label: "Mon", date: "Jun 30" },
  { label: "Tue", date: "Jul 1" },
  { label: "Wed", date: "Jul 2" },
  { label: "Thu", date: "Jul 3" },
  { label: "Fri", date: "Jul 4" },
  { label: "Sat", date: "Jul 5" },
  { label: "Sun", date: "Jul 6" },
];

const TIME_SLOTS = ["7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM", "6:00 PM", "7:00 PM"];
const UNAVAILABLE_SLOTS = new Set(["8:00 AM", "1:00 PM", "5:00 PM"]);

interface PTBookingModalProps {
  session: PTSession;
  onClose: () => void;
}

function PTBookingModal({ session, onClose }: PTBookingModalProps) {
  const [step, setStep] = useState<BookingStep>("datetime");
  const [selectedDay, setSelectedDay] = useState(WEEK_DAYS[1]);
  const [selectedTime, setSelectedTime] = useState<string | null>(null);

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/70 backdrop-blur-sm">
      <div className="bg-[#111111] w-full max-w-md rounded-t-3xl border-t border-x border-[#2a2a2a] max-h-[92vh] overflow-y-auto">
        <div className="flex justify-center pt-3 pb-1">
          <div className="w-10 h-1 rounded-full bg-[#3a3a3a]" />
        </div>

        {step !== "success" && (
          <div className="flex items-center justify-between px-6 py-4 border-b border-[#2a2a2a]">
            <div className="flex items-center gap-3">
              {step === "confirm" && (
                <button
                  onClick={() => setStep("datetime")}
                  className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center"
                >
                  <ChevronLeft className="w-4 h-4" />
                </button>
              )}
              <div>
                <p className="text-xs text-gray-400">
                  {step === "datetime" ? "Step 1 of 2" : "Step 2 of 2"}
                </p>
                <h3 className="text-white font-medium">
                  {step === "datetime" ? "Pick Date & Time" : "Confirm Booking"}
                </h3>
              </div>
            </div>
            <button
              onClick={onClose}
              className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center"
            >
              <X className="w-4 h-4 text-gray-400" />
            </button>
          </div>
        )}

        <div className="px-6 py-5">
          {/* Trainer info pill */}
          {step !== "success" && (
            <div className="flex items-center gap-3 mb-5 bg-[#1a1a1a] rounded-xl p-3 border border-[#2a2a2a]">
              <div className="w-10 h-10 rounded-full bg-[#dc143c]/20 flex items-center justify-center text-[#dc143c] font-semibold text-sm">
                {session.avatar}
              </div>
              <div>
                <p className="text-white text-sm font-medium">{session.trainer}</p>
                <p className="text-xs text-gray-400">{session.specialty} · {session.duration}</p>
              </div>
            </div>
          )}

          {step === "datetime" && (
            <div className="space-y-5">
              {/* Day picker */}
              <div>
                <p className="text-xs text-gray-400 mb-3 uppercase tracking-wide">Select Day</p>
                <div className="grid grid-cols-7 gap-1">
                  {WEEK_DAYS.map((d) => (
                    <button
                      key={d.label}
                      onClick={() => setSelectedDay(d)}
                      className={`flex flex-col items-center py-2.5 rounded-xl transition-all ${
                        selectedDay.label === d.label
                          ? "bg-[#dc143c] text-white"
                          : "bg-[#1a1a1a] text-gray-400 hover:bg-[#2a2a2a]"
                      }`}
                    >
                      <span className="text-xs font-medium">{d.label}</span>
                      <span className="text-xs mt-0.5 opacity-70">{d.date.split(" ")[1]}</span>
                    </button>
                  ))}
                </div>
              </div>

              {/* Time picker */}
              <div>
                <p className="text-xs text-gray-400 mb-3 uppercase tracking-wide">Select Time</p>
                <div className="grid grid-cols-3 gap-2">
                  {TIME_SLOTS.map((t) => {
                    const unavailable = UNAVAILABLE_SLOTS.has(t);
                    return (
                      <button
                        key={t}
                        disabled={unavailable}
                        onClick={() => setSelectedTime(t)}
                        className={`py-2.5 rounded-xl text-sm transition-all ${
                          unavailable
                            ? "bg-[#1a1a1a] text-gray-600 cursor-not-allowed"
                            : selectedTime === t
                            ? "bg-[#dc143c] text-white"
                            : "bg-[#1a1a1a] text-gray-300 hover:bg-[#2a2a2a] border border-[#2a2a2a]"
                        }`}
                      >
                        {t}
                        {unavailable && (
                          <span className="block text-xs text-gray-600 leading-none mt-0.5">Booked</span>
                        )}
                      </button>
                    );
                  })}
                </div>
              </div>

              <button
                disabled={!selectedTime}
                onClick={() => setStep("confirm")}
                className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium disabled:opacity-40 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                Review Booking <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          )}

          {step === "confirm" && (
            <div className="space-y-4">
              <div className="bg-[#1a1a1a] rounded-xl border border-[#2a2a2a] divide-y divide-[#2a2a2a]">
                {[
                  { label: "Trainer", value: session.trainer },
                  { label: "Specialty", value: session.specialty },
                  { label: "Date", value: `${selectedDay.label}, ${selectedDay.date}` },
                  { label: "Time", value: selectedTime! },
                  { label: "Duration", value: session.duration },
                ].map(({ label, value }) => (
                  <div key={label} className="flex justify-between px-4 py-3 text-sm">
                    <span className="text-gray-400">{label}</span>
                    <span className="text-white">{value}</span>
                  </div>
                ))}
              </div>

              <div className="bg-[#dc143c]/10 border border-[#dc143c]/30 rounded-xl p-3 text-sm text-gray-400">
                You can cancel up to 6 hours before your session without penalty.
              </div>

              <button
                onClick={() => setStep("success")}
                className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium"
              >
                Confirm Booking
              </button>
            </div>
          )}

          {step === "success" && (
            <div className="py-8 flex flex-col items-center text-center space-y-5">
              <div className="w-20 h-20 rounded-full bg-[#dc143c]/20 flex items-center justify-center">
                <div className="w-14 h-14 rounded-full bg-[#dc143c] flex items-center justify-center">
                  <Check className="w-8 h-8 text-white" />
                </div>
              </div>
              <div>
                <h3 className="text-2xl text-white mb-2">Booked!</h3>
                <p className="text-gray-400 text-sm">
                  Your session with <span className="text-white">{session.trainer}</span> is confirmed for{" "}
                  <span className="text-white">{selectedDay.label}, {selectedDay.date} at {selectedTime}</span>.
                </p>
              </div>
              <div className="w-full bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a] space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-gray-400">Trainer</span>
                  <span className="text-white">{session.trainer}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Date & Time</span>
                  <span className="text-white">{selectedDay.date} · {selectedTime}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Duration</span>
                  <span className="text-white">{session.duration}</span>
                </div>
              </div>
              <button
                onClick={onClose}
                className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium"
              >
                Done
              </button>
            </div>
          )}
        </div>
        <div className="h-6" />
      </div>
    </div>
  );
}

interface ClassBookingModalProps {
  classItem: ClassItem;
  onClose: () => void;
}

function ClassBookingModal({ classItem, onClose }: ClassBookingModalProps) {
  const [step, setStep] = useState<"confirm" | "success">("confirm");

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/70 backdrop-blur-sm">
      <div className="bg-[#111111] w-full max-w-md rounded-t-3xl border-t border-x border-[#2a2a2a] max-h-[92vh] overflow-y-auto">
        <div className="flex justify-center pt-3 pb-1">
          <div className="w-10 h-1 rounded-full bg-[#3a3a3a]" />
        </div>

        {step === "confirm" && (
          <>
            <div className="flex items-center justify-between px-6 py-4 border-b border-[#2a2a2a]">
              <h3 className="text-white font-medium">Confirm Booking</h3>
              <button
                onClick={onClose}
                className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center"
              >
                <X className="w-4 h-4 text-gray-400" />
              </button>
            </div>

            <div className="px-6 py-5 space-y-4">
              <div className="bg-gradient-to-br from-[#dc143c]/20 to-[#dc143c]/5 rounded-xl p-4 border border-[#dc143c]/30">
                <h4 className="text-white text-lg font-semibold mb-1">{classItem.name}</h4>
                <p className="text-gray-400 text-sm">with {classItem.instructor}</p>
              </div>

              <div className="bg-[#1a1a1a] rounded-xl border border-[#2a2a2a] divide-y divide-[#2a2a2a]">
                {[
                  { label: "Date", value: classItem.date, icon: <Calendar className="w-4 h-4" /> },
                  { label: "Time", value: classItem.time, icon: <Clock className="w-4 h-4" /> },
                  { label: "Duration", value: classItem.duration, icon: null },
                  { label: "Location", value: classItem.location, icon: <MapPin className="w-4 h-4" /> },
                  { label: "Spots left", value: `${classItem.spotsLeft} available`, icon: <Users className="w-4 h-4" /> },
                ].map(({ label, value, icon }) => (
                  <div key={label} className="flex justify-between items-center px-4 py-3 text-sm">
                    <div className="flex items-center gap-2 text-gray-400">
                      {icon && <span className="text-[#dc143c]">{icon}</span>}
                      {label}
                    </div>
                    <span className="text-white">{value}</span>
                  </div>
                ))}
              </div>

              <div className="bg-[#dc143c]/10 border border-[#dc143c]/30 rounded-xl p-3 text-sm text-gray-400">
                You can cancel up to 2 hours before the class starts.
              </div>

              <button
                onClick={() => setStep("success")}
                className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium"
              >
                Confirm Booking
              </button>
            </div>
          </>
        )}

        {step === "success" && (
          <div className="px-6 py-5">
            <div className="py-8 flex flex-col items-center text-center space-y-5">
              <div className="w-20 h-20 rounded-full bg-[#dc143c]/20 flex items-center justify-center">
                <div className="w-14 h-14 rounded-full bg-[#dc143c] flex items-center justify-center">
                  <Check className="w-8 h-8 text-white" />
                </div>
              </div>
              <div>
                <h3 className="text-2xl text-white mb-2">You're In!</h3>
                <p className="text-gray-400 text-sm">
                  <span className="text-white">{classItem.name}</span> on{" "}
                  <span className="text-white">{classItem.date} at {classItem.time}</span> is confirmed.
                </p>
              </div>
              <div className="w-full bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a] space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-gray-400">Class</span>
                  <span className="text-white">{classItem.name}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Instructor</span>
                  <span className="text-white">{classItem.instructor}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Location</span>
                  <span className="text-white">{classItem.location}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Date & Time</span>
                  <span className="text-white">{classItem.date} · {classItem.time}</span>
                </div>
              </div>
              <button
                onClick={onClose}
                className="w-full bg-[#dc143c] text-white py-4 rounded-xl hover:bg-[#a00f2c] transition-colors font-medium"
              >
                Done
              </button>
            </div>
          </div>
        )}
        <div className="h-6" />
      </div>
    </div>
  );
}

interface MyBooking {
  id: string;
  type: "pt" | "class";
  name: string;
  detail: string;
}

export function Booking() {
  const { mode } = useAuth();
  const { tr } = useLang();
  const [activeTab, setActiveTab] = useState<Tab>("pt");
  const [selectedPT, setSelectedPT] = useState<PTSession | null>(null);
  const [selectedClass, setSelectedClass] = useState<ClassItem | null>(null);
  const [myBookings, setMyBookings] = useState<MyBooking[]>([
    { id: "b1", type: "class", name: "Morning HIIT", detail: "Mon, Jul 1 at 7:00 AM" },
    { id: "b2", type: "pt", name: "PT with Sarah Mitchell", detail: "Wed, Jul 3 at 10:00 AM" },
  ]);

  if (mode === "guest") return <GuestLockedTab icon={<Calendar className="w-12 h-12 text-gray-600" />} featureKey={tr("lockBooking")} />;

  const handlePTClose = () => setSelectedPT(null);
  const handleClassClose = () => setSelectedClass(null);

  return (
    <>
      <div className="p-6 space-y-6">
        <div>
          <h2 className="text-2xl mb-2">Book Sessions</h2>
          <p className="text-gray-400">Schedule your workouts</p>
        </div>

        {/* Tabs */}
        <div className="flex gap-2 bg-[#1a1a1a] p-1 rounded-xl border border-[#2a2a2a]">
          <button
            onClick={() => setActiveTab("pt")}
            className={`flex-1 py-3 rounded-lg transition-colors ${
              activeTab === "pt" ? "bg-[#dc143c] text-white" : "text-gray-400 hover:text-white"
            }`}
          >
            <div className="flex items-center justify-center gap-2">
              <User className="w-4 h-4" />
              <span>Personal Training</span>
            </div>
          </button>
          <button
            onClick={() => setActiveTab("classes")}
            className={`flex-1 py-3 rounded-lg transition-colors ${
              activeTab === "classes" ? "bg-[#dc143c] text-white" : "text-gray-400 hover:text-white"
            }`}
          >
            <div className="flex items-center justify-center gap-2">
              <Users className="w-4 h-4" />
              <span>Group Classes</span>
            </div>
          </button>
        </div>

        {/* PT Sessions Tab */}
        {activeTab === "pt" && (
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-lg">Available Trainers</h3>
            </div>
            <div className="space-y-3">
              {PT_SESSIONS.map((session) => (
                <div
                  key={session.id}
                  className="bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a] hover:border-[#dc143c]/30 transition-colors"
                >
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex gap-3">
                      <div className="w-12 h-12 bg-[#dc143c]/20 rounded-full flex items-center justify-center text-[#dc143c] font-semibold">
                        {session.avatar}
                      </div>
                      <div>
                        <h4 className="text-white mb-1">{session.trainer}</h4>
                        <p className="text-sm text-gray-400">{session.specialty}</p>
                      </div>
                    </div>
                    {session.available ? (
                      <span className="text-xs bg-green-500/20 text-green-500 px-2 py-1 rounded-full">Available</span>
                    ) : (
                      <span className="text-xs bg-gray-500/20 text-gray-400 px-2 py-1 rounded-full">Booked</span>
                    )}
                  </div>
                  <div className="flex items-center gap-4 mb-3 text-sm text-gray-400">
                    <div className="flex items-center gap-1">
                      <Clock className="w-4 h-4" />
                      <span>{session.duration}</span>
                    </div>
                  </div>
                  <button
                    disabled={!session.available}
                    onClick={() => setSelectedPT(session)}
                    className={`w-full py-2 rounded-lg transition-colors ${
                      session.available
                        ? "bg-[#dc143c] text-white hover:bg-[#a00f2c]"
                        : "bg-[#2a2a2a] text-gray-500 cursor-not-allowed"
                    }`}
                  >
                    {session.available ? "Book Session" : "Not Available"}
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Classes Tab */}
        {activeTab === "classes" && (
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-lg">Upcoming Classes</h3>
            </div>
            <div className="space-y-3">
              {CLASSES.map((classItem) => {
                const isFull = classItem.spotsLeft === 0;
                return (
                  <div
                    key={classItem.id}
                    className="bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a] hover:border-[#dc143c]/30 transition-colors"
                  >
                    <div className="flex items-start justify-between mb-3">
                      <div>
                        <h4 className="text-white mb-1">{classItem.name}</h4>
                        <p className="text-sm text-gray-400">with {classItem.instructor}</p>
                      </div>
                      <span className={`text-xs px-2 py-1 rounded-full ${
                        isFull ? "bg-gray-500/20 text-gray-400" : "bg-green-500/20 text-green-500"
                      }`}>
                        {isFull ? "Full" : `${classItem.spotsLeft} left`}
                      </span>
                    </div>
                    <div className="grid grid-cols-2 gap-2 mb-3 text-sm text-gray-400">
                      <div className="flex items-center gap-1"><Clock className="w-4 h-4" /><span>{classItem.time}</span></div>
                      <div className="flex items-center gap-1"><MapPin className="w-4 h-4" /><span>{classItem.location}</span></div>
                      <div><span>{classItem.date}</span></div>
                      <div><span>{classItem.duration}</span></div>
                    </div>
                    <button
                      disabled={isFull}
                      onClick={() => setSelectedClass(classItem)}
                      className={`w-full py-2 rounded-lg transition-colors ${
                        isFull
                          ? "bg-[#2a2a2a] text-gray-500 cursor-not-allowed"
                          : "bg-[#dc143c] text-white hover:bg-[#a00f2c]"
                      }`}
                    >
                      {isFull ? "Class Full" : "Book Class"}
                    </button>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* My Bookings */}
        <div className="bg-[#1a1a1a] rounded-xl p-5 border border-[#2a2a2a]">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg">My Upcoming Bookings</h3>
            <ChevronRight className="w-5 h-5 text-gray-400" />
          </div>
          {myBookings.length === 0 ? (
            <p className="text-gray-500 text-sm text-center py-4">No upcoming bookings.</p>
          ) : (
            <div className="space-y-3">
              {myBookings.map((b) => (
                <div key={b.id} className="flex items-center gap-3 py-2">
                  <div className="w-10 h-10 bg-[#dc143c]/20 rounded-lg flex items-center justify-center flex-shrink-0">
                    {b.type === "class" ? (
                      <Users className="w-5 h-5 text-[#dc143c]" />
                    ) : (
                      <User className="w-5 h-5 text-[#dc143c]" />
                    )}
                  </div>
                  <div className="flex-1">
                    <p className="text-white text-sm">{b.name}</p>
                    <p className="text-gray-400 text-xs">{b.detail}</p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {selectedPT && <PTBookingModal session={selectedPT} onClose={handlePTClose} />}
      {selectedClass && <ClassBookingModal classItem={selectedClass} onClose={handleClassClose} />}
    </>
  );
}
