import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Medication {
  final String id;
  final String userId;
  final String name;
  final double dosageValue;
  final String dosageUnit;
  final String form;
  final Frequency frequency;
  final List<TimeOfDay> timesOfDay;
  final DateTime startDate;
  final DateTime? endDate;
  final int initialStock;
  final int currentStock;
  final int? pillsPerPrescription;
  final int refillThreshold;
  final String colorTag;
  final String? notes;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medication({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosageValue,
    required this.dosageUnit,
    required this.form,
    required this.frequency,
    required this.timesOfDay,
    required this.startDate,
    this.endDate,
    required this.initialStock,
    required this.currentStock,
    this.pillsPerPrescription,
    required this.refillThreshold,
    required this.colorTag,
    this.notes,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'dosageValue': dosageValue,
      'dosageUnit': dosageUnit,
      'form': form,
      'frequency': {
        'type': frequency.type.toString().split('.').last,
        'value': frequency.value,
      },
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
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore Document
  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      dosageValue: map['dosageValue'].toDouble(),
      dosageUnit: map['dosageUnit'],
      form: map['form'],
      frequency: Frequency.fromMap(map['frequency']),
      timesOfDay: (map['timesOfDay'] as List).map((timeStr) {
        final parts = timeStr.split(':');
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      initialStock: map['initialStock'],
      currentStock: map['currentStock'],
      pillsPerPrescription: map['pillsPerPrescription'],
      refillThreshold: map['refillThreshold'],
      colorTag: map['colorTag'],
      notes: map['notes'],
      imageUrl: map['imageUrl'],
      isActive: map['isActive'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}

class Frequency {
  final FrequencyType type;
  final dynamic value;

  Frequency({required this.type, required this.value});

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString().split('.').last,
      'value': value,
    };
  }

  factory Frequency.fromMap(Map<String, dynamic> map) {
    return Frequency(
      type: FrequencyType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      value: map['value'],
    );
  }
}

enum FrequencyType {
  daily,
  specificDays,
  interval,
}
