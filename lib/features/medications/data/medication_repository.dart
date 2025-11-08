import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/medication.dart';

class MedicationRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Medication>> getUserMedications(String userId) async {
    final response = await _client
        .from('medications')
        .select('*')
        .eq('user_id', userId)
        .eq('active', true)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Medication.fromJson(json)).toList();
  }

  Future<void> addMedication(Medication medication) async {
    await _client.from('medications').insert(medication.toJson());
  }
}
