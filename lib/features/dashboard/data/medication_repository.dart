import 'package:supabase_flutter/supabase_flutter.dart';

class MedicationRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> getMedicationsStream() {
    final user = _client.auth.currentUser;
    if (user == null) return const Stream.empty();

    final medicationStream = _client
        .from('medications')
        .stream(primaryKey: ['id']).eq('user_id', user.id);

    return medicationStream;
  }
}
