import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication_reminder/features/doses/presentation/dose_list_screen.dart';
import 'package:medication_reminder/features/medications/presentation/add_medication_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../logic/dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationsAsync = ref.watch(medicationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Medications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();

              ref.invalidate(medicationsStreamProvider);
              ref.invalidate(medicationRepositoryProvider);
            },
          ),
        ],
      ),
      body: medicationsAsync.when(
        data: (medications) {
          if (medications.isEmpty) {
            return const Center(child: Text("No medications added yet."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final med = medications[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoseListScreen(medicationId: med['id']),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade200,
                    child: const Icon(Icons.medication),
                  ),
                  title: Text(med['medication_name']),
                  subtitle: Text(
                      "${med['dosage_value']} ${med['unit']} • ${med['form']}"),
                  trailing: med['active'] == true
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.cancel, color: Colors.redAccent),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
