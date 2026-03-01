import 'package:fpdart/fpdart.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import '../../../../core/errors/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<UserEntity> get user {
    return remoteDataSource.user.map((userModel) => userModel.toEntity());
  }

  @override
  UserEntity get currentUser => remoteDataSource.currentUser.toEntity();

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await remoteDataSource.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return await remoteDataSource.signOut();
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    return await remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<Either<Failure, UserEntity>> getUserProfile(String userId) async {
    final result = await remoteDataSource.getUserProfile(userId);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile(UserEntity user) async {
    final userModel = UserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoUrl,
      dateOfBirth: user.dateOfBirth,
      bio: user.bio,
    );
    final result = await remoteDataSource.updateUserProfile(userModel);
    return result.map((model) => model.toEntity());
  }
}
