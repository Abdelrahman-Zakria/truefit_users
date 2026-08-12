import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/translations.dart';
import '../../domain/entities/inbody_scan_entity.dart';

class ProgressCharts extends StatelessWidget {
  final String lang;
  final List<InBodyScanEntity> scans;
  const ProgressCharts({super.key, required this.lang, required this.scans});

  String tr(String key) => Translations.tr(key, lang);

  @override
  Widget build(BuildContext context) {
    // Sort scans by date just in case
    final sortedScans = List<InBodyScanEntity>.from(scans);
    sortedScans.sort((a, b) => a.date.compareTo(b.date));

    // Take last 6 for trend charts
    final trendScans = sortedScans.length > 6 ? sortedScans.sublist(sortedScans.length - 6) : sortedScans;
    
    final weightData = trendScans.map((s) => double.tryParse(s.weight) ?? 0.0).toList();
    final bodyFatData = trendScans.map((s) => double.tryParse(s.bodyFat) ?? 0.0).toList();
    final muscleData = trendScans.map((s) => double.tryParse(s.muscleMass) ?? 0.0).toList();
    final dateLabels = trendScans.map((s) {
      try {
        final date = DateTime.parse(s.date);
        return DateFormat('MMM').format(date);
      } catch (_) {
        return '';
      }
    }).toList();

    // Range for Y-axis (Weight)
    double weightMin = weightData.isNotEmpty ? weightData.reduce(math.min) - 5 : 0;
    double weightMax = weightData.isNotEmpty ? weightData.reduce(math.max) + 5 : 100;
    
    // Range for Y-axis (Body Fat)
    double bfMin = bodyFatData.isNotEmpty ? bodyFatData.reduce(math.min) - 2 : 0;
    double bfMax = bodyFatData.isNotEmpty ? bodyFatData.reduce(math.max) + 2 : 30;

    // Range for Y-axis (Muscle)
    double mMin = muscleData.isNotEmpty ? muscleData.reduce(math.min) - 2 : 0;
    double mMax = muscleData.isNotEmpty ? muscleData.reduce(math.max) + 2 : 50;

    String dateRange = trendScans.isNotEmpty 
        ? '${dateLabels.first} - ${dateLabels.last}'
        : '';

    return Column(
      children: [
        _buildChartCard(tr('weightTrend'), dateRange, _buildLinearChart(weightData, weightMin, weightMax, ' kg', dateLabels)),
        const SizedBox(height: 16),
        _buildChartCard(tr('bodyFatPct'), dateRange, _buildLinearChart(bodyFatData, bfMin, bfMax, '%', dateLabels)),
        const SizedBox(height: 16),
        _buildChartCard(tr('muscleMassGrowth'), dateRange, _buildBarChart(muscleData, mMin, mMax, dateLabels)),
        const SizedBox(height: 16),
        if (sortedScans.isNotEmpty) _buildRadarCard(tr('bodyCompAnalysisTitle'), sortedScans.last),
      ],
    );
  }

  Widget _buildChartCard(String title, String subtitle, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildRadarCard(String title, InBodyScanEntity latest) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 280,
            child: BodyCompositionRadar(latest: latest),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(AppTheme.primaryRed, 'Current'),
              const SizedBox(width: 24),
              _buildLegendItem(const Color(0xFF666666), 'Ideal'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
      ],
    );
  }

  Widget _buildLinearChart(List<double> data, double min, double max, String unit, List<String> labels) {
    if (data.isEmpty) return const Center(child: Text('No data', style: TextStyle(color: Colors.grey)));
    return CustomPaint(
      size: Size.infinite,
      painter: LineChartPainter(data, min, max, unit, labels),
    );
  }

  Widget _buildBarChart(List<double> data, double min, double max, List<String> labels) {
    if (data.isEmpty) return const Center(child: Text('No data', style: TextStyle(color: Colors.grey)));
    return Column(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((val) {
              final ratio = (val - min) / (max - min);
              return Container(
                width: 32,
                height: 200 * ratio,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels.map((m) => SizedBox(width: 32, child: Center(child: Text(m, style: const TextStyle(color: Color(0xFF666666), fontSize: 10))))).toList(),
        ),
      ],
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> data;
  final double min;
  final double max;
  final String unit;
  final List<String> labels;

  LineChartPainter(this.data, this.min, this.max, this.unit, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    const double marginL = 40.0;
    const double marginB = 25.0;
    const double marginT = 10.0;
    const double marginR = 10.0;

    final chartWidth = size.width - marginL - marginR;
    final chartHeight = size.height - marginB - marginT;

    final paint = Paint()
      ..color = AppTheme.primaryRed
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()..color = AppTheme.primaryRed;
    final gridPaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    final stepX = data.length > 1 ? chartWidth / (data.length - 1) : 0.0;
    final rangeY = max - min;

    // Draw Grid Lines (Horizontal) and Y Axis Labels
    for (int i = 0; i < 4; i++) {
      final y = marginT + chartHeight * (i / 3);
      canvas.drawLine(Offset(marginL, y), Offset(marginL + chartWidth, y), gridPaint);

      final val = max - (i / 3 * rangeY);
      textPainter.text = TextSpan(
          text: '${val.toStringAsFixed(1)}$unit',
          style: const TextStyle(color: Color(0xFF666666), fontSize: 10));
      textPainter.layout();
      textPainter.paint(canvas, Offset(marginL - textPainter.width - 8, y - 6));
    }

    if (data.isEmpty) return;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = marginL + i * stepX;
      final y = marginT + chartHeight - ((data[i] - min) / rangeY * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
    canvas.drawPath(path, paint);

    // X Axis Labels
    for (int i = 0; i < labels.length; i++) {
      textPainter.text = TextSpan(
          text: labels[i],
          style: const TextStyle(color: Color(0xFF666666), fontSize: 10));
      textPainter.layout();
      final x = marginL + i * stepX;
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), marginT + chartHeight + 8));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BodyCompositionRadar extends StatelessWidget {
  final InBodyScanEntity latest;
  const BodyCompositionRadar({super.key, required this.latest});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: RadarChartPainter(latest),
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final InBodyScanEntity latest;
  RadarChartPainter(this.latest);

  final List<String> subjects = ["Weight", "Muscle", "Body Fat", "BMI"];
  
  @override
  void paint(Canvas canvas, Size size) {
    final wVal = double.tryParse(latest.weight) ?? 0.0;
    final mVal = double.tryParse(latest.muscleMass) ?? 0.0;
    final bfVal = double.tryParse(latest.bodyFat) ?? 0.0;
    final bmiVal = double.tryParse(latest.bmi) ?? 0.0;

    // Normalizing values (rough approximation for visual representation)
    final List<double> current = [
      (wVal / 150 * 100).clamp(0, 100),   // Weight (assume 150kg is top)
      (mVal / 60 * 100).clamp(0, 100),    // Muscle (assume 60kg is top)
      (bfVal / 40 * 100).clamp(0, 100),   // Body Fat (assume 40% is top)
      (bmiVal / 40 * 100).clamp(0, 100),  // BMI (assume 40 is top)
    ];

    final List<double> ideal = [50, 80, 20, 50]; // Example "Ideal" points for shape comparison

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.7;

    final gridPaint = Paint()..color = const Color(0xFF2A2A2A)..style = PaintingStyle.stroke..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    // Draw circular grid
    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(center, radius * (i / 5), gridPaint);
    }

    // Draw axes and labels
    final angleStep = (2 * math.pi) / subjects.length;
    for (int i = 0; i < subjects.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      canvas.drawLine(center, Offset(x, y), gridPaint);

      textPainter.text = TextSpan(text: subjects[i], style: const TextStyle(color: Color(0xFF666666), fontSize: 10));
      textPainter.layout();
      final labelX = center.dx + math.cos(angle) * (radius + 20) - (textPainter.width / 2);
      final labelY = center.dy + math.sin(angle) * (radius + 20) - (textPainter.height / 2);
      textPainter.paint(canvas, Offset(labelX, labelY));
    }

    // Draw Ideal Radar
    _drawRadar(canvas, center, radius, ideal, const Color(0xFF666666).withValues(alpha: 0.1), const Color(0xFF666666), angleStep);

    // Draw Current Radar
    _drawRadar(canvas, center, radius, current, AppTheme.primaryRed.withValues(alpha: 0.3), AppTheme.primaryRed, angleStep);
  }

  void _drawRadar(Canvas canvas, Offset center, double maxRadius, List<double> data, Color fillColor, Color strokeColor, double angleStep) {
    final path = Path();
    final fillPaint = Paint()..color = fillColor..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = strokeColor..style = PaintingStyle.stroke..strokeWidth = 2;

    for (int i = 0; i < data.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final r = (data[i] / 100) * maxRadius;
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
