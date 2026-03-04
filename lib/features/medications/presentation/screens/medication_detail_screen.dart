import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medication_reminder/features/medications/data/medication_repository.dart';
import 'package:medication_reminder/features/medications/domain/entities/medication.dart';
import 'package:medication_reminder/features/medications/presentation/screens/add_medication_screen.dart';
import 'package:medication_reminder/shared/styles/theme.dart';

class MedicationDetailScreen extends ConsumerWidget {
  final Medication medication;

  const MedicationDetailScreen({super.key, required this.medication});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color =
        Color(int.parse(medication.color.replaceAll('#', '0xff')));
    final isLowStock = medication.currentStock <= medication.refillThreshold &&
        medication.refillThreshold > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          medication.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddMedicationScreen(medication: medication),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card with medication image / color
            _HeaderCard(medication: medication, color: color),

            const SizedBox(height: 20),

            // Low stock warning
            if (isLowStock)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.orange),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Stock is low (${medication.currentStock} remaining). '
                        'Please refill soon.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Details sections
            _SectionCard(
              title: 'Dosage & Type',
              children: [
                _DetailRow(
                  icon: Icons.medication_outlined,
                  label: 'Dosage',
                  value: '${medication.dosage} ${medication.unit}',
                ),
                _DetailRow(
                  icon: Icons.category_outlined,
                  label: 'Type',
                  value: medication.type,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _SectionCard(
              title: 'Schedule',
              children: [
                _DetailRow(
                  icon: Icons.repeat,
                  label: 'Frequency',
                  value: _formatFrequency(medication),
                ),
                _DetailRow(
                  icon: Icons.alarm,
                  label: 'Reminder Times',
                  value: medication.reminderTimes.isEmpty
                      ? 'None'
                      : medication.reminderTimes.join(', '),
                ),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Start Date',
                  value: DateFormat.yMMMMd().format(medication.startDate),
                ),
                if (medication.endDate != null)
                  _DetailRow(
                    icon: Icons.event_busy_outlined,
                    label: 'End Date',
                    value: DateFormat.yMMMMd().format(medication.endDate!),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            _SectionCard(
              title: 'Stock',
              children: [
                _DetailRow(
                  icon: Icons.inventory_2_outlined,
                  label: 'Current Stock',
                  value: '${medication.currentStock} units',
                ),
                _DetailRow(
                  icon: Icons.notifications_active_outlined,
                  label: 'Refill Alert Threshold',
                  value: medication.refillThreshold > 0
                      ? '${medication.refillThreshold} units'
                      : 'Not set',
                ),
              ],
            ),

            if (medication.maxDailyDoses != null ||
                medication.minIntervalMinutes != null) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Overdose Safety',
                children: [
                  if (medication.maxDailyDoses != null)
                    _DetailRow(
                      icon: Icons.shield_outlined,
                      label: 'Max Daily Doses',
                      value: '${medication.maxDailyDoses}',
                    ),
                  if (medication.minIntervalMinutes != null)
                    _DetailRow(
                      icon: Icons.timer_outlined,
                      label: 'Min. Interval Between Doses',
                      value: '${medication.minIntervalMinutes} min',
                    ),
                ],
              ),
            ],

            if (medication.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Notes',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Text(
                      medication.notes!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddMedicationScreen(medication: medication),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.white),
                    label: const Text('Delete',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.shade200,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatFrequency(Medication med) {
    switch (med.frequencyType) {
      case FrequencyType.daily:
        return 'Every day';
      case FrequencyType.specificDays:
        return med.frequencyDays.isEmpty
            ? 'Specific days'
            : med.frequencyDays.join(', ');
      case FrequencyType.interval:
        return 'Every ${med.interval} day${med.interval == 1 ? '' : 's'}';
      case FrequencyType.asNeeded:
        return 'As needed (PRN)';
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Medication'),
        content:
            Text('Remove "${medication.name}" and cancel all reminders?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // close dialog
              try {
                await ref
                    .read(medicationRepositoryProvider)
                    .deleteMedication(medication.id, medication);
                if (context.mounted) {
                  Navigator.pop(context); // go back to list
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${medication.name} deleted')),
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

// ── Header card ──────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final Medication medication;
  final Color color;

  const _HeaderCard({required this.medication, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Medication image or color avatar
          medication.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    medication.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _ColorAvatar(color: color),
                  ),
                )
              : _ColorAvatar(color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${medication.dosage} ${medication.unit} · ${medication.type}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      medication.color.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorAvatar extends StatelessWidget {
  final Color color;
  const _ColorAvatar({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: FaIcon(FontAwesomeIcons.pills, color: color, size: 36),
      ),
    );
  }
}

// ── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          ...children,
        ],
      ),
    );
  }
}

// ── Detail row ───────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
