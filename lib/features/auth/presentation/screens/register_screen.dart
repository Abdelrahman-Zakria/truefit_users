import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';

class RegisterScreen extends StatefulWidget {
  final String lang;
  final VoidCallback onBackToLogin;
  final Function(Map<String, dynamic>) onRegister;

  const RegisterScreen({
    super.key,
    required this.lang,
    required this.onBackToLogin,
    required this.onRegister,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 1;
  final int _totalSteps = 3;

  // Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String tr(String key) => Translations.tr(key, widget.lang);

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      widget.onRegister({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text,
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      widget.onBackToLogin();
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
              const SizedBox(height: 32),
              
              if (_currentStep == 1) _buildStep1(),
              if (_currentStep == 2) _buildStep2(),
              if (_currentStep == 3) _buildStep3(),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _currentStep == _totalSteps ? tr('completeReg') : tr('nextStep'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField(tr('fullName'), LucideIcons.user, _nameController, hint: 'John Doe'),
        const SizedBox(height: 20),
        _buildField(tr('email'), LucideIcons.mail, _emailController, hint: 'you@example.com'),
        const SizedBox(height: 20),
        _buildField(tr('phone'), LucideIcons.phone, _phoneController, hint: tr('phoneHint')),
        const SizedBox(height: 20),
        _buildField(tr('password'), LucideIcons.lock, _passwordController, hint: '••••••••', obscure: true),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('choosePlanStep'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildPlanCard(tr('basic'), 'EGP 500', [tr('basicF1'), tr('basicF2')]),
        const SizedBox(height: 12),
        _buildPlanCard(tr('standard'), 'EGP 900', [tr('standardF1'), tr('standardF2')], isPopular: true),
        const SizedBox(height: 12),
        _buildPlanCard(tr('premiumElite'), 'EGP 1500', [tr('eliteF1'), tr('eliteF2')]),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('paymentStep'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildField(tr('cardName'), LucideIcons.creditCard, TextEditingController(), hint: 'JOHN DOE'),
        const SizedBox(height: 16),
        _buildField(tr('cardNumber'), LucideIcons.creditCard, TextEditingController(), hint: '0000 0000 0000 0000'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildField(tr('expiry'), LucideIcons.calendar, TextEditingController(), hint: 'MM/YY')),
            const SizedBox(width: 16),
            Expanded(child: _buildField(tr('cvv'), LucideIcons.lock, TextEditingController(), hint: '123')),
          ],
        ),
      ],
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController controller, {String? hint, bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
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
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryRed)),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(String name, String price, List<String> features, {bool isPopular = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPopular ? AppTheme.primaryRed : const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha:0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(tr('mostPopular'), style: const TextStyle(color: AppTheme.primaryRed, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(color: AppTheme.primaryRed, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(LucideIcons.check, size: 14, color: Colors.green),
                const SizedBox(width: 8),
                Text(f, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
