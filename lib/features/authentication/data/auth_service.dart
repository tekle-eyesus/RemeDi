import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signUp(email: email, password: password);
    if (res.user == null) {
      throw Exception(res.session == null
          ? 'Unknown error during signup.'
          : 'Please check your email to confirm your account.');
    }

    // Create profile row
    await _client.from('profiles').insert({'id': res.user!.id, 'email': email});
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.user == null) {
      throw Exception('Invalid credentials.');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Stream<bool> get authStateChanges =>
      _client.auth.onAuthStateChange.map((event) => event.session != null);
}
