import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication_reminder/core/services/notification_service.dart';
import '../domain/entities/medication.dart';

final medicationRepositoryProvider = Provider((ref) => MedicationRepository());

final userMedicationsProvider = StreamProvider<List<Medication>>((ref) {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return Stream.value([]);
  return ref.read(medicationRepositoryProvider).getMedications(currentUser.uid);
});

class MedicationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notifications = NotificationService();

  // Add Medication
  Future<void> addMedication(Medication medication) async {
    final docRef = await _firestore.collection('medications').add(medication.toMap());
    final saved = medication.copyWith(id: docRef.id);
    await _notifications.scheduleMedicationReminders(saved);
  }

  // Update Medication
  Future<void> updateMedication(Medication medication) async {
    await _firestore
        .collection('medications')
        .doc(medication.id)
        .update(medication.toMap());
    // Schedule new notifications only after Firestore succeeds
    await _notifications.scheduleMedicationReminders(medication);
  }

  // Delete Medication
  Future<void> deleteMedication(String id, Medication medication) async {
    await _firestore.collection('medications').doc(id).delete();
    // Cancel notifications after successful deletion
    await _notifications.cancelMedicationReminders(medication);
  }

  // Stream Medications for User
  Stream<List<Medication>> getMedications(String userId) {
    return _firestore
        .collection('medications')
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Medication.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Decrement stock by [amount] and fire a refill alert if stock falls low.
  Future<void> decrementStock(Medication medication, {int amount = 1}) async {
    final newStock = (medication.currentStock - amount).clamp(0, 999999);
    await _firestore
        .collection('medications')
        .doc(medication.id)
        .update({'currentStock': newStock});
    if (newStock <= medication.refillThreshold && medication.refillThreshold > 0) {
      await _notifications.showRefillAlert(
        medication.copyWith(currentStock: newStock),
      );
    }
  }
}
