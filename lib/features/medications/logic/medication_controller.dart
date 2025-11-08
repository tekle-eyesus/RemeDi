import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/medication_service.dart';

final medicationServiceProvider = Provider((ref) => MedicationService());

final addMedicationControllerProvider =
    StateNotifierProvider<AddMedicationController, AsyncValue<void>>((ref) {
  return AddMedicationController(ref);
});

class AddMedicationController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  AddMedicationController(this.ref) : super(const AsyncData(null));

  Future<void> addMedication({
    required String name,
    required double dosageValue,
    required String unit,
    required String form,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(medicationServiceProvider).addMedication(
          name: name, dosageValue: dosageValue, unit: unit, form: form);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
