import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../../../core/widgets/guest_locked_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/progress_cubit.dart';
import '../cubit/progress_state.dart';
import '../../domain/entities/inbody_scan_entity.dart';
import '../widgets/progress_charts.dart';
import '../widgets/book_scan_sheet.dart';
import '../widgets/progress_skeleton.dart';

class ProgressScreen extends StatelessWidget {
  final bool isGuest;
  final String lang;
  final VoidCallback onJoinNow;

  const ProgressScreen({
    super.key,
    required this.isGuest,
    required this.lang,
    required this.onJoinNow,
  });

  String tr(String key) => Translations.tr(key, lang);

  void _showBookScan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookScanSheet(lang: lang),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isGuest) {
      return GuestLockedView(
        icon: LucideIcons.trendingUp,
        featureKey: tr('lockProgress'),
        onJoinNow: onJoinNow,
        lang: lang,
      );
    }

    return BlocBuilder<ProgressCubit, ProgressState>(
      builder: (context, state) {
        final authState = context.watch<AuthCubit>().state;
        final int? persId = authState is Authenticated ? authState.user.persId : null;

        if (state is ProgressInitial && persId != null) {
          context.read<ProgressCubit>().loadProgressData(persId);
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundBlack,
          body: RefreshIndicator(
            onRefresh: () async {
              if (persId != null) {
                await context.read<ProgressCubit>().loadProgressData(persId);
              }
            },
            color: AppTheme.primaryRed,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildBody(context, state),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('inBodyProgress'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(tr('trackBodyComp'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProgressState state) {
    if (state is ProgressLoading || state is ProgressInitial) {
      return const ProgressSkeleton();
    }

    if (state is ProgressLoaded) {
      final scan = state.latestScan;
      return Column(
        children: [
          _buildLatestScanCard(scan),
          _buildKeyMetrics(scan),
          _buildChartsSection(state.allScans),
          _buildNextScanSection(context),
        ],
      );
    }

    if (state is ProgressError) {
      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
    }

    return const SizedBox();
  }

  Widget _buildLatestScanCard(InBodyScanEntity scan) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFDC143C), Color(0xFFA00F2C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(top: -20, right: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('latestScan'), style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(scan.date, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildLatestStatItem(tr('bodyWeight'), scan.weight, 'kg', scan.weightChange, LucideIcons.trendingDown)),
                  Expanded(child: _buildLatestStatItem(tr('bodyFat'), scan.bodyFat, '%', scan.bodyFatChange, LucideIcons.trendingDown)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildLatestStatItem(tr('muscleMass'), scan.muscleMass, 'kg', scan.muscleMassChange, LucideIcons.trendingUp)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('bmi'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(scan.bmi, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(scan.bmiStatus, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLatestStatItem(String label, String value, String unit, String change, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(unit, style: const TextStyle(color: Colors.white70, fontSize: 14))),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(change, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyMetrics(InBodyScanEntity scan) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildKeyMetricCard(LucideIcons.scale, scan.totalWeightLost, tr('weightLost') + ' (kg)')),
          const SizedBox(width: 12),
          Expanded(child: _buildKeyMetricCard(LucideIcons.activity, scan.totalMuscleGain, tr('muscleGain') + ' (kg)')),
          const SizedBox(width: 12),
          Expanded(child: _buildKeyMetricCard(LucideIcons.trendingDown, scan.totalBodyFatChange, tr('bodyFat'))),
        ],
      ),
    );
  }

  Widget _buildKeyMetricCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryRed, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildChartsSection(List<InBodyScanEntity> scans) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: ProgressCharts(lang: lang, scans: scans),
    );
  }

  Widget _buildNextScanSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('nextInBodyScan'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(tr('scheduleNextScan'), style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showBookScan(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(tr('bookNextScan'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
