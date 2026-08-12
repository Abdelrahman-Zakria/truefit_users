import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../../../core/widgets/guest_locked_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/diet_cubit.dart';
import '../cubit/diet_state.dart';
import '../../domain/entities/diet_plan_entity.dart';
import '../../domain/entities/meal_entity.dart';
import '../widgets/diet_skeleton.dart';

class DietPlanScreen extends StatelessWidget {
  final bool isGuest;
  final String lang;
  final VoidCallback onJoinNow;

  const DietPlanScreen({
    super.key,
    required this.isGuest,
    required this.lang,
    required this.onJoinNow,
  });

  String tr(String key) => Translations.tr(key, lang);

  @override
  Widget build(BuildContext context) {
    if (isGuest) {
      return GuestLockedView(
        icon: LucideIcons.apple,
        featureKey: tr('lockDiet'),
        onJoinNow: onJoinNow,
        lang: lang,
      );
    }

    return BlocBuilder<DietCubit, DietState>(
      builder: (context, state) {
        final authState = context.watch<AuthCubit>().state;
        final int? persId = authState is Authenticated ? authState.user.persId : null;

        if (state is DietInitial && persId != null) {
          context.read<DietCubit>().loadDietPlan(persId);
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundBlack,
          body: RefreshIndicator(
            onRefresh: () async {
              if (persId != null) {
                await context.read<DietCubit>().loadDietPlan(persId);
              }
            },
            color: AppTheme.primaryRed,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildBody(context, state, persId),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('dailyMealPlan'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(tr('dietPlanSub'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, DietState state, int? persId) {
    if (state is DietLoading) {
      return const DietSkeleton();
    }

    if (state is DietLoaded) {
      final plan = state.dietPlan;
      return Column(
        children: [
          _buildTargetsCard(plan),
          _buildMacroDistribution(plan),
          _buildMealSchedule(plan.meals),
          _buildHydrationTracker(context, plan, persId),
          _buildNutritionistNotes(),
        ],
      );
    }

    if (state is DietError) {
      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
    }

    return const SizedBox();
  }

  Widget _buildTargetsCard(DietPlanEntity plan) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDC143C), Color(0xFFA00F2C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.flame, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(tr('todaysTarget'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('totalCalories'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(plan.totalCalories, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        const Text('kcal', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('waterGoal'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(plan.waterGoal, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        Text(lang == 'ar' ? 'لتر' : 'liters', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTargetMacro(LucideIcons.beef, plan.proteinGoal, tr('protein')),
                  _buildTargetMacro(LucideIcons.wheat, plan.carbsGoal, tr('carbs')),
                  _buildTargetMacro(LucideIcons.droplets, plan.fatsGoal, tr('fats')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetMacro(IconData icon, String val, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildMacroDistribution(DietPlanEntity plan) {
    final proteinVal = int.parse(plan.proteinGoal.replaceAll(RegExp(r'[^0-9]'), ''));
    final carbsVal = int.parse(plan.carbsGoal.replaceAll(RegExp(r'[^0-9]'), ''));
    final fatsVal = int.parse(plan.fatsGoal.replaceAll(RegExp(r'[^0-9]'), ''));
    final totalCals = int.parse(plan.totalCalories.replaceAll(RegExp(r'[^0-9]'), ''));

    final pPct = (proteinVal * 4 / totalCals);
    final cPct = (carbsVal * 4 / totalCals);
    final fPct = (fatsVal * 9 / totalCals);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('macroDistribution'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildMacroBar(tr('protein'), pPct, AppTheme.primaryRed),
          const SizedBox(height: 16),
          _buildMacroBar(tr('carbs'), cPct, AppTheme.primaryRed.withValues(alpha: 0.7)),
          const SizedBox(height: 16),
          _buildMacroBar(tr('fats'), fPct, AppTheme.primaryRed.withValues(alpha: 0.5)),
        ],
      ),
    );
  }

  Widget _buildMacroBar(String label, double pct, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text('${(pct * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: pct, color: color, backgroundColor: const Color(0xFF2A2A2A), minHeight: 8, borderRadius: BorderRadius.circular(4)),
      ],
    );
  }

  Widget _buildMealSchedule(List<MealEntity> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text(tr('mealSchedule'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...meals.map((meal) => _buildMealCard(meal)),
      ],
    );
  }

  Widget _buildMealCard(MealEntity meal) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.clock, color: Colors.grey, size: 14),
                      const SizedBox(width: 6),
                      Text(meal.time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(LucideIcons.flame, color: AppTheme.primaryRed, size: 16),
                  const SizedBox(width: 4),
                  Text('${meal.calories} kcal', style: const TextStyle(color: AppTheme.primaryRed, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...meal.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(LucideIcons.apple, color: Colors.grey, size: 14),
                const SizedBox(width: 8),
                Text(item, style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13)),
              ],
            ),
          )),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMealMacroInfo('P', '${meal.protein}g'),
              const SizedBox(width: 24),
              _buildMealMacroInfo('C', '${meal.carbs}g'),
              const SizedBox(width: 24),
              _buildMealMacroInfo('F', '${meal.fats}g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealMacroInfo(String label, String val) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12),
        children: [
          TextSpan(text: '$label: ', style: const TextStyle(color: Colors.grey)),
          TextSpan(text: val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHydrationTracker(BuildContext context, DietPlanEntity plan, int? persId) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.droplet, color: AppTheme.primaryRed, size: 20),
                  const SizedBox(width: 8),
                  Text(tr('waterIntake'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Text('${plan.currentWater} / ${plan.waterGoal} L', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: plan.currentWater / double.parse(plan.waterGoal),
              minHeight: 12,
              color: AppTheme.primaryRed,
              backgroundColor: const Color(0xFF2A2A2A),
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 6,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.2,
            children: List.generate(12, (index) {
              // Assuming each box is 0.25L roughly (12 boxes * 0.25 = 3L)
              final isFilled = (index + 1) * (double.parse(plan.waterGoal) / 12) <= plan.currentWater;
              return GestureDetector(
                onTap: () {
                  if (persId != null) {
                    final newAmount = (index + 1) * (double.parse(plan.waterGoal) / 12);
                    context.read<DietCubit>().updateWater(persId, newAmount);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isFilled ? AppTheme.primaryRed.withValues(alpha: 0.3) : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isFilled ? AppTheme.primaryRed : Colors.transparent),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionistNotes() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('nutritionistNotes'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(tr('dietNotes'), style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}
