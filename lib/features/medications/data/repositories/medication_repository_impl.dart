import 'package:fpdart/fpdart.dart';

import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_remote_data_source.dart';
import '../../../../core/errors/failures.dart';
import '../models/medication_model.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDataSource remoteDataSource;

  MedicationRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<Medication>> get medicationsStream {
    return remoteDataSource.getMedicationsStream().map((models) {
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<Medication>>> getMedications() async {
    final result = await remoteDataSource.getMedications();

    return result.fold(
      (failure) => Left(failure),
      (models) => Right(models.map((model) => model.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, Medication>> getMedication(String id) async {
    final result = await remoteDataSource.getMedication(id);

    return result.fold(
      (failure) => Left(failure),
      (model) => Right(model.toEntity()),
    );
  }

  @override
  Future<Either<Failure, Medication>> addMedication(
      Medication medication) async {
    final model = MedicationModel(
      id: medication.id,
      userId: medication.userId,
      name: medication.name,
      dosageValue: medication.dosageValue,
      dosageUnit: medication.dosageUnit,
      form: medication.form,
      frequency: medication.frequency,
      timesOfDay: medication.timesOfDay,
      startDate: medication.startDate,
      endDate: medication.endDate,
      initialStock: medication.initialStock,
      currentStock: medication.currentStock,
      pillsPerPrescription: medication.pillsPerPrescription,
      refillThreshold: medication.refillThreshold,
      colorTag: medication.colorTag,
      notes: medication.notes,
      imageUrl: medication.imageUrl,
      isActive: medication.isActive,
      createdAt: medication.createdAt,
      updatedAt: medication.updatedAt,
    );

    final result = await remoteDataSource.addMedication(model);

    return result.fold(
      (failure) => Left(failure),
      (model) => Right(model.toEntity()),
    );
  }

  @override
  Future<Either<Failure, Medication>> updateMedication(
      Medication medication) async {
    final model = MedicationModel(
      id: medication.id,
      userId: medication.userId,
      name: medication.name,
      dosageValue: medication.dosageValue,
      dosageUnit: medication.dosageUnit,
      form: medication.form,
      frequency: medication.frequency,
      timesOfDay: medication.timesOfDay,
      startDate: medication.startDate,
      endDate: medication.endDate,
      initialStock: medication.initialStock,
      currentStock: medication.currentStock,
      pillsPerPrescription: medication.pillsPerPrescription,
      refillThreshold: medication.refillThreshold,
      colorTag: medication.colorTag,
      notes: medication.notes,
      imageUrl: medication.imageUrl,
      isActive: medication.isActive,
      createdAt: medication.createdAt,
      updatedAt: medication.updatedAt,
    );

    final result = await remoteDataSource.updateMedication(model);

    return result.fold(
      (failure) => Left(failure),
      (model) => Right(model.toEntity()),
    );
  }

  @override
  Future<Either<Failure, void>> deleteMedication(String id) async {
    return await remoteDataSource.deleteMedication(id);
  }

  @override
  Future<Either<Failure, String>> uploadMedicationImage(
      String imagePath) async {
    return await remoteDataSource.uploadMedicationImage(imagePath);
  }
}
