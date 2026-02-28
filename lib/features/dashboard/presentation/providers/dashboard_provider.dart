// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fpdart/fpdart.dart';

// import '../../domain/entities/dashboard_entity.dart';
// import '../../domain/repositories/dashboard_repository.dart';

// class DashboardRepositoryImpl implements DashboardRepository {
//   @override
//   Future<Either<String, DashboardData>> getDashboardData() async {
//     // Mock data for now
//     await Future.delayed(const Duration(seconds: 1));

//     final mockSchedules = [
//       MedicationSchedule(
//         medicationId: '1',
//         medicationName: 'Vitamin D',
//         dosage: 1000,
//         unit: 'IU',
//         form: 'Tablet',
//         time: const TimeOfDay(hour: 8, minute: 0),
//         status: ScheduleStatus.upcoming,
//         colorTag: '#2196F3',
//         stockRemaining: 10,
//       ),
//       MedicationSchedule(
//         medicationId: '2',
//         medicationName: 'Blood Pressure',
//         dosage: 5,
//         unit: 'mg',
//         form: 'Tablet',
//         time: const TimeOfDay(hour: 12, minute: 0),
//         status: ScheduleStatus.taken,
//         colorTag: '#4CAF50',
//         stockRemaining: 3,
//       ),
//       MedicationSchedule(
//         medicationId: '3',
//         medicationName: 'Pain Relief',
//         dosage: 500,
//         unit: 'mg',
//         form: 'Tablet',
//         time: const TimeOfDay(hour: 18, minute: 0),
//         status: ScheduleStatus.upcoming,
//         colorTag: '#FF9800',
//         stockRemaining: 15,
//       ),
//     ];

//     final mockLowStock = [
//       LowStockMedication(
//         id: '2',
//         name: 'Blood Pressure',
//         currentStock: 3,
//         refillThreshold: 5,
//         colorTag: '#4CAF50',
//       ),
//     ];

//     return Right(DashboardData(
//       todaySchedules: mockSchedules,
//       upcomingCount: mockSchedules
//           .where((s) => s.status == ScheduleStatus.upcoming)
//           .length,
//       takenCount:
//           mockSchedules.where((s) => s.status == ScheduleStatus.taken).length,
//       missedCount:
//           mockSchedules.where((s) => s.status == ScheduleStatus.missed).length,
//       lowStockMedications: mockLowStock,
//     ));
//   }

//   @override
//   Future<Either<String, void>> markDoseAsTaken(
//       MedicationSchedule schedule) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     // In a real app, update the database here
//     print('Marked dose as taken: ${schedule.medicationName}');
//     return const Right(null);
//   }

//   @override
//   Future<Either<String, void>> markDoseAsSkipped(
//       MedicationSchedule schedule) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     // In a real app, update the database here
//     print('Marked dose as skipped: ${schedule.medicationName}');
//     return const Right(null);
//   }
// }

// // Dashboard Repository Provider
// final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
//   return DashboardRepositoryImpl();
// });

// // Dashboard State
// class DashboardState {
//   final bool isLoading;
//   final DashboardData? data;
//   final String? error;

//   const DashboardState({
//     this.isLoading = false,
//     this.data,
//     this.error,
//   });

//   bool get hasData => data != null;
//   bool get hasError => error != null;

//   DashboardState copyWith({
//     bool? isLoading,
//     DashboardData? data,
//     String? error,
//   }) {
//     return DashboardState(
//       isLoading: isLoading ?? this.isLoading,
//       data: data ?? this.data,
//       error: error ?? this.error,
//     );
//   }
// }

// // Dashboard Notifier
// class DashboardNotifier extends StateNotifier<DashboardState> {
//   final DashboardRepository _repository;

//   DashboardNotifier(this._repository) : super(const DashboardState());

//   Future<void> loadDashboardData() async {
//     state = state.copyWith(isLoading: true, error: null);

//     final result = await _repository.getDashboardData();

//     result.fold(
//       (error) => state = state.copyWith(
//         isLoading: false,
//         error: error,
//       ),
//       (data) => state = state.copyWith(
//         isLoading: false,
//         data: data,
//         error: null,
//       ),
//     );
//   }

//   Future<void> markDoseAsTaken(MedicationSchedule schedule) async {
//     final result = await _repository.markDoseAsTaken(schedule);

//     result.fold(
//       (error) => state = state.copyWith(error: error),
//       (_) => loadDashboardData(), // Reload data after marking
//     );
//   }

//   Future<void> markDoseAsSkipped(MedicationSchedule schedule) async {
//     final result = await _repository.markDoseAsSkipped(schedule);

//     result.fold(
//       (error) => state = state.copyWith(error: error),
//       (_) => loadDashboardData(), // Reload data after marking
//     );
//   }
// }

// // Dashboard Provider
// final dashboardProvider =
//     StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
//   final repository = ref.read(dashboardRepositoryProvider);
//   return DashboardNotifier(repository);
// });
