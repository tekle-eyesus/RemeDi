class Dose {
  final String id;
  final String medicationId;
  final DateTime scheduledAt;
  final int quantity;
  final String? notes;
  final DateTime? takenAt;
  final String status;

  Dose({
    required this.id,
    required this.medicationId,
    required this.scheduledAt,
    required this.quantity,
    this.takenAt,
    this.notes,
    required this.status,
  });

  factory Dose.fromMap(Map<String, dynamic> map) => Dose(
      id: map['id'] as String,
      medicationId: map['medication_id'] as String,
      scheduledAt: DateTime.parse(map['scheduled_at'] as String),
      takenAt: map['taken_at'] != null ? DateTime.parse(map['taken_at']) : null,
      quantity: map['quantity'],
      status: map['status'] ?? 'upcoming',
      notes: map['notes'] ?? "None");

  Map<String, dynamic> toMap() => {
        'medication_id': medicationId,
        'scheduled_at': scheduledAt.toIso8601String(),
        'taken_at': takenAt?.toIso8601String(),
        'status': status,
      };
}
