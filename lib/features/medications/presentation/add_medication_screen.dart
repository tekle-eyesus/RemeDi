import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../medications/data/medication_repository.dart';
import '../../medications/data/models/medication.dart';
import '../../medications/data/medication_provider.dart';

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
  final _stockController = TextEditingController();
  final _unitsPerPrescriptionController = TextEditingController();
  final _refillThresholdController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedUnit;
  String? _selectedForm;
  String? _selectedColor;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _forms = [
    'Tablet',
    'Capsule',
    'Liquid',
    'Injection',
    'Other'
  ];
  final List<String> _units = ['mg', 'ml', 'pills', 'drops'];
  final List<Color> _colorOptions = [
    Colors.teal,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Medication"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, "Medication Name",
                  validator: (v) {
                if (v == null || v.isEmpty) return "Enter medication name";
                return null;
              }),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_dosageController, "Dosage",
                        inputType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      "Unit",
                      _units,
                      _selectedUnit,
                      (v) => setState(() => _selectedUnit = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDropdown("Form", _forms, _selectedForm,
                  (v) => setState(() => _selectedForm = v)),
              const SizedBox(height: 16),
              _buildDatePickers(context),
              const SizedBox(height: 16),
              _buildTextField(_stockController, "Initial Stock",
                  inputType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(
                  _unitsPerPrescriptionController, "Units per Prescription",
                  inputType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(_refillThresholdController, "Refill Threshold",
                  inputType: TextInputType.number),
              const SizedBox(height: 20),
              _buildColorPicker(),
              const SizedBox(height: 20),
              _buildTextField(_notesController, "Notes / Instructions",
                  maxLines: 3),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text("Add Medication",
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {String? Function(String?)? validator,
      TextInputType inputType = TextInputType.text,
      int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value,
      void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildDatePickers(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            label: "Start Date",
            date: _startDate,
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _startDate = picked);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDateField(
            label: "End Date",
            date: _endDate,
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _startDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _endDate = picked);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
      {required String label,
      DateTime? date,
      required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          date != null ? "${date.toLocal()}".split(' ')[0] : 'Select Date',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Color Tag",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: _colorOptions.map((color) {
            final isSelected = _selectedColor == color.value.toRadixString(16);
            return GestureDetector(
              onTap: () => setState(() => _selectedColor =
                  '#${color.value.toRadixString(16).substring(2)}'),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw "Not logged in";

      final medication = Medication(
        userId: user.id,
        medicationName: _nameController.text.trim(),
        dosageValue: double.tryParse(_dosageController.text),
        dosageUnit: _selectedUnit,
        form: _selectedForm,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        colorTag: _selectedColor,
        notes: _notesController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        stock: int.tryParse(_stockController.text) ?? 0,
        unitsPerPrescription:
            int.tryParse(_unitsPerPrescriptionController.text),
        refillThreshold: int.tryParse(_refillThresholdController.text) ?? 5,
      );

      await MedicationRepository().addMedication(medication);

      // Refresh and go back to dashboard
      ref.refresh(medicationsProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication added successfully ✅')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
