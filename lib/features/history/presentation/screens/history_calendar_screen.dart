import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medication_reminder/features/history/domain/entities/dose_log.dart';
import 'package:medication_reminder/features/history/presentation/providers/history_provider.dart';
import 'package:medication_reminder/shared/styles/theme.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryCalendarScreen extends ConsumerStatefulWidget {
  const HistoryCalendarScreen({super.key});

  @override
  ConsumerState<HistoryCalendarScreen> createState() =>
      _HistoryCalendarScreenState();
}

class _HistoryCalendarScreenState
    extends ConsumerState<HistoryCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMonth());
  }

  void _loadMonth() {
    final start = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final end = DateTime(_focusedDay.year, _focusedDay.month + 1, 0, 23, 59);
    ref.read(historyProvider.notifier).loadDoseLogs(
          startDate: start,
          endDate: end,
        );
  }

  List<DoseLog> _logsForDay(DateTime day) {
    return ref
        .read(historyProvider)
        .doseLogs
        .where((log) =>
            log.scheduledTime.year == day.year &&
            log.scheduledTime.month == day.month &&
            log.scheduledTime.day == day.day)
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);
    final selectedLogs = _logsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          TableCalendar<DoseLog>(
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            onPageChanged: (focused) {
              _focusedDay = focused;
              _loadMonth();
            },
            eventLoader: _logsForDay,
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (ctx, day, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                final taken = events.where((e) => e.isTaken).length;
                final total = events.length;
                final color = taken == total
                    ? Colors.green
                    : taken == 0
                        ? Colors.red
                        : Colors.orange;
                return Positioned(
                  bottom: 2,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : selectedLogs.isEmpty
                    ? Center(
                        child: Text(
                          'No doses recorded for\n${DateFormat('MMM d, y').format(_selectedDay)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : Column(
                        children: [
                          _DaySummaryBar(logs: selectedLogs),
                          Expanded(
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: selectedLogs.length,
                              itemBuilder: (ctx, i) =>
                                  _DoseLogTile(log: selectedLogs[i]),
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

// ── Summary bar ───────────────────────────────────────────────────────────────

class _DaySummaryBar extends StatelessWidget {
  final List<DoseLog> logs;
  const _DaySummaryBar({required this.logs});

  @override
  Widget build(BuildContext context) {
    final taken = logs.where((l) => l.isTaken).length;
    final missed = logs.where((l) => l.isMissed).length;
    final skipped = logs.where((l) => l.isSkipped).length;
    final adherence =
        logs.isEmpty ? 0.0 : (taken / logs.length) * 100;

    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _SummaryChip(label: 'Taken', count: taken, color: Colors.green),
          const SizedBox(width: 12),
          _SummaryChip(label: 'Missed', count: missed, color: Colors.red),
          const SizedBox(width: 12),
          _SummaryChip(label: 'Skipped', count: skipped, color: Colors.orange),
          const Spacer(),
          Text(
            '${adherence.toStringAsFixed(0)}%',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(backgroundColor: color, radius: 5),
        const SizedBox(width: 4),
        Text('$count $label',
            style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}

// ── Dose log tile ─────────────────────────────────────────────────────────────

class _DoseLogTile extends StatelessWidget {
  final DoseLog log;
  const _DoseLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final color =
        Color(int.parse(log.colorTag.replaceAll('#', '0xff')));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(log.statusIcon, color: log.statusColor, size: 20),
        ),
        title: Text(log.medicationName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${log.dosage}${log.unit} · ${log.formattedScheduledTime}'),
            if (log.notes != null && log.notes!.isNotEmpty)
              Text(log.notes!,
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 12)),
            if (log.isTaken)
              Text('Taken at ${log.formattedTakenTime}',
                  style: TextStyle(
                      color: Colors.green.shade600, fontSize: 12)),
          ],
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: log.statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            log.statusText,
            style: TextStyle(
                color: log.statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ),
        isThreeLine: log.notes != null || log.isTaken,
      ),
    );
  }
}

