import { createContext, useContext, useState, ReactNode } from "react";

export type AuthMode = "unauthenticated" | "guest" | "pending" | "member";

export interface MockUser {
  displayName: string;
  email: string;
  phone?: string;
  address?: string;
  birthday?: string;
  plan?: string;
  memberSince?: string;
}

interface AuthContextValue {
  user: MockUser | null;
  mode: AuthMode;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  continueAsGuest: () => void;
  guestSubscribe: (data: { name: string; phone: string; address: string; birthday: string; plan: string }) => void;
  approveMembership: () => void;
  updateProfile: (data: Partial<MockUser>) => void;
  error: string | null;
  clearError: () => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<MockUser | null>(null);
  const [mode, setMode] = useState<AuthMode>("unauthenticated");
  const [error, setError] = useState<string | null>(null);

  const login = async (email: string, password: string) => {
    setError(null);
    await new Promise((r) => setTimeout(r, 900));
    if (!email || !password) { setError("fillAllFields"); throw new Error(); }
    setUser({
      displayName: email.split("@")[0],
      email,
      plan: "Premium Elite",
      memberSince: "Jan 2024",
    });
    setMode("member");
  };

  const logout = async () => {
    setUser(null);
    setMode("unauthenticated");
  };

  const continueAsGuest = () => setMode("guest");

  const guestSubscribe = (data: { name: string; phone: string; address: string; birthday: string; plan: string }) => {
    setUser({
      displayName: data.name,
      email: "",
      phone: data.phone,
      address: data.address,
      birthday: data.birthday,
      plan: data.plan,
      memberSince: new Date().toLocaleDateString("en-US", { month: "short", year: "numeric" }),
    });
    setMode("pending");
  };

  const approveMembership = () => setMode("member");

  const updateProfile = (data: Partial<MockUser>) => {
    setUser((prev) => (prev ? { ...prev, ...data } : prev));
  };

  const clearError = () => setError(null);

  return (
    <AuthContext.Provider value={{ user, mode, login, logout, continueAsGuest, guestSubscribe, approveMembership, updateProfile, error, clearError }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used inside AuthProvider");
  return ctx;
}
