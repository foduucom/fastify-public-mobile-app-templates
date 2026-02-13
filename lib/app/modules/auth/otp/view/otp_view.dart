import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/otp/controller.dart/otp_controller.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_text.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_text_field.dart';
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
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          "Verify your account and get access to exclusive travel features",
                          fontSize: height * 0.018,
                          height: 1.4,
                          letterSpacing: 0,
                          maxLines: 3,
                          color: DefaultThemeColors.darklighter,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: height * 0.02),

                  // OTP Input Widget
                  Center(
                    child: OtpInputWidget(
                      length: 4,
                      controller: controller,
                      onCompleted: (otp) {
                        // Auto-verify when OTP is complete
                        if (otp.length == 4) {
                          controller.verifyOtp(otp: otp);
                        }
                      },
                    ),
                  ),

                  SizedBox(height: height * 0.04),

                  // Resend Code Section
                  Center(
                    child: Obx(() {
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
                                  color: DefaultThemeColors.darklighter,
                                ),
                              ),
                              SizedBox(width: width * 0.01),
                              InkWell(
                                onTap: () {
                                  //print('CLICKED ON CREATE AN ACCOUNT');
                                  //Get.toNamed(Routes.SIGNUP);
                                },
                                child: Text(
                                  'Send Code Again',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: width * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: DefaultThemeColors.mainprimary,
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
                            color: DefaultThemeColors.darklighter,
                          ),
                        );
                      }
                    }),
                  ),

                  SizedBox(height: height * 0.04),

                  // OTP
                  Obx(() => PrimaryActionButton(
                        text: "Submit",
                        onPressed: controller.otpCode.value.length == 4 &&
                                !controller.isLoading.value
                            ? () {
                                controller.verifyOtp(
                                    otp: controller.otpCode.value);
                              }
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
