import 'package:flutter/material.dart';
import '/app/modules/Profie/profile/controllers/profile_controller.dart';
import '/components/foduuformtextfield.dart';
import '/constants/constants.dart';
import 'package:get/get.dart';
import '../../../../../components/buttons/appbutton.dart';
import '../../../../routes/app_pages.dart';

class ChangePasswordView extends GetView<ProfileController> {
  const ChangePasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          controller.newPasswordController.text = '';
          controller.oldPasswordController.text = '';
          controller.comfirmPasswordController.text = '';
          return true;
        },
        child: Scaffold(
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
            automaticallyImplyLeading: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Form(
              key: controller.formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05,
                  vertical: height * 0.02,
                ),
                children: [
                  SizedBox(height: height * 0.012),

                  // Form Fields Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Old Password Field
                      Text(
                        'Old Password',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: height * 0.016,
                          height: 1.5,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                            () => TextFormField(
                          obscureText:
                          !controller.oldPasswordObsecureValue.value,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: width * 0.04,
                              vertical: height * 0.018,
                            ),
                            hintText: 'Insert your old password',
                            hintStyle: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: height * 0.0165,
                              color: Colors.grey,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFDDDDDD),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 253, 81, 81),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 253, 81, 81),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                controller.oldPasswordObsecureValue.value =
                                !controller.oldPasswordObsecureValue.value;
                              },
                              child: Icon(
                                controller.oldPasswordObsecureValue.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: controller.oldPasswordObsecureValue.value
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                size: height * 0.022,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: height * 0.0165,
                          ),
                          controller: controller.oldPasswordController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your old password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ),

                      SizedBox(height: height * 0.02),

                      // New Password Field
                      Text(
                        'New Password',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: height * 0.016,
                          height: 1.5,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                            () => TextFormField(
                          obscureText:
                          !controller.newPasswordObsecureValue.value,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: width * 0.04,
                              vertical: height * 0.018,
                            ),
                            hintText: 'Insert your new password',
                            hintStyle: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: height * 0.0165,
                              color: Colors.grey,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFDDDDDD),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 253, 81, 81),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 253, 81, 81),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                controller.newPasswordObsecureValue.value =
                                !controller.newPasswordObsecureValue.value;
                              },
                              child: Icon(
                                controller.newPasswordObsecureValue.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: controller.newPasswordObsecureValue.value
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                size: height * 0.022,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: height * 0.0165,
                          ),
                          controller: controller.newPasswordController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your new password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ),

                      SizedBox(height: height * 0.02),

                      // Confirm Password Field
                      Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: height * 0.016,
                          height: 1.5,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                            () => TextFormField(
                          obscureText:
                          !controller.comfirmPasswordObsecureValue.value,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: width * 0.04,
                              vertical: height * 0.018,
                            ),
                            hintText: 'Confirm your new password',
                            hintStyle: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: height * 0.0165,
                              color: Colors.grey,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFDDDDDD),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 253, 81, 81),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 253, 81, 81),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                controller.comfirmPasswordObsecureValue.value =
                                !controller
                                    .comfirmPasswordObsecureValue.value;
                              },
                              child: Icon(
                                controller.comfirmPasswordObsecureValue.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: controller
                                    .comfirmPasswordObsecureValue.value
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                size: height * 0.022,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: height * 0.0165,
                          ),
                          controller: controller.comfirmPasswordController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            if (value != controller.newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.only(
              bottom: 20.0,
              left: 16.0,
              right: 16.0,
            ),
            child: Obx(
                  () => AppButton(
                itemText: 'Update Password',
                keypressEvent: controller.isLoading.value
                    ? null
                    : () {
                  if (controller.formKey.currentState!.validate()) {
                    controller.changePassword();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}