import 'package:fpdart/fpdart.dart';

import '../entities/medication.dart';
import '../repositories/medication_repository.dart';
import '../../../../core/errors/failures.dart';

class GetMedications {
  final MedicationRepository repository;

  GetMedications(this.repository);

  Future<Either<Failure, List<Medication>>> call() async {
    return await repository.getMedications();
  }
}
