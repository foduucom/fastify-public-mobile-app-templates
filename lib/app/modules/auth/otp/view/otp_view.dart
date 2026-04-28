import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/otp/controller.dart/otp_controller.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/otp_timer.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OTPView extends GetView<OtpController> {
  OTPView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Otp Verfiy'),
          elevation: 0,
        ),
        body: GestureDetector(
          onTap: () {
            HelperFunctions().closeKeyboard(context);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Form(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dynamic title based on context
                          Obx(() {
                            String contextText =
                                controller.otpContext.value == OtpContext.login
                                    ? 'Login'
                                    : 'Registration';
                            return Text("$contextText Code Verification:".tr,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16));
                          }),
                          SizedBox(height: Get.height * 0.01),
                          // Show email being verified
                          Obx(() {
                            return RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'Enter the verification code sent to '.tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .fontSize,
                                  // color: themeTextColor
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: controller.email.value,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      // color: themeTextColor
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 30.0),
                          Obx(() => PinFieldAutoFill(
                                codeLength: controller.otpLength.value,
                                keyboardType: TextInputType.number,
                                decoration: BoxLooseDecoration(
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    bgColorBuilder: FixedColorBuilder(
                                        Theme.of(context).colorScheme.surface),
                                    strokeColorBuilder: FixedColorBuilder(
                                        Theme.of(context).colorScheme.primary)),
                                autoFocus: true,
                                onCodeSubmitted: (value) {
                                  print(value);
                                },
                                cursor: Cursor(
                                  width: 2,
                                  height: 25,
                                  color: Theme.of(context).colorScheme.primary,
                                  radius: const Radius.circular(1),
                                  enabled: true,
                                ),
                                onCodeChanged: (value) {
                                  if (value!.length ==
                                      controller.otpLength.value) {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    controller.verifyOtp(otp: value);
                                  }
                                },
                              )),
                          const SizedBox(height: 30),
                          // Obx(() {
                          //   if (controller.isLoading.value) {
                          //     return Center(
                          //       child: HelperFunctions().loadingIndicator(),
                          //     );
                          //   }
                          //   return const SizedBox.shrink();
                          // }),
                          const SizedBox(height: 15.0),
                          Obx(() {
                            if (!controller.isResendVisible.value) {
                              return OtpTimer(
                                onEnd: () {
                                  controller.isResendVisible(true);
                                },
                                timeDuration: 60,
                              );
                            }
                            return Container();
                          }),
                          const SizedBox(height: 15.0),
                          Obx(() {
                            if (controller.isResendVisible.value) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Don't get code?".tr,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        // color: themeTextColor
                                      )),
                                  TextButton(
                                    onPressed: () {
                                      controller.resendOtp();
                                    },
                                    child: Text(
                                      'Resend'.tr,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Container();
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
