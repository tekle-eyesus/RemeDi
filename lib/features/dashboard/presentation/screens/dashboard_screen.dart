import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medication_reminder/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:medication_reminder/features/dashboard/presentation/widgets/dose_tile.dart';
import 'package:medication_reminder/features/history/data/datasources/history_remote_data_source.dart';
import 'package:medication_reminder/features/history/data/models/dose_log_model.dart';
import 'package:medication_reminder/features/history/domain/entities/dose_log.dart';
import 'package:medication_reminder/features/medications/data/medication_repository.dart';
import 'package:medication_reminder/features/medications/domain/entities/medication.dart';
import 'package:medication_reminder/shared/styles/theme.dart';
import 'package:uuid/uuid.dart';

DoseLogModel _toModel(DoseLog log) => DoseLogModel(
      id: log.id,
      medicationId: log.medicationId,
      medicationName: log.medicationName,
      dosage: log.dosage,
      unit: log.unit,
      form: log.form,
      scheduledTime: log.scheduledTime,
      takenTime: log.takenTime,
      status: log.status,
      notes: log.notes,
      colorTag: log.colorTag,
      createdAt: log.createdAt,
    );

// ── Screen ────────────────────────────────────────────────────────────────────

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadToday();
    });
  }

  // ── Overdose pre-check ────────────────────────────────────────────────────

  /// Returns a warning message if taking this dose would trigger an overdose
  /// alert, or null if safe to proceed.
  String? _overdoseWarning(ScheduledDose dose) {
    final med = dose.medication;
    final todayDoses = ref
        .read(dashboardProvider)
        .todayDoses
        .where((d) => d.medication.id == med.id);

    if (med.maxDailyDoses != null) {
      final alreadyTaken = todayDoses.where((d) => d.isTaken).length;
      if (alreadyTaken + 1 > med.maxDailyDoses!) {
        return 'Taking this dose would exceed the maximum daily dose of '
            '${med.maxDailyDoses} for ${med.name}.';
      }
    }

    if (med.minIntervalMinutes != null) {
      final recentTaken = todayDoses
          .where((d) => d.isTaken && d.takenTime != null)
          .toList()
        ..sort((a, b) => b.takenTime!.compareTo(a.takenTime!));
      if (recentTaken.isNotEmpty) {
        final mins =
            DateTime.now().difference(recentTaken.first.takenTime!).inMinutes;
        if (mins < med.minIntervalMinutes!) {
          final unit = mins == 1 ? 'minute' : 'minutes';
          return 'You took ${med.name} only $mins $unit ago. '
              'The minimum interval is ${med.minIntervalMinutes} minutes.';
        }
      }
    }
    return null;
  }

  // ── Log a dose ─────────────────────────────────────────────────────────────

  Future<void> _logDose(ScheduledDose dose, DoseStatus status,
      {String? notes}) async {
    try {
      final source = HistoryRemoteDataSourceImpl();
      final med = dose.medication;

      if (dose.doseLogId != null) {
        final updated = DoseLog(
          id: dose.doseLogId!,
          medicationId: med.id,
          medicationName: med.name,
          dosage: med.dosage,
          unit: med.unit,
          form: med.type,
          scheduledTime: dose.scheduledTime,
          takenTime: status == DoseStatus.taken ? DateTime.now() : null,
          status: status,
          notes: notes,
          colorTag: med.color,
          createdAt: DateTime.now(),
        );
        await source.updateDoseLog(_toModel(updated));
      } else {
        final newLog = DoseLog(
          id: const Uuid().v4(),
          medicationId: med.id,
          medicationName: med.name,
          dosage: med.dosage,
          unit: med.unit,
          form: med.type,
          scheduledTime: dose.scheduledTime,
          takenTime: status == DoseStatus.taken ? DateTime.now() : null,
          status: status,
          notes: notes,
          colorTag: med.color,
          createdAt: DateTime.now(),
        );
        await source.addDoseLog(_toModel(newLog));

        if (status == DoseStatus.taken) {
          await ref.read(medicationRepositoryProvider).decrementStock(med);
        }
      }

      if (mounted) {
        ref.read(dashboardProvider.notifier).loadToday();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // ── Dose action bottom sheet ───────────────────────────────────────────────

  void _showDoseActions(ScheduledDose dose) {
    final notesController = TextEditingController(text: dose.notes ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dose.medication.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${dose.medication.dosage}${dose.medication.unit} · ${dose.formattedTime}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Dose notes (optional)',
                  hintText: 'e.g. taken with food',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Take',
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                      onTap: () {
                        final warning = _overdoseWarning(dose);
                        final notes = notesController.text.trim().isEmpty
                            ? null
                            : notesController.text.trim();
                        if (warning != null) {
                          Navigator.pop(ctx);
                          _showOverdoseConfirmation(
                              warning, dose, DoseStatus.taken, notes);
                        } else {
                          Navigator.pop(ctx);
                          _logDose(dose, DoseStatus.taken, notes: notes);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'Skip',
                      icon: Icons.do_not_disturb_on_outlined,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(ctx);
                        _logDose(dose, DoseStatus.skipped,
                            notes: notesController.text.trim().isEmpty
                                ? null
                                : notesController.text.trim());
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'Undo',
                      icon: Icons.undo,
                      color: Colors.grey,
                      onTap: () {
                        Navigator.pop(ctx);
                        _logDose(dose, DoseStatus.upcoming);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOverdoseConfirmation(
      String warning, ScheduledDose dose, DoseStatus status, String? notes) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('⚠️ Overdose Warning'),
        content: Text(warning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            onPressed: () {
              Navigator.pop(context);
              _logDose(dose, status, notes: notes);
            },
            child: const Text('Log Anyway'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final today = DateTime.now();
    final greeting = _greeting(today.hour);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(greeting,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Text(
              DateFormat('EEEE, MMM d').format(today),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(dashboardProvider.notifier).loadToday(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _ErrorView(
                  message: state.error!,
                  onRetry: () =>
                      ref.read(dashboardProvider.notifier).loadToday(),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(dashboardProvider.notifier).loadToday(),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _AdherenceCard(state: state),
                        ),
                      ),
                      if (_lowStockMeds(state).isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _LowStockBanner(meds: _lowStockMeds(state)),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text(
                            "Today's Schedule",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      state.todayDoses.isEmpty
                          ? SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FaIcon(FontAwesomeIcons.calendarCheck,
                                        size: 48, color: Colors.grey.shade300),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No doses scheduled for today',
                                      style: TextStyle(
                                          color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) {
                                  final dose = state.todayDoses[i];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    child: DoseTile(
                                      dose: dose,
                                      onTap: () => _showDoseActions(dose),
                                    ),
                                  );
                                },
                                childCount: state.todayDoses.length,
                              ),
                            ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
                ),
    );
  }

  List<Medication> _lowStockMeds(DashboardState state) {
    final seen = <String>{};
    return state.todayDoses
        .map((d) => d.medication)
        .where((m) =>
            m.refillThreshold > 0 &&
            m.currentStock <= m.refillThreshold &&
            seen.add(m.id))
        .toList();
  }

  String _greeting(int hour) {
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _AdherenceCard extends StatelessWidget {
  final DashboardState state;
  const _AdherenceCard({required this.state});

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
                _StatChip(
                    label: 'Taken',
                    count: state.takenCount,
                    color: Colors.green.shade300),
                const SizedBox(width: 6),
                _StatChip(
                    label: 'Missed',
                    count: state.missedCount,
                    color: Colors.red.shade300),
                const SizedBox(width: 6),
                _StatChip(
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

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count',
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }
}

class _LowStockBanner extends StatelessWidget {
  final List<Medication> meds;
  const _LowStockBanner({required this.meds});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Low stock: ${meds.map((m) => m.name).join(', ')}',
              style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
