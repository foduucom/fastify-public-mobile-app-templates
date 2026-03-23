library dynamic_theme;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants/dynamic_theme.dart' as themeExt;
import '/app/modules/auth/login/views/widgets/controller.dart';

class CreateAccountView extends GetView<CreateAccountController> {
  const CreateAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Dynamic scaffold background
      backgroundColor: context.backgroundColor,

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 12),

            /// 🔹 Skip Button
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: controller.skipLogin,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  // ✅ Dynamic button colors
                  decoration: BoxDecoration(
                    color: context.primaryColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      // ✅ Dynamic text color
                      color: context.onPrimaryColor,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// 🔹 Logo — with fallback
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  // ✅ Dynamic logo background
                  color: context.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      // ✅ Fallback icon if logo missing
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.storefront_rounded,
                        color: context.onPrimaryColor,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            /// 🔹 Title
            Text(
              'Create Account',
              // ✅ Dynamic title styling
              style: context.textTheme.headlineLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: context.onSurfaceColor,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Sign up to get started',
              // ✅ Dynamic subtitle
              style: context.textTheme.bodyLarge?.copyWith(
                fontSize: 15,
                color: context.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 32),

            /// 🔹 Email
            _buildLabel(context, 'Email Address'),
            const SizedBox(height: 10),
            TextFormField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              validator: controller.validEmail,
              // ✅ Dynamic text color
              style: TextStyle(color: context.onSurfaceColor),
              decoration: _inputDecoration(context, 'Enter your email'),
            ),

            const SizedBox(height: 24),

            /// 🔹 Password
            _buildLabel(context, 'Password'),
            const SizedBox(height: 10),
            Obx(() => TextFormField(
              controller: controller.passwordController,
              obscureText: controller.obscureText.value,
              validator: controller.validPassword,
              style: TextStyle(color: context.onSurfaceColor),
              decoration: _inputDecoration(context, 'Enter your password')
                  .copyWith(
                suffixIcon: GestureDetector(
                  onTap: controller.togglePassword,
                  child: Icon(
                    controller.obscureText.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 20,
                    // ✅ Dynamic icon color
                    color: context.onSurfaceVariant,
                  ),
                ),
              ),
            )),

            const SizedBox(height: 32),

            /// 🔹 Submit Button
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.onSubmit,
                // ✅ Dynamic button styling
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: context.onPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    // ✅ Dynamic loader color
                    color: context.onPrimaryColor,
                  ),
                )
                    : Text(
                  'Continue',
                  // ✅ Dynamic button text
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.onPrimaryColor,
                  ),
                ),
              ),
            )),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 🔹 Dynamic Label Widget
  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: context.textTheme.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: context.onSurfaceColor,
      ),
    );
  }

  /// 🔹 Dynamic Input Decoration
  InputDecoration _inputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: context.textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        color: context.onSurfaceVariant,
      ),
      filled: true,
      // ✅ Dynamic field background
      fillColor: context.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(
          color: context.primaryColor,
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(color: context.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(
          color: context.errorColor,
          width: 1.2,
        ),
      ),
    );
  }
}
