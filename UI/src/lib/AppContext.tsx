import { createContext, useContext } from "react";

interface AppContextValue {
  triggerRegistration: (preSelectedPlan?: string) => void;
}

export const AppContext = createContext<AppContextValue>({
  triggerRegistration: () => {},
});

export function useAppContext() {
  return useContext(AppContext);
}
