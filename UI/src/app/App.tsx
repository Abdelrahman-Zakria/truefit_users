import { useState } from "react";
import { RouterProvider } from "react-router";
import { router } from "./routes";
import { AuthProvider, useAuth } from "../lib/AuthContext";
import { LanguageProvider } from "../lib/LanguageContext";
import { AppContext } from "../lib/AppContext";
import { Splash } from "./screens/Splash";
import { Login } from "./screens/Login";
import { GuestRegistration } from "./screens/GuestRegistration";
import { Pending } from "./screens/Pending";

function AppShell() {
  const { mode } = useAuth();
  const [splashDone, setSplashDone] = useState(false);
  const [showReg, setShowReg] = useState(false);
  const [preSelectedPlanId, setPreSelectedPlanId] = useState<string | undefined>(undefined);

  const triggerRegistration = (planId?: string) => {
    setPreSelectedPlanId(planId);
    setShowReg(true);
  };

  if (!splashDone) return <Splash onDone={() => setSplashDone(true)} />;
  if (mode === "pending") return <Pending />;

  if (mode === "unauthenticated") {
    return <Login onGoRegister={() => {}} />;
  }

  // Guest or Member — show the main router
  return (
    <AppContext.Provider value={{ triggerRegistration }}>
      <RouterProvider router={router} />
      {/* Registration overlay for guests who tap subscribe */}
      {showReg && mode === "guest" && (
        <GuestRegistration
          onClose={() => setShowReg(false)}
          preSelectedPlanId={preSelectedPlanId}
        />
      )}
    </AppContext.Provider>
  );
}

export default function App() {
  return (
    <LanguageProvider>
      <AuthProvider>
        <AppShell />
      </AuthProvider>
    </LanguageProvider>
  );
}
