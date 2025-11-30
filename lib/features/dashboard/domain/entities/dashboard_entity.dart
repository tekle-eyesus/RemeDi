import 'package:flutter/material.dart';
import 'package:medication_reminder/shared/styles/theme.dart';

class DashboardData {
  final List<MedicationSchedule> todaySchedules;
  final int upcomingCount;
  final int takenCount;
  final int missedCount;
  final List<LowStockMedication> lowStockMedications;

  DashboardData({
    required this.todaySchedules,
    required this.upcomingCount,
    required this.takenCount,
    required this.missedCount,
    required this.lowStockMedications,
  });

  DashboardData.empty()
      : todaySchedules = [],
        upcomingCount = 0,
        takenCount = 0,
        missedCount = 0,
        lowStockMedications = [];
}

class LowStockMedication {
  final String id;
  final String name;
  final int currentStock;
  final int refillThreshold;
  final String colorTag;

  LowStockMedication({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.refillThreshold,
    required this.colorTag,
  });
}

class MedicationSchedule {
  final String medicationId;
  final String medicationName;
  final double dosage;
  final String unit;
  final String form;
  final TimeOfDay time;
  final ScheduleStatus status;
  final String colorTag;
  final int? stockRemaining;

  MedicationSchedule({
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.unit,
    required this.form,
    required this.time,
    required this.status,
    required this.colorTag,
    this.stockRemaining,
  });
}

enum ScheduleStatus {
  upcoming,
  taken,
  missed,
  skipped,
}

extension ScheduleStatusExtension on ScheduleStatus {
  String get displayName {
    switch (this) {
      case ScheduleStatus.upcoming:
        return 'Upcoming';
      case ScheduleStatus.taken:
        return 'Taken';
      case ScheduleStatus.missed:
        return 'Missed';
      case ScheduleStatus.skipped:
        return 'Skipped';
    }
  }

  Color get color {
    switch (this) {
      case ScheduleStatus.upcoming:
        return AppTheme.primary;
      case ScheduleStatus.taken:
        return AppTheme.secondary;
      case ScheduleStatus.missed:
        return AppTheme.error;
      case ScheduleStatus.skipped:
        return AppTheme.textSecondary;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ScheduleStatus.upcoming:
        return AppTheme.primaryLight;
      case ScheduleStatus.taken:
        return AppTheme.secondaryLight;
      case ScheduleStatus.missed:
        return AppTheme.error.withOpacity(0.1);
      case ScheduleStatus.skipped:
        return AppTheme.textDisabled.withOpacity(0.1);
    }
  }
}
