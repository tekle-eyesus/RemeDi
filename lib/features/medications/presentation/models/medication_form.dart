// import 'package:flutter/material.dart';
// import 'package:formz/formz.dart';

// import '../../domain/entities/medication.dart';

// // Form field models
// class MedicationName extends FormzInput<String, String> {
//   const MedicationName.pure() : super.pure('');
//   const MedicationName.dirty([String value = '']) : super.dirty(value);

//   @override
//   String? validator(String value) {
//     if (value.isEmpty) return 'Medication name is required';
//     if (value.length < 2) return 'Name must be at least 2 characters';
//     return null;
//   }
// }

// class DosageValue extends FormzInput<String, String> {
//   const DosageValue.pure() : super.pure('');
//   const DosageValue.dirty([String value = '']) : super.dirty(value);

//   @override
//   String? validator(String value) {
//     if (value.isEmpty) return 'Dosage value is required';
//     final numValue = double.tryParse(value);
//     if (numValue == null || numValue <= 0) return 'Enter a valid dosage';
//     return null;
//   }
// }

// class DosageUnit extends FormzInput<String, String> {
//   const DosageUnit.pure() : super.pure('mg');
//   const DosageUnit.dirty([String value = 'mg']) : super.dirty(value);

//   @override
//   String? validator(String value) {
//     if (value.isEmpty) return 'Unit is required';
//     return null;
//   }
// }

// class InitialStock extends FormzInput<String, String> {
//   const InitialStock.pure() : super.pure('');
//   const InitialStock.dirty([String value = '']) : super.dirty(value);

//   @override
//   String? validator(String value) {
//     if (value.isEmpty) return 'Initial stock is required';
//     final numValue = int.tryParse(value);
//     if (numValue == null || numValue <= 0) return 'Enter a valid number';
//     return null;
//   }
// }

// class RefillThreshold extends FormzInput<String, String> {
//   const RefillThreshold.pure() : super.pure('');
//   const RefillThreshold.dirty([String value = '']) : super.dirty(value);

//   @override
//   String? validator(String value) {
//     if (value.isEmpty) return 'Refill threshold is required';
//     final numValue = int.tryParse(value);
//     if (numValue == null || numValue < 0) return 'Enter a valid number';
//     return null;
//   }
// }

// // Form state
// class MedicationFormState {
//   final MedicationName name;
//   final DosageValue dosageValue;
//   final DosageUnit dosageUnit;
//   final FormzInput<String?, String?> form;
//   final FrequencyType frequencyType;
//   final dynamic frequencyValue;
//   final List<TimeOfDay> timesOfDay;
//   final DateTime startDate;
//   final DateTime? endDate;
//   final InitialStock initialStock;
//   final RefillThreshold refillThreshold;
//   final String colorTag;
//   final String? notes;
//   final String? imageUrl;
//   final bool isActive;
//   final FormzStatus status;

//   const MedicationFormState({
//     this.name = const MedicationName.pure(),
//     this.dosageValue = const DosageValue.pure(),
//     this.dosageUnit = const DosageUnit.pure(),
//     this.form = const FormzInput.dirty('Tablet'),
//     this.frequencyType = FrequencyType.daily,
//     this.frequencyValue,
//     this.timesOfDay = const [TimeOfDay(hour: 8, minute: 0)],
//     DateTime? startDate,
//     this.endDate,
//     this.initialStock = const InitialStock.pure(),
//     this.refillThreshold = const RefillThreshold.pure(),
//     this.colorTag = '#2196F3',
//     this.notes,
//     this.imageUrl,
//     this.isActive = true,
//     this.status = FormzStatus.pure,
//   }) : startDate = startDate ?? DateTime.now();

//   MedicationFormState copyWith({
//     MedicationName? name,
//     DosageValue? dosageValue,
//     DosageUnit? dosageUnit,
//     FormzInput<String?, String?>? form,
//     FrequencyType? frequencyType,
//     dynamic frequencyValue,
//     List<TimeOfDay>? timesOfDay,
//     DateTime? startDate,
//     DateTime? endDate,
//     InitialStock? initialStock,
//     RefillThreshold? refillThreshold,
//     String? colorTag,
//     String? notes,
//     String? imageUrl,
//     bool? isActive,
//     FormzStatus? status,
//   }) {
//     return MedicationFormState(
//       name: name ?? this.name,
//       dosageValue: dosageValue ?? this.dosageValue,
//       dosageUnit: dosageUnit ?? this.dosageUnit,
//       form: form ?? this.form,
//       frequencyType: frequencyType ?? this.frequencyType,
//       frequencyValue: frequencyValue ?? this.frequencyValue,
//       timesOfDay: timesOfDay ?? this.timesOfDay,
//       startDate: startDate ?? this.startDate,
//       endDate: endDate ?? this.endDate,
//       initialStock: initialStock ?? this.initialStock,
//       refillThreshold: refillThreshold ?? this.refillThreshold,
//       colorTag: colorTag ?? this.colorTag,
//       notes: notes ?? this.notes,
//       imageUrl: imageUrl ?? this.imageUrl,
//       isActive: isActive ?? this.isActive,
//       status: status ?? this.status,
//     );
//   }

//   Medication toMedication(String userId) {
//     return Medication(
//       id: '',
//       userId: userId,
//       name: name.value,
//       dosageValue: double.parse(dosageValue.value),
//       dosageUnit: dosageUnit.value,
//       form: form.value ?? 'Tablet',
//       frequency: Frequency(
//         type: frequencyType,
//         value: frequencyValue,
//       ),
//       timesOfDay: timesOfDay,
//       startDate: startDate,
//       endDate: endDate,
//       initialStock: int.parse(initialStock.value),
//       currentStock: int.parse(initialStock.value),
//       pillsPerPrescription: null,
//       refillThreshold: int.parse(refillThreshold.value),
//       colorTag: colorTag,
//       notes: notes,
//       imageUrl: imageUrl,
//       isActive: isActive,
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:formz/formz.dart'; // Import formz package

import '../../domain/entities/medication.dart';

// Form field models - Use simpler validation for now
class MedicationName {
  final String value;
  final String? error;

  const MedicationName({this.value = '', this.error});

  MedicationName copyWith({String? value, String? error}) {
    return MedicationName(
      value: value ?? this.value,
      error: error ?? this.error,
    );
  }

  String? validate() {
    if (value.isEmpty) return 'Medication name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    return null;
  }
}

class DosageValue {
  final String value;
  final String? error;

  const DosageValue({this.value = '', this.error});

  DosageValue copyWith({String? value, String? error}) {
    return DosageValue(
      value: value ?? this.value,
      error: error ?? this.error,
    );
  }

  String? validate() {
    if (value.isEmpty) return 'Dosage value is required';
    final numValue = double.tryParse(value);
    if (numValue == null || numValue <= 0) return 'Enter a valid dosage';
    return null;
  }
}

class DosageUnit {
  final String value;
  final String? error;

  const DosageUnit({this.value = 'mg', this.error});

  DosageUnit copyWith({String? value, String? error}) {
    return DosageUnit(
      value: value ?? this.value,
      error: error ?? this.error,
    );
  }

  String? validate() {
    if (value.isEmpty) return 'Unit is required';
    return null;
  }
}

class InitialStock {
  final String value;
  final String? error;

  const InitialStock({this.value = '', this.error});

  InitialStock copyWith({String? value, String? error}) {
    return InitialStock(
      value: value ?? this.value,
      error: error ?? this.error,
    );
  }

  String? validate() {
    if (value.isEmpty) return 'Initial stock is required';
    final numValue = int.tryParse(value);
    if (numValue == null || numValue <= 0) return 'Enter a valid number';
    return null;
  }
}

class RefillThreshold {
  final String value;
  final String? error;

  const RefillThreshold({this.value = '', this.error});

  RefillThreshold copyWith({String? value, String? error}) {
    return RefillThreshold(
      value: value ?? this.value,
      error: error ?? this.error,
    );
  }

  String? validate() {
    if (value.isEmpty) return 'Refill threshold is required';
    final numValue = int.tryParse(value);
    if (numValue == null || numValue < 0) return 'Enter a valid number';
    return null;
  }
}

// Simple form status enum
enum FormStatus {
  pure,
  dirty,
  valid,
  invalid,
  submitting,
  success,
  failure,
}

// Form state
class MedicationFormState {
  final MedicationName name;
  final DosageValue dosageValue;
  final DosageUnit dosageUnit;
  final String form;
  final FrequencyType frequencyType;
  final dynamic frequencyValue;
  final List<TimeOfDay> timesOfDay;
  final DateTime startDate;
  final DateTime? endDate;
  final InitialStock initialStock;
  final RefillThreshold refillThreshold;
  final String colorTag;
  final String? notes;
  final String? imageUrl;
  final bool isActive;
  final FormStatus status;

  MedicationFormState({
    this.name = const MedicationName(),
    this.dosageValue = const DosageValue(),
    this.dosageUnit = const DosageUnit(),
    this.form = 'Tablet',
    this.frequencyType = FrequencyType.daily,
    this.frequencyValue,
    this.timesOfDay = const [TimeOfDay(hour: 8, minute: 0)],
    DateTime? startDate,
    this.endDate,
    this.initialStock = const InitialStock(),
    this.refillThreshold = const RefillThreshold(),
    this.colorTag = '#2196F3',
    this.notes,
    this.imageUrl,
    this.isActive = true,
    this.status = FormStatus.pure,
  }) : startDate = startDate ?? DateTime.now();

  MedicationFormState copyWith({
    MedicationName? name,
    DosageValue? dosageValue,
    DosageUnit? dosageUnit,
    String? form,
    FrequencyType? frequencyType,
    dynamic frequencyValue,
    List<TimeOfDay>? timesOfDay,
    DateTime? startDate,
    DateTime? endDate,
    InitialStock? initialStock,
    RefillThreshold? refillThreshold,
    String? colorTag,
    String? notes,
    String? imageUrl,
    bool? isActive,
    FormStatus? status,
  }) {
    return MedicationFormState(
      name: name ?? this.name,
      dosageValue: dosageValue ?? this.dosageValue,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      form: form ?? this.form,
      frequencyType: frequencyType ?? this.frequencyType,
      frequencyValue: frequencyValue ?? this.frequencyValue,
      timesOfDay: timesOfDay ?? this.timesOfDay,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      initialStock: initialStock ?? this.initialStock,
      refillThreshold: refillThreshold ?? this.refillThreshold,
      colorTag: colorTag ?? this.colorTag,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
    );
  }

  bool get isValid {
    return name.validate() == null &&
        dosageValue.validate() == null &&
        dosageUnit.validate() == null &&
        initialStock.validate() == null &&
        refillThreshold.validate() == null &&
        timesOfDay.isNotEmpty;
  }

  Medication toMedication(String userId) {
    return Medication(
      id: '',
      userId: userId,
      name: name.value,
      dosageValue: double.parse(dosageValue.value),
      dosageUnit: dosageUnit.value,
      form: form,
      frequency: Frequency(
        type: frequencyType,
        value: frequencyValue,
      ),
      timesOfDay: timesOfDay,
      startDate: startDate,
      endDate: endDate,
      initialStock: int.parse(initialStock.value),
      currentStock: int.parse(initialStock.value),
      pillsPerPrescription: null,
      refillThreshold: int.parse(refillThreshold.value),
      colorTag: colorTag,
      notes: notes,
      imageUrl: imageUrl,
      isActive: isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
