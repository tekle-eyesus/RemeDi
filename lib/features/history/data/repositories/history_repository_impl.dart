import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/dose_log.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_data_source.dart';
import '../../../../core/errors/failures.dart';
import '../models/dose_log_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<DoseLog>> get doseLogsStream {
    return remoteDataSource.getDoseLogsStream().map((models) {
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<DoseLog>>> getDoseLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? medicationId,
  }) async {
    final result = await remoteDataSource.getDoseLogs(
      startDate: startDate,
      endDate: endDate,
      medicationId: medicationId,
    );

    return result.fold(
      (failure) => Left(failure),
      (models) => Right(models.map((model) => model.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, DoseLog>> addDoseLog(DoseLog doseLog) async {
    final model = DoseLogModel(
      id: doseLog.id,
      medicationId: doseLog.medicationId,
      medicationName: doseLog.medicationName,
      dosage: doseLog.dosage,
      unit: doseLog.unit,
      form: doseLog.form,
      scheduledTime: doseLog.scheduledTime,
      takenTime: doseLog.takenTime,
      status: doseLog.status,
      notes: doseLog.notes,
      colorTag: doseLog.colorTag,
      createdAt: doseLog.createdAt,
    );

    final result = await remoteDataSource.addDoseLog(model);

    return result.fold(
      (failure) => Left(failure),
      (model) => Right(model.toEntity()),
    );
  }

  @override
  Future<Either<Failure, DoseLog>> updateDoseLog(DoseLog doseLog) async {
    final model = DoseLogModel(
      id: doseLog.id,
      medicationId: doseLog.medicationId,
      medicationName: doseLog.medicationName,
      dosage: doseLog.dosage,
      unit: doseLog.unit,
      form: doseLog.form,
      scheduledTime: doseLog.scheduledTime,
      takenTime: doseLog.takenTime,
      status: doseLog.status,
      notes: doseLog.notes,
      colorTag: doseLog.colorTag,
      createdAt: doseLog.createdAt,
    );

    final result = await remoteDataSource.updateDoseLog(model);

    return result.fold(
      (failure) => Left(failure),
      (model) => Right(model.toEntity()),
    );
  }

  @override
  Future<Either<Failure, void>> deleteDoseLog(String id) async {
    return await remoteDataSource.deleteDoseLog(id);
  }

  @override
  Future<Either<Failure, List<DailySummary>>> getDailySummaries(
      DateTimeRange range) async {
    return await remoteDataSource.getDailySummaries(range);
  }
}
