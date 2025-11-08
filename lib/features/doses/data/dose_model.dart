class Dose {
  final String? id;
  final String medicationId;
  final DateTime scheduledAt;
  final DateTime? takenAt;
  final String status; // 'scheduled', 'taken', 'missed'
  final int quantity;
  final String? note;

  Dose({
    this.id,
    required this.medicationId,
    required this.scheduledAt,
    this.takenAt,
    this.status = 'scheduled',
    this.quantity = 1,
    this.note,
  });

  factory Dose.fromJson(Map<String, dynamic> json) {
    return Dose(
      id: json['id'] as String,
      medicationId: json['medication_id'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at']),
      takenAt:
          json['taken_at'] != null ? DateTime.parse(json['taken_at']) : null,
      status: json['status'] ?? 'scheduled',
      quantity: json['quantity'] ?? 1,
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'medication_id': medicationId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'status': status,
      'quantity': quantity,
      'note': note,
    };

    if (id != null && id!.isNotEmpty) {
      data['id'] = id;
    }
    return data;
  }
}
