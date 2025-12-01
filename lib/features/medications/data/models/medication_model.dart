import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/medication.dart';

class MedicationModel extends Medication {
  MedicationModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.dosageValue,
    required super.dosageUnit,
    required super.form,
    required super.frequency,
    required super.timesOfDay,
    required super.startDate,
    super.endDate,
    required super.initialStock,
    required super.currentStock,
    super.pillsPerPrescription,
    required super.refillThreshold,
    required super.colorTag,
    super.notes,
    super.imageUrl,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MedicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MedicationModel(
      id: doc.id,
      userId: data['userId'],
      name: data['name'],
      dosageValue: (data['dosageValue'] as num).toDouble(),
      dosageUnit: data['dosageUnit'],
      form: data['form'],
      frequency: Frequency.fromMap(data['frequency']),
      timesOfDay: (data['timesOfDay'] as List).map((timeStr) {
        final parts = timeStr.toString().split(':');
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      initialStock: data['initialStock'],
      currentStock: data['currentStock'],
      pillsPerPrescription: data['pillsPerPrescription'],
      refillThreshold: data['refillThreshold'],
      colorTag: data['colorTag'],
      notes: data['notes'],
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'dosageValue': dosageValue,
      'dosageUnit': dosageUnit,
      'form': form,
      'frequency': frequency.toMap(),
      'timesOfDay':
          timesOfDay.map((time) => '${time.hour}:${time.minute}').toList(),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'initialStock': initialStock,
      'currentStock': currentStock,
      'pillsPerPrescription': pillsPerPrescription,
      'refillThreshold': refillThreshold,
      'colorTag': colorTag,
      'notes': notes,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Medication toEntity() {
    return Medication(
      id: id,
      userId: userId,
      name: name,
      dosageValue: dosageValue,
      dosageUnit: dosageUnit,
      form: form,
      frequency: frequency,
      timesOfDay: timesOfDay,
      startDate: startDate,
      endDate: endDate,
      initialStock: initialStock,
      currentStock: currentStock,
      pillsPerPrescription: pillsPerPrescription,
      refillThreshold: refillThreshold,
      colorTag: colorTag,
      notes: notes,
      imageUrl: imageUrl,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  MedicationModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? dosageValue,
    String? dosageUnit,
    String? form,
    Frequency? frequency,
    List<TimeOfDay>? timesOfDay,
    DateTime? startDate,
    DateTime? endDate,
    int? initialStock,
    int? currentStock,
    int? pillsPerPrescription,
    int? refillThreshold,
    String? colorTag,
    String? notes,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosageValue: dosageValue ?? this.dosageValue,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      form: form ?? this.form,
      frequency: frequency ?? this.frequency,
      timesOfDay: timesOfDay ?? this.timesOfDay,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      initialStock: initialStock ?? this.initialStock,
      currentStock: currentStock ?? this.currentStock,
      pillsPerPrescription: pillsPerPrescription ?? this.pillsPerPrescription,
      refillThreshold: refillThreshold ?? this.refillThreshold,
      colorTag: colorTag ?? this.colorTag,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
