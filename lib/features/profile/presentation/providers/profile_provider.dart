import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication_reminder/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:medication_reminder/features/authentication/domain/entities/user_entity.dart';
import 'package:medication_reminder/features/authentication/presentation/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Profile State
class ProfileState {
  final bool isLoading;
  final UserEntity? user;
  final String? error;
  final bool isSuccess;

  const ProfileState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isSuccess = false,
  });

  static const _unset = Object();

  ProfileState copyWith({
    bool? isLoading,
    UserEntity? user,
    Object? error = _unset,
    bool? isSuccess,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: identical(error, _unset) ? this.error : error as String?,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final AuthRepositoryImpl _authRepository;

  ProfileNotifier({required AuthRepositoryImpl authRepository})
      : _authRepository = authRepository,
        super(const ProfileState()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    state = state.copyWith(isLoading: true, error: null);
    final result = await _authRepository.getUserProfile(currentUserId);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        error: null,
      ),
    );
  }

  Future<void> refreshProfile() => _loadProfile();

  Future<void> updateProfile(UserEntity updatedUser) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    final result = await _authRepository.updateUserProfile(updatedUser);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
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

  void clearSuccess() {
    state = state.copyWith(isSuccess: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    authRepository: ref.read(authRepositoryProvider),
  );
});
