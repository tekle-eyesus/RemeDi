import 'package:flutter/material.dart';
import 'package:medication_reminder/core/constants/app_constants.dart';

class AuthForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? displayNameController;
  final TextEditingController? confirmPasswordController; // Added this
  final bool isLoading;
  final String? error;
  final VoidCallback onSubmit;
  final String submitButtonText;
  final bool showDisplayName;
  final bool showConfirmPassword; // Added this

  const AuthForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    this.displayNameController,
    this.confirmPasswordController,
    required this.isLoading,
    this.error,
    required this.onSubmit,
    required this.submitButtonText,
    this.showDisplayName = false,
    this.showConfirmPassword = false,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          // Error Message
          if (widget.error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppConstants.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppConstants.errorColor.withOpacity(0.3)),
              ),
              child: Text(
                widget.error!,
                style: TextStyle(color: AppConstants.errorColor, fontSize: 14),
              ),
            ),
          ],

          // Display Name Field (Sign Up Only)
          if (widget.showDisplayName) ...[
            _buildTextField(
              controller: widget.displayNameController!,
              label: 'Name',
              icon: Icons.person_outline,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please enter your full name'
                  : null,
            ),
            const SizedBox(height: 16),
          ],

          // Email Field
          _buildTextField(
            controller: widget.emailController,
            label: 'Email',
            icon: Icons.mail_outline,
            inputType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Please enter your email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password Field
          _buildTextField(
            controller: widget.passwordController,
            label: 'Password',
            icon: Icons.lock_outline,
            isPassword: true,
            isObscured: _obscurePassword,
            onToggleVisibility: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Please enter your password';
              if (value.length < 6)
                return 'Password must be at least 6 characters';
              return null;
            },
          ),

          // Confirm Password Field (Sign Up Only)
          if (widget.showConfirmPassword &&
              widget.confirmPasswordController != null) ...[
            const SizedBox(height: 16),
            _buildTextField(
              controller: widget.confirmPasswordController!,
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              isPassword: true,
              isObscured: _obscureConfirmPassword,
              onToggleVisibility: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
              validator: (value) {
                if (value != widget.passwordController.text)
                  return 'Passwords do not match';
                return null;
              },
            ),
          ],

          const SizedBox(height: 10),

          // Remember Me & Forgot Password Row
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _rememberMe,
                  activeColor: AppConstants.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  onChanged: (value) => setState(() => _rememberMe = value!),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Remember me",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const Spacer(),
              if (!widget.showConfirmPassword) // Show only on Login
                GestureDetector(
                  onTap: () {
                    // Handle Forgot Password
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Pill shape
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      widget.submitButtonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for custom input styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? isObscured : false,
      keyboardType: inputType,
      style: const TextStyle(fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never, // Matches design
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey[500],
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.grey[50], // Very light grey background
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppConstants.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppConstants.errorColor),
        ),
      ),
    );
  }
}
