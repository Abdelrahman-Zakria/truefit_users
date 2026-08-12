import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';

class QuickAccessGrid extends StatelessWidget {
  final Function(int) onNavigate;
  final String lang;

  const QuickAccessGrid({super.key, required this.onNavigate, required this.lang});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildItem(context, LucideIcons.calendar, 'book', 2),
        _buildItem(context, LucideIcons.apple, 'diet', 3),
        _buildItem(context, LucideIcons.trendingUp, 'progress', 4),
        _buildItem(context, LucideIcons.messageCircle, 'chat', 5),
      ],
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String labelKey, int index) {
    return GestureDetector(
      onTap: () => onNavigate(index),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
            child: Icon(icon, color: AppTheme.primaryRed, size: 24),
          ),
          const SizedBox(height: 8),
          Text(Translations.tr(labelKey, lang), style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}
