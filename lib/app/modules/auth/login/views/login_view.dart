// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_social_button.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_password_field.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_text.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_text_field.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leadingWidth: 77,
        actions: [
          InkWell(
            onTap: () {
              controller.box.write('isLogin', false);
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
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          children: [
            SizedBox(height: height * 0.04),

            // Welcome Section
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: AppText(
                          "Hi, Welcome!",
                          fontSize: height * 0.04,
                          height: 1.1,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? DefaultThemeColors.lightDarker
                              : DefaultThemeColors.lightOnBackground,
                        ),
                      ),
                      SizedBox(width: 8),
                      Image.asset(
                        'assets/images/hello.png',
                        width: height * 0.045,
                        height: height * 0.045,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    "Log in to Mono and experience a faster, easier way to send and receive money.",
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

            SizedBox(height: height * 0.05),

            // Form Section - OTP Only (No Password Field)
            Form(
              key: controller.loginFormKey,
              child: Column(
                children: [
                  // Email or Phone Field
                  Obx(() => controller.isMobileOtpMode.value
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              "Phone Number",
                              fontSize: height * 0.016,
                              height: 1.5,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? DefaultThemeColors.lightDarker
                                  : DefaultThemeColors.lightOnBackground,
                            ),
                            SizedBox(height: 4),
                            IntlPhoneField(
                              controller: controller.mobileController,
                              decoration: InputDecoration(
                                hintText: 'Phone Number',
                                hintStyle: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? DefaultThemeColors.darklighter
                                      : DefaultThemeColors.lightDarker,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: DefaultThemeColors.mainprimary!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: DefaultThemeColors.mainprimary!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: DefaultThemeColors.mainprimary!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.phone_android_outlined,
                                  color: DefaultThemeColors.mainprimary,
                                ),
                              ),
                              initialCountryCode: 'IN',
                              languageCode: "en",
                              onChanged: (phone) {
                                controller.countryCode.value =
                                    phone.countryCode;
                              },
                              onCountryChanged: (country) {
                                controller.countryCode.value = country.dialCode;
                              },
                              validator: (value) {
                                if (value == null || value.number.isEmpty) {
                                  return 'Please enter your Phone No';
                                }
                                return null;
                              },
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              "Email",
                              fontSize: height * 0.016,
                              height: 1.5,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? DefaultThemeColors.lightDarker
                                  : DefaultThemeColors.lightOnBackground,
                            ),
                            SizedBox(height: 4),
                            AppTextField(
                              controller: controller.emailController,
                              hintText: "Enter your email",
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              fontSize: height * 0.0165,
                              textColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? DefaultThemeColors.darklighter
                                  : DefaultThemeColors.lightDarker,
                              hintColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? DefaultThemeColors.darklighter
                                  : DefaultThemeColors.lightDarker,
                              borderColor: DefaultThemeColors.mainprimary,
                              focusColor: DefaultThemeColors.mainprimary,
                              disabledColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? DefaultThemeColors.darklighter
                                  : DefaultThemeColors.lightDarker,
                              fillColor: Theme.of(context).colorScheme.surface,
                              //validator: controller.validEmail,
                            ),
                          ],
                        )),

                  Obx(() => controller.isPasswordMode.value
                      ? Column(
                          children: [
                            SizedBox(height: height * 0.02),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  "Password",
                                  fontSize: height * 0.016,
                                  height: 1.5,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? DefaultThemeColors.lightDarker
                                      : DefaultThemeColors.lightOnBackground,
                                ),
                                SizedBox(height: 4),
                                AppPasswordField(
                                  controller: controller.passwordController,
                                  isVisible: controller.obsecuretext,
                                  onToggle: controller.togglePasswordVisibility,
                                  fontSize: height * 0.0165,
                                  hintText: "Enter your password",
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter your password";
                                    }
                                    if (value.length < 6) {
                                      return "Password must be at least 6 characters";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox.shrink()),

                  SizedBox(height: height * 0.03),

                  // Send OTP Button
                  Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: DefaultThemeColors.mainprimary,
                        ),
                      );
                    } else {
                      return PrimaryActionButton(
                        text: controller.isPasswordMode.value
                            ? 'Login'
                            : 'Send OTP',
                        backgroundColor: DefaultThemeColors.mainprimary,
                        textColor: DefaultThemeColors.lightOnPrimary,
                        onPressed: () {
                          print(
                              '${controller.isPasswordMode.value ? 'Login' : 'Send OTP'} button clicked');
                          HelperFunctions().closeKeyboard(context);
                          controller.onSubmit();
                        },
                      );
                    }
                  }),

                  SizedBox(height: height * 0.03),

                  // Divider with "Or sign in with"
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Theme.of(context).colorScheme.outline,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Or sign in with :",
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Theme.of(context).colorScheme.outline,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: height * 0.03),

                  // Social Login Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppSocialButton(
                        imagePath: 'assets/images/google.png',
                        //onPressed: controller.handleGoogleSignIn,
                      ),
                      SizedBox(width: width * 0.05),
                      AppSocialButton(
                        imagePath: 'assets/images/apple.png',
                        //onPressed: controller.handleAppleSignIn,
                      ),
                      SizedBox(width: width * 0.05),
                      AppSocialButton(
                        imagePath: 'assets/images/facebook.png',
                        //onPressed: controller.handleFacebookSignIn,
                      ),
                    ],
                  ),

                  SizedBox(height: height * 0.04),

                  // Sign Up Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: width * 0.04,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: width * 0.01),
                        InkWell(
                          onTap: () {
                            print('Sign up clicked');
                            Get.toNamed(Routes.REGISTER);
                          },
                          child: Text(
                            'Sign up',
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
                  ),

                  SizedBox(height: height * 0.05),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
