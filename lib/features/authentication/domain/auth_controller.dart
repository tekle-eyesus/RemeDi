import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  AuthController(this.ref) : super(const AsyncData(null));

  Future<void> signUp(String email, String password) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(authServiceProvider)
          .signUp(email: email, password: password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(authServiceProvider)
          .signIn(email: email, password: password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
  }
}
