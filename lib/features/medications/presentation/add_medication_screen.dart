import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/medication_controller.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  ConsumerState<AddMedicationScreen> createState() =>
      _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _unitController = TextEditingController();
  final _formController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final addMedState = ref.watch(addMedicationControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Medication")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Medication Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(labelText: 'Dosage Value'),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unitController,
                decoration:
                    const InputDecoration(labelText: 'Unit (e.g., mg, pills)'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _formController,
                decoration: const InputDecoration(
                    labelText: 'Form (e.g., tablet, capsule)'),
              ),
              const SizedBox(height: 24),
              addMedState.when(
                data: (_) => ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await ref
                          .read(addMedicationControllerProvider.notifier)
                          .addMedication(
                            name: _nameController.text,
                            dosageValue: double.parse(_dosageController.text),
                            unit: _unitController.text,
                            form: _formController.text,
                          );

                      if (mounted) Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Save Medication'),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Column(
                  children: [
                    Text('Error: $err',
                        style: const TextStyle(color: Colors.red)),
                    ElevatedButton(
                        onPressed: () =>
                            ref.invalidate(addMedicationControllerProvider),
                        child: const Text("Try Again")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
