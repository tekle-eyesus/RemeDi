import 'package:fpdart/fpdart.dart';

import '../entities/medication.dart';
import '../../../../core/errors/failures.dart';

abstract class MedicationRepository {
  Stream<List<Medication>> get medicationsStream;
  Future<Either<Failure, List<Medication>>> getMedications();
  Future<Either<Failure, Medication>> getMedication(String id);
  Future<Either<Failure, Medication>> addMedication(Medication medication);
  Future<Either<Failure, Medication>> updateMedication(Medication medication);
  Future<Either<Failure, void>> deleteMedication(String id);
  Future<Either<Failure, String>> uploadMedicationImage(String imagePath);
}
