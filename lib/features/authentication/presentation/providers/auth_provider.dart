import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:medication_reminder/core/errors/failures.dart';
import 'package:medication_reminder/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:medication_reminder/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:medication_reminder/features/authentication/domain/entities/user_entity.dart';
import 'package:medication_reminder/features/authentication/domain/usecases/sign_in_usecase.dart';
import 'package:medication_reminder/features/authentication/domain/usecases/sign_up_usecase.dart';

// Providers
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
  );
});

final signInUseCaseProvider = Provider<SignInWithEmailAndPassword>((ref) {
  return SignInWithEmailAndPassword(ref.read(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpWithEmailAndPassword>((ref) {
  return SignUpWithEmailAndPassword(ref.read(authRepositoryProvider));
});

// Auth State Notifier
class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final Failure? error;
  final bool isSuccess;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isSuccess = false,
  });

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    Failure? error,
    bool? isSuccess,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SignInWithEmailAndPassword _signInUseCase;
  final SignUpWithEmailAndPassword _signUpUseCase;
  final AuthRepositoryImpl _authRepository;

  AuthNotifier({
    required SignInWithEmailAndPassword signInUseCase,
    required SignUpWithEmailAndPassword signUpUseCase,
    required AuthRepositoryImpl authRepository,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _authRepository = authRepository,
        super(const AuthState());

  // Stream to listen to auth state changes
  Stream<UserEntity> get userStream => _authRepository.user;

  void _updateUser(UserEntity? user) {
    state = state.copyWith(user: user, error: null);
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _signInUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure,
        isSuccess: false,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        error: null,
        isSuccess: true,
      ),
    );
  }

  Future<void> signUp(String email, String password, String displayName) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _signUpUseCase(
      email: email,
      password: password,
      displayName: displayName,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure,
        isSuccess: false,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        error: null,
        isSuccess: true,
      ),
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    final result = await _authRepository.signOut();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure,
      ),
      (_) => state = state.copyWith(
        isLoading: false,
        user: UserEntity.empty,
        isSuccess: false,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    signInUseCase: ref.read(signInUseCaseProvider),
    signUpUseCase: ref.read(signUpUseCaseProvider),
    authRepository: ref.read(authRepositoryProvider),
  );
});
