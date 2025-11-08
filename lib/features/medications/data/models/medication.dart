import 'package:supabase_flutter/supabase_flutter.dart';

class Medication {
  final String? id;
  final String userId;
  final String medicationName;
  final double? dosageValue;
  final String? dosageUnit;
  final String? form;
  final String? colorTag;
  final String? notes;
  final String? imageUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool active;
  final int stock;
  final int? unitsPerPrescription;
  final int refillThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medication({
    this.id,
    required this.userId,
    required this.medicationName,
    this.dosageValue,
    this.dosageUnit,
    this.form,
    this.colorTag,
    this.notes,
    this.imageUrl,
    this.startDate,
    this.endDate,
    this.active = true,
    this.stock = 0,
    this.unitsPerPrescription,
    this.refillThreshold = 5,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      medicationName: json['medication_name'] as String,
      dosageValue: (json['dosage_value'] as num?)?.toDouble(),
      dosageUnit: json['dosage_unit'] as String?,
      form: json['form'] as String?,
      colorTag: json['color_tag'] as String?,
      notes: json['notes'] as String?,
      imageUrl: json['image_url'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      active: json['active'] ?? true,
      stock: json['stock'] ?? 0,
      unitsPerPrescription: json['units_per_prescription'],
      refillThreshold: json['refill_threshold'] ?? 5,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'medication_name': medicationName,
      'dosage_value': dosageValue,
      'dosage_unit': dosageUnit,
      'form': form,
      'color_tag': colorTag,
      'notes': notes,
      'image_url': imageUrl,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'active': active,
      'stock': stock,
      'units_per_prescription': unitsPerPrescription,
      'refill_threshold': refillThreshold,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
