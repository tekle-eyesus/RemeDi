import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'medication_repository.dart';
import 'models/medication.dart';

final medicationRepositoryProvider = Provider((ref) => MedicationRepository());

final medicationsProvider = FutureProvider<List<Medication>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  return ref.read(medicationRepositoryProvider).getUserMedications(user.id);
});
