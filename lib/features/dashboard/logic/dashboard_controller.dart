import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/medication_repository.dart';

final medicationRepositoryProvider = Provider((ref) => MedicationRepository());

final medicationsStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(medicationRepositoryProvider);
  return repo.getMedicationsStream();
});
