import 'package:medication_reminder/features/medications/data/models/medication.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dose_model.dart';

class DoseRepository {
  final _client = Supabase.instance.client;

  Future<List<Dose>> fetchDosesForMedication(String medicationId) async {
    final res = await _client
        .from('doses')
        .select('*')
        .eq('medication_id', medicationId)
        .order('scheduled_at', ascending: true);

    return (res as List).map((d) => Dose.fromJson(d)).toList();
  }

  Future<void> markDoseTaken(String doseId) async {
    await _client.from('doses').update({
      'status': 'taken',
      'taken_at': DateTime.now().toIso8601String(),
    }).eq('id', doseId);
  }

  Future<void> markDoseMissed(String doseId) async {
    await _client.from('doses').update({'status': 'missed'}).eq('id', doseId);
  }

  Future<void> addDose(Dose dose) async {
    await _client.from('doses').insert(dose.toJson());
  }

  /// Mark dose as taken, reduce stock, and trigger refill alert if needed
  // Future<bool> markDoseTakenAndUpdateStock(String doseId, Medication medication, {int quantity = 1}) async {
  //   final batch = _client.from('medications').update({
  //     'stock': Supabase.literal('GREATEST(stock - $quantity, 0)')
  //   }).eq('id', medication.id);

  //   // Mark dose as taken
  //   await _client.from('doses').update({
  //     'status': 'taken',
  //     'taken_at': DateTime.now().toIso8601String(),
  //     'quantity': quantity,
  //   }).eq('id', doseId);

  //   // Update stock
  //   final updated = await batch.select('stock').single();

  //   final currentStock = updated['stock'] as int? ?? 0;

  //   // If stock <= refill threshold, insert a refill alert entry
  //   if (currentStock <= (medication.refillThreshold)) {
  //     await _client.from('refills').insert({
  //       'medication_id': medication.id,
  //       'user_id': medication.userId,
  //       'quantity': 0,
  //       'note': 'Stock below refill threshold, please refill.',
  //     });
  //     return true; // indicates refill alert should be shown
  //   }

  //   return false;
  // }

  Future<bool> markDoseTakenAndUpdateStock(
    String doseId,
    Medication medication, {
    int quantity = 1,
  }) async {
    final client = _client;

    // 1️⃣ Mark dose as taken
    await client.from('doses').update({
      'status': 'taken',
      'taken_at': DateTime.now().toIso8601String(),
      'quantity': quantity,
    }).eq('id', doseId);

    // 2️⃣ Fetch current stock
    final res = await client
        .from('medications')
        .select('stock')
        .eq('id', medication.id!)
        .single();

    int currentStock = res['stock'] as int? ?? 0;

    // 3️⃣ Reduce stock locally (never below 0)
    int newStock = (currentStock - quantity).clamp(0, currentStock);

    // 4️⃣ Update medication stock
    await client
        .from('medications')
        .update({'stock': newStock}).eq('id', medication.id!);

    // 5️⃣ Check refill threshold
    if (newStock <= (medication.refillThreshold)) {
      await client.from('refills').insert({
        'medication_id': medication.id,
        'user_id': medication.userId,
        'quantity': 0,
        'note': 'Stock below refill threshold, please refill.',
      });
      return true; // refill alert needed
    }

    return false; // no refill alert
  }
}
