import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/company_trademark_widget.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';
import '../controllers/login_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _passwordFocusNode = FocusNode();
  late final LoginController controller;
  bool _isSkipNavigating = false;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<LoginController>()) {
      controller = Get.find<LoginController>();
    } else {
      controller = Get.put(LoginController());
    }
    controller.applyRouteArguments();

    if (Get.arguments != null &&
        Get.arguments is Map &&
        Get.arguments['email'] != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _passwordFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? context.colors.surface : const Color(0xFFF4F8FB);

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Top Bar: Skip Pill
                          _buildTopBar(),
                          const SizedBox(height: 16),

                          // 2. Logo Section
                          _buildLogoSection(context),
                          const SizedBox(height: 24),

                          // 3. Elevated Card Container
                          _buildCardContainer(context),
                          const SizedBox(height: 20),

                          // 4. Register Now & Support Section
                          _buildRegisterNowSection(context),
                          const SizedBox(height: 14),
                          _buildHelpAndSupportSection(context),

                          const Spacer(),

                          // 5. Company Trademark (FODUU)
                          const SizedBox(height: 16),
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (_isSkipNavigating) return;
          _isSkipNavigating = true;
          controller.box.write('isLogin', false);
          Get.offAllNamed(Routes.BOTTOMBAR);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Skip',
                style: TextStyle(
                  color: themePrimaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: themePrimaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = (MediaQuery.of(context).size.width * 0.70).clamp(200.0, 300.0);
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: logoImage,
            )
          : logoImage,
    );
  }

  Widget _buildCardContainer(BuildContext context) {
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
            // Header: Welcome Back (matching website)
            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Please sign in to your account',
              style: TextStyle(
                fontSize: 13,
                color: context.themeSecondrytext,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),

            // Email Label & Input Field
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
              validator: (value) => controller.validEmail(value ?? ''),
              onSaved: (value) => controller.email = value?.trim() ?? '',
            ),
            const SizedBox(height: 16),

            // Password Label & Input Field
            _buildFieldLabel('Password'),
            const SizedBox(height: 6),
            Obx(() {
              return TextFormField(
                controller: controller.passwordController,
                focusNode: _passwordFocusNode,
                obscureText: controller.obsecuretext.value,
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
                      controller.obsecuretext.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: controller.obsecuretext.value
                          ? const Color(0xFF94A3B8)
                          : themePrimaryColor,
                    ),
                    onPressed: () {
                      controller.obsecuretext.toggle();
                    },
                  ),
                ),
                validator: (value) => controller.validPassword(value ?? ''),
                onSaved: (value) => controller.password = value ?? '',
              );
            }),
            const SizedBox(height: 12),

            // Remember Me & Forgot Password Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Remember Me
                Obx(() {
                  return InkWell(
                    onTap: () {
                      controller.rememberMe.value = !controller.rememberMe.value;
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Checkbox(
                            value: controller.rememberMe.value,
                            activeColor: themePrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: const BorderSide(
                              color: Color(0xFFB0B9C6),
                              width: 1.4,
                            ),
                            onChanged: (val) {
                              controller.rememberMe.value = val ?? false;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Remember me',
                          style: TextStyle(
                            color: context.themeSecondrytext,
                            fontSize: 12.5,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Forgot Password Link
                InkWell(
                  onTap: () {
                    Get.toNamed(Routes.FORGETPASSWORD);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: themePrimaryColor,
                        fontSize: 12.5,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit / Sign In Button
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
                          'SIGN IN',
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

  Widget _buildRegisterNowSection(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(
            color: context.themeSecondrytext,
            fontFamily: 'Poppins',
            fontSize: 13.5,
          ),
          children: [
            TextSpan(
              text: 'Register Now',
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Get.toNamed(Routes.REGISTER);
                },
              style: const TextStyle(
                color: themePrimaryColor,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpAndSupportSection(BuildContext context) {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Get.toNamed(Routes.HELPANDSUPPORT);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.headset_mic_outlined,
                size: 16,
                color: context.themeSecondrytext,
              ),
              const SizedBox(width: 6),
              Text(
                'Need help? ',
                style: TextStyle(
                  color: context.themeSecondrytext,
                  fontFamily: 'Poppins',
                  fontSize: 13,
                ),
              ),
              const Text(
                'Contact Support',
                style: TextStyle(
                  color: themePrimaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
