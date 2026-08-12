import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../../data/models/user_subscription_model.dart';
import '../../domain/entities/membership_plan_entity.dart';
import '../widgets/renewal_modal.dart';
import '../widgets/subscription_skeleton.dart';

class SubscriptionScreen extends StatelessWidget {
  final bool isGuest;
  final String lang;
  final VoidCallback onJoinNow;

  const SubscriptionScreen({
    super.key,
    required this.isGuest,
    required this.lang,
    required this.onJoinNow,
  });

  String tr(String key) => Translations.tr(key, lang);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        print('DEBUG: SubscriptionScreen state: $state');
        if (state is SubscriptionInitial) {
          // Trigger load if somehow skipped
          final authState = context.read<AuthCubit>().state;
          if (authState is Authenticated) {
            context.read<SubscriptionCubit>().loadMembershipPlans(persId: authState.user.persId);
          } else {
            context.read<SubscriptionCubit>().loadMembershipPlans();
          }
          return SubscriptionSkeleton(isGuest: isGuest);
        }
        
        if (state is SubscriptionLoading) {
          return SubscriptionSkeleton(isGuest: isGuest);
        }

        if (state is SubscriptionPlansLoaded) {
          print('DEBUG: Plans loaded: ${state.plans.length}');
          if (state.plans.isEmpty) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundBlack,
              body: Center(child: Text(tr('noPlansFound') ?? "No plans found in Firestore", style: const TextStyle(color: Colors.white))),
            );
          }
          return Scaffold(
            backgroundColor: AppTheme.backgroundBlack,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  if (!isGuest && (state.activePlan != null || state.userSubscription != null)) 
                    _buildCurrentPlan(
                      context, 
                      state.plans,
                      state.activePlan ?? MembershipPlanEntity(id: '0', name: const {'en': 'Member', 'ar': 'عضو'}, price: '0', features: const {}, isPopular: false), 
                      state.userSubscription?.toDate
                    ),
                  if (!isGuest) _buildSavedCards(state.userSubscription),
                  _buildBody(context, state),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        }

        if (state is SubscriptionError) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundBlack,
            body: Center(child: Text(state.message, style: const TextStyle(color: Colors.red))),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('yourMembership'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(tr('managePlan'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCurrentPlan(BuildContext context, List<MembershipPlanEntity> allPlans, MembershipPlanEntity plan, String? expiryDate) {
    String formattedExpiry = expiryDate ?? '—';
    try {
      if (expiryDate != null) {
        final date = DateTime.parse(expiryDate);
        formattedExpiry = DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (_) {}

    final planName = plan.name[lang] ?? plan.name['en'] ?? tr('member');

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('currentPlan'), style: const TextStyle(color: AppTheme.primaryRed, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(planName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.withValues(alpha: 0.3))),
                child: Text(tr('active'), style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(tr('nextBilling'), formattedExpiry),
          const SizedBox(height: 12),
          _buildInfoRow(tr('paymentMethod'), 'Cash / Manual'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showRenewalModal(context, allPlans, initialPlan: plan),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(tr('renewNow'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildBody(BuildContext context, SubscriptionPlansLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text(isGuest ? tr('choosePlan') : tr('otherPlans'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: state.plans.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _buildPlanCard(context, state.plans, state.plans[index]),
        ),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, List<MembershipPlanEntity> allPlans, MembershipPlanEntity plan) {
    final planName = plan.name[lang] ?? plan.name['en'] ?? '';
    final features = plan.features[lang] ?? plan.features['en'] ?? [];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: plan.isPopular ? AppTheme.primaryRed.withValues(alpha: 0.5) : const Color(0xFF2A2A2A), width: plan.isPopular ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.isPopular)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(8)),
              child: Text(tr('mostPopular'), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(planName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (plan.originalPrice != null)
                    Text(
                      '${plan.originalPrice} LE',
                      style: const TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough),
                    ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '${plan.price} LE', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        TextSpan(text: ' / ${lang == 'ar' ? 'اشتراك' : 'plan'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(LucideIcons.check, color: AppTheme.primaryRed, size: 16),
                    const SizedBox(width: 12),
                    Text(f, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showRenewalModal(context, allPlans, initialPlan: plan),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: plan.isPopular ? AppTheme.primaryRed : const Color(0xFF3A3A3A)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(tr('subscribeNow'), style: TextStyle(color: plan.isPopular ? AppTheme.primaryRed : Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showRenewalModal(BuildContext context, List<MembershipPlanEntity> plans, {MembershipPlanEntity? initialPlan}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RenewalModal(
        lang: lang,
        plans: plans,
        initialPlan: initialPlan,
      ),
    );
  }

  Widget _buildSavedCards(UserSubscriptionModel? userSub) {
    String expiry = userSub?.toDate ?? 'Manual / Admin';
    try {
      if (userSub?.toDate != null) {
        final date = DateTime.parse(userSub!.toDate);
        expiry = DateFormat('MMMM dd, yyyy').format(date);
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('billingInfo'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildBillingItem(LucideIcons.calendar, tr('nextBilling'), expiry),
          const Divider(color: Color(0xFF2A2A2A), height: 32),
          _buildBillingItem(
            LucideIcons.creditCard, 
            tr('paymentMethod'), 
            'Legacy System',
            trailing: Text(tr('update'), style: const TextStyle(color: AppTheme.primaryRed, fontSize: 12, fontWeight: FontWeight.bold))
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 32),
          _buildAutoRenewalRow(),
        ],
      ),
    );
  }

  Widget _buildBillingItem(IconData icon, String label, String value, {Widget? trailing}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppTheme.primaryRed, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildAutoRenewalRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(LucideIcons.check, color: Colors.green, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('autoRenewal'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(tr('enabled'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Switch(
          value: true,
          onChanged: (val) {},
          activeTrackColor: AppTheme.primaryRed.withValues(alpha: 0.3),
          activeThumbColor: AppTheme.primaryRed,
        ),
      ],
    );
  }
}
