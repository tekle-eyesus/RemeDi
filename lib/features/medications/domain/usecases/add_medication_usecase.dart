import 'package:fpdart/fpdart.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';
import '../../../../core/errors/failures.dart';

class AddMedication {
  final MedicationRepository repository;

  AddMedication(this.repository);

  Future<Either<Failure, Medication>> call(Medication medication) async {
    return await repository.addMedication(medication);
  }
}
