import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medication_reminder/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:medication_reminder/features/history/presentation/screens/history_calendar_screen.dart';
import 'package:medication_reminder/features/medications/presentation/screens/medication_list_screen.dart';
import 'package:medication_reminder/features/profile/presentation/profile_screen.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int _currentIndex = 0;

  // List of screens for each tab
  final List<Widget> _screens = [
    DashboardScreen(),
    HistoryCalendarScreen(),
    MedicationListScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const unselectedItemColor = Colors.grey;
    final backgroundColor = isDarkMode
        ? const Color(0xFF000000)
        : const Color(
            0xFFFFFFFF,
          );
    final selectedItemColor = isDarkMode
        ? const Color(0xFFFFFFFF)
        : const Color(
            0xFF0F1419,
          );

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: backgroundColor,
          selectedItemColor: selectedItemColor,
          unselectedItemColor: unselectedItemColor,
          showSelectedLabels: false, // X style: hide labels
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.house, size: 24),
              activeIcon: FaIcon(FontAwesomeIcons.house, size: 24),
              label: 'Home',
              tooltip: 'Home',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.history, size: 24),
              activeIcon: FaIcon(FontAwesomeIcons.history, size: 24),
              label: 'history',
              tooltip: 'History',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.kitMedical, size: 24),
              activeIcon: FaIcon(FontAwesomeIcons.kitMedical, size: 24),
              label: 'Medications',
              tooltip: 'Medications',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.user, size: 24),
              activeIcon: FaIcon(FontAwesomeIcons.solidUser, size: 24),
              label: 'Profile',
              tooltip: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
