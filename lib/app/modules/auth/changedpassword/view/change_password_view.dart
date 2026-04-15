// lib/app/modules/auth/resetpassword/views/resetpassword_view.dart

import 'package:flutter/material.dart';
import '../../../../../components/app_back_button.dart';
import '../../../../../components/app_bar.dart';
import '../controller/change_password.dart';
import 'package:get/get.dart';

class ResetpasswordView extends GetView<ResetpasswordController> {
  const ResetpasswordView({Key? key}) : super(key: key);

  @override
  ResetpasswordController get controller => Get.put(ResetpasswordController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ── AppBar ──────────────────────────────────────────────────────
      appBar: CustomAppBar(title: 'Change Password'),

      // ── Submit Button pinned at bottom ──────────────────────────────
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }
          return SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                controller.resetPassword();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                'Submit',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }),
      ),

      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 24),

                // ── Subtitle ─────────────────────────────────────────
                Text(
                  'The new password must be different\nfrom the current password',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Password Label ────────────────────────────────────
                Text(
                  'Password',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Password Field ────────────────────────────────────
                Obx(() => _PasswordField(
                  controller: controller.newPasswordController,
                  hint: 'Enter your password',
                  obscure: controller.obscureNew.value,
                  onToggle: () => controller.obscureNew.toggle(),
                  validator: (v) {
                    if (v == null || v.isEmpty || v.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                )),

                const SizedBox(height: 16),

                // ── Live Password Rules ───────────────────────────────
                // ✅ Use controller.passwordText.value — this is reactive
                Obx(() {
                  final pwd        = controller.passwordText.value;
                  final hasLength  = pwd.length >= 8;
                  final hasSpecial = RegExp(r'[!@#\$%^&*]').hasMatch(pwd);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PasswordRule(
                        met:   hasLength,
                        text:  'There must be at least 8 characters',
                      ),
                      const SizedBox(height: 6),
                      _PasswordRule(
                        met:   hasSpecial,
                        text:  'There must be a unique code like @!#',
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 24),

                // ── Confirm Password Label ────────────────────────────
                Text(
                  'Confirm Password',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Confirm Password Field ────────────────────────────
                Obx(() => _PasswordField(
                  controller: controller.confirmPasswordController,
                  hint: 'Enter your password',
                  obscure: controller.obscureConfirm.value,
                  onToggle: () => controller.obscureConfirm.toggle(),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (v != controller.newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                )),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Password Field with Eye Toggle ───────────────────────────────────────────
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.remove_red_eye_outlined,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
    );
  }
}

// ── Password Rule Row ─────────────────────────────────────────────────────────
class _PasswordRule extends StatelessWidget {
  final bool met;
  final String text;

  const _PasswordRule({
    required this.met,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          Icons.check,
          size: 16,
          color: met ? colorScheme.primary : colorScheme.outline,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: met ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}