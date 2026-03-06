import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medication_reminder/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:medication_reminder/features/history/domain/entities/dose_log.dart';

class DoseTile extends StatelessWidget {
  final ScheduledDose dose;
  final VoidCallback onTap;
  const DoseTile({required this.dose, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final med = dose.medication;
    final color = Color(int.parse(med.color.replaceAll('#', '0xff')));

    Color statusColor;
    IconData statusIcon;
    switch (dose.status) {
      case DoseStatus.taken:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case DoseStatus.missed:
        statusColor = Colors.red;
        statusIcon = Icons.warning_rounded;
        break;
      case DoseStatus.skipped:
        statusColor = Colors.orange;
        statusIcon = Icons.do_not_disturb_on;
        break;
      case DoseStatus.upcoming:
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: FaIcon(FontAwesomeIcons.pills, color: color, size: 18),
        ),
        title:
            Text(med.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${med.dosage}${med.unit} · ${dose.formattedTime}'
            '${dose.notes != null ? ' · ${dose.notes}' : ''}'),
        trailing: Icon(statusIcon, color: statusColor),
      ),
    );
  }
}
