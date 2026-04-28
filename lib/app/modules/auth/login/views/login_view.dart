// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/components/foduuformtextfield.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Transform.translate(
          offset: Offset(15, 0),
          child: Image.asset('assets/images/logo.png'),
        ),
        leadingWidth: 77,
        actions: [
          InkWell(
            onTap: () {
              controller.box.write('isLogin', false);
              // Get.offAllNamed(Routes.INTRO);
              Get.offAllNamed(Routes.BOTTOMBAR);
            },
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text(
                  'SKIP',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          HelperFunctions().closeKeyboard(context);
        },
        child: Padding(
          padding: pageSurroundingPadding,
          child: Form(
            key: controller.formKey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'sdfsdfd' + ACCESS_KEY,
                    //   style: TextStyle(color: Colors.white),
                    // ),
                    // Text('sffdf+' + websiteDomain,
                    //     style: TextStyle(color: Colors.white)),
                    Text(
                      AuthDetails.isUserLogin().toString(),
                      style: TextStyle(color: Colors.red),
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Hey, \n',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Lato',
                        ),
                        children: [TextSpan(text: 'Login Now')],
                      ),
                    ),
                    SizedBox(height: 60),

                    // Email Field
                    FoduuFormTextField(
                      fieldHintText: '',
                      title: 'Email',
                      validationmsg: 'Please enter email',
                      validCheck: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter an email address".tr;
                        } else if (!GetUtils.isEmail(value)) {
                          return "Please enter a valid email address".tr;
                        }
                        return null;
                      },
                      keyType: TextInputType.emailAddress,
                      controller: controller.emailController,
                    ),
                    SizedBox(height: 20),

                    // Password Field - only show if password mode
                    Obx(() {
                      if (!controller.isOtpMode.value) {
                        return Column(
                          children: [
                            FoduuFormTextField(
                              // cursorColor: themeSecondrytext,
                              obsecure: controller.obsecuretext.value,
                              controller: controller.passwordController,
                              title: 'Password',
                              validationmsg: '',

                              fieldHintText: '',
                              keyType: TextInputType.visiblePassword,
                              validCheck: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length < 6) {
                                  return 'Please enter valid Password';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 9),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.toNamed(Routes.FORGETPASSWORD);
                                  },
                                  child: Text(
                                    'Forgot Password ?',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.8),
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      return SizedBox.shrink();
                    }),

                    SizedBox(height: 30),

                    // Login Button
                    Obx(() {
                      if (controller.isLoading.value) {
                        return Center(
                          child: const CircularProgressIndicator(
                              // color: themegreyColor,
                              ),
                        );
                      } else {
                        return AppButton(
                          itemText: controller.isOtpMode.value
                              ? 'Send OTP'
                              : 'Sign In',
                          keypressEvent: () {
                            print('Loing click click click lickc ');
                            HelperFunctions().closeKeyboard(context);
                            controller.onSubmit();
                          },
                        );
                      }
                    }),

                    SizedBox(height: Get.height * 0.04),
                    const SizedBox(height: 10),

                    // Redirect to registration page
                    Center(
                      child: TextButton(
                        onPressed: () {
                          HelperFunctions().closeKeyboard(context);
                          Get.offNamed(Routes.REGISTER);
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'For New User '.tr,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'create now'.tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                  fontSize: 15,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
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
      ),
    );
  }
}
