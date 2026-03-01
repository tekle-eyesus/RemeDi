import 'package:fpdart/fpdart.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/firestore_datasource.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel> get user;
  UserModel get currentUser;

  Future<Either<Failure, UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserModel>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, void>> createUserProfile(UserModel user);
  Future<Either<Failure, UserModel>> getUserProfile(String userId);
  Future<Either<Failure, UserModel>> updateUserProfile(UserModel user);
}

class AuthRemoteDataSourceImpl extends FirestoreDataSource
    implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl({firebase_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  @override
  Stream<UserModel> get user {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return UserModel(id: '', email: '', displayName: '');
      }

      // Try to get user profile from Firestore
      try {
        final userDoc = await usersCollection.doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          return UserModel.fromFirestore(userDoc);
        } else {
          // Create profile if it doesn't exist
          final newUser = UserModel.fromFirebaseUser(firebaseUser);
          await createUserProfile(newUser);
          return newUser;
        }
      } catch (e) {
        return UserModel.fromFirebaseUser(firebaseUser);
      }
    });
  }

  @override
  UserModel get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return UserModel(id: '', email: '', displayName: '');
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return Left(Failure('Sign in failed: User is null'));
      }

      final userModel = UserModel.fromFirebaseUser(user);
      return Right(userModel);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(Failure(_getAuthErrorMessage(e)));
    } catch (e) {
      return Left(Failure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return Left(Failure('Sign up failed: User is null'));
      }

      // Update display name
      await user.updateDisplayName(displayName);

      final userModel = UserModel(
        id: user.uid,
        email: email,
        displayName: displayName,
      );

      // Create user profile in Firestore
      await createUserProfile(userModel);

      return Right(userModel);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(Failure(_getAuthErrorMessage(e)));
    } catch (e) {
      return Left(Failure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(Failure('Sign out failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(Failure(_getAuthErrorMessage(e)));
    } catch (e) {
      return Left(Failure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> createUserProfile(UserModel user) async {
    try {
      await usersCollection.doc(user.id).set(user.toFirestore());
      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to create user profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getUserProfile(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        return Right(UserModel.fromFirestore(doc));
      } else {
        final fbUser = _firebaseAuth.currentUser;
        if (fbUser != null) {
          return Right(UserModel.fromFirebaseUser(fbUser));
        }
        return Left(Failure('User profile not found'));
      }
    } catch (e) {
      return Left(Failure('Failed to get user profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateUserProfile(UserModel user) async {
    try {
      await usersCollection.doc(user.id).update(user.toUpdateMap());
      final doc = await usersCollection.doc(user.id).get();
      return Right(UserModel.fromFirestore(doc));
    } catch (e) {
      return Left(Failure('Failed to update user profile: ${e.toString()}'));
    }
  }

  String _getAuthErrorMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This user has been disabled';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
