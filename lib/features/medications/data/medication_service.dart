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

  Future<void> decrementStock(String medicationId, int amount) async {
    final med = await _client
        .from('medications')
        .select()
        .eq('id', medicationId)
        .single();
    final currentStock = med['stock'] as int? ?? 0;
    final newStock = (currentStock - amount).clamp(0, double.infinity).toInt();

    await _client
        .from('medications')
        .update({'stock': newStock}).eq('id', medicationId);

    // Trigger refill alert if below threshold
    final threshold = med['refill_threshold'] ?? 0;
    if (newStock <= threshold) {
      // Here we can later hook into push notification logic
      print(
          '⚠️ Refill alert: ${med['medication_name']} is low ($newStock left)');
    }
  }

  Future<void> refillStock(String medicationId, int addedAmount) async {
    final med = await _client
        .from('medications')
        .select()
        .eq('id', medicationId)
        .single();
    final currentStock = med['stock'] as int? ?? 0;
    final newStock = currentStock + addedAmount;

    await _client
        .from('medications')
        .update({'stock': newStock}).eq('id', medicationId);
  }
}
