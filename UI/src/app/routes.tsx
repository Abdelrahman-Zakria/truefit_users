import { createBrowserRouter } from "react-router";
import { Layout } from "./components/Layout";
import { Home } from "./components/Home";
import { Subscription } from "./components/Subscription";
import { Booking } from "./components/Booking";
import { DietPlan } from "./components/DietPlan";
import { InBodyProgress } from "./components/InBodyProgress";
import { Conversations } from "./components/Conversations";
import { Chat } from "./components/Chat";
import { Profile } from "./components/Profile";
import { Notifications } from "./components/Notifications";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: Layout,
    children: [
      { index: true, Component: Home },
      { path: "subscription", Component: Subscription },
      { path: "booking", Component: Booking },
      { path: "diet", Component: DietPlan },
      { path: "progress", Component: InBodyProgress },
      { path: "chat", Component: Conversations },
      { path: "chat/:id", Component: Chat },
      { path: "profile", Component: Profile },
      { path: "notifications", Component: Notifications },
    ],
  },
]);
