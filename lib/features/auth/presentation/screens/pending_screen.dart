import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';

class PendingScreen extends StatelessWidget {
  final String lang;
  final VoidCallback onSignOut;

  const PendingScreen({
    super.key,
    required this.lang,
    required this.onSignOut,
  });

  String tr(String key) => Translations.tr(key, lang);

  @override
  Widget build(BuildContext context) {
    final isRtl = lang == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundBlack,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Animated Check
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha:0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green.withValues(alpha:0.2)),
                  ),
                  child: const Icon(LucideIcons.checkCircle, color: Colors.green, size: 40),
                ),
                const SizedBox(height: 32),
                Text(
                  tr('pendingTitle'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  tr('pendingSubtitle'),
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        tr('pendingMessage'),
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.info, size: 14, color: Color(0xFF6B7280)),
                          const SizedBox(width: 8),
                          Text(
                            tr('pendingNote'),
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Contact support logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF2A2A2A)),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(tr('contactSupport')),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onSignOut,
                  child: Text(
                    tr('signOut'),
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
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
