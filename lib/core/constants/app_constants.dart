import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Medication Reminder';

  // Color palette (avoiding purple)
  static const Color primaryColor = Color(0xFF781E14); // Blue
  static const Color secondaryColor = Color(0xFF4CAF50); // Green
  static const Color accentColor = Color(0xFFFF9800); // Orange
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFF44336);
  static const Color textColor = Color(0xFF333333);

  // Time constants
  static const Duration notificationLeadTime = Duration(minutes: 15);

  // Firestore collections
  static const String usersCollection = 'users';
  static const String medicationsCollection = 'medications';
  static const String dosesCollection = 'doses';
  static const String settingsCollection = 'settings';
}
