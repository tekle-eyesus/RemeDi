import 'package:supabase_flutter/supabase_flutter.dart';
import 'dose_model.dart';

class DoseRepository {
  final _client = Supabase.instance.client;

  Future<List<Dose>> fetchDoses(String medicationId) async {
    final res = await _client
        .from('doses')
        .select()
        .eq('medication_id', medicationId)
        .order('scheduled_at', ascending: true);
    return (res as List).map((d) => Dose.fromMap(d)).toList();
  }

  Future<void> addDose(Dose dose) async {
    await _client.from('doses').insert(dose.toMap());
  }

  Future<void> markDoseTaken(String doseId) async {
    await _client.from('doses').update({
      'status': 'taken',
      'taken_at': DateTime.now().toIso8601String(),
    }).eq('id', doseId);
  }

  Future<void> markDoseMissed(String doseId) async {
    await _client.from('doses').update({
      'status': 'missed',
    }).eq('id', doseId);
  }
}
