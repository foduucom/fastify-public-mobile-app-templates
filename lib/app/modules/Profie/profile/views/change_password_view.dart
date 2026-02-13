import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/controllers/profile_controller.dart';
import 'package:foduu_ecommerce/components/foduuformtextfield.dart';
import 'package:foduu_ecommerce/components/form_field.dart';
import 'package:foduu_ecommerce/constants/constants.dart';

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
            appBar: AppBar(
              leading: Transform.translate(
                offset: const Offset(15, 0),
                child: Image.asset('assets/images/logo.png', width: 77),
              ),
              automaticallyImplyLeading: true,
              leadingWidth: 77,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
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
                      const Text(
                        'Change Password',
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
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
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFFDDDDDD), width: 1)),
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFFDDDDDD), width: 1)),
                              focusedErrorBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 253, 81, 81),
                                      width: 1)),
                              errorBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 253, 81, 81),
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
                                          : Colors.grey)),
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
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFFDDDDDD), width: 1)),
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFFDDDDDD), width: 1)),
                              focusedErrorBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 253, 81, 81),
                                      width: 1)),
                              errorBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 253, 81, 81),
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
                                          : Colors.grey)),
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
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFFDDDDDD), width: 1)),
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFFDDDDDD), width: 1)),
                              focusedErrorBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 253, 81, 81),
                                      width: 1)),
                              errorBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 253, 81, 81),
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
                                          : Colors.grey)),
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
