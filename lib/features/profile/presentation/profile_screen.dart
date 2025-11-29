import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medication_reminder/features/authentication/data/auth_service.dart';
import 'package:medication_reminder/features/authentication/presentation/widgets/custom_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.teal.shade100,
            child: Icon(Icons.person, color: Colors.teal.shade700, size: 50),
          ),
          const SizedBox(height: 16),
          Text(
            user?.email ?? "Unknown User",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade200,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              await AuthService().signOut();
              CustomSnackBar.show(context, message: "Logged out successfully");
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: Text(
              "Log Out",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
