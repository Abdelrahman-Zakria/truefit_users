import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../intl/translations.dart';

class GuestLockedView extends StatelessWidget {
  final IconData icon;
  final String featureKey;
  final VoidCallback onJoinNow;
  final String lang;

  const GuestLockedView({
    super.key,
    required this.icon,
    required this.featureKey,
    required this.onJoinNow,
    required this.lang,
  });

  String tr(String key) => Translations.tr(key, lang);

  @override
  Widget build(BuildContext context) {
    final isRtl = lang == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Blurred icon background
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Opacity(
                    opacity: 0.3,
                    child: Icon(icon, size: 48, color: const Color(0xFF6B7280)),
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryRed.withValues(alpha:0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryRed.withValues(alpha:0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(LucideIcons.lock, color: AppTheme.primaryRed, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              tr('featureLocked'),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              featureKey,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              tr('featureLockedDesc'),
              style: const TextStyle(color: Color(0xFF4B5563), fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onJoinNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(tr('viewPackages'), style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Icon(isRtl ? LucideIcons.chevronLeft : LucideIcons.chevronRight, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
