import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medication_reminder/features/medications/presentation/add_medication_screen.dart';
import '../../medications/data/medication_provider.dart';
import '../../medications/data/models/medication.dart';
import '../../doses/data/dose_repository.dart';
import '../../doses/data/dose_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationsAsync = ref.watch(medicationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: medicationsAsync.when(
          data: (medications) => RefreshIndicator(
            onRefresh: () async => ref.refresh(medicationsProvider),
            child: ListView(
              children: [
                Text(
                  "Today's Medications",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                if (medications.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Text(
                        "No medications scheduled for today.",
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                else
                  ...medications.map((m) => MedicationCard(
                        medication: m,
                        ref: ref,
                      )),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              "Error loading medications: $e",
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
        ),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final WidgetRef ref;

  const MedicationCard(
      {super.key, required this.medication, required this.ref});

  @override
  Widget build(BuildContext context) {
    final color = _parseColorTag(medication.colorTag ?? "#8BC34A");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(Icons.medication, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    medication.medicationName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    medication.active ? "Active" : "Inactive",
                    style: GoogleFonts.poppins(
                      color: color,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "${medication.dosageValue ?? ''} ${medication.dosageUnit ?? ''}  |  ${medication.form ?? '—'}",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    minimumSize: const Size(80, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final dose = Dose(
                        medicationId: medication.id!,
                        scheduledAt: DateTime.now(),
                      );

                      await DoseRepository().addDose(dose);
                      final doses = await DoseRepository()
                          .fetchDosesForMedication(medication.id!);
                      final latestDose = doses.last;

                      final needsRefill = await DoseRepository()
                          .markDoseTakenAndUpdateStock(
                              latestDose.id!, medication);

                      ref.refresh(medicationsProvider);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            needsRefill
                                ? 'Dose marked as taken ✅ Stock low! Please refill.'
                                : 'Dose marked as taken ✅',
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: const Text("Take"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    minimumSize: const Size(80, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      // Remove id assignment
                      final dose = Dose(
                        medicationId: medication.id!,
                        scheduledAt: DateTime.now(),
                      );

                      // Insert dose (Supabase will generate UUID automatically)
                      await DoseRepository().addDose(dose);

                      // You need to get the inserted dose's id to mark taken/missed
                      // Simplest: just update by filtering latest created dose for this medication
                      final doses = await DoseRepository()
                          .fetchDosesForMedication(medication.id!);
                      final latestDose = doses.last; // newest inserted
                      await DoseRepository().markDoseMissed(latestDose.id!);

                      ref.refresh(medicationsProvider);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dose marked as taken ✅')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: const Text("Skip"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColorTag(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return Colors.teal;
    }
  }
}
