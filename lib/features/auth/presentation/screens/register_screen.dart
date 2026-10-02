import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../../../core/services/payment_service.dart';
import '../../../subscription/presentation/cubit/subscription_cubit.dart';
import '../../../subscription/presentation/cubit/subscription_state.dart';
import '../../../subscription/domain/entities/membership_plan_entity.dart';
import '../../../subscription/domain/entities/branch_entity.dart';

class RegisterScreen extends StatefulWidget {
  final String lang;
  final VoidCallback onBackToLogin;
  final Function(Map<String, dynamic>) onRegister;
  final String? initialPlanId;

  const RegisterScreen({
    super.key,
    required this.lang,
    required this.onBackToLogin,
    required this.onRegister,
    this.initialPlanId,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 1;
  final int _totalSteps = 3;
  bool _isSubmitting = false;

  // Form Controllers
  final _formKeyStep1 = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdayController = TextEditingController();

  BranchEntity? _selectedBranch;
  MembershipPlanEntity? _selectedPlan;
  String _selectedPaymentMethod = 'cash'; // 'cash' or 'instapay'

  File? _screenshot;
  final PaymentService _paymentService = PaymentService();

  String tr(String key) => Translations.tr(key, widget.lang);

  @override
  void initState() {
    super.initState();
    // Load plans & branches for guest selection
    context.read<SubscriptionCubit>().loadMembershipPlans();
  }

  Future<void> _handleInstaPay() async {
    try {
      await _paymentService.openInstaPay();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.primaryRed),
      );
    }
  }

  Future<void> _pickScreenshot() async {
    final file = await _paymentService.pickPaymentScreenshot();
    if (file != null) {
      setState(() => _screenshot = file);
    }
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (!_formKeyStep1.currentState!.validate()) {
        return;
      }
      if (_selectedBranch == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('branchRequired')),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_selectedPlan == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('choosePlan')),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
        return;
      }
      setState(() => _currentStep = 3);
    } else if (_currentStep == 3) {
      _completeRegistration();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      widget.onBackToLogin();
    }
  }

  void _completeRegistration() async {
    String? screenshotUrl;

    if (_selectedPaymentMethod == 'instapay') {
      if (_screenshot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('pleaseUploadScreenshot')),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        screenshotUrl = await _paymentService.uploadScreenshot(_screenshot!);
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppTheme.primaryRed,
            ),
          );
        }
        return;
      }
    } else {
      setState(() => _isSubmitting = true);
    }

    final double priceVal = double.tryParse(_selectedPlan?.price.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0.0;
    final planNameStr = _selectedPlan?.name[widget.lang] ?? _selectedPlan?.name['en'] ?? 'Membership Plan';

    final data = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      'birthday': _birthdayController.text.trim().isEmpty ? '2000-01-01' : _birthdayController.text.trim(),
      'branchId': _selectedBranch?.id,
      'branchName': _selectedBranch?.displayName,
      'planId': _selectedPlan?.id,
      'planName': planNameStr,
      'amount': priceVal,
      'paymentMethod': _selectedPaymentMethod,
      'screenshotUrl': screenshotUrl,
    };

    try {
      await widget.onRegister(data);
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    }
  }

  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryRed,
              onPrimary: Colors.white,
              surface: Color(0xFF1F1F1F),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = intl.DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = widget.lang == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundBlack,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(isRtl ? LucideIcons.chevronRight : LucideIcons.chevronLeft, color: Colors.white),
            onPressed: _prevStep,
          ),
          title: Text(
            "${tr('step')} $_currentStep ${tr('of')} $_totalSteps",
            style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('guestRegTitle'),
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                tr('guestRegSub'),
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              ),
              const SizedBox(height: 28),

              if (_currentStep == 1) _buildStep1(),
              if (_currentStep == 2) _buildStep2(),
              if (_currentStep == 3) _buildStep3(),

              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.primaryRed.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Text(tr('processingPayment')),
                          ],
                        )
                      : Text(
                          _currentStep == _totalSteps ? tr('completeReg') : tr('nextStep'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        List<BranchEntity> branches = [];
        if (state is SubscriptionPlansLoaded) {
          branches = state.branches;
          if (_selectedBranch == null && branches.isNotEmpty) {
            _selectedBranch = branches.first;
          }
        }

        return Form(
          key: _formKeyStep1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('personalInfo'),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                label: tr('fullName'),
                icon: LucideIcons.user,
                controller: _nameController,
                hint: 'e.g. John Doe',
                validator: (val) => val == null || val.trim().isEmpty ? tr('fillAllFields') : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                label: tr('phone'),
                icon: LucideIcons.phone,
                controller: _phoneController,
                hint: tr('phoneHint'),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 11,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return tr('fillAllFields');
                  }
                  if (val.trim().length != 11) {
                    return tr('invalidPhone');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                label: tr('email'),
                icon: LucideIcons.mail,
                controller: _emailController,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _selectBirthday,
                child: AbsorbPointer(
                  child: _buildTextFormField(
                    label: tr('birthday'),
                    icon: LucideIcons.calendar,
                    controller: _birthdayController,
                    hint: 'YYYY-MM-DD',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                tr('selectBranch'),
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (branches.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryRed)),
                      const SizedBox(width: 12),
                      Text(tr('loading'), style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              else
                Column(
                  children: branches.map((branch) {
                    final isSelected = _selectedBranch?.id == branch.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedBranch = branch),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryRed.withValues(alpha: 0.1) : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryRed : const Color(0xFF2A2A2A),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.mapPin,
                              color: isSelected ? AppTheme.primaryRed : const Color(0xFF6B7280),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    branch.displayName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (branch.address.isNotEmpty)
                                    Text(
                                      branch.address,
                                      style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(LucideIcons.checkCircle2, color: AppTheme.primaryRed, size: 20),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep2() {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        List<MembershipPlanEntity> plans = [];
        if (state is SubscriptionPlansLoaded) {
          plans = state.plans;
          if (_selectedPlan == null && plans.isNotEmpty) {
            if (widget.initialPlanId != null) {
              _selectedPlan = plans.firstWhere(
                (p) => p.id == widget.initialPlanId,
                orElse: () => plans.first,
              );
            } else {
              _selectedPlan = plans.first;
            }
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('choosePlanStep'),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (plans.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppTheme.primaryRed),
                ),
              )
            else
              Column(
                children: plans.map((plan) {
                  final isSelected = _selectedPlan?.id == plan.id;
                  final planName = plan.name[widget.lang] ?? plan.name['en'] ?? 'Membership';
                  final featuresList = plan.features[widget.lang] ?? plan.features['en'] ?? [];

                  return GestureDetector(
                    onTap: () => setState(() => _selectedPlan = plan),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryRed.withValues(alpha: 0.1) : const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryRed : const Color(0xFF2A2A2A),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                planName,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              if (plan.isPopular)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryRed.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tr('mostPopular'),
                                    style: const TextStyle(color: AppTheme.primaryRed, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            plan.price,
                            style: const TextStyle(color: AppTheme.primaryRed, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          if (featuresList.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ...featuresList.map((f) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      const Icon(LucideIcons.check, size: 14, color: Colors.green),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          f,
                                          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStep3() {
    final planName = _selectedPlan?.name[widget.lang] ?? _selectedPlan?.name['en'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('paymentStep'),
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('selectedPlan'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(planName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('branch'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(_selectedBranch?.displayName ?? 'Default Branch', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(color: Color(0xFF2A2A2A), height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('totalDue'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(_selectedPlan?.price ?? '0 EGP', style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text(
          tr('selectPaymentMethod'),
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Payment Option: Cash at Reception
        GestureDetector(
          onTap: () => setState(() => _selectedPaymentMethod = 'cash'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedPaymentMethod == 'cash' ? AppTheme.primaryRed.withValues(alpha: 0.1) : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _selectedPaymentMethod == 'cash' ? AppTheme.primaryRed : const Color(0xFF2A2A2A),
                width: _selectedPaymentMethod == 'cash' ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.banknote, color: Colors.amber, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('cashAtReception'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(tr('payAtGym'), style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                    ],
                  ),
                ),
                if (_selectedPaymentMethod == 'cash')
                  const Icon(LucideIcons.checkCircle2, color: AppTheme.primaryRed, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Payment Option: InstaPay Transfer
        GestureDetector(
          onTap: () => setState(() => _selectedPaymentMethod = 'instapay'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedPaymentMethod == 'instapay' ? AppTheme.primaryRed.withValues(alpha: 0.1) : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _selectedPaymentMethod == 'instapay' ? AppTheme.primaryRed : const Color(0xFF2A2A2A),
                width: _selectedPaymentMethod == 'instapay' ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Image.asset('assets/images/instapay.png', width: 38, height: 38),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('payViaInstaPay'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      const Text('InstaPay Transfer / Mobile Wallet', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                    ],
                  ),
                ),
                if (_selectedPaymentMethod == 'instapay')
                  const Icon(LucideIcons.checkCircle2, color: AppTheme.primaryRed, size: 20),
              ],
            ),
          ),
        ),

        if (_selectedPaymentMethod == 'instapay') _buildInstaPayFlow(),
      ],
    );
  }

  Widget _buildInstaPayFlow() {
    final double priceVal = double.tryParse(_selectedPlan?.price.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Divider(color: Color(0xFF2A2A2A)),
        const SizedBox(height: 16),
        Text(tr('followSteps'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildStep(
          1,
          tr('clickToOpenInstaPay'),
          action: TextButton.icon(
            onPressed: _handleInstaPay,
            icon: const Icon(LucideIcons.externalLink, size: 14),
            label: Text(tr('openInstaPay')),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryRed, padding: EdgeInsets.zero),
          ),
        ),
        _buildStep(2, "${tr('enterAmountManually')}: ${priceVal.toInt()} LE"),
        _buildStep(
          3,
          tr('uploadTransferScreenshot'),
          action: GestureDetector(
            onTap: _pickScreenshot,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: _screenshot != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_screenshot!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.image, color: Colors.grey, size: 32),
                        const SizedBox(height: 8),
                        Text(tr('tapToUpload'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep(int n, String text, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle),
            child: Center(
              child: Text(
                "$n",
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                if (action != null) action,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            counterText: "",
            hintStyle: const TextStyle(color: Color(0xFF4B5563)),
            prefixIcon: Icon(icon, size: 16, color: const Color(0xFF6B7280)),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryRed)),
            errorStyle: const TextStyle(color: AppTheme.primaryRed),
          ),
        ),
      ],
    );
  }
}
