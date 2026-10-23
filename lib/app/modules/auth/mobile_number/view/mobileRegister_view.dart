import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zouhi/app/modules/auth/email_password/register/controllers/register_controller.dart';
import 'package:zouhi/components/CustomTextField.dart';
import 'package:zouhi/components/buttons/appbutton.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class MobileNoRegisterView extends StatefulWidget {
  const MobileNoRegisterView({Key? key}) : super(key: key);

  @override
  State<MobileNoRegisterView> createState() => _MobileNoRegisterViewState();
}

class _MobileNoRegisterViewState extends State<MobileNoRegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final RegisterController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<RegisterController>()) {
      controller = Get.find<RegisterController>();
    } else {
      controller = Get.put(RegisterController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: Transform.translate(
          offset: Offset(15, 0),
          child: Image.asset('assets/images/logo.png'),
        ),
        leadingWidth: 77,
      ),
      body: Padding(
        padding: pageSurroundingPadding,
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hey,',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),

                  const Text('Signup Now',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 30),
                  CartTextField(
                      fieldHintText: '',
                      title: 'Full Name',
                      validationmsg: '',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
                      ],
                      validCheck: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        if (value.trim().length < 3) {
                          return 'Name must be at least 3 characters!';
                        }
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                          return 'Name can only contain letters and spaces!';
                        }
                        return null;
                      },
                      maxLength: 0,
                      controller: controller.nameController),
                  SizedBox(height: Get.height * 0.03),
                  CartTextField(
                      fieldHintText: '',
                      title: 'Email',
                      validationmsg: '',
                      // inputFormatters: [RemoveEmojiInputFormatter()],
                      maxLength: 0,
                      validCheck: (value) {
                        if (value != null && !GetUtils.isEmail(value)) {
                          return "Please enter a valid Email";
                        }
                        return null;
                      },
                      controller: controller.emailController),
                  SizedBox(height: Get.height * 0.03),
                  // CartTextField(
                  //     fieldHintText: '',
                  //     title: 'Mobile Number',
                  //     validationmsg: '',
                  //     maxLength: 15,
                  //     validCheck: (value) {
                  //       if (value == null ||
                  //           value.isEmpty ||
                  //           value.length < 15) {
                  //         return "Please enter a valid phone number";
                  //       }
                  //       return null;
                  //     },
                  //     keyType: TextInputType.number,
                  //     controller: controller.mobileController),
                  // PhoneFormFieldHint(
                  //   controller: controller.mobileController,
                  //   decoration: InputDecoration(
                  //       floatingLabelBehavior: FloatingLabelBehavior.always,
                  //       contentPadding: const EdgeInsets.symmetric(
                  //           vertical: 10.0, horizontal: 20.0),
                  //       enabledBorder: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(8),
                  //           borderSide:
                  //               BorderSide(color: greyBorder, width: 1)),
                  //       focusedBorder: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(8),
                  //           borderSide:
                  //               BorderSide(color: greyBorder, width: 1)),
                  //       border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(8),
                  //           borderSide:
                  //               BorderSide(color: greyBorder, width: 1)),
                  //       hintText: "Enter your mobile number",
                  //       labelText: 'Mobile No.',
                  //       labelStyle:
                  //           TextStyle(fontSize: 18, color: greyTextColor),
                  //       hintStyle:
                  //           const TextStyle(fontSize: 16, color: Colors.grey)),
                  //   validator: (value) {
                  //     if (value == null ||
                  //         value.isEmpty ||
                  //         value.length != 10
                  //        ) {
                  //       return 'Please enter valid mobile number!';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  const SizedBox(height: 10),
                  // Obx(
                  //   () => FoduuFormTextField(
                  //     onsaved: (String? value) {},
                  //     title: '',
                  //
                  //     controller: controller.passwordController,
                  //     fieldHintText: "Password",
                  //     obsecure: controller.showPassword.isFalse ? true : false,
                  //     validCheck: (value) {
                  //       if (value == null ||
                  //           value.isEmpty ||
                  //           value.length < 6) {
                  //         return 'Please enter valid password!';
                  //       }
                  //       return null;
                  //     },
                  //     validationmsg: "",
                  //   ),
                  // ),
                  // SizedBox(height: !isOtpLogin ? 40.0 : 20.0),
                  Obx(() => controller.isLoading.isFalse
                      ? AppButton(
                          itemText: "SIGN UP",
                          // radius: 8,
                          keypressEvent: () async {
                            HelperFunctions().closeKeyboard(context);
                            await controller.onSubmit(_formKey);
                          })
                      : HelperFunctions().loadingIndicator()),
                  SizedBox(height: Get.height * 0.04),
                  // Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //     children: [
                  //   SizedBox(
                  //       width: Get.width * 0.32,
                  //       child: Divider(color: greyBorder, thickness: 1.5)),
                  //   Text('Or sign up with',
                  //       style: TextStyle(
                  //           color: greyTextColor,
                  //           fontSize: 14,
                  //           fontWeight: FontWeight.w400)),
                  //   SizedBox(
                  //       width: Get.width * 0.32,
                  //       child: Divider(color: greyBorder, thickness: 1.5))
                  // ]),
                  // SizedBox(height: 25),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     IconButton(
                  //         iconSize: 50,
                  //         onPressed: () {},
                  //         icon: Image.asset('assets/images/google.png')),
                  //     IconButton(
                  //         iconSize: 50,
                  //         onPressed: () {},
                  //         icon: Image.asset('assets/images/facebook.png')),
                  //   ],
                  // ),

                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        HelperFunctions().closeKeyboard(context);
                        Get.back();
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an Account? ',
                          style: TextStyle(
                              color: context.themeTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                fontSize: 15,
                                color: context.colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
