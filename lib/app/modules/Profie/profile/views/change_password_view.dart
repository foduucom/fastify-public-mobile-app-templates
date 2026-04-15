import 'package:flutter/material.dart';
import '../../../../../components/app_bar.dart';
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
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          controller.newPasswordController.text = '';
          controller.oldPasswordController.text = '';
          controller.comfirmPasswordController.text = '';
          return true;
        },
        child: Scaffold(
            appBar:  CustomAppBar(title: 'Change Password'),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: pageSurroundingPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      Text(
                        'Change Password',
                        style: TextStyle(
                            fontSize: 25,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),
                      // FoduuFormTextField(
                      //   fieldHintText: '',
                      //   title: 'Old Password',
                      //   keyType: TextInputType.text,
                      //   readOnly: false,
                      //   validationmsg: '',
                      //   controller: controller.oldPasswordController,
                      //   validCheck: (value) {
                      //     if (value == null ||
                      //         value.isEmpty ||
                      //         value.length < 6) {
                      //       return 'Please enter valid full name!';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      // SizedBox(
                      //   height: 20,
                      // ),
                      // FoduuFormTextField(
                      //   fieldHintText: '',
                      //   title: 'New Password',
                      //   keyType: TextInputType.text,
                      //   readOnly: false,
                      //   validationmsg: '',
                      //   controller: controller.newPasswordController,
                      //   validCheck: (value) {
                      //     if (value == null ||
                      //         value.isEmpty ||
                      //         value.length < 6) {
                      //       return 'Please enter valid full name!';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      // const SizedBox(height: 20),
                      // FoduuFormTextField(
                      //   fieldHintText: '',
                      //   title: 'Confirm Password',
                      //   keyType: TextInputType.text,
                      //   readOnly: false,
                      //   validationmsg: '',
                      //   obsecure: true,
                      //   controller: controller.comfirmPasswordController,
                      //   validCheck: (value) {
                      //     if (value == null ||
                      //         value.isEmpty ||
                      //         value.length < 6) {
                      //       return 'Please enter valid full name!';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      SizedBox(
                        height: 10,
                      ),
                      Obx(
                        () => TextFormField(
                          // cursorColor: themeSecondrytext,
                          obscureText:
                              !controller.oldPasswordObsecureValue.value,
                          decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              contentPadding: const EdgeInsets.fromLTRB(
                                  30.0, 15.0, 30.0, 15.0),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.outline, width: 1)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.outline, width: 1)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.error,
                                      width: 1)),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.error,
                                      width: 1)),
                              // labelStyle: const TextStyle(
                              //     color: themeSecondrytext, fontFamily: 'Lato'),
                              suffixIcon: GestureDetector(
                                  onTap: (() {
                                    controller.oldPasswordObsecureValue.value =
                                        !controller
                                            .oldPasswordObsecureValue.value;
                                  }),
                                  child: Icon(
                                      controller.oldPasswordObsecureValue.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: controller
                                              .oldPasswordObsecureValue.value
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).colorScheme.onSurfaceVariant)),
                              labelText: 'Old password'),
                          controller: controller.oldPasswordController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 6) {
                              return 'Please enter valid Password';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => TextFormField(
                          // cursorColor: themeSecondrytext,
                          obscureText:
                              !controller.newPasswordObsecureValue.value,
                          decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              contentPadding: const EdgeInsets.fromLTRB(
                                  30.0, 15.0, 30.0, 15.0),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.outline, width: 1)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.outline, width: 1)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.error,
                                      width: 1)),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.error,
                                      width: 1)),
                              suffixIcon: GestureDetector(
                                  onTap: (() {
                                    print('object');
                                    controller.newPasswordObsecureValue.value =
                                        !controller
                                            .newPasswordObsecureValue.value;
                                  }),
                                  child: Icon(
                                      controller.newPasswordObsecureValue.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: controller
                                              .newPasswordObsecureValue.value
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).colorScheme.onSurfaceVariant)),
                              labelText: 'New password'),
                          controller: controller.newPasswordController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 6) {
                              return 'Please enter valid Password';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => TextFormField(
                          // cursorColor: themeSecondrytext,
                          obscureText:
                              !controller.comfirmPasswordObsecureValue.value,
                          decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              contentPadding: const EdgeInsets.fromLTRB(
                                  30.0, 15.0, 30.0, 15.0),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.outline, width: 1)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.outline, width: 1)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.error,
                                      width: 1)),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.error,
                                      width: 1)),
                              // labelStyle: const TextStyle(
                              //     color: themeSecondrytext, fontFamily: 'Lato'),
                              suffixIcon: GestureDetector(
                                  onTap: (() {
                                    print('object');
                                    controller.comfirmPasswordObsecureValue
                                            .value =
                                        !controller
                                            .comfirmPasswordObsecureValue.value;
                                  }),
                                  child: Icon(
                                      controller.comfirmPasswordObsecureValue
                                              .value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: controller
                                              .comfirmPasswordObsecureValue
                                              .value
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).colorScheme.onSurfaceVariant)),
                              labelText: 'Confirm password'),
                          controller: controller.comfirmPasswordController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 6) {
                              return 'Please enter valid Password';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                          itemText: 'Change password',
                          keypressEvent: () {
                            controller.changePassword();
                          }),
                      const SizedBox(height: 20),
                      Center(
                        child: InkWell(
                          onTap: () {
                            Get.back();
                            controller.newPasswordController.text = '';
                            controller.oldPasswordController.text = '';
                            controller.comfirmPasswordController.text = '';
                            controller.newPasswordObsecureValue.value = false;
                            controller.oldPasswordObsecureValue.value = false;
                            controller.comfirmPasswordObsecureValue.value =
                                false;
                          },
                          child: RichText(
                              text: TextSpan(
                                  text: 'Back',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                  children: [])),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
