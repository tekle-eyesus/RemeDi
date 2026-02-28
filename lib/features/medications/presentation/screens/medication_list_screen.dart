import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medication_reminder/features/medications/data/medication_repository.dart';
import 'package:medication_reminder/features/medications/domain/entities/medication.dart';
import 'package:medication_reminder/features/medications/presentation/screens/add_medication_screen.dart';
import 'package:medication_reminder/shared/styles/theme.dart';

class MedicationListScreen extends ConsumerWidget {
  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationsAsync = ref.watch(userMedicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medications'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMedicationScreen(),
            ),
          );
        },
      ),
      body: medicationsAsync.when(
        data: (medications) {
          if (medications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.pills,
                      size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text("No medications added yet",
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final med = medications[index];
              return _MedicationCard(med: med);
            },
          );
        },
        error: (err, stack) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.triangleExclamation,
                    size: 60, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text("Failed to load medications",
                    style: TextStyle(color: Colors.red.shade500)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _MedicationCard extends ConsumerWidget {
  final Medication med;
  const _MedicationCard({required this.med});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(int.parse(med.color.replaceAll('#', '0xff')));
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: const FaIcon(FontAwesomeIcons.pills,
              color: Colors.white, size: 18),
        ),
        title: Text(med.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${med.dosage}${med.unit} · ${med.type}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (med.currentStock <= med.refillThreshold &&
                med.refillThreshold > 0)
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.orange),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddMedicationScreen(medication: med),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Medication'),
        content: Text('Remove "${med.name}" and cancel all reminders?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(medicationRepositoryProvider)
                    .deleteMedication(med.id, med);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${med.name} deleted')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

