import 'package:fpdart/fpdart.dart';
import 'package:flutter/material.dart';

import '../entities/dose_log.dart';
import '../../../../core/errors/failures.dart';

abstract class HistoryRepository {
  Stream<List<DoseLog>> get doseLogsStream;
  Future<Either<Failure, List<DoseLog>>> getDoseLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? medicationId,
  });
  Future<Either<Failure, DoseLog>> addDoseLog(DoseLog doseLog);
  Future<Either<Failure, DoseLog>> updateDoseLog(DoseLog doseLog);
  Future<Either<Failure, void>> deleteDoseLog(String id);
  Future<Either<Failure, List<DailySummary>>> getDailySummaries(
      DateTimeRange range);
}
