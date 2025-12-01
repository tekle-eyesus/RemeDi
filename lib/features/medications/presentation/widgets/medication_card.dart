import 'package:flutter/material.dart';
import 'package:medication_reminder/shared/styles/theme.dart';

import '../../domain/entities/medication.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onTap;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Stack(
          children: [
            // Color indicator on left
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: Color(
                      int.parse(medication.colorTag.replaceFirst('#', '0xff'))),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.borderRadius),
                    bottomLeft: Radius.circular(AppTheme.borderRadius),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medication Name
                  Text(
                    medication.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Dosage and Form
                  Row(
                    children: [
                      Icon(
                        _getFormIcon(medication.form),
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        medication.dosageString,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '• ${medication.form}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Schedule
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          medication.scheduleSummary,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stock Status
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 14,
                        color: medication.isLowStock
                            ? AppTheme.error
                            : AppTheme.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${medication.currentStock} left',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: medication.isLowStock
                                  ? AppTheme.error
                                  : AppTheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Spacer(),
                      if (medication.isLowStock)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Low',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppTheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFormIcon(String form) {
    switch (form.toLowerCase()) {
      case 'tablet':
        return Icons.medication_outlined;
      case 'capsule':
        return Icons.circle_outlined;
      case 'liquid':
        return Icons.water_drop_outlined;
      case 'injection':
        return Icons.medical_services_outlined;
      case 'cream':
        return Icons.cabin;
      default:
        return Icons.medication_outlined;
    }
  }
}
