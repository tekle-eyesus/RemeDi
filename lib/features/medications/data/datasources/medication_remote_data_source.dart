import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:medication_reminder/core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/firestore_datasource.dart';
import '../models/medication_model.dart';

abstract class MedicationRemoteDataSource {
  Stream<List<MedicationModel>> getMedicationsStream();
  Future<Either<Failure, List<MedicationModel>>> getMedications();
  Future<Either<Failure, MedicationModel>> getMedication(String id);
  Future<Either<Failure, MedicationModel>> addMedication(
      MedicationModel medication);
  Future<Either<Failure, MedicationModel>> updateMedication(
      MedicationModel medication);
  Future<Either<Failure, void>> deleteMedication(String id);
  Future<Either<Failure, String>> uploadMedicationImage(String imagePath);
}

class MedicationRemoteDataSourceImpl extends FirestoreDataSource
    implements MedicationRemoteDataSource {
  final FirebaseStorage _storage;
  final Uuid _uuid;

  MedicationRemoteDataSourceImpl({
    FirebaseStorage? storage,
    Uuid? uuid,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _uuid = uuid ?? const Uuid();

  CollectionReference get _medicationsCollection {
    return getUserCollection(AppConstants.medicationsCollection);
  }

  @override
  Stream<List<MedicationModel>> getMedicationsStream() {
    return _medicationsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MedicationModel.fromFirestore(doc))
          .where((med) => med.isActive)
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<MedicationModel>>> getMedications() async {
    try {
      final snapshot = await _medicationsCollection
          .orderBy('createdAt', descending: true)
          .get();

      final medications = snapshot.docs
          .map((doc) => MedicationModel.fromFirestore(doc))
          .where((med) => med.isActive)
          .toList();

      return Right(medications);
    } catch (e) {
      return Left(Failure('Failed to load medications: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MedicationModel>> getMedication(String id) async {
    try {
      final doc = await _medicationsCollection.doc(id).get();

      if (!doc.exists) {
        return Left(Failure('Medication not found'));
      }

      return Right(MedicationModel.fromFirestore(doc));
    } catch (e) {
      return Left(Failure('Failed to get medication: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MedicationModel>> addMedication(
      MedicationModel medication) async {
    try {
      final id = _uuid.v4();
      final medicationWithId = medication.copyWith(id: id);

      await _medicationsCollection.doc(id).set(medicationWithId.toFirestore());

      return Right(medicationWithId);
    } catch (e) {
      return Left(Failure('Failed to add medication: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MedicationModel>> updateMedication(
      MedicationModel medication) async {
    try {
      await _medicationsCollection
          .doc(medication.id)
          .update(medication.toFirestore());

      return Right(medication);
    } catch (e) {
      return Left(Failure('Failed to update medication: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMedication(String id) async {
    try {
      // Soft delete - set isActive to false
      await _medicationsCollection.doc(id).update(
          {'isActive': false, 'updatedAt': FieldValue.serverTimestamp()});

      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to delete medication: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadMedicationImage(
      String imagePath) async {
    try {
      final fileName = 'medications/${_uuid.v4()}.jpg';
      final ref = _storage.ref().child(fileName);

      final uploadTask = await ref.putFile(File(imagePath));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return Right(downloadUrl);
    } catch (e) {
      return Left(Failure('Failed to upload image: ${e.toString()}'));
    }
  }
}
