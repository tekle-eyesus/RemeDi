import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:medication_reminder/features/medications/domain/entities/medication.dart';
import 'package:medication_reminder/features/medications/presentation/models/medication_form.dart';
import 'package:medication_reminder/features/medications/presentation/widgets/form_section.dart';
import 'package:medication_reminder/shared/styles/theme.dart';
import '../providers/medication_provider.dart';
import '../widgets/time_picker_chip.dart';
import '../../../../features/authentication/presentation/providers/auth_provider.dart';

class AddEditMedicationScreen extends ConsumerStatefulWidget {
  final String? medicationId;

  const AddEditMedicationScreen({super.key, this.medicationId});

  @override
  ConsumerState<AddEditMedicationScreen> createState() =>
      _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState
    extends ConsumerState<AddEditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late MedicationFormState _formState;
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _initialStockController = TextEditingController();
  final _refillThresholdController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _dosageUnits = [
    'mg',
    'g',
    'ml',
    'pills',
    'drops',
    'IU',
    'mcg'
  ];
  final List<String> _forms = [
    'Tablet',
    'Capsule',
    'Liquid',
    'Injection',
    'Cream',
    'Ointment',
    'Inhaler',
    'Drops'
  ];

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<bool> _selectedDays = List.filled(7, false);

  bool _isEditing = false;
  Medication? _existingMedication;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.medicationId != null;
    _initializeForm();
  }

  void _initializeForm() {
    if (_isEditing) {
      // Load existing medication
      final medications = ref.read(medicationListProvider).medications;
      _existingMedication = medications.firstWhere(
        (m) => m.id == widget.medicationId,
        orElse: () => Medication.empty(),
      );

      if (_existingMedication!.isNotEmpty) {
        _nameController.text = _existingMedication!.name;
        _dosageController.text = _existingMedication!.dosageValue.toString();
        _initialStockController.text =
            _existingMedication!.currentStock.toString();
        _refillThresholdController.text =
            _existingMedication!.refillThreshold.toString();
        _notesController.text = _existingMedication!.notes ?? '';

        _selectedDays = List.generate(7, (index) {
          if (_existingMedication!.frequency.type ==
              FrequencyType.specificDays) {
            final days = _existingMedication!.frequency.value as List<String>;
            return days
                .contains(_daysOfWeek[index].substring(0, 3).toLowerCase());
          }
          return false;
        });
        _formState = MedicationFormState(
          name: MedicationName(value: _existingMedication!.name),
          dosageValue:
              DosageValue(value: _existingMedication!.dosageValue.toString()),
          dosageUnit: DosageUnit(value: _existingMedication!.dosageUnit),
          form: _existingMedication!.form, // Changed from FormzInput.dirty
          frequencyType: _existingMedication!.frequency.type,
          frequencyValue: _existingMedication!.frequency.value,
          timesOfDay: _existingMedication!.timesOfDay,
          startDate: _existingMedication!.startDate,
          endDate: _existingMedication!.endDate,
          initialStock:
              InitialStock(value: _existingMedication!.currentStock.toString()),
          refillThreshold: RefillThreshold(
              value: _existingMedication!.refillThreshold.toString()),
          colorTag: _existingMedication!.colorTag,
          notes: _existingMedication!.notes,
          imageUrl: _existingMedication!.imageUrl,
          isActive: _existingMedication!.isActive,
        );
        // _formState = MedicationFormState(
        //   name: MedicationName.dirty(_existingMedication!.name),
        //   dosageValue:
        //       DosageValue.dirty(_existingMedication!.dosageValue.toString()),
        //   dosageUnit: DosageUnit.dirty(_existingMedication!.dosageUnit),
        //   form: FormzInput.dirty(_existingMedication!.form),
        //   frequencyType: _existingMedication!.frequency.type,
        //   frequencyValue: _existingMedication!.frequency.value,
        //   timesOfDay: _existingMedication!.timesOfDay,
        //   startDate: _existingMedication!.startDate,
        //   endDate: _existingMedication!.endDate,
        //   initialStock:
        //       InitialStock.dirty(_existingMedication!.currentStock.toString()),
        //   refillThreshold: RefillThreshold.dirty(
        //       _existingMedication!.refillThreshold.toString()),
        //   colorTag: _existingMedication!.colorTag,
        //   notes: _existingMedication!.notes,
        //   imageUrl: _existingMedication!.imageUrl,
        //   isActive: _existingMedication!.isActive,
        // );
      }
    } else {
      _formState = MedicationFormState();
      _initialStockController.text = '30';
      _refillThresholdController.text = '5';
    }
  }

  void _updateFormState(Function(MedicationFormState) update) {
    setState(() {
      _formState = update(_formState);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // TODO: Upload image to Firebase Storage
      _updateFormState((state) => state.copyWith(imageUrl: pickedFile.path));
    }
  }

  Future<void> _showColorPicker() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: Color(
                  int.parse(_formState.colorTag.replaceFirst('#', '0xff'))),
              onColorChanged: (color) {
                _updateFormState((state) => state.copyWith(
                      colorTag:
                          '#${color.value.toRadixString(16).substring(2)}',
                    ));
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
              hexInputBar: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      _updateFormState((state) {
        final times = List<TimeOfDay>.from(state.timesOfDay);
        if (!times.any((time) =>
            time.hour == pickedTime.hour && time.minute == pickedTime.minute)) {
          times.add(pickedTime);
          times.sort((a, b) {
            if (a.hour == b.hour) return a.minute.compareTo(b.minute);
            return a.hour.compareTo(b.hour);
          });
        }
        return state.copyWith(timesOfDay: times);
      });
    }
  }

  void _removeTime(TimeOfDay time) {
    _updateFormState((state) {
      final times = List<TimeOfDay>.from(state.timesOfDay);
      times.removeWhere((t) => t.hour == time.hour && t.minute == time.minute);
      return state.copyWith(timesOfDay: times);
    });
  }

  Future<void> _showStartDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _formState.startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      _updateFormState((state) => state.copyWith(startDate: pickedDate));
    }
  }

  Future<void> _showEndDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          _formState.endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: _formState.startDate,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      _updateFormState((state) => state.copyWith(endDate: pickedDate));
    }
  }

  void _removeEndDate() {
    _updateFormState((state) => state.copyWith(endDate: null));
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = ref.read(authNotifierProvider).user;
      if (user == null || user.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
        return;
      }

      final medication = _formState.toMedication(user.id);

      if (_isEditing && _existingMedication != null) {
        final updatedMedication = _existingMedication!.copyWith(
          name: medication.name,
          dosageValue: medication.dosageValue,
          dosageUnit: medication.dosageUnit,
          form: medication.form,
          frequency: medication.frequency,
          timesOfDay: medication.timesOfDay,
          startDate: medication.startDate,
          endDate: medication.endDate,
          currentStock: int.parse(_initialStockController.text),
          refillThreshold: medication.refillThreshold,
          colorTag: medication.colorTag,
          notes: medication.notes,
          imageUrl: medication.imageUrl,
          isActive: medication.isActive,
          updatedAt: DateTime.now(),
        );

        final result = await ref
            .read(medicationListProvider.notifier)
            .updateMedication(updatedMedication);

        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update: ${failure.message}')),
          ),
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Medication updated successfully')),
            );
            context.pop();
          },
        );
      } else {
        final result = await ref
            .read(medicationListProvider.notifier)
            .addMedication(medication);

        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add: ${failure.message}')),
          ),
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Medication added successfully')),
            );
            context.pop();
          },
        );
      }
    }
  }

  void _deleteMedication() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: const Text('Are you sure you want to delete this medication?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await ref
                  .read(medicationListProvider.notifier)
                  .deleteMedication(widget.medicationId!);

              result.fold(
                (failure) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Failed to delete: ${failure.message}')),
                ),
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Medication deleted')),
                  );
                  context.pop();
                },
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Medication' : 'Add Medication'),
        centerTitle: true,
        actions: _isEditing
            ? [
                IconButton(
                  onPressed: _deleteMedication,
                  icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload
              _buildImageUploadSection(),

              const SizedBox(height: 24),

              // Basic Information
              FormSection(
                title: 'Basic Information',
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Medication Name *',
                      prefixIcon: Icon(Icons.medication_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter medication name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _updateFormState((state) => state.copyWith(
                            form: value ?? 'Tablet',
                          ));
                    },
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
                            labelText: 'Dosage *',
                            prefixIcon: Icon(Icons.exposure),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter dosage';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _formState.dosageUnit.value,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(),
                          ),
                          items: _dosageUnits.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (value) {
                            _updateFormState((state) => state.copyWith(
                                  form: value ??
                                      'Tablet', // Changed from FormzInput.dirty
                                ));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _forms.first,
                    decoration: const InputDecoration(
                      labelText: 'Form *',
                      prefixIcon: Icon(Icons.shape_line_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _forms.map((form) {
                      return DropdownMenuItem(
                        value: form,
                        child: Text(form),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _updateFormState((state) => state.copyWith(
                            form: value ??
                                'Tablet', // Changed from FormzInput.dirty
                          ));
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Color Tag
              FormSection(
                title: 'Color Tag',
                children: [
                  GestureDetector(
                    onTap: _showColorPicker,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(int.parse(
                            _formState.colorTag.replaceFirst('#', '0xff'))),
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadius),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.color_lens, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            _formState.colorTag.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Schedule
              _buildScheduleSection(),

              const SizedBox(height: 24),

              // Stock Information
              FormSection(
                title: 'Stock Information',
                children: [
                  TextFormField(
                    controller: _initialStockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Initial Stock *',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                      border: OutlineInputBorder(),
                      helperText: 'How many pills/units do you have now?',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter initial stock';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _refillThresholdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Refill Threshold *',
                      prefixIcon: Icon(Icons.notifications_active_outlined),
                      border: OutlineInputBorder(),
                      helperText: 'Get notified when stock reaches this level',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter refill threshold';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Additional Information
              FormSection(
                title: 'Additional Information',
                children: [
                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Notes & Instructions',
                      border: OutlineInputBorder(),
                      helperText: 'E.g., Take with food, Avoid alcohol, etc.',
                    ),
                    onChanged: (value) {
                      _updateFormState((state) => state.copyWith(notes: value));
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadius),
                    ),
                    elevation: AppTheme.elevation,
                  ),
                  child: Text(
                    _isEditing ? 'Update Medication' : 'Add Medication',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(
            color: AppTheme.divider,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: _formState.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                child: Image.network(
                  _formState.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagePlaceholder();
                  },
                ),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.camera_alt_outlined,
          size: 48,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to upload medication image',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '(Optional)',
          style: TextStyle(
            color: AppTheme.textDisabled,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return FormSection(
      title: 'Schedule',
      children: [
        // Frequency
        DropdownButtonFormField<FrequencyType>(
          value: _formState.frequencyType,
          decoration: const InputDecoration(
            labelText: 'Frequency *',
            prefixIcon: Icon(Icons.calendar_today_outlined),
            border: OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: FrequencyType.daily,
              child: const Text('Daily'),
            ),
            DropdownMenuItem(
              value: FrequencyType.specificDays,
              child: const Text('Specific Days'),
            ),
            DropdownMenuItem(
              value: FrequencyType.interval,
              child: const Text('Every X Days'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              dynamic newValue;
              if (value == FrequencyType.daily) {
                newValue = null;
              } else if (value == FrequencyType.specificDays) {
                newValue = [];
              } else {
                newValue = 2;
              }

              _updateFormState((state) => state.copyWith(
                    frequencyType: value,
                    frequencyValue: newValue,
                  ));
            }
          },
        ),

        const SizedBox(height: 16),

        // Specific Days or Interval Input
        if (_formState.frequencyType == FrequencyType.specificDays)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Days',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (index) {
                  return FilterChip(
                    label: Text(_daysOfWeek[index]),
                    selected: _selectedDays[index],
                    onSelected: (selected) {
                      setState(() {
                        _selectedDays[index] = selected;

                        final selectedDays = <String>[];
                        for (var i = 0; i < _selectedDays.length; i++) {
                          if (_selectedDays[i]) {
                            selectedDays.add(
                                _daysOfWeek[i].substring(0, 3).toLowerCase());
                          }
                        }

                        _updateFormState((state) => state.copyWith(
                              frequencyValue: selectedDays,
                            ));
                      });
                    },
                    backgroundColor: AppTheme.surface,
                    selectedColor: AppTheme.primaryLight,
                    labelStyle: TextStyle(
                      color: _selectedDays[index]
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusSmall),
                      side: BorderSide(
                        color: _selectedDays[index]
                            ? AppTheme.primary
                            : AppTheme.divider,
                      ),
                    ),
                  );
                }),
              ),
            ],
          )
        else if (_formState.frequencyType == FrequencyType.interval)
          TextFormField(
            initialValue: (_formState.frequencyValue ?? 2).toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Interval (in days)',
              prefixIcon: Icon(Icons.repeat_outlined),
              border: OutlineInputBorder(),
              helperText: 'Every how many days?',
            ),
            onChanged: (value) {
              final interval = int.tryParse(value);
              if (interval != null && interval > 0) {
                _updateFormState((state) => state.copyWith(
                      frequencyValue: interval,
                    ));
              }
            },
          ),

        const SizedBox(height: 16),

        // Times of Day
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Times of Day *',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _addTime,
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppTheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_formState.timesOfDay.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Center(
                  child: Text(
                    'No times added. Tap + to add a time.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _formState.timesOfDay.map((time) {
                  return TimePickerChip(
                    time: time,
                    onDelete: () => _removeTime(time),
                  );
                }).toList(),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Start and End Dates
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Date',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showStartDatePicker,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusSmall),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 12),
                          Text(
                            '${_formState.startDate.day}/${_formState.startDate.month}/${_formState.startDate.year}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'End Date',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(Optional)',
                        style: TextStyle(
                          color: AppTheme.textDisabled,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showEndDatePicker,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusSmall),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: _formState.endDate != null
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _formState.endDate != null
                                  ? '${_formState.endDate!.day}/${_formState.endDate!.month}/${_formState.endDate!.year}'
                                  : 'No end date',
                              style: TextStyle(
                                fontSize: 14,
                                color: _formState.endDate != null
                                    ? AppTheme.textPrimary
                                    : AppTheme.textSecondary,
                                fontStyle: _formState.endDate == null
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ),
                          ),
                          if (_formState.endDate != null)
                            GestureDetector(
                              onTap: _removeEndDate,
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
