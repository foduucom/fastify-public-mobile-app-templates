// ignore_for_file: prefer_const_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/components/foduuformtextfield.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_password_field.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_social_button.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_text.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_text_field.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  LoginView({Key? key}) : super(key: key);

  final loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;

    return Scaffold(
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
                  // First Row
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

                  // Description
                  AppText(
                    "Log in to Mono and experience a faster, easier way to send and receive money.",
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

            SizedBox(height: height * 0.05),

            // Form Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "Email",
                      fontSize: height * 0.016,
                      height: 1.5,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 4),
                    AppTextField(
                      controller: controller.emailController,
                      hintText: "Insert your email here",
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
                  ],
                ),

                SizedBox(height: height * 0.02),

                // Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "Password",
                      fontWeight: FontWeight.w600,
                      fontSize: height * 0.016,
                      height: 1.5,
                      letterSpacing: 0,
                    ),
                    SizedBox(height: 4),
                    AppPasswordField(
                      controller: controller.passwordController,
                      isVisible: controller.obsecuretext,
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
                  ],
                ),

                SizedBox(height: height * 0.02),

                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: width * 0.05,
                          height: width * 0.05,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: DefaultThemeColors.lightOnSecondary,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check,
                              size: width * 0.025,
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                        SizedBox(width: width * 0.02),
                        Text(
                          "Remember me",
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w600,
                            fontSize: width * 0.035,
                            color: DefaultThemeColors.darkmain,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        print('CLICKED ON Submit Button');
                        Get.toNamed(Routes.FORGETPASSWORD);
                      },
                      child: Text(
                        "Forgot Password",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: width * 0.035,
                          color: DefaultThemeColors.alertErrorLighter,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: height * 0.03),

                // Sign In Button
                PrimaryActionButton(
                  text: "Sign In",
                  backgroundColor: DefaultThemeColors.mainprimary,
                  textColor: DefaultThemeColors.lightOnPrimary,
                  onPressed: () {
                    //controller.signIn();
                    Get.toNamed(Routes.BOTTOMBAR);
                  },
                ),

                SizedBox(height: height * 0.03),

                // Divider with "Or sign in with"
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: DefaultThemeColors.lightDarker,
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
                          color: DefaultThemeColors.darklighter,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: DefaultThemeColors.lightDarker,
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
                    AppSocialButton(imagePath: 'assets/images/google.png'),
                    SizedBox(width: width * 0.05),
                    AppSocialButton(imagePath: 'assets/images/apple.png'),
                    SizedBox(width: width * 0.05),
                    AppSocialButton(imagePath: 'assets/images/facebook.png'),
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
                          color: DefaultThemeColors.darklighter,
                        ),
                      ),
                      SizedBox(width: width * 0.01),
                      InkWell(
                        onTap: () {
                          print('CLICKED ON CREATE AN ACCOUNT');
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

                // Extra space at bottom for keyboard
                SizedBox(height: height * 0.05),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
