import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medication_reminder/core/services/cloudinary_service.dart';
import 'package:medication_reminder/features/authentication/presentation/providers/auth_provider.dart';
import 'package:medication_reminder/features/medications/data/medication_repository.dart';
import 'package:medication_reminder/features/medications/domain/entities/medication.dart';
import 'package:medication_reminder/shared/styles/theme.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  final Medication? medication; // null = add mode, non-null = edit mode
  const AddMedicationScreen({super.key, this.medication});

  @override
  ConsumerState<AddMedicationScreen> createState() =>
      _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _stockController = TextEditingController();
  final _thresholdController = TextEditingController();
  final _notesController = TextEditingController();

  // State Variables
  String _selectedUnit = 'mg';
  String _selectedType = 'Tablet';
  Color _selectedColor = AppTheme.primaryColor;
  FrequencyType _frequencyType = FrequencyType.daily;
  final List<String> _selectedDays = [];
  final List<String> _reminderTimes = [];
  int _interval = 1;
  DateTime? _endDate;
  File? _selectedImage;
  bool _isLoading = false;
  // Overdose warning fields
  final _maxDailyDosesController = TextEditingController();
  final _minIntervalController = TextEditingController();

  final List<String> _daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  @override
  void initState() {
    super.initState();
    final med = widget.medication;
    if (med != null) {
      _nameController.text = med.name;
      _dosageController.text = med.dosage.toString();
      _stockController.text = med.currentStock.toString();
      _thresholdController.text = med.refillThreshold.toString();
      _notesController.text = med.notes ?? '';
      _selectedUnit = med.unit;
      _selectedType = med.type;
      _selectedColor =
          Color(int.parse(med.color.replaceAll('#', '0xff')));
      _frequencyType = med.frequencyType;
      _selectedDays.addAll(med.frequencyDays);
      _reminderTimes.addAll(med.reminderTimes);
      _interval = med.interval;
      _endDate = med.endDate;
      if (med.maxDailyDoses != null) {
        _maxDailyDosesController.text = med.maxDailyDoses.toString();
      }
      if (med.minIntervalMinutes != null) {
        _minIntervalController.text = med.minIntervalMinutes.toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    _notesController.dispose();
    _maxDailyDosesController.dispose();
    _minIntervalController.dispose();
    super.dispose();
  }

  // --- Image Handling ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error picking image: $e")));
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  // --- Time & Date Handling ---
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (!_reminderTimes.contains(formatted)) {
        setState(() {
          _reminderTimes.add(formatted);
          _reminderTimes.sort();
        });
      }
    }
  }

  Future<void> _pickEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  // --- Save Logic ---
  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;
    if (_reminderTimes.isEmpty && _frequencyType != FrequencyType.asNeeded) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please add at least one reminder time")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isEditing = widget.medication != null;
      final user = ref.read(authNotifierProvider).user;
      if (user == null) throw Exception("User not logged in");

      // 1. Upload Image if a new local image was selected
      String? imageUrl = widget.medication?.imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _cloudinaryService.uploadImage(_selectedImage!);
        if (imageUrl == null) throw Exception("Failed to upload image");
      }

      final colorHex =
          '#${_selectedColor.value.toRadixString(16).substring(2)}';

      final maxDaily = _maxDailyDosesController.text.trim().isEmpty
          ? null
          : int.tryParse(_maxDailyDosesController.text.trim());
      final minInterval = _minIntervalController.text.trim().isEmpty
          ? null
          : int.tryParse(_minIntervalController.text.trim());

      if (isEditing) {
        // 2a. Update existing medication
        final updated = widget.medication!.copyWith(
          name: _nameController.text.trim(),
          dosage: double.parse(_dosageController.text),
          unit: _selectedUnit,
          type: _selectedType,
          color: colorHex,
          currentStock: int.parse(_stockController.text),
          refillThreshold: int.parse(_thresholdController.text),
          frequencyType: _frequencyType,
          frequencyDays: _selectedDays,
          interval: _interval,
          reminderTimes: _reminderTimes,
          endDate: _endDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          imageUrl: imageUrl,
          maxDailyDoses: maxDaily,
          minIntervalMinutes: minInterval,
        );
        await ref
            .read(medicationRepositoryProvider)
            .updateMedication(updated);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Medication updated")));
        }
      } else {
        // 2b. Add new medication
        final newMed = Medication(
          id: '',
          userId: user.id,
          name: _nameController.text.trim(),
          dosage: double.parse(_dosageController.text),
          unit: _selectedUnit,
          type: _selectedType,
          color: colorHex,
          currentStock: int.parse(_stockController.text),
          refillThreshold: int.parse(_thresholdController.text),
          frequencyType: _frequencyType,
          frequencyDays: _selectedDays,
          interval: _interval,
          reminderTimes: _reminderTimes,
          startDate: DateTime.now(),
          endDate: _endDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          imageUrl: imageUrl,
          maxDailyDoses: maxDaily,
          minIntervalMinutes: minInterval,
        );
        await ref.read(medicationRepositoryProvider).addMedication(newMed);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Medication added")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.medication != null;
    return Scaffold(
      appBar: AppBar(
          title: Text(isEditing ? "Edit Medication" : "Add Medication")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Image Upload Section ---
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showImageSourceModal(context),
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover)
                              : null,
                        ),
                        child: _selectedImage == null
                            ? const Icon(Icons.add_a_photo,
                                size: 40, color: Colors.grey)
                            : null,
                      ),
                    ),
                    if (_selectedImage != null)
                      TextButton.icon(
                        onPressed: _clearImage,
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 20),
                        label: const Text("Remove Image",
                            style: TextStyle(color: Colors.red)),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text("Add Photo (Optional)",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Basic Info ---
              _buildSectionTitle("Basic Information"),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: "Medication Name",
                    prefixIcon: Icon(Icons.medication)),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _dosageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: "Dosage", prefixIcon: Icon(Icons.scale)),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(labelText: "Unit"),
                      items: ['mg', 'ml', 'pill', 'g', 'mcg', 'IU']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedUnit = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                    labelText: "Type", prefixIcon: Icon(Icons.category)),
                items: [
                  'Tablet',
                  'Capsule',
                  'Liquid',
                  'Injection',
                  'Cream',
                  'Drops',
                  'Inhaler'
                ]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),

              const SizedBox(height: 24),

              // --- Flexible Color Picker ---
              _buildSectionTitle("Appearance"),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Color Tag"),
                subtitle: const Text("Tap to pick a custom color"),
                leading: CircleAvatar(backgroundColor: _selectedColor),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Pick a color"),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: _selectedColor,
                          onColorChanged: (c) =>
                              setState(() => _selectedColor = c),
                          pickerAreaHeightPercent: 0.8,
                          enableAlpha: false,
                          displayThumbColor: true,
                          showLabel: true,
                          paletteType: PaletteType.hsvWithHue,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Select"),
                        )
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // --- Schedule ---
              _buildSectionTitle("Schedule"),
              DropdownButtonFormField<FrequencyType>(
                value: _frequencyType,
                decoration: const InputDecoration(
                    labelText: "Frequency",
                    prefixIcon: Icon(Icons.calendar_month)),
                items: FrequencyType.values
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child:
                            Text(e.toString().split('.').last.toUpperCase())))
                    .toList(),
                onChanged: (v) => setState(() => _frequencyType = v!),
              ),

              if (_frequencyType == FrequencyType.specificDays) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: _daysOfWeek.map((day) {
                    final isSelected = _selectedDays.contains(day);
                    return FilterChip(
                      label: Text(day),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                      onSelected: (selected) {
                        setState(() {
                          if (selected)
                            _selectedDays.add(day);
                          else
                            _selectedDays.remove(day);
                        });
                      },
                    );
                  }).toList(),
                )
              ],

              if (_frequencyType == FrequencyType.interval) ...[
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: "1",
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Every X Days",
                      helperText: "Example: 2 for every other day"),
                  onChanged: (v) =>
                      setState(() => _interval = int.tryParse(v) ?? 1),
                ),
              ],

              const SizedBox(height: 16),

              // Reminder Times
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Reminder Times",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.add_circle,
                          color: AppTheme.primaryColor)),
                ],
              ),
              Wrap(
                spacing: 8,
                children: _reminderTimes
                    .map((time) => Chip(
                          label: Text(time),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () =>
                              setState(() => _reminderTimes.remove(time)),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 16),

              // --- End Date (Optional) ---
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("End Date (Optional)"),
                subtitle: Text(_endDate == null
                    ? "No end date set"
                    : DateFormat('MMM dd, yyyy').format(_endDate!)),
                leading: const Icon(Icons.event_busy, color: Colors.grey),
                trailing: _endDate == null
                    ? const Icon(Icons.calendar_today)
                    : IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: () => setState(() => _endDate = null),
                      ),
                onTap: _pickEndDate,
              ),

              const SizedBox(height: 24),

              // --- Inventory ---
              _buildSectionTitle("Inventory Tracking"),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: "Current Stock"),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _thresholdController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: "Refill Warning"),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: "Notes (Optional)", alignLabelWithHint: true),
              ),

              const SizedBox(height: 24),

              // --- Overdose Warning ---
              _buildSectionTitle("Overdose Warning (Optional)"),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _maxDailyDosesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Max Daily Doses",
                        helperText: "e.g. 4",
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        if (int.tryParse(v.trim()) == null) {
                          return 'Enter a whole number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _minIntervalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Min Interval (min)",
                        helperText: "e.g. 240",
                        prefixIcon: Icon(Icons.timer),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        if (int.tryParse(v.trim()) == null) {
                          return 'Enter a whole number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // --- Save Button ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMedication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2)),
                            SizedBox(width: 10),
                            Text("Saving..."),
                          ],
                        )
                      : Text(isEditing ? "Update Medication" : "Save Medication",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helpers ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87)),
    );
  }

  void _showImageSourceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
