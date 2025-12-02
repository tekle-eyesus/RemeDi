import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication_reminder/features/history/presentation/providers/history_provider.dart';
import 'package:medication_reminder/features/history/presentation/widgets/daily_summary_card.dart';
import 'package:medication_reminder/features/history/presentation/widgets/statistics_card.dart';
import 'package:medication_reminder/shared/styles/theme.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../shared/widgets/empty_state.dart';

class HistoryCalendarScreen extends ConsumerStatefulWidget {
  const HistoryCalendarScreen({super.key});

  @override
  ConsumerState<HistoryCalendarScreen> createState() =>
      _HistoryCalendarScreenState();
}

class _HistoryCalendarScreenState extends ConsumerState<HistoryCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTimeRange _selectedRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).loadHistory(_selectedRange);
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    if (start != null && end != null) {
      final range = DateTimeRange(start: start, end: end);
      setState(() {
        _selectedRange = range;
        _focusedDay = focusedDay;
        _selectedDay = null;
      });
      ref.read(historyProvider.notifier).loadHistory(range);
    } else {
      setState(() {
        _selectedDay = focusedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Medication History'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Show statistics modal
            },
            icon: const Icon(Icons.insights_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(historyProvider.notifier).loadHistory(_selectedRange);
        },
        child: CustomScrollView(
          slivers: [
            // Calendar
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
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
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onDaySelected: _onDaySelected,
                  onRangeSelected: _onRangeSelected,
                  rangeSelectionMode: RangeSelectionMode.toggledOn,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(color: Colors.white),
                    todayTextStyle: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    weekendTextStyle: const TextStyle(color: AppTheme.error),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonDecoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    formatButtonTextStyle: const TextStyle(color: Colors.white),
                    titleTextStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Statistics Card
            if (historyState.hasData && historyState.dailySummaries.isNotEmpty)
              SliverToBoxAdapter(
                child: StatisticsCard(
                  dailySummaries: historyState.dailySummaries,
                ),
              ),

            // Daily Summaries Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Text(
                  'Daily History',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                ),
              ),
            ),

            // Loading State
            if (historyState.isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )

            // Empty State
            else if (historyState.dailySummaries.isEmpty &&
                !historyState.isLoading)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.history_outlined,
                  title: 'No History Yet',
                  message: 'Your medication history will appear here',
                ),
              )

            // Daily Summaries List
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final summary = historyState.dailySummaries[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        index == 0 ? 0 : 8,
                        16,
                        index == historyState.dailySummaries.length - 1
                            ? 24
                            : 8,
                      ),
                      child: DailySummaryCard(
                        summary: summary,
                        onTap: () {
                          // TODO: Show day details
                        },
                      ),
                    );
                  },
                  childCount: historyState.dailySummaries.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
