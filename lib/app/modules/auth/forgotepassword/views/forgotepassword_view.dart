import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/otp/view/otp_view.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_text.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_text_field.dart';
// import 'package:foduu_ecommerce/app/modules/auth/resetpassword/views/resetpassword_view.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';
import '../controllers/forgotepassword_controller.dart';

class ForgotepasswordView extends GetView<ForgotepasswordController> {
  const ForgotepasswordView({Key? key}) : super(key: key);

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
              child: Form(
                key: controller.formKey,
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
                            "Forgot your password?",
                            fontSize: height * 0.03,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                          const SizedBox(height: 8),
                          AppText(
                            "Don\'t worry, we'll help you reset it quickly and easily!",
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

                    // Email Field
                    AppText(
                      "Email",
                      fontSize: height * 0.016,
                      fontWeight: FontWeight.w600,
                    ),

                    const SizedBox(height: 4),

                    AppTextField(
                      controller: controller.emailController,
                      hintText: "Insert Your Email Here",
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      fontSize: height * 0.0165,
                      textColor: DefaultThemeColors.darklighter,
                      hintColor: DefaultThemeColors.darklighter,
                      borderColor: DefaultThemeColors.mainprimary!,
                      focusColor: DefaultThemeColors.mainprimary!,
                      disabledColor: DefaultThemeColors.darklighter,
                      fillColor: DefaultThemeColors.lightOnPrimary,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter your email';
                        if (!value.contains('@'))
                          return 'Please enter a valid email';
                        return null;
                      },
                    ),

                    // Show error message if any
                    Obx(() => controller.errorMessage.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              controller.errorMessage.value,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: height * 0.014,
                              ),
                            ),
                          )
                        : const SizedBox.shrink()),

                    SizedBox(height: height * 0.015),

                    // Submit Button
                    PrimaryActionButton(
                      text: "Submit",
                      isLoading: controller.isLoading.value,
                      onPressed: () {
                        if (!controller.isLoading.value) {
                          controller.forgot_password();
                        }
                      },
                    ),
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
