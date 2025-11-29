import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class FirestoreDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get currentUserId => auth.currentUser?.uid ?? '';

  CollectionReference get usersCollection => firestore.collection('users');

  CollectionReference getUserCollection(String collectionName) {
    return usersCollection.doc(currentUserId).collection(collectionName);
  }
}
