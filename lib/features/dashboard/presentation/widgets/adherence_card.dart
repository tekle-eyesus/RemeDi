import 'package:flutter/material.dart';
import 'package:medication_reminder/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:medication_reminder/features/dashboard/presentation/widgets/stat_chip.dart';
import 'package:medication_reminder/shared/styles/theme.dart';

class AdherenceCard extends StatelessWidget {
  final DashboardState state;
  const AdherenceCard({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final pct = state.adherenceRate;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppTheme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Today's Adherence",
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${pct.toStringAsFixed(0)}%',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                StatChip(
                    label: 'Taken',
                    count: state.takenCount,
                    color: Colors.green.shade300),
                const SizedBox(width: 6),
                StatChip(
                    label: 'Missed',
                    count: state.missedCount,
                    color: Colors.red.shade300),
                const SizedBox(width: 6),
                StatChip(
                    label: 'Due',
                    count: state.upcomingCount,
                    color: Colors.blue.shade200),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct / 100,
                minHeight: 8,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
