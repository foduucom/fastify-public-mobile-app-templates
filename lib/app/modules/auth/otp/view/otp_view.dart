import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/otp/controller.dart/otp_controller.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_text.dart';
import 'package:foduu_ecommerce/app/modules/auth/otp/view/otp_input_widget.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class OTPView extends GetView<OtpController> {
  const OTPView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button — fully left aligned
            Padding(
              padding: EdgeInsets.only(
                left: width * 0.01, // minimal edge padding
                top: height * 0.01,
              ),
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back,
                  size: width * 0.06,
                  color: context.onSurfaceColor, // Theme-aware back button
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.03,
                  vertical: height * 0.02,
                ),
                children: [
                  // Title + Description
                  Container(
                    //margin: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          "Enter your OTP code",
                          fontSize: height * 0.03,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          color: context.onBackgroundColor, // Theme-aware title
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          controller.otpContext.value ==
                                  OtpContext.forgotPassword
                              ? 'Enter the code sent to you to continue password recovery.'
                              : 'Enter the code sent to verify your account.',
                          fontSize: height * 0.018,
                          height: 1.4,
                          letterSpacing: 0,
                          maxLines: 3,
                          color: colorScheme.onSurfaceVariant,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: height * 0.02),

                  Obx(() {
                    if (controller.forgotPasswordOtpVerified.value) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              controller.forgotPasswordMessage.value,
                              style: TextStyle(
                                  color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                          const SizedBox(height: 16),
                          PrimaryActionButton(
                            text: 'Back to Sign In',
                            onPressed: () => Get.offAllNamed(Routes.LOGIN),
                          ),
                        ],
                      );
                    }

                    return Center(
                      child: OtpInputWidget(
                        length: 6,
                        controller: controller,
                        onCompleted: (otp) {
                          if (otp.length == 6) {
                            controller.verifyOtp(otp: otp);
                          }
                        },
                      ),
                    );
                  }),

                  SizedBox(height: height * 0.04),

                  // Resend Code Section
                  Center(
                    child: Obx(() {
                      if (controller.forgotPasswordOtpVerified.value) {
                        return const SizedBox.shrink();
                      }
                      if (controller.isResendVisible.value) {
                        return Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'did not receive the code?',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: width * 0.04,
                                  color: context
                                      .onSurfaceVariantColor, // Theme-aware
                                ),
                              ),
                              SizedBox(width: width * 0.01),
                              InkWell(
                                onTap: controller.resendOtp,
                                child: Text(
                                  'Send Code Again',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: width * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Text(
                          'Resend code in ${controller.countdown.value}s',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: width * 0.04,
                            color: colorScheme.onSurface,
                          ),
                        );
                      }
                    }),
                  ),

                  SizedBox(height: height * 0.04),

                  // OTP
                  Obx(() => controller.forgotPasswordOtpVerified.value
                      ? const SizedBox.shrink()
                      : PrimaryActionButton(
                          text: 'Verify Code',
                          onPressed: controller.otpCode.value.length == 6 &&
                                  !controller.isLoading.value
                              ? () => controller.verifyOtp(
                                  otp: controller.otpCode.value)
                              : null,
                          isLoading: controller.isLoading.value,
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
