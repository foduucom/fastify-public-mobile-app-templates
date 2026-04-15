// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '/app/modules/auth/auth_details.dart';
import '/app/routes/app_pages.dart';
import '/components/buttons/appbutton.dart';
import '/components/foduuformtextfield.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.primary, // ← green top area
      body: GestureDetector(
        onTap: () => HelperFunctions().closeKeyboard(context),
        child: Column(
          children: [
            // ── TOP: Green Header Area ──────────────────────────────────
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Debug text — keep as-is (your existing code)
                    // Text(
                    //   AuthDetails.isUserLogin().toString(),
                    //   style: TextStyle(color: Colors.red),
                    // ),

                    Text(
                      'Hi, Welcome Back! 👋',
                      style: textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lorem ipsum dolor sit amet',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.85),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── BOTTOM: White Card ──────────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Form(
                  key: controller.formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Email Field ───────────────────────────────
                        FoduuFormTextField(
                          fieldHintText: 'Enter your email address',
                          title: 'Email',
                          validationmsg: 'Please enter email',
                          validCheck: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter an email address".tr;
                            } else if (!GetUtils.isEmail(value)) {
                              return "Please enter a valid email address".tr;
                            }
                            return null;
                          },
                          keyType: TextInputType.emailAddress,
                          controller: controller.emailController,
                        ),
                        const SizedBox(height: 20),

                        // ── Password Field (only if not OTP mode) ─────
                        Obx(() {
                          if (!controller.isOtpMode.value) {
                            return Column(
                              children: [
                                FoduuFormTextField(
                                  obsecure: controller.obsecuretext.value,
                                  controller: controller.passwordController,
                                  title: 'Password',
                                  validationmsg: '',
                                  fieldHintText: '',
                                  keyType: TextInputType.visiblePassword,
                                  validCheck: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value.length < 6) {
                                      return 'Please enter valid Password';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 9),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () =>
                                          Get.toNamed(Routes.FORGETPASSWORD),
                                      child: Text(
                                        'Forgot Password ?',
                                        style: TextStyle(
                                          color: colorScheme.primary
                                              .withOpacity(0.8),
                                          fontFamily: 'Lato',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                          return SizedBox.shrink();
                        }),

                        const SizedBox(height: 28),

                        // ── Continue with Email Button ────────────────
                        Obx(() {
                          if (controller.isLoading.value) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: colorScheme.primary,
                              ),
                            );
                          }
                          return SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                HelperFunctions().closeKeyboard(context);
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
                                controller.isOtpMode.value
                                    ? 'Continue with Email'
                                    : 'Continue with Email',
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 28),

                        // ── Divider: Or continue with ─────────────────
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: colorScheme.onSurfaceVariant,
                                    thickness: 1)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'Or continue with',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: colorScheme.onSurfaceVariant,
                                    thickness: 1)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Continue with Google ──────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: Google sign in
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: colorScheme.outline),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google_logo.png',
                                  height: 22,
                                  width: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ── Continue with Apple ───────────────────────

                        const SizedBox(height: 28),

                        // ── Don't have an account? Sign Up ────────────
                        Center(
                          child: TextButton(
                            onPressed: () {
                              HelperFunctions().closeKeyboard(context);
                              Get.toNamed(Routes.REGISTER);
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have an account? ",
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sign Up',
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
