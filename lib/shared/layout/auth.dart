import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medication_reminder/features/authentication/presentation/screens/auth_screen.dart';
import 'package:medication_reminder/shared/layout/tab_screen.dart';

class AuthUser extends StatelessWidget {
  const AuthUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return TabScreen();
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
