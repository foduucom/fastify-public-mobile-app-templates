import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/createnewpassword/controllers/create_new_password_controllers.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_password_field.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_text.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/helpers/dialog_helper.dart';
import 'package:get/get.dart';

class CreateNewPasswordView extends GetView<CreateNewPasswordController> {
  const CreateNewPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;
    return Scaffold(
      body: SafeArea(
        child: Column(
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
                          "Create a New Password",
                          fontSize: height * 0.03,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          color: context.onBackgroundColor, // Theme-aware title
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          "Enter your new password to regain access to your account",
                          fontSize: height * 0.018,
                          height: 1.4,
                          letterSpacing: 0,
                          maxLines: 3,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? DefaultThemeColors.darklighter
                              : DefaultThemeColors.lightDarker,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: height * 0.02),

                  // Form Section
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Password Field
                        AppText(
                          "Password",
                          fontWeight: FontWeight.w600,
                          fontSize: height * 0.016,
                          height: 1.5,
                          letterSpacing: 0,
                          color: context.onSurfaceColor, // Theme-aware label
                        ),

                        const SizedBox(height: 4),

                        AppPasswordField(
                          controller: controller.passwordController,
                          isVisible: controller.isPasswordVisible,
                          onToggle: controller.togglePasswordVisibility,
                          fontSize: height * 0.0165,
                          hintText: "Insert your password",
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Please enter your password';
                            if (value.length < 6)
                              return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),

                        SizedBox(height: height * 0.02),

                        // Confirm Password Field
                        AppText(
                          "Confirm Password",
                          fontWeight: FontWeight.w600,
                          fontSize: height * 0.016,
                          height: 1.5,
                          letterSpacing: 0,
                          color: context.onSurfaceColor, // Theme-aware label
                        ),

                        const SizedBox(height: 4),

                        AppPasswordField(
                          controller: controller.confirmPasswordController,
                          isVisible: controller.isConfirmPasswordVisible,
                          onToggle: controller.toggleConfirmPasswordVisibility,
                          fontSize: height * 0.0165,
                          hintText: "Insert your password",
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Please enter your password';
                            if (value.length < 6)
                              return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                      ]),

                  SizedBox(height: height * 0.02),

                  // Submit Button
                  PrimaryActionButton(
                    text: "Submit",
                    onPressed: () {
                      DialogHelper.showSuccessDialog(
                        title: "Password Changed Successfully",
                        description:
                            "Your password has been successfully changed. Please use your new password to log in and enjoy a more secure experience on our platform.",
                        imagePath: "assets/images/Illustration.png",
                        buttonText: "Continue",
                        onPressed: () {
                          Get.back();
                          // Navigate if needed
                          Get.toNamed(Routes.ADDPROFILE);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
