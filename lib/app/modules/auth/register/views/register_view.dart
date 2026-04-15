// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../../../../components/app_back_button.dart';
import '../../otp/view/otp_view.dart';
import '/app/routes/app_pages.dart';
import '/components/buttons/appbutton.dart';

import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ── AppBar ──────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: AppBackButton(),
        ),
        centerTitle: true,
        title: Text(
          'Sign Up',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),

              // ── Headline ───────────────────────────────────────────
              Text(
                'Complet your account',
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lorem ipsum dolor sit amet',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 32),

              // ── Form ───────────────────────────────────────────────
              Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── First Name ─────────────────────────────────
                    _FieldLabel('First Name', textTheme),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: controller.nameController,
                      hint: 'Enter your email address',
                      keyType: TextInputType.name,
                      validator: (v) {
                        if (v == null || v.trim().length < 2) {
                          return 'Enter valid first name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Last Name ──────────────────────────────────
                    _FieldLabel('Last Name', textTheme),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: controller.mobileController,
                      hint: 'Enter your name',
                      keyType: TextInputType.name,
                    ),

                    const SizedBox(height: 20),

                    // ── E-mail ─────────────────────────────────────
                    _FieldLabel('E-mail', textTheme),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: controller.emailController,
                      hint: 'Enter your email',
                      keyType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email required';
                        if (!GetUtils.isEmail(v)) return 'Enter valid email';
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Password ───────────────────────────────────
                    _FieldLabel('Password', textTheme),
                    const SizedBox(height: 8),
                    _PasswordField(
                      controller: controller.passwordController,
                      hint: 'Enter your password',
                      validator: (v) {
                        if (v == null || v.length < 6) {
                          return 'Password must be 6+ characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Confirm Password ───────────────────────────
                    _FieldLabel('Confirm Password', textTheme),
                    const SizedBox(height: 8),
                    _PasswordField(
                      controller: controller.confirmPasswordController,
                      hint: 'Enter your password',
                      validator: (v) {
                        if (v != controller.passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),
// ── Sign Up Button ─────────────────────────────────────────────
                    Obx(() {
                      if (controller.isLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                              color: colorScheme.primary),
                        );
                      }
                      return SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            HelperFunctions().closeKeyboard(context);
                            // ✅ onSubmit() already navigates to OTP or LOGIN internally
                            // ❌ REMOVED: Navigator.push to OTPView — was causing double navigation
                            controller.onSubmit();
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
                            'Sign Up',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }),
                    // ── Sign Up Button ─────────────────────────────
                    // Obx(() {
                    //   if (controller.isLoading.value) {
                    //     return Center(
                    //       child: CircularProgressIndicator(
                    //           color: colorScheme.primary),
                    //     );
                    //   }
                    //   return SizedBox(
                    //     width: double.infinity,
                    //     height: 54,
                    //     child: ElevatedButton(
                    //       onPressed: () {
                    //         HelperFunctions().closeKeyboard(context);
                    //
                    //         if (controller.formKey.currentState!.validate()) {
                    //           controller.onSubmit();
                    //
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => OTPView(),
                    //             ),
                    //           );
                    //         }
                    //       },
                    //       style: ElevatedButton.styleFrom(
                    //         backgroundColor: colorScheme.primary,
                    //         foregroundColor: colorScheme.onPrimary,
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(30),
                    //         ),
                    //         elevation: 0,
                    //       ),
                    //       child: Text(
                    //         'Sign Up',
                    //         style: textTheme.titleMedium?.copyWith(
                    //           color: colorScheme.onPrimary,
                    //           fontWeight: FontWeight.w600,
                    //           fontSize: 16,
                    //         ),
                    //       ),
                    //     ),
                    //   );
                    // }),

                    const SizedBox(height: 24),

                    // ── Already have account ───────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () => Get.offNamed(Routes.LOGIN),
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            children: [
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Field Label ───────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  final TextTheme textTheme;
  const _FieldLabel(this.label, this.textTheme);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      label,
      style: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ── Plain Input Field ─────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyType;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hint,
    this.keyType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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

// ── Password Field with Eye Toggle ───────────────────────────────────────────
class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.hint,
    this.validator,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant, fontSize: 14),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscure = !_obscure),
          child: Icon(
            _obscure
                ? Icons.remove_red_eye_outlined
                : Icons.visibility_off_outlined,
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
