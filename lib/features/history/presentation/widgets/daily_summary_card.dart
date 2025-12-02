import 'package:flutter/material.dart';
import 'package:medication_reminder/shared/styles/theme.dart';

import '../../domain/entities/dose_log.dart';

class DailySummaryCard extends StatelessWidget {
  final DailySummary summary;
  final VoidCallback onTap;

  const DailySummaryCard({
    super.key,
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Date Header
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: Text(
                    summary.dayName.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  summary.formattedDate,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats Row
            Row(
              children: [
                _StatItem(
                  count: summary.takenCount,
                  label: 'Taken',
                  color: AppTheme.secondary,
                  icon: Icons.check_circle,
                ),
                const SizedBox(width: 16),
                _StatItem(
                  count: summary.missedCount,
                  label: 'Missed',
                  color: AppTheme.error,
                  icon: Icons.warning,
                ),
                const SizedBox(width: 16),
                _StatItem(
                  count: summary.skippedCount,
                  label: 'Skipped',
                  color: AppTheme.accent,
                  icon: Icons.do_not_disturb,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Adherence Bar
            _AdherenceBar(adherenceRate: summary.adherenceRate),

            // Medication List
            if (summary.doses.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Medications:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              ...summary.doses.take(3).map((dose) {
                return _MedicationRow(dose: dose);
              }).toList(),
              if (summary.doses.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+ ${summary.doses.length - 3} more',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
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

class _AdherenceBar extends StatelessWidget {
  final double adherenceRate;

  const _AdherenceBar({required this.adherenceRate});

  @override
  Widget build(BuildContext context) {
    final rate = double.parse(adherenceRate.clamp(0, 100).toString());
    final color = _getColorForRate(rate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Adherence',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
            ),
            Text(
              '${rate.toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.divider,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Expanded(
                flex: rate.round(),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Expanded(
                flex: 100 - rate.round(),
                child: const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getColorForRate(double rate) {
    if (rate >= 90) return AppTheme.secondary;
    if (rate >= 70) return AppTheme.accent;
    return AppTheme.error;
  }
}

class _MedicationRow extends StatelessWidget {
  final DoseLog dose;

  const _MedicationRow({required this.dose});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Color(int.parse(dose.colorTag.replaceFirst('#', '0xff'))),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dose.medicationName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dose.dosage} ${dose.unit} • ${dose.formattedScheduledTime}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: dose.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(dose.statusIcon, size: 12, color: dose.statusColor),
                const SizedBox(width: 4),
                Text(
                  dose.statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: dose.statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
