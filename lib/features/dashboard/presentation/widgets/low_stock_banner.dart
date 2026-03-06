import 'package:flutter/material.dart';
import 'package:medication_reminder/features/medications/domain/entities/medication.dart';

class LowStockBanner extends StatelessWidget {
  final List<Medication> meds;
  const LowStockBanner({required this.meds, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Low stock: ${meds.map((m) => m.name).join(', ')}',
              style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
