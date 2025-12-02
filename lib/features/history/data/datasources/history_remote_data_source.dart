import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medication_reminder/features/history/domain/entities/dose_log.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/firestore_datasource.dart';
import '../models/dose_log_model.dart';

abstract class HistoryRemoteDataSource {
  Stream<List<DoseLogModel>> getDoseLogsStream();
  Future<Either<Failure, List<DoseLogModel>>> getDoseLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? medicationId,
  });
  Future<Either<Failure, DoseLogModel>> addDoseLog(DoseLogModel doseLog);
  Future<Either<Failure, DoseLogModel>> updateDoseLog(DoseLogModel doseLog);
  Future<Either<Failure, void>> deleteDoseLog(String id);
  Future<Either<Failure, List<DoseLogModel>>> getTodayDoseLogs();
  Future<Either<Failure, List<DailySummary>>> getDailySummaries(
      DateTimeRange range);
}

class HistoryRemoteDataSourceImpl extends FirestoreDataSource
    implements HistoryRemoteDataSource {
  CollectionReference get _dosesCollection {
    return getUserCollection('doses');
  }

  @override
  Stream<List<DoseLogModel>> getDoseLogsStream() {
    return _dosesCollection
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DoseLogModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<DoseLogModel>>> getDoseLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? medicationId,
  }) async {
    try {
      Query query = _dosesCollection.orderBy('scheduledTime', descending: true);

      if (startDate != null) {
        query = query.where('scheduledTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('scheduledTime',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (medicationId != null) {
        query = query.where('medicationId', isEqualTo: medicationId);
      }

      final snapshot = await query.get();
      final doseLogs =
          snapshot.docs.map((doc) => DoseLogModel.fromFirestore(doc)).toList();

      return Right(doseLogs);
    } catch (e) {
      return Left(Failure('Failed to load dose logs: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DoseLogModel>> addDoseLog(DoseLogModel doseLog) async {
    try {
      final docRef = _dosesCollection.doc();
      final doseLogWithId = doseLog.copyWith(id: docRef.id);

      await docRef.set(doseLogWithId.toFirestore());

      return Right(doseLogWithId);
    } catch (e) {
      return Left(Failure('Failed to add dose log: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DoseLogModel>> updateDoseLog(
      DoseLogModel doseLog) async {
    try {
      await _dosesCollection.doc(doseLog.id).update(doseLog.toFirestore());

      return Right(doseLog);
    } catch (e) {
      return Left(Failure('Failed to update dose log: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDoseLog(String id) async {
    try {
      await _dosesCollection.doc(id).delete();
      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to delete dose log: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DoseLogModel>>> getTodayDoseLogs() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _dosesCollection
          .where('scheduledTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduledTime',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('scheduledTime')
          .get();

      final doseLogs =
          snapshot.docs.map((doc) => DoseLogModel.fromFirestore(doc)).toList();

      return Right(doseLogs);
    } catch (e) {
      return Left(
          Failure('Failed to load today\'s dose logs: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DailySummary>>> getDailySummaries(
      DateTimeRange range) async {
    try {
      final doseLogsResult = await getDoseLogs(
        startDate: range.start,
        endDate: range.end,
      );

      return doseLogsResult.fold(
        (failure) => Left(failure),
        (doseLogs) {
          // Group dose logs by date
          final grouped = <DateTime, List<DoseLogModel>>{};

          for (final doseLog in doseLogs) {
            final date = DateTime(
              doseLog.scheduledTime.year,
              doseLog.scheduledTime.month,
              doseLog.scheduledTime.day,
            );

            if (!grouped.containsKey(date)) {
              grouped[date] = [];
            }
            grouped[date]!.add(doseLog);
          }

          // Create daily summaries
          final summaries = grouped.entries.map((entry) {
            final doses = entry.value;
            final takenCount = doses.where((d) => d.isTaken).length;
            final missedCount = doses.where((d) => d.isMissed).length;
            final skippedCount = doses.where((d) => d.isSkipped).length;

            return DailySummary(
              date: entry.key,
              totalDoses: doses.length,
              takenCount: takenCount,
              missedCount: missedCount,
              skippedCount: skippedCount,
              doses: doses.map((d) => d.toEntity()).toList(),
            );
          }).toList();

          // Sort by date descending
          summaries.sort((a, b) => b.date.compareTo(a.date));

          return Right(summaries);
        },
      );
    } catch (e) {
      return Left(Failure('Failed to get daily summaries: ${e.toString()}'));
    }
  }
}
