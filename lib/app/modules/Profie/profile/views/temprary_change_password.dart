import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_password_field.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_text.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/controllers/profile_controller.dart'; // Import your controller
import 'package:get/get.dart';

class TempraryChangePassword extends StatelessWidget {
  const TempraryChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;

    // Get the ProfileController
    final ProfileController controller = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: SizedBox(
          width: width * 0.4,
          child: Text(
            "Change Password",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: height * 0.025,
              fontWeight: FontWeight.w700,
              height: 1.6,
            ),
          ),
        ),
      ),
      body: Form(
        key: controller.changePasswordFormKey,
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.02,
          ),
          children: [
            SizedBox(height: height * 0.012),

            // Form Section
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Old Password Field
              AppText(
                "Old Password",
                fontWeight: FontWeight.w600,
                fontSize: height * 0.016,
                height: 1.5,
                letterSpacing: 0,
                color: context.onSurfaceColor,
              ),

              const SizedBox(height: 4),

              Obx(() => AppPasswordField(
                    controller: controller.oldPasswordController,
                    isVisible: controller.oldPasswordObsecureValue,
                    onToggle: () =>
                        controller.oldPasswordObsecureValue.toggle(),
                    fontSize: height * 0.0165,
                    hintText: "Insert your old password",
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your old password';
                      if (value.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  )),

              SizedBox(height: height * 0.02),

              // New Password Field
              AppText(
                "New Password",
                fontWeight: FontWeight.w600,
                fontSize: height * 0.016,
                height: 1.5,
                letterSpacing: 0,
                color: context.onSurfaceColor,
              ),

              const SizedBox(height: 4),

              Obx(() => AppPasswordField(
                    controller: controller.newPasswordController,
                    isVisible: controller.newPasswordObsecureValue,
                    onToggle: () =>
                        controller.newPasswordObsecureValue.toggle(),
                    fontSize: height * 0.0165,
                    hintText: "Insert your new password",
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your new password';
                      if (value.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  )),

              SizedBox(height: height * 0.02),

              // Confirm Password Field
              AppText(
                "Confirm Password",
                fontWeight: FontWeight.w600,
                fontSize: height * 0.016,
                height: 1.5,
                letterSpacing: 0,
                color: context.onSurfaceColor,
              ),

              const SizedBox(height: 4),

              Obx(() {
                return AppPasswordField(
                  controller: controller.comfirmPasswordController,
                  isVisible: controller.comfirmPasswordObsecureValue,
                  onToggle: () {
                    controller.comfirmPasswordObsecureValue.toggle();
                  },
                  fontSize: height * 0.0165,
                  hintText: "Confirm your new password",
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please confirm your password';
                    if (value.length < 6)
                      return 'Password must be at least 6 characters';
                    if (value != controller.newPasswordController.text)
                      return 'Passwords do not match';
                    return null;
                  },
                );
              }),
            ]),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 20.0, left: 16.0, right: 16.0),
        child: Obx(() => PrimaryActionButton(
              text: "Update Password",
              onPressed: controller.isLoading.value
                  ? null // Disable button when loading
                  : () {
                      if (controller.changePasswordFormKey.currentState!.validate()) {
                        controller
                            .changePassword(); // Call the changePassword method
                      }
                    },
            )),
      ),
    );
  }
}
