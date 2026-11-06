import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../../constants/dynamic_theme.dart' as themeExt;
import '../controller/otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Dynamic scaffold background — matches login/register
      backgroundColor: context.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar (inlined, same pattern as CreateAccountView) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: context.onSurfaceColor,
                    ),
                    tooltip: 'Back',
                  ),
                  const Spacer(),
                  Text(
                    'Verify Email',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: context.onSurfaceColor,
                        ),
                  ),
                  const Spacer(),
                  // Symmetry spacer so the title stays centered
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),

                    // ── Icon ─────────────────────────────────
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: context.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mark_email_unread_outlined,
                        size: 36,
                        color: context.onPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Check your email',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: context.onSurfaceColor,
                              ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'We sent a verification code to\n${controller.email}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 14,
                            height: 1.5,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 36),

                    // ── OTP Input ─────────────────────────────
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      onChanged: controller.onOtpChanged,
                      onCompleted: (_) => controller.verifyOtp(),
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.scale,

                      // ✅ Dynamic digit color (readable on filled active box)
                      textStyle: TextStyle(
                        color: context.onPrimaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),

                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(16),
                        fieldHeight: 56,
                        fieldWidth: 48,

                        // ✅ Dynamic fills
                        activeFillColor: context.primaryColor,
                        selectedFillColor: context.primaryColor,
                        inactiveFillColor: context.surfaceColor,

                        // ✅ Dynamic borders
                        activeColor: context.primaryColor,
                        selectedColor: context.primaryColor,
                        inactiveColor: context.onSurfaceColor.withOpacity(0.12),
                      ),

                      enableActiveFill: true,
                      cursorColor: context.onPrimaryColor,
                      // ✅ Caret color readable on filled boxes
                    ),
                    const SizedBox(height: 32),

                    // ── Verify Button ─────────────────────────
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            // ✅ () => … — actually invokes the method
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.verifyOtp(),
                            style: ElevatedButton.styleFrom(
                              // ✅ Match login/register submit button
                              backgroundColor: context.primaryColor,
                              foregroundColor: context.onPrimaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: context.onPrimaryColor,
                                    ),
                                  )
                                : Text(
                                    'Verify OTP',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: context.onPrimaryColor,
                                        ),
                                  ),
                          ),
                        )),
                    const SizedBox(height: 20),

                    // ── Resend ────────────────────────────────
                    Obx(() => GestureDetector(
                          onTap: controller.isResending.value
                              ? null
                              : controller.resendOtp,
                          child: controller.isResending.value
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: context.primaryColor,
                                  ),
                                )
                              : RichText(
                                  text: TextSpan(
                                    text: "Didn't receive it? ",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Resend',
                                        style: TextStyle(
                                          color: context.primaryColor,
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        )),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
