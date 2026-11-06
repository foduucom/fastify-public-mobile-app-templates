library dynamic_theme;

import 'package:flutter/material.dart';
import 'package:foddu/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../../../constants/dynamic_theme.dart' as themeExt;
import '/app/modules/auth/login/views/widgets/controller.dart';
import '/app/modules/auth/register/controller/register_controller.dart';

enum AuthMode { login, register }

class CreateAccountView extends StatefulWidget {
  final AuthMode mode;
  const CreateAccountView({super.key, this.mode = AuthMode.login});

  @override
  State<CreateAccountView> createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView> {
  final _formKey = GlobalKey<FormState>();

  // Only resolve the controller we actually need for this mode.
  late final CreateAccountController _loginCtrl;
  late final RegisterController _registerCtrl;
  bool get _isRegister => widget.mode == AuthMode.register;

  @override
  void initState() {
    super.initState();
    if (_isRegister) {
      _registerCtrl = Get.find<RegisterController>();
    } else {
      _loginCtrl = Get.find<CreateAccountController>();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 12),

            /// Skip
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Get.offAllNamed('/bottombar'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.onPrimaryColor,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Logo
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
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

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSubtitle(context),
                  const SizedBox(height: 32),

                  /// Name (register only)
                  if (_isRegister) ...[
                    _buildLabel(context, 'Full Name'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _registerCtrl.nameController,
                      keyboardType: TextInputType.name,
                      validator: _registerCtrl.validName,
                      style: TextStyle(color: context.onSurfaceColor),
                      decoration:
                          _inputDecoration(context, 'Enter your full name'),
                    ),
                    const SizedBox(height: 24),
                  ],

                  /// Email
                  _buildLabel(context, 'Email Address'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _isRegister
                        ? _registerCtrl.emailController
                        : _loginCtrl.emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _isRegister
                        ? _registerCtrl.validEmail
                        : _loginCtrl.validEmail,
                    style: TextStyle(color: context.onSurfaceColor),
                    decoration: _inputDecoration(context, 'Enter your email'),
                  ),

                  /// Password (login only, when not OTP mode)
                  if (!_isRegister)
                    Obx(() {
                      if (_loginCtrl.isOtpMode.value)
                        return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildLabel(context, 'Password'),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _loginCtrl.passwordController,
                            obscureText: _loginCtrl.obscureText.value,
                            validator: _loginCtrl.validPassword,
                            style: TextStyle(color: context.onSurfaceColor),
                            decoration:
                                _inputDecoration(context, 'Enter your password')
                                    .copyWith(
                              suffixIcon: GestureDetector(
                                onTap: _loginCtrl.togglePassword,
                                child: Icon(
                                  _loginCtrl.obscureText.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 20,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                  const SizedBox(height: 32),

                  /// Submit
                  Obx(() => _buildSubmitButton(context)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// Footer link
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: _isRegister
                    ? [
                        Text(
                          'Already have an account?',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        TextButton(
                          onPressed: () => Get.offNamed(Routes.LOGIN),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign in',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: context.primaryColor,
                                ),
                          ),
                        ),
                      ]
                    : [
                        Text(
                          'Don\'t have an account?',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(Routes.REGISTER),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign up',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: context.primaryColor,
                                ),
                          ),
                        ),
                      ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSubtitle(BuildContext context) {
    if (_isRegister) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Account',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: context.onSurfaceColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign up to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      );
    }
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _loginCtrl.isOtpMode.value ? 'Welcome' : 'Create Account',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: context.onSurfaceColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _loginCtrl.isOtpMode.value
                  ? 'Sign in or register to get started'
                  : 'Sign up to get started',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ));
  }

  Widget _buildSubmitButton(BuildContext context) {
    final isLoading = _isRegister
        ? _registerCtrl.isLoading.value
        : _loginCtrl.isLoading.value;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                debugPrint('Registration view button clicked');
                if (_formKey.currentState?.validate() ?? false) {
                  if (_isRegister) {
                    debugPrint(
                        'Registration view button clicked inside the if condition');
                    _registerCtrl.onSubmit();
                  } else {
                    debugPrint(
                        'Registration view button clicked inside the else condition');
                    _loginCtrl.onSubmit();
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: context.primaryColor,
          foregroundColor: context.onPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: context.onPrimaryColor,
                ),
              )
            : Text(
                'Continue',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.onPrimaryColor,
                    ),
              ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: context.onSurfaceColor,
          ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
      filled: true,
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
        borderSide: BorderSide(color: context.primaryColor, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(color: context.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(color: context.errorColor, width: 1.2),
      ),
    );
  }
}
