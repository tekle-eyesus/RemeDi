import 'package:fpdart/fpdart.dart';

import '../entities/medication.dart';
import '../repositories/medication_repository.dart';
import '../../../../core/errors/failures.dart';

class UpdateMedication {
  final MedicationRepository repository;

  UpdateMedication(this.repository);

  Future<Either<Failure, Medication>> call(Medication medication) async {
    return await repository.updateMedication(medication);
  }
}
