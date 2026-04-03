import 'package:flutter/material.dart';
import '../../../../../components/app_bar.dart';
import '/app/modules/auth/otp/controller.dart/otp_controller.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import '/constants/otp_timer.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OTPView extends GetView<OtpController> {
  OTPView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,

      // ── AppBar: back button only, no title ───────────────────────
      appBar :CustomAppBar(title: "OTP"),

      body: GestureDetector(
        onTap: () => HelperFunctions().closeKeyboard(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(height: 32),

              // ── Title ──────────────────────────────────────────────
              Text(
                'Enter OTP',
                style: textTheme.headlineMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),

              const SizedBox(height: 14),

              // ── Subtitle — ORIGINAL Obx logic kept ─────────────────
              Obx(() {
                return RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text:
                    'We have just sent you ${controller.otpLength.value} digit code via your\nemail ',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Color(0xFF6C6C6C),
                      height: 1.6,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: controller.email.value,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 48),

              // ── PinField — ORIGINAL logic kept, only styling updated ─
              Obx(() => PinFieldAutoFill(
                codeLength: controller.otpLength.value,
                keyboardType: TextInputType.number,
                decoration: BoxLooseDecoration(
                  textStyle: textTheme.headlineSmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  // ✅ Circular box style
                  radius: const Radius.circular(50),
                  strokeWidth: 1.5,
                  gapSpace: 16,
                  bgColorBuilder: FixedColorBuilder(Colors.white),
                  strokeColorBuilder:
                  FixedColorBuilder(colorScheme.primary),
                ),
                autoFocus: true,
                onCodeSubmitted: (value) {
                  print(value); // original
                },
                cursor: Cursor(
                  width: 2,
                  height: 25,
                  color: colorScheme.primary,
                  radius: const Radius.circular(1),
                  enabled: true,
                ),
                onCodeChanged: (value) {
                  // original logic — untouched
                  if (value!.length == controller.otpLength.value) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    controller.verifyOtp(otp: value);
                  }
                },
              )),

              const SizedBox(height: 48),

              // ── Continue Button (new) ──────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Timer — ORIGINAL Obx logic kept ────────────────────
              Obx(() {
                if (!controller.isResendVisible.value) {
                  return OtpTimer(
                    onEnd: () {
                      controller.isResendVisible(true);
                    },
                    timeDuration: 60,
                  );
                }
                return const SizedBox.shrink();
              }),

              // ── Resend — ORIGINAL Obx logic kept, styling updated ───
              Obx(() {
                if (controller.isResendVisible.value) {
                  return GestureDetector(
                    onTap: () => controller.resendOtp(),
                    child: RichText(
                      text: TextSpan(
                        text: "Didn't receive code? ",
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        children: [
                          TextSpan(
                            text: 'Resend Code',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}