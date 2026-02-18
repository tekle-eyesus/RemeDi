import 'package:flutter/material.dart';
import 'package:medication_reminder/features/authentication/presentation/screens/login_screen.dart';
import 'package:medication_reminder/features/authentication/presentation/screens/signup_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // toggle between login and signup
  bool _isLogin = true;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLogin) {
      return LoginScreen(ontoggleAuthMode: _toggleAuthMode);
    } else {
      return SignUpScreen(ontoggleAuthMode: _toggleAuthMode);
    }
  }
}
