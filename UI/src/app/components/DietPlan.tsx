import { Flame, Droplet, Beef, Wheat, Apple, Clock } from "lucide-react";
import { useAuth } from "../../lib/AuthContext";
import { useLang } from "../../lib/LanguageContext";
import { GuestLockedTab } from "./GuestLockedTab";

export function DietPlan() {
  const { mode } = useAuth();
  const { tr } = useLang();
  if (mode === "guest") return <GuestLockedTab icon={<Apple className="w-12 h-12 text-gray-600" />} featureKey={tr("lockDiet")} />;
  const meals = [
    {
      id: 1,
      name: "Breakfast",
      time: "7:00 AM",
      items: [
        "3 Scrambled Eggs",
        "2 Whole Wheat Toast",
        "1 Avocado",
        "Green Tea",
      ],
      calories: 450,
      protein: 28,
      carbs: 42,
      fats: 18,
    },
    {
      id: 2,
      name: "Mid-Morning Snack",
      time: "10:00 AM",
      items: [
        "Greek Yogurt (200g)",
        "Mixed Berries",
        "Almonds (30g)",
      ],
      calories: 280,
      protein: 18,
      carbs: 24,
      fats: 12,
    },
    {
      id: 3,
      name: "Lunch",
      time: "1:00 PM",
      items: [
        "Grilled Chicken Breast (200g)",
        "Brown Rice (150g)",
        "Steamed Broccoli",
        "Mixed Salad",
      ],
      calories: 580,
      protein: 48,
      carbs: 62,
      fats: 12,
    },
    {
      id: 4,
      name: "Pre-Workout Snack",
      time: "4:00 PM",
      items: [
        "Banana",
        "Peanut Butter (2 tbsp)",
        "Whey Protein Shake",
      ],
      calories: 350,
      protein: 32,
      carbs: 38,
      fats: 10,
    },
    {
      id: 5,
      name: "Dinner",
      time: "7:00 PM",
      items: [
        "Grilled Salmon (180g)",
        "Sweet Potato (200g)",
        "Asparagus",
        "Olive Oil Dressing",
      ],
      calories: 520,
      protein: 42,
      carbs: 48,
      fats: 16,
    },
  ];

  const totalCalories = meals.reduce((sum, meal) => sum + meal.calories, 0);
  const totalProtein = meals.reduce((sum, meal) => sum + meal.protein, 0);
  const totalCarbs = meals.reduce((sum, meal) => sum + meal.carbs, 0);
  const totalFats = meals.reduce((sum, meal) => sum + meal.fats, 0);

  return (
    <div className="p-6 space-y-6">
      <div>
        <h2 className="text-2xl mb-2">Daily Meal Plan</h2>
        <p className="text-gray-400">Your personalized nutrition guide</p>
      </div>

      {/* Daily Macros Summary */}
      <div className="bg-gradient-to-br from-[#dc143c] to-[#a00f2c] rounded-2xl p-6 relative overflow-hidden">
        <div className="absolute top-0 right-0 w-40 h-40 bg-white/10 rounded-full -mr-20 -mt-20"></div>
        
        <div className="relative z-10">
          <div className="flex items-center gap-2 mb-4">
            <Flame className="w-6 h-6" />
            <h3 className="text-xl">Today's Target</h3>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <p className="text-white/80 text-sm mb-1">Total Calories</p>
              <p className="text-3xl">{totalCalories}</p>
              <p className="text-sm text-white/80">kcal</p>
            </div>
            <div>
              <p className="text-white/80 text-sm mb-1">Water Goal</p>
              <p className="text-3xl">3.0</p>
              <p className="text-sm text-white/80">liters</p>
            </div>
          </div>

          <div className="grid grid-cols-3 gap-3 mt-4 pt-4 border-t border-white/20">
            <div className="text-center">
              <Beef className="w-5 h-5 mx-auto mb-1 text-white/80" />
              <p className="text-xl">{totalProtein}g</p>
              <p className="text-xs text-white/80">Protein</p>
            </div>
            <div className="text-center">
              <Wheat className="w-5 h-5 mx-auto mb-1 text-white/80" />
              <p className="text-xl">{totalCarbs}g</p>
              <p className="text-xs text-white/80">Carbs</p>
            </div>
            <div className="text-center">
              <Droplet className="w-5 h-5 mx-auto mb-1 text-white/80" />
              <p className="text-xl">{totalFats}g</p>
              <p className="text-xs text-white/80">Fats</p>
            </div>
          </div>
        </div>
      </div>

      {/* Macro Distribution */}
      <div className="bg-[#1a1a1a] rounded-xl p-5 border border-[#2a2a2a]">
        <h3 className="text-lg mb-4">Macro Distribution</h3>
        
        <div className="space-y-4">
          <div>
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm text-gray-400">Protein</span>
              <span className="text-sm text-white">{Math.round((totalProtein * 4 / totalCalories) * 100)}%</span>
            </div>
            <div className="w-full h-2 bg-[#2a2a2a] rounded-full overflow-hidden">
              <div 
                className="h-full bg-[#dc143c] rounded-full"
                style={{ width: `${Math.round((totalProtein * 4 / totalCalories) * 100)}%` }}
              ></div>
            </div>
          </div>

          <div>
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm text-gray-400">Carbs</span>
              <span className="text-sm text-white">{Math.round((totalCarbs * 4 / totalCalories) * 100)}%</span>
            </div>
            <div className="w-full h-2 bg-[#2a2a2a] rounded-full overflow-hidden">
              <div 
                className="h-full bg-[#dc143c]/70 rounded-full"
                style={{ width: `${Math.round((totalCarbs * 4 / totalCalories) * 100)}%` }}
              ></div>
            </div>
          </div>

          <div>
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm text-gray-400">Fats</span>
              <span className="text-sm text-white">{Math.round((totalFats * 9 / totalCalories) * 100)}%</span>
            </div>
            <div className="w-full h-2 bg-[#2a2a2a] rounded-full overflow-hidden">
              <div 
                className="h-full bg-[#dc143c]/50 rounded-full"
                style={{ width: `${Math.round((totalFats * 9 / totalCalories) * 100)}%` }}
              ></div>
            </div>
          </div>
        </div>
      </div>

      {/* Meal Plan */}
      <div className="space-y-3">
        <h3 className="text-lg">Meal Schedule</h3>
        
        {meals.map((meal) => (
          <div
            key={meal.id}
            className="bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a]"
          >
            <div className="flex items-start justify-between mb-3">
              <div>
                <h4 className="text-white mb-1">{meal.name}</h4>
                <div className="flex items-center gap-2 text-sm text-gray-400">
                  <Clock className="w-4 h-4" />
                  <span>{meal.time}</span>
                </div>
              </div>
              <div className="flex items-center gap-1 text-[#dc143c]">
                <Flame className="w-4 h-4" />
                <span className="text-sm">{meal.calories} kcal</span>
              </div>
            </div>

            <div className="space-y-1 mb-3">
              {meal.items.map((item, index) => (
                <div key={index} className="flex items-center gap-2">
                  <Apple className="w-3 h-3 text-gray-500" />
                  <span className="text-sm text-gray-300">{item}</span>
                </div>
              ))}
            </div>

            <div className="flex gap-4 pt-3 border-t border-[#2a2a2a] text-xs">
              <div>
                <span className="text-gray-400">P: </span>
                <span className="text-white">{meal.protein}g</span>
              </div>
              <div>
                <span className="text-gray-400">C: </span>
                <span className="text-white">{meal.carbs}g</span>
              </div>
              <div>
                <span className="text-gray-400">F: </span>
                <span className="text-white">{meal.fats}g</span>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Hydration Tracker */}
      <div className="bg-[#1a1a1a] rounded-xl p-5 border border-[#2a2a2a]">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Droplet className="w-5 h-5 text-[#dc143c]" />
            <h3 className="text-lg">Water Intake</h3>
          </div>
          <span className="text-sm text-gray-400">2.1 / 3.0 L</span>
        </div>

        <div className="w-full h-3 bg-[#2a2a2a] rounded-full overflow-hidden mb-3">
          <div 
            className="h-full bg-gradient-to-r from-[#dc143c] to-[#a00f2c] rounded-full"
            style={{ width: '70%' }}
          ></div>
        </div>

        <div className="flex gap-2">
          {[...Array(12)].map((_, i) => (
            <div
              key={i}
              className={`flex-1 h-8 rounded ${
                i < 8 ? "bg-[#dc143c]/30" : "bg-[#2a2a2a]"
              }`}
            ></div>
          ))}
        </div>
      </div>

      {/* Dietary Notes */}
      <div className="bg-[#dc143c]/10 border border-[#dc143c]/30 rounded-xl p-4">
        <h4 className="text-white mb-2">Nutritionist Notes</h4>
        <p className="text-sm text-gray-300">
          Your meal plan is optimized for muscle gain and recovery. Remember to adjust portions based on workout intensity. Stay consistent with meal timing for best results.
        </p>
      </div>
    </div>
  );
}
