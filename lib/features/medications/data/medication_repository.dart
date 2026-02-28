import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/medication.dart';

final medicationRepositoryProvider = Provider((ref) => MedicationRepository());

final userMedicationsProvider = StreamProvider<List<Medication>>((ref) {
  // final user = ref.watch( authNotifierProvider).user;
  // if (user == null) return Stream.value([]);
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return Stream.value([]);
  return ref.read(medicationRepositoryProvider).getMedications(currentUser.uid);
});

class MedicationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add Medication
  Future<void> addMedication(Medication medication) async {
    await _firestore.collection('medications').add(medication.toMap());
  }

  // Update Medication
  Future<void> updateMedication(Medication medication) async {
    await _firestore
        .collection('medications')
        .doc(medication.id)
        .update(medication.toMap());
  }

  // Delete Medication
  Future<void> deleteMedication(String id) async {
    await _firestore.collection('medications').doc(id).delete();
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
}
