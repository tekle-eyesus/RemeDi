import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medication_reminder/core/constants/app_constants.dart';
import 'package:medication_reminder/features/authentication/presentation/providers/auth_provider.dart';
import 'package:medication_reminder/features/authentication/presentation/widgets/custom_snackbar.dart';
import 'package:medication_reminder/features/profile/presentation/providers/profile_provider.dart';
import 'package:medication_reminder/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:medication_reminder/shared/providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileNotifierProvider);
    final user = profileState.user;

    return Scaffold(
      body: SafeArea(
        child: profileState.isLoading && user == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    // Avatar
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppConstants.primaryColor
                              .withValues(alpha: 0.15),
                          backgroundImage: user?.photoUrl != null
                              ? NetworkImage(user!.photoUrl!)
                              : null,
                          child: user?.photoUrl == null
                              ? Icon(
                                  Icons.person,
                                  color: AppConstants.primaryColor,
                                  size: 56,
                                )
                              : null,
                        ),
                        GestureDetector(
                          onTap: user == null
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditProfileScreen(user: user),
                                    ),
                                  );
                                },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Display name
                    Text(
                      user?.displayName?.isNotEmpty == true
                          ? user!.displayName!
                          : 'No Name Set',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Email
                    Text(
                      user?.email ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Edit Profile button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: user == null
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditProfileScreen(user: user),
                                  ),
                                );
                              },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppConstants.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: Icon(Icons.edit_outlined,
                            color: AppConstants.primaryColor),
                        label: Text(
                          'Edit Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Dark / Light mode toggle
                    const _DarkModeToggle(),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Profile details
                    _ProfileInfoCard(
                      items: [
                        _ProfileInfoItem(
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: user?.phoneNumber?.isNotEmpty == true
                              ? user!.phoneNumber!
                              : 'Not set',
                        ),
                        _ProfileInfoItem(
                          icon: Icons.cake_outlined,
                          label: 'Date of Birth',
                          value: user?.dateOfBirth != null
                              ? DateFormat.yMMMMd()
                                  .format(user!.dateOfBirth!)
                              : 'Not set',
                        ),
                        _ProfileInfoItem(
                          icon: Icons.info_outline,
                          label: 'Bio',
                          value: user?.bio?.isNotEmpty == true
                              ? user!.bio!
                              : 'Not set',
                        ),
                        if (user?.createdAt != null)
                          _ProfileInfoItem(
                            icon: Icons.calendar_today_outlined,
                            label: 'Member Since',
                            value: DateFormat.yMMMd()
                                .format(user!.createdAt!),
                          ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Sign Out button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.shade200,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await ref
                              .read(authNotifierProvider.notifier)
                              .signOut();
                          if (context.mounted) {
                            CustomSnackBar.show(context,
                                message: 'Logged out successfully');
                          }
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: Text(
                          'Log Out',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DarkModeToggle extends ConsumerWidget {
  const _DarkModeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final isDark = ref.watch(themeNotifierProvider) == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: SwitchListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Icon(
          isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
          color: AppConstants.primaryColor,
        ),
        title: Text(
          'Dark Mode',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        value: isDark,
        activeColor: AppConstants.primaryColor,
        onChanged: (_) => themeNotifier.toggleTheme(),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final List<_ProfileInfoItem> items;

  const _ProfileInfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items
            .asMap()
            .entries
            .map((entry) => Column(
                  children: [
                    entry.value,
                    if (entry.key < items.length - 1)
                      Divider(
                          height: 1,
                          indent: 56,
                          color: Theme.of(context).dividerColor),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppConstants.primaryColor, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: textTheme.bodyMedium?.color,
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

