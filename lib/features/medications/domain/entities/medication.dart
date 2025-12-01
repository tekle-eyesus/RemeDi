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

  Medication copyWith({
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
    return Medication(
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

  Map<String, dynamic> toMap() {
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
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'initialStock': initialStock,
      'currentStock': currentStock,
      'pillsPerPrescription': pillsPerPrescription,
      'refillThreshold': refillThreshold,
      'colorTag': colorTag,
      'notes': notes,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      dosageValue: (map['dosageValue'] as num).toDouble(),
      dosageUnit: map['dosageUnit'],
      form: map['form'],
      frequency: Frequency.fromMap(map['frequency']),
      timesOfDay: (map['timesOfDay'] as List).map((timeStr) {
        final parts = timeStr.toString().split(':');
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList(),
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      initialStock: map['initialStock'],
      currentStock: map['currentStock'],
      pillsPerPrescription: map['pillsPerPrescription'],
      refillThreshold: map['refillThreshold'],
      colorTag: map['colorTag'],
      notes: map['notes'],
      imageUrl: map['imageUrl'],
      isActive: map['isActive'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  factory Medication.empty() {
    return Medication(
      id: '',
      userId: '',
      name: '',
      dosageValue: 0,
      dosageUnit: 'mg',
      form: 'Tablet',
      frequency: Frequency(type: FrequencyType.daily, value: null),
      timesOfDay: [const TimeOfDay(hour: 8, minute: 0)],
      startDate: DateTime.now(),
      endDate: null,
      initialStock: 30,
      currentStock: 30,
      pillsPerPrescription: 30,
      refillThreshold: 5,
      colorTag: '#2196F3',
      notes: null,
      imageUrl: null,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  bool get isLowStock => currentStock <= refillThreshold;

  List<String> get formattedTimes {
    return timesOfDay.map((time) {
      final hour = time.hourOfPeriod;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:$minute $period';
    }).toList();
  }

  String get dosageString => '$dosageValue $dosageUnit';

  String get scheduleSummary {
    final times = formattedTimes.join(', ');
    switch (frequency.type) {
      case FrequencyType.daily:
        return 'Daily at $times';
      case FrequencyType.specificDays:
        final days = (frequency.value as List<String>).join(', ');
        return '$days at $times';
      case FrequencyType.interval:
        return 'Every ${frequency.value} days at $times';
    }
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
    final typeStr = map['type'];
    final frequencyType = FrequencyType.values.firstWhere(
      (e) => e.toString().split('.').last == typeStr,
      orElse: () => FrequencyType.daily,
    );

    return Frequency(
      type: frequencyType,
      value: map['value'],
    );
  }
}

enum FrequencyType {
  daily,
  specificDays,
  interval,
}
