import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../../app_colors.dart';
import '../../../../../components/app_bar/custom_app_bar.dart';
import '../controller/otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ push content up on keyboard
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            AppTopBar(title: 'Verify Email', showCart: false),
            const SizedBox(height: 40),

            Expanded(
              child: SingleChildScrollView( // ✅ KEY FIX
                padding: const EdgeInsets.symmetric(horizontal: 24),
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    // ── Icon ─────────────────────────────────
                    Container(
                      width: 80, height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.scaffoldBackground, shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mark_email_unread_outlined,
                          size: 36, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 24),

                    const Text('Check your email',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 8),

                    Text(
                      'We sent a verification code to\n${controller.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9E9E9E),
                          height: 1.5),
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

                      textStyle: const TextStyle( // ✅ REQUIRED
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),

                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(16),
                        fieldHeight: 56,
                        fieldWidth: 48,

                        // ✅ FIX COLORS
                        activeFillColor: const Color(0xFF1A1A1A),
                        selectedFillColor: const Color(0xFF1A1A1A),
                        inactiveFillColor: const Color(0xFFF5F5F5),

                        activeColor: const Color(0xFF1A1A1A),
                        selectedColor: const Color(0xFF1A1A1A),
                        inactiveColor: Colors.grey.shade300,
                      ),

                      enableActiveFill: true,
                      cursorColor: Colors.white,
                    ),
                    const SizedBox(height: 32),

                    // ── Verify Button ─────────────────────────
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  AppColors.scaffoldBackground,
                          foregroundColor: AppColors.scaffoldBackground,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.scaffoldBackground))
                            : const Text('Verify OTP',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                    )),
                    const SizedBox(height: 20),

                    // ── Resend ────────────────────────────────
                    Obx(() => GestureDetector(
                      onTap: controller.isResending.value
                          ? null
                          : controller.resendOtp,
                      child: controller.isResending.value
                          ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF1A1A1A)))
                          : RichText(
                        text: const TextSpan(
                          text: "Didn't receive it? ",
                          style: TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Resend',
                              style: TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w700,
                                decoration:
                                TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),

                    const SizedBox(height: 32), // ✅ bottom breathing room
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
