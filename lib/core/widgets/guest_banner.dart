import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GuestBanner extends StatelessWidget {
  final VoidCallback onJoinNow;

  const GuestBanner({super.key, required this.onJoinNow});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.primaryRed.withValues(alpha:0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Browsing as guest',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
          ),
          TextButton(
            onPressed: onJoinNow,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Join Now',
              style: TextStyle(
                color: AppTheme.primaryRed,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
