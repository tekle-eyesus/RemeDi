import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:medication_reminder/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:medication_reminder/shared/styles/theme.dart';

class AdherenceCard extends StatelessWidget {
  final DashboardState state;
  const AdherenceCard({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final pct = state.adherenceRate;
    final hasDoses = state.totalDoses > 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppTheme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Adherence",
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Donut chart ──────────────────────────────────────────────
                SizedBox(
                  width: 110,
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          sectionsSpace: 2,
                          centerSpaceRadius: 36,
                          sections:
                              hasDoses ? _buildSections() : _emptySection(),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${pct.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'done',
                            style:
                                TextStyle(color: Colors.white60, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // ── Legend + counts ───────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendRow(
                        color: _takenColor,
                        label: 'Taken',
                        count: state.takenCount,
                        total: state.totalDoses,
                      ),
                      const SizedBox(height: 8),
                      _LegendRow(
                        color: _missedColor,
                        label: 'Missed',
                        count: state.missedCount,
                        total: state.totalDoses,
                      ),
                      const SizedBox(height: 8),
                      _LegendRow(
                        color: _skippedColor,
                        label: 'Skipped',
                        count: state.skippedCount,
                        total: state.totalDoses,
                      ),
                      const SizedBox(height: 8),
                      _LegendRow(
                        color: _upcomingColor,
                        label: 'Upcoming',
                        count: state.upcomingCount,
                        total: state.totalDoses,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasDoses) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static const Color _takenColor = Color(0xFF4CAF50);
  static const Color _missedColor = Color(0xFFEF5350);
  static const Color _skippedColor = Color(0xFFFF9800);
  static const Color _upcomingColor = Color(0xFF64B5F6);

  static List<PieChartSectionData> _emptySection() => [
        PieChartSectionData(
          value: 1,
          color: Colors.white24,
          radius: 18,
          showTitle: false,
        ),
      ];

  List<PieChartSectionData> _buildSections() {
    final sections = <PieChartSectionData>[];

    void addSection(int count, Color color) {
      if (count > 0) {
        sections.add(PieChartSectionData(
          value: count.toDouble(),
          color: color,
          radius: 18,
          showTitle: false,
        ));
      }
    }

    addSection(state.takenCount, _takenColor);
    addSection(state.missedCount, _missedColor);
    addSection(state.skippedCount, _skippedColor);
    addSection(state.upcomingCount, _upcomingColor);

    return sections.isEmpty ? _emptySection() : sections;
  }
}

// ── Legend row ────────────────────────────────────────────────────────────────

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final int total;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        if (total > 0)
          Text(
            ' / $total',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
      ],
    );
  }
}
