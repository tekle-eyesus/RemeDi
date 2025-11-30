import 'package:fpdart/fpdart.dart';
import 'package:medication_reminder/core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity> get user;
  UserEntity get currentUser;

  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
}
