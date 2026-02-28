import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication_reminder/features/history/data/datasources/history_remote_data_source.dart';
import 'package:medication_reminder/features/history/domain/entities/dose_log.dart';
import 'package:medication_reminder/features/medications/data/medication_repository.dart';
import 'package:medication_reminder/features/medications/domain/entities/medication.dart';

// ── Scheduled dose item ─────────────────────────────────────────────────────

class ScheduledDose {
  final Medication medication;
  final DateTime scheduledTime;
  final DoseStatus status;
  final String? doseLogId;
  final String? notes;
  final DateTime? takenTime;

  const ScheduledDose({
    required this.medication,
    required this.scheduledTime,
    required this.status,
    this.doseLogId,
    this.notes,
    this.takenTime,
  });

  bool get isUpcoming => status == DoseStatus.upcoming;
  bool get isTaken => status == DoseStatus.taken;
  bool get isSkipped => status == DoseStatus.skipped;
  bool get isMissed => status == DoseStatus.missed;

  String get formattedTime {
    final h = scheduledTime.hour.toString().padLeft(2, '0');
    final m = scheduledTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── Dashboard state ──────────────────────────────────────────────────────────

class DashboardState {
  final bool isLoading;
  final List<ScheduledDose> todayDoses;
  final String? error;

  const DashboardState({
    this.isLoading = false,
    this.todayDoses = const [],
    this.error,
  });

  int get takenCount => todayDoses.where((d) => d.isTaken).length;
  int get missedCount => todayDoses.where((d) => d.isMissed).length;
  int get skippedCount => todayDoses.where((d) => d.isSkipped).length;
  int get upcomingCount => todayDoses.where((d) => d.isUpcoming).length;
  int get totalDoses => todayDoses.length;

  double get adherenceRate =>
      totalDoses == 0 ? 0.0 : (takenCount / totalDoses) * 100;

  DashboardState copyWith({
    bool? isLoading,
    List<ScheduledDose>? todayDoses,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      todayDoses: todayDoses ?? this.todayDoses,
      error: error ?? this.error,
    );
  }
}

// ── Dashboard notifier ───────────────────────────────────────────────────────

class DashboardNotifier extends StateNotifier<DashboardState> {
  final MedicationRepository _medRepo;
  final HistoryRemoteDataSource _historySource;

  DashboardNotifier(this._medRepo, this._historySource)
      : super(const DashboardState());

  Future<void> loadToday() async {
    state = const DashboardState(isLoading: true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final medications = await _medRepo.getMedications(uid).first;
      final todayLogsResult = await _historySource.getTodayDoseLogs();
      final todayLogs = todayLogsResult.fold(
        (_) => <DoseLog>[],
        (models) => List<DoseLog>.from(models),
      );

      final doses = _computeTodaySchedule(medications, todayLogs);
      state = DashboardState(todayDoses: doses);
    } catch (e) {
      state = DashboardState(error: e.toString());
    }
  }

  List<ScheduledDose> _computeTodaySchedule(
      List<Medication> medications, List<DoseLog> todayLogs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // ISO weekday: Mon=1 … Sun=7 → abbreviated name
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayName = dayNames[now.weekday - 1];

    final List<ScheduledDose> doses = [];

    for (final med in medications) {
      final startDay =
          DateTime(med.startDate.year, med.startDate.month, med.startDate.day);
      if (startDay.isAfter(today)) continue;
      if (med.endDate != null) {
        final endDay = DateTime(
            med.endDate!.year, med.endDate!.month, med.endDate!.day);
        if (endDay.isBefore(today)) continue;
      }
      if (med.frequencyType == FrequencyType.asNeeded) continue;

      bool takeToday = false;
      switch (med.frequencyType) {
        case FrequencyType.daily:
          takeToday = true;
          break;
        case FrequencyType.specificDays:
          takeToday = med.frequencyDays.contains(todayName);
          break;
        case FrequencyType.interval:
          final daysSinceStart = today.difference(startDay).inDays;
          takeToday = med.interval > 0 && daysSinceStart % med.interval == 0;
          break;
        case FrequencyType.asNeeded:
          break;
      }
      if (!takeToday) continue;

      for (final timeStr in med.reminderTimes) {
        final parts = timeStr.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final scheduledTime =
            DateTime(today.year, today.month, today.day, hour, minute);

        final DoseLog? matchingLog = todayLogs.cast<DoseLog?>().firstWhere(
              (log) =>
                  log != null &&
                  log.medicationId == med.id &&
                  log.scheduledTime.hour == hour &&
                  log.scheduledTime.minute == minute,
              orElse: () => null,
            );

        DoseStatus status;
        if (matchingLog != null) {
          status = matchingLog.status;
        } else if (scheduledTime.isBefore(now)) {
          status = DoseStatus.missed;
        } else {
          status = DoseStatus.upcoming;
        }

        doses.add(ScheduledDose(
          medication: med,
          scheduledTime: scheduledTime,
          status: status,
          doseLogId: matchingLog?.id,
          notes: matchingLog?.notes,
          takenTime: matchingLog?.takenTime,
        ));
      }
    }

    doses.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return doses;
  }
}

// ── Providers ────────────────────────────────────────────────────────────────

final _historySourceProvider = Provider<HistoryRemoteDataSource>(
    (_) => HistoryRemoteDataSourceImpl());

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(
    ref.read(medicationRepositoryProvider),
    ref.read(_historySourceProvider),
  );
});
