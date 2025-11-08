import 'package:supabase_flutter/supabase_flutter.dart';

class MedicationService {
  final _client = Supabase.instance.client;

  Future<void> addMedication({
    required String name,
    required double dosageValue,
    required String unit,
    required String form,
    bool active = true,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Not authenticated");

    final data = {
      'user_id': user.id,
      'medication_name': name,
      'dosage_value': dosageValue,
      'dosage_unit': unit,
      'form': form,
      'active': active,
      'stock': 0,
      'refill_threshold': 0,
      'color_tag': '#A7C7E7',
    };

    final response = await _client.from('medications').insert(data);
    if (response.error != null) {
      throw response.error!;
    }
  }
}
