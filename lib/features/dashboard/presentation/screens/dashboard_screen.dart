import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:medication_reminder/features/dashboard/presentation/widgets/low_stock_warning.dart';
import 'package:medication_reminder/shared/styles/theme.dart';

import '../widgets/dashboard_header.dart';
import '../widgets/medication_schedule_card.dart';
import '../widgets/quick_stats_grid.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDashboardData();
    });
  }

  Future<void> _refreshData() async {
    await ref.read(dashboardProvider.notifier).loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LiquidPullToRefresh(
          onRefresh: _refreshData,
          color: AppTheme.primary,
          backgroundColor: AppTheme.primaryLight,
          height: 150,
          springAnimationDurationInMilliseconds: 600,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: DashboardHeader(
                  onProfileTap: () {
                    // TODO: Navigate to profile
                  },
                  onNotificationTap: () {
                    // TODO: Navigate to notifications
                  },
                ),
              ),

              // Quick Stats
              if (dashboardState.isLoading)
                const SliverToBoxAdapter(
                  child: DashboardLoadingShimmer(),
                )
              else if (dashboardState.hasData) ...[
                SliverToBoxAdapter(
                  child: QuickStatsGrid(
                    upcomingCount: dashboardState.data!.upcomingCount,
                    takenCount: dashboardState.data!.takenCount,
                    missedCount: dashboardState.data!.missedCount,
                  ),
                ),

                // Low Stock Warning
                if (dashboardState.data!.lowStockMedications.isNotEmpty)
                  SliverToBoxAdapter(
                    child: LowStockWarning(
                      medications: dashboardState.data!.lowStockMedications,
                    ),
                  ),

                // Today's Schedule Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Row(
                      children: [
                        Text(
                          "Today's Schedule",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          _getFormattedDate(),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Schedule List
                if (dashboardState.data!.todaySchedules.isEmpty)
                  const SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.medication_outlined,
                      title: 'No medications scheduled',
                      message: 'Add your first medication to get started',
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final schedule =
                            dashboardState.data!.todaySchedules[index];
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            index == 0 ? 0 : 8,
                            24,
                            index ==
                                    dashboardState.data!.todaySchedules.length -
                                        1
                                ? 24
                                : 0,
                          ),
                          child: MedicationScheduleCard(
                            schedule: schedule,
                            onMarkTaken: () {
                              ref
                                  .read(dashboardProvider.notifier)
                                  .markDoseAsTaken(schedule);
                            },
                            onMarkSkipped: () {
                              ref
                                  .read(dashboardProvider.notifier)
                                  .markDoseAsSkipped(schedule);
                            },
                          ),
                        );
                      },
                      childCount: dashboardState.data!.todaySchedules.length,
                    ),
                  ),
              ] else if (dashboardState.hasError)
                SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: 'Something went wrong',
                    message: dashboardState.error!,
                    actionText: 'Try Again',
                    onAction: _refreshData,
                  ),
                ),
            ],
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add medication
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: AppTheme.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${_getWeekday(now.weekday)}, ${now.day} ${_getMonth(now.month)}';
  }

  String _getWeekday(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
