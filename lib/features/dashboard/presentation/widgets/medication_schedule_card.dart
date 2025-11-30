import 'package:flutter/material.dart';
import 'package:medication_reminder/shared/styles/theme.dart';

import '../../domain/entities/dashboard_entity.dart';

class MedicationScheduleCard extends StatelessWidget {
  final MedicationSchedule schedule;
  final VoidCallback onMarkTaken;
  final VoidCallback onMarkSkipped;

  const MedicationScheduleCard({
    super.key,
    required this.schedule,
    required this.onMarkTaken,
    required this.onMarkSkipped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Header Row
          Row(
            children: [
              // Color Indicator
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(
                      int.parse(schedule.colorTag.replaceFirst('#', '0xff'))),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),

              // Medication Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.medicationName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${schedule.dosage} ${schedule.unit} • ${schedule.form}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),

              // Time
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Text(
                  _formatTime(schedule.time),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Status and Actions
          Row(
            children: [
              // Status Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: schedule.status.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(schedule.status),
                      color: schedule.status.color,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      schedule.status.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: schedule.status.color,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              if (schedule.status == ScheduleStatus.upcoming) ...[
                _ActionButton(
                  icon: Icons.close,
                  label: 'Skip',
                  color: AppTheme.textSecondary,
                  onTap: onMarkSkipped,
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.check,
                  label: 'Taken',
                  color: AppTheme.secondary,
                  onTap: onMarkTaken,
                ),
              ] else
                Text(
                  _getStatusMessage(schedule.status),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                ),
            ],
          ),

          // Stock Warning
          if (schedule.stockRemaining != null && schedule.stockRemaining! <= 5)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                border: Border.all(
                  color: AppTheme.error.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: AppTheme.error,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Low stock: ${schedule.stockRemaining} remaining',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  IconData _getStatusIcon(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.upcoming:
        return Icons.schedule;
      case ScheduleStatus.taken:
        return Icons.check_circle;
      case ScheduleStatus.missed:
        return Icons.warning;
      case ScheduleStatus.skipped:
        return Icons.do_not_disturb;
    }
  }

  String _getStatusMessage(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.taken:
        return 'Marked as taken';
      case ScheduleStatus.missed:
        return 'Missed dose';
      case ScheduleStatus.skipped:
        return 'Skipped';
      case ScheduleStatus.upcoming:
        return '';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
