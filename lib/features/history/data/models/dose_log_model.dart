import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/dose_log.dart';

class DoseLogModel extends DoseLog {
  DoseLogModel({
    required super.id,
    required super.medicationId,
    required super.medicationName,
    required super.dosage,
    required super.unit,
    required super.form,
    required super.scheduledTime,
    super.takenTime,
    required super.status,
    super.notes,
    required super.colorTag,
    required super.createdAt,
  });

  factory DoseLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DoseLogModel(
      id: doc.id,
      medicationId: data['medicationId'],
      medicationName: data['medicationName'],
      dosage: (data['dosage'] as num).toDouble(),
      unit: data['unit'],
      form: data['form'],
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      takenTime: data['takenTime'] != null
          ? (data['takenTime'] as Timestamp).toDate()
          : null,
      status: DoseStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => DoseStatus.upcoming,
      ),
      notes: data['notes'],
      colorTag: data['colorTag'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dosage': dosage,
      'unit': unit,
      'form': form,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'takenTime': takenTime != null ? Timestamp.fromDate(takenTime!) : null,
      'status': status.toString().split('.').last,
      'notes': notes,
      'colorTag': colorTag,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Add copyWith method
  DoseLogModel copyWith({
    String? id,
    String? medicationId,
    String? medicationName,
    double? dosage,
    String? unit,
    String? form,
    DateTime? scheduledTime,
    DateTime? takenTime,
    DoseStatus? status,
    String? notes,
    String? colorTag,
    DateTime? createdAt,
  }) {
    return DoseLogModel(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      unit: unit ?? this.unit,
      form: form ?? this.form,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      colorTag: colorTag ?? this.colorTag,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  DoseLog toEntity() {
    return DoseLog(
      id: id,
      medicationId: medicationId,
      medicationName: medicationName,
      dosage: dosage,
      unit: unit,
      form: form,
      scheduledTime: scheduledTime,
      takenTime: takenTime,
      status: status,
      notes: notes,
      colorTag: colorTag,
      createdAt: createdAt,
    );
  }
}
