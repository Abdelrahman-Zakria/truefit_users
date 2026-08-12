import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';

class ForgotPasswordModal extends StatefulWidget {
  final String lang;
  const ForgotPasswordModal({super.key, required this.lang});

  @override
  State<ForgotPasswordModal> createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  final TextEditingController _emailController = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  String tr(String key) => Translations.tr(key, widget.lang);

  Future<void> _handleSend() async {
    if (_emailController.text.isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _loading = false;
        _sent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = widget.lang == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('forgotPasswordTitle'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2A2A2A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF9E9E9E)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_sent) ...[
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha:0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.checkCircle, color: Colors.green, size: 28),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tr('resetEmailSent'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(tr('backToLogin')),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  tr('forgotPasswordSub'),
                  style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                ),
                const SizedBox(height: 20),
                Text(
                  tr('email'),
                  style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'you@example.com',
                    hintStyle: const TextStyle(color: Color(0xFF4B5563)),
                    prefixIcon: const Icon(LucideIcons.mail, size: 16, color: Color(0xFF6B7280)),
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
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _emailController.text.isEmpty || _loading ? null : _handleSend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.primaryRed.withValues(alpha:0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                              SizedBox(width: 8),
                              Text('Sending…'),
                            ],
                          )
                        : Text(tr('sendResetLink')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
