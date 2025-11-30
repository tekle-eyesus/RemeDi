import 'package:fpdart/fpdart.dart';

import '../entities/dashboard_entity.dart';

abstract class DashboardRepository {
  Future<Either<String, DashboardData>> getDashboardData();
  Future<Either<String, void>> markDoseAsTaken(MedicationSchedule schedule);
  Future<Either<String, void>> markDoseAsSkipped(MedicationSchedule schedule);
}
