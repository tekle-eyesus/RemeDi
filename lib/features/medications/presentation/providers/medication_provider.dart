import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:medication_reminder/features/medications/data/datasources/medication_remote_data_source.dart';
import 'package:medication_reminder/features/medications/data/repositories/medication_repository_impl.dart';
import 'package:medication_reminder/features/medications/domain/entities/medication.dart';
import 'package:medication_reminder/features/medications/domain/usecases/add_medication_usecase.dart';
import 'package:medication_reminder/features/medications/domain/usecases/delete_medication_usecase.dart';
import 'package:medication_reminder/features/medications/domain/usecases/get_medications_usecase.dart';
import 'package:medication_reminder/features/medications/domain/usecases/update_medication_usecase.dart';
import '../../../../core/errors/failures.dart';

// Providers
final medicationRemoteDataSourceProvider =
    Provider<MedicationRemoteDataSource>((ref) {
  return MedicationRemoteDataSourceImpl();
});

final medicationRepositoryProvider = Provider<MedicationRepositoryImpl>((ref) {
  return MedicationRepositoryImpl(
    remoteDataSource: ref.read(medicationRemoteDataSourceProvider),
  );
});

final getMedicationsUseCaseProvider = Provider<GetMedications>((ref) {
  return GetMedications(ref.read(medicationRepositoryProvider));
});

final addMedicationUseCaseProvider = Provider<AddMedication>((ref) {
  return AddMedication(ref.read(medicationRepositoryProvider));
});

final updateMedicationUseCaseProvider = Provider<UpdateMedication>((ref) {
  return UpdateMedication(ref.read(medicationRepositoryProvider));
});

final deleteMedicationUseCaseProvider = Provider<DeleteMedication>((ref) {
  return DeleteMedication(ref.read(medicationRepositoryProvider));
});

// Medication List State
class MedicationListState {
  final bool isLoading;
  final List<Medication> medications;
  final Failure? error;
  final bool isSuccess;

  const MedicationListState({
    this.isLoading = false,
    this.medications = const [],
    this.error,
    this.isSuccess = false,
  });

  List<Medication> get activeMedications =>
      medications.where((m) => m.isActive).toList();
  List<Medication> get lowStockMedications =>
      medications.where((m) => m.isLowStock).toList();

  MedicationListState copyWith({
    bool? isLoading,
    List<Medication>? medications,
    Failure? error,
    bool? isSuccess,
  }) {
    return MedicationListState(
      isLoading: isLoading ?? this.isLoading,
      medications: medications ?? this.medications,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class MedicationListNotifier extends StateNotifier<MedicationListState> {
  final GetMedications _getMedicationsUseCase;
  final AddMedication _addMedicationUseCase;
  final UpdateMedication _updateMedicationUseCase;
  final DeleteMedication _deleteMedicationUseCase;
  final MedicationRepositoryImpl _medicationRepository;

  MedicationListNotifier({
    required GetMedications getMedicationsUseCase,
    required AddMedication addMedicationUseCase,
    required UpdateMedication updateMedicationUseCase,
    required DeleteMedication deleteMedicationUseCase,
    required MedicationRepositoryImpl medicationRepository,
  })  : _getMedicationsUseCase = getMedicationsUseCase,
        _addMedicationUseCase = addMedicationUseCase,
        _updateMedicationUseCase = updateMedicationUseCase,
        _deleteMedicationUseCase = deleteMedicationUseCase,
        _medicationRepository = medicationRepository,
        super(const MedicationListState());

  // Stream of medications from Firestore
  Stream<List<Medication>> get medicationsStream =>
      _medicationRepository.medicationsStream;

  Future<void> loadMedications() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getMedicationsUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure,
        isSuccess: false,
      ),
      (medications) => state = state.copyWith(
        isLoading: false,
        medications: medications,
        error: null,
        isSuccess: true,
      ),
    );
  }

  Future<Either<Failure, Medication>> addMedication(
      Medication medication) async {
    final result = await _addMedicationUseCase(medication);

    result.fold(
      (failure) => state = state.copyWith(error: failure),
      (newMedication) => state = state.copyWith(
        medications: [...state.medications, newMedication],
        isSuccess: true,
      ),
    );

    return result;
  }

  Future<Either<Failure, Medication>> updateMedication(
      Medication medication) async {
    final result = await _updateMedicationUseCase(medication);

    result.fold(
      (failure) => state = state.copyWith(error: failure),
      (updatedMedication) {
        final index =
            state.medications.indexWhere((m) => m.id == medication.id);
        if (index != -1) {
          final updatedList = List<Medication>.from(state.medications);
          updatedList[index] = updatedMedication;
          state = state.copyWith(medications: updatedList, isSuccess: true);
        }
      },
    );

    return result;
  }

  Future<Either<Failure, void>> deleteMedication(String medicationId) async {
    final result = await _deleteMedicationUseCase(medicationId);

    result.fold(
      (failure) => state = state.copyWith(error: failure),
      (_) {
        final updatedList =
            state.medications.where((m) => m.id != medicationId).toList();
        state = state.copyWith(medications: updatedList, isSuccess: true);
      },
    );

    return result;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final medicationListProvider =
    StateNotifierProvider<MedicationListNotifier, MedicationListState>((ref) {
  return MedicationListNotifier(
    getMedicationsUseCase: ref.read(getMedicationsUseCaseProvider),
    addMedicationUseCase: ref.read(addMedicationUseCaseProvider),
    updateMedicationUseCase: ref.read(updateMedicationUseCaseProvider),
    deleteMedicationUseCase: ref.read(deleteMedicationUseCaseProvider),
    medicationRepository: ref.read(medicationRepositoryProvider),
  );
});
