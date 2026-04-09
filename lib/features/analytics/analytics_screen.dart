import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/services/analytics_service.dart';
import '../../theme/app_theme.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(analyticsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(analyticsDataProvider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats row
            Row(
              children: [
                _StatCard(
                  value: '${data.currentStreak}',
                  label: 'Série de jours',
                  icon: Icons.local_fire_department,
                  color: data.currentStreak > 0
                      ? AppTheme.success
                      : AppTheme.textSecondary,
                  flex: 1,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  value: '${data.biteFreeDays30}',
                  label: 'Sans morsure\n(30 jours)',
                  icon: Icons.star_outline,
                  color: AppTheme.accent,
                  flex: 1,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(
                  value: '${data.totalBites7Days}',
                  label: 'Morsures (7j)',
                  icon: Icons.trending_down,
                  color: AppTheme.warning,
                  flex: 1,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  value: '${data.totalBitesAllTime}',
                  label: 'Total enregistré',
                  icon: Icons.history,
                  color: AppTheme.textSecondary,
                  flex: 1,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Chart
            const Text(
              'Morsures par jour — 30 derniers jours',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Faites glisser pour explorer l\'historique',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            _BiteChart(data: data),
            const SizedBox(height: 24),

            // Insights
            Row(
              children: const [
                Icon(Icons.lightbulb_outline, color: AppTheme.accent, size: 20),
                SizedBox(width: 8),
                Text(
                  'Informations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...data.insights.map((insight) => _InsightCard(text: insight)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final int flex;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BiteChart extends StatelessWidget {
  final AnalyticsData data;

  const _BiteChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = data.bitesPerDayLast30.entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.toDouble());
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    final maxY =
        data.bitesPerDayLast30.values.isEmpty
            ? 5.0
            : (data.bitesPerDayLast30.values.reduce((a, b) => a > b ? a : b) +
                    2)
                .toDouble();

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 29,
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.shade100,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (val, meta) => Text(
                  '${val.toInt()}',
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textSecondary),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 7,
                getTitlesWidget: (val, meta) {
                  // x=0 = 29 days ago, x=29 = today
                  final date = DateTime.now()
                      .subtract(Duration(days: 29 - val.toInt()));
                  return Text(
                    DateFormat('MMM d').format(date),
                    style: const TextStyle(
                        fontSize: 9, color: AppTheme.textSecondary),
                  );
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
              isCurved: true,
              color: AppTheme.accent,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: spot.y > 0 ? 4 : 2,
                  color: AppTheme.accent,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.accent.withOpacity(0.2),
                    AppTheme.accent.withOpacity(0.0),
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

class _InsightCard extends StatelessWidget {
  final String text;
  const _InsightCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5, right: 12),
            decoration: const BoxDecoration(
              color: AppTheme.accent,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
