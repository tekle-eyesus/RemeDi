import 'package:fpdart/fpdart.dart';
import 'package:medication_reminder/features/medications/domain/repositories/medication_repository.dart';
import '../../../../core/errors/failures.dart';

class DeleteMedication {
  final MedicationRepository repository;

  DeleteMedication(this.repository);

  Future<Either<Failure, void>> call(String medicationId) async {
    return await repository.deleteMedication(medicationId);
  }
}
