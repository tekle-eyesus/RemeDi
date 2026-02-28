import 'package:flutter/material.dart';
import 'package:medication_reminder/shared/styles/theme.dart';
import 'package:shimmer/shimmer.dart';

class DashboardLoadingShimmer extends StatelessWidget {
  const DashboardLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Stats Grid Shimmer
            Row(
              children: [
                Expanded(child: _StatShimmer()),
                const SizedBox(width: 12),
                Expanded(child: _StatShimmer()),
                const SizedBox(width: 12),
                Expanded(child: _StatShimmer()),
              ],
            ),
            const SizedBox(height: 32),
            // Schedule Cards Shimmer
            ...List.generate(
                3,
                (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ScheduleCardShimmer(),
                    )),
          ],
        ),
      ),
    );
  }
}

class _StatShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _ScheduleCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
