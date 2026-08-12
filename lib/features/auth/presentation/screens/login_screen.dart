import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../widgets/forgot_password_modal.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onGoRegister;
  final Function(String, String) onLogin;
  final VoidCallback onContinueAsGuest;

  const LoginScreen({
    super.key,
    required this.onGoRegister,
    required this.onLogin,
    required this.onContinueAsGuest,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _lang = 'en';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPass = false;

  String tr(String key) => Translations.tr(key, _lang);

  void _toggleLang(String l) {
    setState(() => _lang = l);
  }

  void _showErrorSnackBar(String message) {
    String displayMessage = tr('loginFailed');
    
    if (message.contains('User not found')) {
      displayMessage = tr('userNotFound');
    } else if (message.contains('Incorrect password')) {
      displayMessage = tr('incorrectPassword');
    } else if (message.contains('Error parsing')) {
      displayMessage = tr('errorParsing');
    } else if (message.contains('fillAllFields')) {
      displayMessage = tr('fillAllFields');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(displayMessage, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      widget.onLogin(_phoneController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = _lang == 'ar';
    final dir = isRtl ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: dir,
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            _showErrorSnackBar(state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.backgroundBlack,
          body: SafeArea(
            child: Stack(
              children: [
                // Lang toggle
                Positioned(
                  top: 16,
                  right: isRtl ? null : 16,
                  left: isRtl ? 16 : null,
                  child: Row(
                    children: ['en', 'ar'].map((l) {
                      final isActive = _lang == l;
                      return GestureDetector(
                        onTap: () => _toggleLang(l),
                        child: Container(
                          margin: const EdgeInsets.only(left: 4, right: 4),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? AppTheme.primaryRed : const Color(0xFF1A1A1A),
                            border: isActive ? null : Border.all(color: const Color(0xFF2A2A2A)),
                          ),
                          child: Center(
                            child: Text(
                              l.toUpperCase(),
                              style: TextStyle(
                                color: isActive ? Colors.white : const Color(0xFF9E9E9E),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Hero
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 56, bottom: 32, left: 24, right: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primaryRed.withValues(alpha:0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.primaryRed.withValues(alpha:0.3)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryRed.withValues(alpha:0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/images/Profile Pic.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              tr('welcomeBack'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tr('signInAccount'),
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Form
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr('phone'),
                                style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _phoneController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.phone,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                maxLength: 11,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return tr('fillAllFields');
                                  }
                                  if (value.length != 11) {
                                    return tr('invalidPhone');
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: tr('phoneHint'),
                                  counterText: "",
                                  hintStyle: const TextStyle(color: Color(0xFF4B5563)),
                                  prefixIcon: const Icon(LucideIcons.phone, size: 16, color: Color(0xFF6B7280)),
                                  filled: true,
                                  fillColor: const Color(0xFF1A1A1A),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppTheme.primaryRed),
                                  ),
                                  errorStyle: const TextStyle(color: AppTheme.primaryRed),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppTheme.primaryRed),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              Text(
                                tr('password'),
                                style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_showPass,
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return tr('fillAllFields');
                                  }
                                  if (value.length < 6) {
                                    return tr('invalidPassword');
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  hintStyle: const TextStyle(color: Color(0xFF4B5563)),
                                  prefixIcon: const Icon(LucideIcons.lock, size: 16, color: Color(0xFF6B7280)),
                                  suffixIcon: GestureDetector(
                                    onTap: () => setState(() => _showPass = !_showPass),
                                    child: Icon(
                                      _showPass ? LucideIcons.eyeOff : LucideIcons.eye,
                                      size: 16,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF1A1A1A),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppTheme.primaryRed),
                                  ),
                                  errorStyle: const TextStyle(color: AppTheme.primaryRed),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppTheme.primaryRed),
                                  ),
                                ),
                              ),

                              Align(
                                alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => ForgotPasswordModal(lang: _lang),
                                    );
                                  },
                                  child: Text(
                                    tr('forgotPassword'),
                                    style: const TextStyle(color: AppTheme.primaryRed, fontSize: 14),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  final loading = state is AuthLoading;
                                  return SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: loading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryRed,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: AppTheme.primaryRed.withValues(alpha:0.5),
                                        padding: const EdgeInsets.symmetric(vertical: 18),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: loading
                                          ? Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                                                const SizedBox(width: 12),
                                                Text(tr('signingIn')),
                                              ],
                                            )
                                          : Text(tr('signIn'), style: const TextStyle(fontWeight: FontWeight.w500)),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const Expanded(child: Divider(color: Color(0xFF2A2A2A))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      tr('or'),
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ),
                                  const Expanded(child: Divider(color: Color(0xFF2A2A2A))),
                                ],
                              ),
                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: widget.onContinueAsGuest,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.primaryRed,
                                    side: BorderSide(color: AppTheme.primaryRed.withValues(alpha:0.5)),
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(tr('continueAsGuest'), style: const TextStyle(fontWeight: FontWeight.w500)),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
