import 'package:flutter/material.dart';
import 'package:zouhi/app/modules/auth/mobile_number/controller.dart/mobileLoginOtp_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/otp_timer.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

class LoginOtpView extends GetView<MobieNoLoginOtpController> {
  LoginOtpView({super.key});
  var controller = Get.put(MobieNoLoginOtpController());
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
                          Text("Code Verification:".tr,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16)),
                          SizedBox(height: Get.height * 0.01),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: 'Enter your verification code here:'.tr,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .fontSize,
                                  color: context.themeTextColor),
                              // children: <TextSpan>[
                              //   const TextSpan(
                              //     text: 'OTP',
                              //     style: TextStyle(
                              //         fontWeight: FontWeight.bold,
                              //         color: themeTextColor),
                              //   ),
                              //   const TextSpan(
                              //       text:
                              //           ' code from the phone we just sent you on'),
                              //   TextSpan(
                              //     text:
                              //         ' ${Get.find<LoginController>().usernameController.text}.',
                              //     style: const TextStyle(
                              //       fontWeight: FontWeight.bold,
                              //       color: themeTextColor,
                              //     ),
                              //   ),
                              // ],
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          PinFieldAutoFill(
                            codeLength: 6,
                            // currentCode: "1234",
                            keyboardType: TextInputType.number,
                            decoration: BoxLooseDecoration(
                                textStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: context.colors.onSurface),
                                bgColorBuilder:
                                    FixedColorBuilder(context.themeBorderColor),
                                strokeColorBuilder:
                                    FixedColorBuilder(context.themeBorderColor)),
                            autoFocus: true,
                            onCodeSubmitted: (value) {
                              print(value);
                            },
                            // currentCode: controller.otpCode.value,
                            cursor: Cursor(
                              width: 2,
                              height: 25,
                              color: context.colors.onSurface,
                              radius: const Radius.circular(1),
                              enabled: true,
                            ),
                            onCodeChanged: (value) {
                              if (value!.length == 6) {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                controller.attemptLogin(otp: value);
                              }
                            },
                          ),
                          const SizedBox(height: 30),
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
                                  Text('Don’t get code?'.tr,
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: context.themeTextColor)),
                                  TextButton(
                                    onPressed: () {
                                      controller.resendOtp();
                                    },
                                    child: Text(
                                      'Resend'.tr,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: context.colors.onSurface,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Container();
                          }),
                          const SizedBox(height: 20),
                          Center(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                HelperFunctions().closeKeyboard(context);
                                Get.toNamed(Routes.HELPANDSUPPORT);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.headset_mic_outlined,
                                      size: 18,
                                      color: context.themeRedColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Having trouble receiving code? '.tr,
                                      style: TextStyle(
                                        color: context.themeTextColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Contact Support'.tr,
                                      style: TextStyle(
                                        color: context.themeRedColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
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
              // Image.asset(
              //   "assets/headers/bottom-img.png",
              //   width: double.infinity,
              // )
            ],
          ),
        ),
      ),
    );
  }
}
