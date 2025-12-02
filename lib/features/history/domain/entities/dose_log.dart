import 'package:flutter/material.dart';
import 'package:medication_reminder/shared/styles/theme.dart';

class DoseLog {
  final String id;
  final String medicationId;
  final String medicationName;
  final double dosage;
  final String unit;
  final String form;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final DoseStatus status;
  final String? notes;
  final String colorTag;
  final DateTime createdAt;

  const DoseLog({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.unit,
    required this.form,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
    this.notes,
    required this.colorTag,
    required this.createdAt,
  });

  DoseLog copyWith({
    String? id,
    String? medicationId,
    String? medicationName,
    double? dosage,
    String? unit,
    String? form,
    DateTime? scheduledTime,
    DateTime? takenTime,
    DoseStatus? status,
    String? notes,
    String? colorTag,
    DateTime? createdAt,
  }) {
    return DoseLog(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      unit: unit ?? this.unit,
      form: form ?? this.form,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      colorTag: colorTag ?? this.colorTag,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedScheduledTime {
    final date = scheduledTime;
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    final date = scheduledTime;
    return '${date.day}/${date.month}/${date.year}';
  }

  String get formattedTakenTime {
    if (takenTime == null) return 'Not taken';
    final date = takenTime!;
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color get statusColor {
    switch (status) {
      case DoseStatus.taken:
        return AppTheme.secondary;
      case DoseStatus.missed:
        return AppTheme.error;
      case DoseStatus.skipped:
        return AppTheme.accent;
      case DoseStatus.upcoming:
        return AppTheme.primary;
    }
  }

  String get statusText {
    switch (status) {
      case DoseStatus.taken:
        return 'Taken';
      case DoseStatus.missed:
        return 'Missed';
      case DoseStatus.skipped:
        return 'Skipped';
      case DoseStatus.upcoming:
        return 'Upcoming';
    }
  }

  IconData get statusIcon {
    switch (status) {
      case DoseStatus.taken:
        return Icons.check_circle;
      case DoseStatus.missed:
        return Icons.warning;
      case DoseStatus.skipped:
        return Icons.do_not_disturb;
      case DoseStatus.upcoming:
        return Icons.schedule;
    }
  }

  bool get isTaken => status == DoseStatus.taken;
  bool get isMissed => status == DoseStatus.missed;
  bool get isSkipped => status == DoseStatus.skipped;
  bool get isUpcoming => status == DoseStatus.upcoming;
}

enum DoseStatus {
  taken,
  missed,
  skipped,
  upcoming,
}

class DailySummary {
  final DateTime date;
  final int totalDoses;
  final int takenCount;
  final int missedCount;
  final int skippedCount;
  final List<DoseLog> doses;

  const DailySummary({
    required this.date,
    required this.totalDoses,
    required this.takenCount,
    required this.missedCount,
    required this.skippedCount,
    required this.doses,
  });

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get dayName {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  double get adherenceRate {
    if (totalDoses == 0) return 0.0;
    return (takenCount / totalDoses) * 100;
  }
}

class MedicationHistory {
  final String medicationId;
  final String medicationName;
  final List<DoseLog> doseLogs;
  final int totalDoses;
  final int takenCount;
  final int missedCount;
  final int skippedCount;
  final double adherenceRate;

  const MedicationHistory({
    required this.medicationId,
    required this.medicationName,
    required this.doseLogs,
    required this.totalDoses,
    required this.takenCount,
    required this.missedCount,
    required this.skippedCount,
    required this.adherenceRate,
  });
}
