import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../../../core/widgets/payment_selection_step.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/membership_plan_entity.dart';
import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';

class RenewalModal extends StatefulWidget {
  final String lang;
  final List<MembershipPlanEntity> plans;
  final MembershipPlanEntity? initialPlan;
  const RenewalModal({
    super.key,
    required this.lang,
    required this.plans,
    this.initialPlan,
  });

  @override
  State<RenewalModal> createState() => _RenewalModalState();
}

class _RenewalModalState extends State<RenewalModal> {
  int _currentStep = 0; // 0: plan, 1: payment, 2: success
  late MembershipPlanEntity _selectedPlan;
  
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default to initialPlan or the first popular plan, or just the first plan
    _selectedPlan = widget.initialPlan ?? 
                    (widget.plans as Iterable<MembershipPlanEntity>).firstWhere((p) => p.isPopular, orElse: () => widget.plans.first);
  }

  String tr(String key) => Translations.tr(key, widget.lang);

  @override
  Widget build(BuildContext context) {
    final isRtl = widget.lang == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF111111),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF3A3A3A), borderRadius: BorderRadius.circular(2))),
              
              if (_currentStep < 2) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (_currentStep > 0)
                            IconButton(
                              onPressed: () => setState(() => _currentStep--),
                              icon: Icon(isRtl ? LucideIcons.chevronRight : LucideIcons.chevronLeft, color: Colors.white, size: 20),
                            ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${tr('step')} ${_currentStep + 1} ${tr('of')} 2", style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                              Text(
                                _currentStep == 0 ? tr('choosePlan') : tr('paymentDetails'),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF1A1A1A)),
              ],

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildStepContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    return BlocConsumer<SubscriptionCubit, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionSuccess && _currentStep == 1) {
          setState(() => _currentStep = 2);
        }
      },
      builder: (context, state) {
        if (_currentStep == 0) return _buildPlanStep();
        if (_currentStep == 1) return _buildPaymentStep();
        return _buildSuccessStep();
      },
    );
  }

  Widget _buildPlanStep() {
    return Column(
      children: [
        ...widget.plans.map((plan) {
          final isSelected = _selectedPlan.id == plan.id;
          final planName = plan.name[widget.lang] ?? plan.name['en'] ?? '';
          final features = plan.features[widget.lang] ?? plan.features['en'] ?? [];

          return GestureDetector(
            onTap: () => setState(() => _selectedPlan = plan),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryRed.withValues(alpha:0.1) : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppTheme.primaryRed : const Color(0xFF2A2A2A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppTheme.primaryRed : Colors.transparent,
                              border: Border.all(color: isSelected ? AppTheme.primaryRed : const Color(0xFF3A3A3A), width: 2),
                            ),
                            child: isSelected ? const Icon(LucideIcons.check, size: 12, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 8),
                          Text(planName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (plan.originalPrice != null)
                            Text(
                              '${plan.originalPrice} LE',
                              style: const TextStyle(color: Colors.grey, fontSize: 10, decoration: TextDecoration.lineThrough),
                            ),
                          Text("${plan.price} LE", style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...features.take(2).map((f) => Padding(
                    padding: const EdgeInsets.only(left: 28, bottom: 2),
                    child: Row(children: [const Icon(LucideIcons.check, size: 12, color: AppTheme.primaryRed), const SizedBox(width: 6), Text(f, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12))]),
                  )),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        _buildActionButton(tr('continue'), () => setState(() => _currentStep++)),
      ],
    );
  }

  Widget _buildPaymentStep() {
    final authState = context.read<AuthCubit>().state;
    int persId = 0;
    String email = "Guest";
    String memberName = "Guest User";

    if (authState is Authenticated) {
      persId = authState.user.persId ?? 0;
      email = authState.user.email ?? "";
      memberName = authState.user.displayName ?? authState.user.nameEn ?? authState.user.nameAr ?? "Member";
    } else if (authState is GuestAuthenticated) {
      persId = 0; 
      email = "Guest User";
    }

    final pName = widget.lang == 'ar' ? (_selectedPlan.name['ar'] ?? '') : (_selectedPlan.name['en'] ?? '');

    return PaymentSelectionStep(
      lang: widget.lang,
      amount: double.parse(_selectedPlan.price),
      itemName: pName,
      onCompleted: (method, screenshotUrl) {
        context.read<SubscriptionCubit>().requestPayment(
          persId: persId,
          email: email,
          memberName: memberName,
          planId: _selectedPlan.id,
          planName: pName,
          amount: double.parse(_selectedPlan.price),
          method: method,
          screenshotUrl: screenshotUrl,
        );
      },
    );
  }

  Widget _buildSuccessStep() {
    final planName = _selectedPlan.name[widget.lang] ?? _selectedPlan.name['en'] ?? '';
    return Column(
      children: [
        const SizedBox(height: 32),
        Container(width: 80, height: 80, decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha:0.1), shape: BoxShape.circle), child: const Icon(LucideIcons.check, color: AppTheme.primaryRed, size: 40)),
        const SizedBox(height: 24),
        Text(tr('allSet'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("${tr('yourSubscription')} $planName ${tr('membershipRenewed')}", style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        _buildActionButton(tr('done'), () {
          final authState = context.read<AuthCubit>().state;
          if (authState is Authenticated) {
            context.read<SubscriptionCubit>().loadMembershipPlans(persId: authState.user.persId);
          }
          Navigator.pop(context);
        }),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF4B5563)),
            prefixIcon: Icon(icon, size: 16, color: const Color(0xFF6B7280)),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.primaryRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
