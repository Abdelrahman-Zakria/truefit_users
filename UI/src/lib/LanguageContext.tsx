import { createContext, useContext, useState, ReactNode } from "react";
import t, { Lang, TKey } from "./translations";

interface LangContextValue {
  lang: Lang;
  setLang: (l: Lang) => void;
  tr: (key: TKey) => string;
  dir: "ltr" | "rtl";
}

const LangContext = createContext<LangContextValue | null>(null);

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [lang, setLang] = useState<Lang>("en");
  const dir = lang === "ar" ? "rtl" : "ltr";
  const tr = (key: TKey): string => t[lang][key] as string;

  return (
    <LangContext.Provider value={{ lang, setLang, tr, dir }}>
      {children}
    </LangContext.Provider>
  );
}

export function useLang() {
  const ctx = useContext(LangContext);
  if (!ctx) throw new Error("useLang must be used inside LanguageProvider");
  return ctx;
}
