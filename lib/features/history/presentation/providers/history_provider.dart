import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/dose_log.dart';
import '../../data/datasources/history_remote_data_source.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../../../core/errors/failures.dart';

// Providers
final historyRemoteDataSourceProvider =
    Provider<HistoryRemoteDataSource>((ref) {
  return HistoryRemoteDataSourceImpl();
});

final historyRepositoryProvider = Provider<HistoryRepositoryImpl>((ref) {
  return HistoryRepositoryImpl(
    remoteDataSource: ref.read(historyRemoteDataSourceProvider),
  );
});

// History State
class HistoryState {
  final bool isLoading;
  final List<DailySummary> dailySummaries;
  final List<DoseLog> doseLogs;
  final Failure? error;
  final bool isSuccess;

  const HistoryState({
    this.isLoading = false,
    this.dailySummaries = const [],
    this.doseLogs = const [],
    this.error,
    this.isSuccess = false,
  });

  bool get hasData => dailySummaries.isNotEmpty;
  bool get hasError => error != null;

  HistoryState copyWith({
    bool? isLoading,
    List<DailySummary>? dailySummaries,
    List<DoseLog>? doseLogs,
    Failure? error,
    bool? isSuccess,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      dailySummaries: dailySummaries ?? this.dailySummaries,
      doseLogs: doseLogs ?? this.doseLogs,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// History Notifier
class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryRepositoryImpl _repository;

  HistoryNotifier(this._repository) : super(const HistoryState());

  Future<void> loadHistory(DateTimeRange range) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getDailySummaries(range);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure,
        isSuccess: false,
      ),
      (summaries) => state = state.copyWith(
        isLoading: false,
        dailySummaries: summaries,
        error: null,
        isSuccess: true,
      ),
    );
  }

  Future<void> loadDoseLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? medicationId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getDoseLogs(
      startDate: startDate,
      endDate: endDate,
      medicationId: medicationId,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure,
        isSuccess: false,
      ),
      (logs) => state = state.copyWith(
        isLoading: false,
        doseLogs: logs,
        error: null,
        isSuccess: true,
      ),
    );
  }

  Future<Either<Failure, DoseLog>> addDoseLog(DoseLog doseLog) async {
    final result = await _repository.addDoseLog(doseLog);

    result.fold(
      (failure) => state = state.copyWith(error: failure),
      (newLog) => state = state.copyWith(
        doseLogs: [...state.doseLogs, newLog],
        isSuccess: true,
      ),
    );

    return result;
  }

  Future<Either<Failure, DoseLog>> updateDoseLog(DoseLog doseLog) async {
    final result = await _repository.updateDoseLog(doseLog);

    result.fold(
      (failure) => state = state.copyWith(error: failure),
      (updatedLog) {
        final index = state.doseLogs.indexWhere((log) => log.id == doseLog.id);
        if (index != -1) {
          final updatedList = List<DoseLog>.from(state.doseLogs);
          updatedList[index] = updatedLog;
          state = state.copyWith(doseLogs: updatedList, isSuccess: true);
        }
      },
    );

    return result;
  }

  Future<Either<Failure, void>> deleteDoseLog(String id) async {
    final result = await _repository.deleteDoseLog(id);

    result.fold(
      (failure) => state = state.copyWith(error: failure),
      (_) {
        final updatedList =
            state.doseLogs.where((log) => log.id != id).toList();
        state = state.copyWith(doseLogs: updatedList, isSuccess: true);
      },
    );

    return result;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref.read(historyRepositoryProvider));
});
