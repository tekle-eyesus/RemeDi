// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../data/dose_repository.dart';
// import '../data/dose_model.dart';

// // final doseRepositoryProvider = Provider((ref) => DoseRepository());

// final dosesFutureProvider =
//     FutureProvider.family<List<Dose>, String>((ref, medicationId) async {
//   return ref.read(doseRepositoryProvider).fetchDosesForMedication(medicationId);
// });

// class DoseListScreen extends ConsumerWidget {
//   final String medicationId;
//   const DoseListScreen({super.key, required this.medicationId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final dosesAsync = ref.watch(dosesFutureProvider(medicationId));

//     return Scaffold(
//       appBar: AppBar(title: const Text("Medication Schedule")),
//       body: dosesAsync.when(
//         data: (doses) => ListView.builder(
//           itemCount: doses.length,
//           itemBuilder: (context, i) {
//             final d = doses[i];
//             return ListTile(
//               title: Text(
//                 TimeOfDay.fromDateTime(d.scheduledAt).format(context),
//                 style: TextStyle(
//                   color: d.status == 'taken'
//                       ? Colors.green
//                       : d.status == 'missed'
//                           ? Colors.red
//                           : Colors.black,
//                 ),
//               ),
//               subtitle: Text('Status: ${d.status}'),
//               trailing: d.status == 'upcoming'
//                   ? IconButton(
//                       icon: const Icon(Icons.check),
//                       onPressed: () async {
//                         await ref
//                             .read(doseRepositoryProvider)
//                             .markDoseTaken(d.id!);
//                         ref.invalidate(dosesFutureProvider(medicationId));
//                       },
//                     )
//                   : null,
//             );
//           },
//         ),
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, _) => Center(child: Text('Error: $e')),
//       ),
//     );
//   }
// }
