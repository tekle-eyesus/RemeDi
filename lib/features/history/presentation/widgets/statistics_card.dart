import 'package:flutter/material.dart';
import 'package:medication_reminder/shared/styles/theme.dart';
import '../../domain/entities/dose_log.dart';

class StatisticsCard extends StatelessWidget {
  final List<DailySummary> dailySummaries;

  const StatisticsCard({super.key, required this.dailySummaries});

  @override
  Widget build(BuildContext context) {
    final totalDoses =
        dailySummaries.fold(0, (sum, summary) => sum + summary.totalDoses);
    final totalTaken =
        dailySummaries.fold(0, (sum, summary) => sum + summary.takenCount);
    final totalMissed =
        dailySummaries.fold(0, (sum, summary) => sum + summary.missedCount);
    final totalSkipped =
        dailySummaries.fold(0, (sum, summary) => sum + summary.skippedCount);

    final overallAdherence =
        totalDoses > 0 ? (totalTaken / totalDoses) * 100 : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.insights_outlined,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Statistics Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${dailySummaries.length} days',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Overall Adherence
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Adherence',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${overallAdherence.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatCircle(
                value: totalTaken,
                total: totalDoses,
                label: 'Taken',
                color: AppTheme.secondary,
              ),
              const SizedBox(width: 12),
              _StatCircle(
                value: totalMissed,
                total: totalDoses,
                label: 'Missed',
                color: AppTheme.error,
              ),
              const SizedBox(width: 12),
              _StatCircle(
                value: totalSkipped,
                total: totalDoses,
                label: 'Skipped',
                color: AppTheme.accent,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Streak Information
          Row(
            children: [
              _StreakItem(
                icon: Icons.local_fire_department,
                value: _calculateCurrentStreak(dailySummaries).toString(),
                label: 'Current Streak',
                color: AppTheme.accent,
              ),
              const SizedBox(width: 20),
              _StreakItem(
                icon: Icons.emoji_events_outlined,
                value: _calculateBestStreak(dailySummaries).toString(),
                label: 'Best Streak',
                color: AppTheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _calculateCurrentStreak(List<DailySummary> summaries) {
    int streak = 0;
    final now = DateTime.now();

    for (int i = 0; i < summaries.length; i++) {
      final summary = summaries[i];
      if (summary.adherenceRate >= 100 &&
          _isConsecutiveDay(
              summary.date, i > 0 ? summaries[i - 1].date : null)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  int _calculateBestStreak(List<DailySummary> summaries) {
    int bestStreak = 0;
    int currentStreak = 0;

    for (int i = 0; i < summaries.length; i++) {
      final summary = summaries[i];
      if (summary.adherenceRate >= 100 &&
          _isConsecutiveDay(
              summary.date, i > 0 ? summaries[i - 1].date : null)) {
        currentStreak++;
        bestStreak = currentStreak > bestStreak ? currentStreak : bestStreak;
      } else {
        currentStreak = 0;
      }
    }

    return bestStreak;
  }

  bool _isConsecutiveDay(DateTime date1, DateTime? date2) {
    if (date2 == null) return true;
    final diff = date1.difference(date2).inDays;
    return diff == 1;
  }
}

class _StatCircle extends StatelessWidget {
  final int value;
  final int total;
  final String label;
  final Color color;

  const _StatCircle({
    required this.value,
    required this.total,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: total > 0 ? value / total : 0,
                strokeWidth: 8,
                backgroundColor: AppTheme.divider,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StreakItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StreakItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                '$value days',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
