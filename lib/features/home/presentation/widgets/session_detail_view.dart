import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';

class SessionDetailView extends StatelessWidget {
  final Map<String, dynamic> session;
  final String lang;
  final VoidCallback onBook;

  const SessionDetailView({
    super.key,
    required this.session,
    required this.lang,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final title = session['title'][lang];
    final instructor = session['instructor'][lang];
    final isFull = session['spots'] == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha:0.1), borderRadius: BorderRadius.circular(10)),
              child: const Text('No membership required', style: TextStyle(color: AppTheme.primaryRed, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            if (isFull) ...[
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey.withValues(alpha:0.1), borderRadius: BorderRadius.circular(10)), child: const Text('Full', style: TextStyle(color: Colors.grey, fontSize: 10))),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text('Instructor: $instructor', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
        const SizedBox(height: 24),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            _buildInfoCard(LucideIcons.mapPin, 'Location', session['location'][lang]),
            _buildInfoCard(LucideIcons.calendar, 'Date', session['date']),
            _buildInfoCard(LucideIcons.clock, 'Time', session['time']),
            _buildInfoCard(LucideIcons.users, 'Capacity', '${session['spots']} spots left'),
          ],
        ),
        
        const SizedBox(height: 24),
        const Text('About this Session', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          session['about'][lang],
          style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14, height: 1.5),
        ),
        
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isFull ? null : onBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF2A2A2A),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(isFull ? 'Session Full' : 'Join Session', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String val) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryRed, size: 14),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              val,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
