import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/company_trademark_widget.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';
import '../controllers/register_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final RegisterController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<RegisterController>()) {
      controller = Get.find<RegisterController>();
    } else {
      controller = Get.put(RegisterController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? context.colors.surface : const Color(0xFFF4F8FB);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button row
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: themePrimaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Logo Section
                  _buildLogo(context),
                  const SizedBox(height: 20),

                  // Elevated Card Form
                  _buildCardForm(context),
                  const SizedBox(height: 18),

                  // Sign In Navigation
                  _buildSignInLink(context),
                  const SizedBox(height: 16),

                  // FODUU Trademark
                  const Center(
                    child: CompanyTrademarkWidget(
                      fontSize: 13.0,
                      logoHeight: 24.0,
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = (MediaQuery.of(context).size.width * 0.65).clamp(180.0, 280.0);
    final logoImage = Image.asset(
      'assets/images/VIC-Logo-Final-1213.png',
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'Vision Infrastructure Canada',
    );

    return Center(
      child: isDark
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: logoImage,
            )
          : logoImage,
    );
  }

  Widget _buildCardForm(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFEDF2F7),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sign up to get started with Vision Infrastructure',
              style: TextStyle(
                fontSize: 13,
                color: context.themeSecondrytext,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 22),

            // Full Name Field
            _buildFieldLabel('Full Name'),
            const SizedBox(height: 6),
            TextFormField(
              controller: controller.nameController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
              ],
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontFamily: 'Poppins',
              ),
              decoration: _buildInputDecoration(
                hintText: 'Enter your full name',
                prefixIcon: Icons.person_outline_rounded,
                isDark: isDark,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name!';
                }
                if (value.trim().length < 3) {
                  return 'Name must be at least 3 characters!';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Email Field
            _buildFieldLabel('Email Address'),
            const SizedBox(height: 6),
            TextFormField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontFamily: 'Poppins',
              ),
              decoration: _buildInputDecoration(
                hintText: 'Enter email address',
                prefixIcon: Icons.mail_outline_rounded,
                isDark: isDark,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter email address!';
                }
                if (!GetUtils.isEmail(value.trim())) {
                  return 'Please enter a valid email address!';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Password Field
            _buildFieldLabel('Password'),
            const SizedBox(height: 6),
            Obx(() {
              return TextFormField(
                controller: controller.passwordController,
                obscureText: !controller.isPasswordVisible.value,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontFamily: 'Poppins',
                ),
                decoration: _buildInputDecoration(
                  hintText: 'Enter password',
                  prefixIcon: Icons.lock_outline_rounded,
                  isDark: isDark,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: controller.isPasswordVisible.value
                          ? themePrimaryColor
                          : const Color(0xFF94A3B8),
                    ),
                    onPressed: () {
                      controller.isPasswordVisible.toggle();
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password!';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters!';
                  }
                  return null;
                },
              );
            }),
            const SizedBox(height: 14),

            // Confirm Password Field
            _buildFieldLabel('Confirm Password'),
            const SizedBox(height: 6),
            Obx(() {
              return TextFormField(
                controller: controller.confirmPasswordController,
                obscureText: !controller.isConfirmPasswordVisible.value,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontFamily: 'Poppins',
                ),
                decoration: _buildInputDecoration(
                  hintText: 'Re-enter password',
                  prefixIcon: Icons.lock_outline_rounded,
                  isDark: isDark,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isConfirmPasswordVisible.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: controller.isConfirmPasswordVisible.value
                          ? themePrimaryColor
                          : const Color(0xFF94A3B8),
                    ),
                    onPressed: () {
                      controller.isConfirmPasswordVisible.toggle();
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please re-enter password!';
                  }
                  if (value != controller.passwordController.text) {
                    return 'Passwords do not match!';
                  }
                  return null;
                },
              );
            }),
            const SizedBox(height: 16),

            // Terms & Conditions Checkbox
            _buildTermsAndConditions(context),
            const SizedBox(height: 22),

            // Submit / Register Button
            Obx(() {
              return SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themePrimaryColor,
                    foregroundColor: Colors.white,
                    elevation: 1.5,
                    shadowColor: themePrimaryColor.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          HelperFunctions().closeKeyboard(context);
                          controller.onSubmit(_formKey);
                        },
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'SIGN UP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            letterSpacing: 0.8,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
        fontFamily: 'Poppins',
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 13.5,
        fontFamily: 'Poppins',
      ),
      prefixIcon: Icon(
        prefixIcon,
        size: 19,
        color: const Color(0xFF64748B),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: themePrimaryColor,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFEF4444),
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFEF4444),
          width: 1.6,
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Obx(() {
          return SizedBox(
            height: 22,
            width: 22,
            child: Checkbox(
              activeColor: themePrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              side: const BorderSide(color: Color(0xFFB0B9C6), width: 1.4),
              value: controller.isChecked.value,
              onChanged: (val) {
                controller.onChecked(val);
              },
            ),
          );
        }),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Get.toNamed(Routes.POLICY_DETAIL, arguments: {'type': 'terms'});
            },
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: context.themeSecondrytext,
                  fontSize: 12.5,
                  fontFamily: 'Poppins',
                ),
                children: [
                  const TextSpan(text: "I accept "),
                  TextSpan(
                    text: "Terms & Conditions",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: themePrimaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.toNamed(Routes.POLICY_DETAIL, arguments: {'type': 'terms'});
                      },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInLink(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () => Get.back(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(
                color: context.themeSecondrytext,
                fontFamily: 'Poppins',
                fontSize: 13.5,
              ),
              children: const [
                TextSpan(
                  text: 'Sign In',
                  style: TextStyle(
                    color: themePrimaryColor,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
