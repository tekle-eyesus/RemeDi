import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum FrequencyType { daily, specificDays, interval, asNeeded }

class Medication {
  final String id;
  final String userId;
  final String name;
  final double dosage;
  final String unit; // mg, ml, pill
  final String type; // Tablet, Liquid, etc.
  final String color; // Hex string e.g. #FF0000
  final int currentStock;
  final int refillThreshold;
  final FrequencyType frequencyType;
  final List<String> frequencyDays; // ["Mon", "Wed"] if specificDays
  final int interval; // Every X days
  final List<String> reminderTimes; // ["08:00", "20:00"]
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final String? imageUrl;
  // Overdose warning fields
  final int? maxDailyDoses;
  final int? minIntervalMinutes;

  Medication({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.unit,
    required this.type,
    required this.color,
    required this.currentStock,
    required this.refillThreshold,
    required this.frequencyType,
    required this.frequencyDays,
    required this.interval,
    required this.reminderTimes,
    required this.startDate,
    this.endDate,
    this.notes,
    this.imageUrl,
    this.maxDailyDoses,
    this.minIntervalMinutes,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'unit': unit,
      'type': type,
      'color': color,
      'currentStock': currentStock,
      'refillThreshold': refillThreshold,
      'frequencyType': frequencyType.toString().split('.').last,
      'frequencyDays': frequencyDays,
      'interval': interval,
      'reminderTimes': reminderTimes,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'notes': notes,
      'imageUrl': imageUrl,
      'maxDailyDoses': maxDailyDoses,
      'minIntervalMinutes': minIntervalMinutes,
    };
  }

  // Create from Firebase
  factory Medication.fromMap(Map<String, dynamic> map, String id) {
    return Medication(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      dosage: (map['dosage'] ?? 0).toDouble(),
      unit: map['unit'] ?? 'mg',
      type: map['type'] ?? 'Tablet',
      color: map['color'] ?? '#781E14',
      currentStock: map['currentStock'] ?? 0,
      refillThreshold: map['refillThreshold'] ?? 0,
      frequencyType: _parseFrequency(map['frequencyType']),
      frequencyDays: List<String>.from(map['frequencyDays'] ?? []),
      interval: map['interval'] ?? 1,
      reminderTimes: List<String>.from(map['reminderTimes'] ?? []),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      notes: map['notes'],
      imageUrl: map['imageUrl'],
      maxDailyDoses: map['maxDailyDoses'] as int?,
      minIntervalMinutes: map['minIntervalMinutes'] as int?,
    );
  }

  static FrequencyType _parseFrequency(String? value) {
    return FrequencyType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => FrequencyType.daily,
    );
  }

  Medication copyWith({
    String? id,
    String? userId,
    String? name,
    double? dosage,
    String? unit,
    String? type,
    String? color,
    int? currentStock,
    int? refillThreshold,
    FrequencyType? frequencyType,
    List<String>? frequencyDays,
    int? interval,
    List<String>? reminderTimes,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    String? imageUrl,
    int? maxDailyDoses,
    int? minIntervalMinutes,
  }) {
    return Medication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      unit: unit ?? this.unit,
      type: type ?? this.type,
      color: color ?? this.color,
      currentStock: currentStock ?? this.currentStock,
      refillThreshold: refillThreshold ?? this.refillThreshold,
      frequencyType: frequencyType ?? this.frequencyType,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      interval: interval ?? this.interval,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      maxDailyDoses: maxDailyDoses ?? this.maxDailyDoses,
      minIntervalMinutes: minIntervalMinutes ?? this.minIntervalMinutes,
    );
  }
}
