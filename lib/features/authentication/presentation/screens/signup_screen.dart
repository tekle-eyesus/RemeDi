import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medication_reminder/core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  final Function() ontoggleAuthMode;
  const SignUpScreen({super.key, required this.ontoggleAuthMode});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController(); // Added controller
  final _displayNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _confirmPasswordController.dispose(); // Dispose new controller
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Extra validation check just in case
      if (_passwordController.text != _confirmPasswordController.text) {
        return;
      }

      ref.read(authNotifierProvider.notifier).signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _displayNameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    if (authState.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Logo
              Center(
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/icon/icon.png',
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Text(
                'Create an account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up minutes to connect',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 40),

              // Sign Up Form
              AuthForm(
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                displayNameController: _displayNameController,
                confirmPasswordController:
                    _confirmPasswordController, // Pass controller
                isLoading: authState.isLoading,
                error: authState.error?.message,
                onSubmit: _submit,
                submitButtonText: 'Sign Up',
                showDisplayName: true,
                showConfirmPassword: true, // Enable confirm password field
              ),

              const SizedBox(height: 30),

              // Or divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Or log in with',
                        style: TextStyle(color: Colors.grey[500])),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 24),

              // Social Buttons
              Row(
                children: [
                  Expanded(
                      child: _buildSocialButton(
                          label: 'Google', icon: Icons.g_mobiledata)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildSocialButton(
                          label: 'Apple', icon: Icons.apple)),
                ],
              ),

              const SizedBox(height: 40),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have a account?',
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.ontoggleAuthMode,
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Duplicating the helper widget here for the register screen
  // Ideally, move this to a shared 'widgets/social_button.dart' file
  Widget _buildSocialButton({required String label, required IconData icon}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
