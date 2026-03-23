import 'package:flutter/material.dart';
import 'package:foddu/app_colors.dart';
import 'package:get/get.dart';

import '../../../../../components/app_bar/custom_app_bar.dart';
import '../../../../../components/app_bar/custom_app_bar2.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();

  int _selectedTab = 0;
  final _oldPasswordCtrl     = TextEditingController();
  final _newPasswordCtrl     = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _oldVisible     = false;
  bool _newVisible     = false;
  bool _confirmVisible = false;

  bool get _hasInput =>
      _oldPasswordCtrl.text.isNotEmpty &&
          _newPasswordCtrl.text.isNotEmpty &&
          _confirmPasswordCtrl.text.isNotEmpty;

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEECE8),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Top Bar ─────────────────────────────────────────
            AppTopBar(title: 'change password',),
            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  onChanged: () => setState(() {}),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Show fields based on tab ───────────
                      if (_selectedTab == 0) ...[
                        _FieldLabel(label: 'Old password'),
                        const SizedBox(height: 10),
                        _PasswordField(
                          controller: _oldPasswordCtrl,
                          hint: 'Enter your old password',
                          isVisible: _oldVisible,
                          onToggle: () =>
                              setState(() => _oldVisible = !_oldVisible),
                        ),
                        const SizedBox(height: 20),

                        _FieldLabel(label: 'New password'),
                        const SizedBox(height: 10),
                        _PasswordField(
                          controller: _newPasswordCtrl,
                          hint: 'Enter your new password',
                          isVisible: _newVisible,
                          onToggle: () =>
                              setState(() => _newVisible = !_newVisible),
                        ),
                        const SizedBox(height: 20),

                        _FieldLabel(label: 'Confirm password'),
                        const SizedBox(height: 10),
                        _PasswordField(
                          controller: _confirmPasswordCtrl,
                          hint: 'Enter your confirm password',
                          isVisible: _confirmVisible,
                          onToggle: () => setState(
                                  () => _confirmVisible = !_confirmVisible),
                        ),
                      ] else ...[

                        // ── Security Tab Placeholder ───────────
                        const SizedBox(height: 40),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.security_outlined,
                                  size: 36,
                                  color: Color(0xFF9E9E9E),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Security settings\ncoming soon',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF9E9E9E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _hasInput ? _onUpdate : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _hasInput
                ? const Color(0xFF1A1A1A)
                : const Color(0xFFD0CFC9),
            foregroundColor: AppColors.scaffoldBackground,
            disabledBackgroundColor: const Color(0xFFD0CFC9),
            disabledForegroundColor: AppColors.scaffoldBackground,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: const Text(
            'Update',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _onUpdate() {
    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      Get.snackbar(
        'Error',
        'New password and confirm password do not match!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    Get.snackbar(
      'Success',
      'Password updated successfully!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1A1A1A),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A1A),
      ),
    );
  }
}

// ── Password Field ─────────────────────────────────────────────────
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isVisible;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.isVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1A1A1A),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 15,
            color: Color(0xFFB0AEAB),
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
          // ✅ Eye toggle icon
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                isVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFFB0AEAB),
                size: 20,
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 48),
        ),
      ),
    );
  }
}
