// ignore_for_file: prefer_const_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_password_field.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_social_button.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_text.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_text_field.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/components/foduuformtextfield.dart';
import 'package:foduu_ecommerce/components/form_field.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';

import 'package:get/get.dart';
// import 'package:multicartapp/ants/ants.dart';

import '../controllers/register_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = Get.height;
    var width = Get.width;

    return Scaffold(
        body: SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        children: [
          SizedBox(height: height * 0.04),

          Container(
            margin: const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  "Create an account",
                  fontSize: height * 0.04,
                  height: 1.1,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  color: context.onBackgroundColor, // Theme-aware title
                ),

                const SizedBox(height: 8),

                // Description
                AppText(
                  "Create an account to manage your money transfers with Mono.",
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

          // Form Field
          Form(
            key: controller.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Name Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "Fullname",
                      fontSize: height * 0.016,
                      height: 1.5,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      color: context.onSurfaceColor, // Theme-aware label
                    ),
                    SizedBox(height: 4),
                    AppTextField(
                      controller: controller.nameController,
                      hintText: "Roberto Lavaruni",
                      keyboardType: TextInputType.name,
                      prefixIcon: Icons.person,
                      fontSize: height * 0.0165,
                      textColor: Theme.of(context).brightness == Brightness.dark
                          ? DefaultThemeColors.darklighter
                          : DefaultThemeColors.lightDarker,
                      hintColor: Theme.of(context).brightness == Brightness.dark
                          ? DefaultThemeColors.darklighter
                          : DefaultThemeColors.lightDarker,
                      borderColor: DefaultThemeColors.mainprimary!,
                      focusColor: DefaultThemeColors.mainprimary!,
                      disabledColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? DefaultThemeColors.darklighter
                              : DefaultThemeColors.lightDarker,
                      fillColor: context.surfaceColor, // Theme-aware background
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please Enter Your Full Name';
                        return null;
                      },
                    ),
                  ],
                ),

                SizedBox(height: height * 0.015),

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
                      color: context.onSurfaceColor, // Theme-aware label
                    ),
                    SizedBox(height: 4),
                    AppTextField(
                      controller: controller.emailController,
                      hintText: "robertolavaruno@gmail.com",
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      fontSize: height * 0.0165,
                      textColor: Theme.of(context).brightness == Brightness.dark
                          ? DefaultThemeColors.darklighter
                          : DefaultThemeColors.lightDarker,
                      hintColor: Theme.of(context).brightness == Brightness.dark
                          ? DefaultThemeColors.darklighter
                          : DefaultThemeColors.lightDarker,
                      borderColor: DefaultThemeColors.mainprimary!,
                      focusColor: DefaultThemeColors.mainprimary!,
                      disabledColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? DefaultThemeColors.darklighter
                              : DefaultThemeColors.lightDarker,
                      fillColor: context.surfaceColor, // Theme-aware background
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

                SizedBox(height: height * 0.015),

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
                      color: context.onSurfaceColor, // Theme-aware label
                    ),
                    SizedBox(height: 4),
                    AppPasswordField(
                      controller: controller.passwordController,
                      isVisible: controller.showPassword,
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

                SizedBox(height: height * 0.015),

                // Phone Number Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "Phone Number(Don't Use Country Code)",
                      fontSize: height * 0.016,
                      height: 1.5,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      color: context.onSurfaceColor, // Theme-aware label
                    ),
                    SizedBox(height: 4),
                    AppTextField(
                      controller: controller.mobileController,
                      hintText: "9876543210",
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_android_outlined,
                      fontSize: height * 0.0165,
                      textColor: Theme.of(context).brightness == Brightness.dark
                          ? DefaultThemeColors.darklighter
                          : DefaultThemeColors.lightDarker,
                      hintColor: Theme.of(context).brightness == Brightness.dark
                          ? DefaultThemeColors.darklighter
                          : DefaultThemeColors.lightDarker,
                      borderColor: DefaultThemeColors.mainprimary!,
                      focusColor: DefaultThemeColors.mainprimary!,
                      disabledColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? DefaultThemeColors.darklighter
                              : DefaultThemeColors.lightDarker,
                      fillColor: context.surfaceColor, // Theme-aware background
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter your Phone No';
                        return null;
                      },
                    ),
                  ],
                ),

                SizedBox(height: height * 0.015),

                // Wrap with Obx to make it reactive
                Obx(() => Row(
                      children: [
                        // Checkbox
                        Checkbox(
                          value: controller.isChecked.value,
                          onChanged: (bool? value) {
                            controller.toggleCheckbox();
                          },
                          activeColor: DefaultThemeColors.mainprimary,
                          checkColor:
                              context.onPrimaryColor, // Theme-aware checkmark
                          visualDensity: VisualDensity.compact,
                        ),

                        // Flexible text row
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                "I agree to the ",
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: width * 0.035,
                                  color: context
                                      .onSurfaceVariantColor, // Theme-aware
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  print('Terms & Conditions tapped');
                                },
                                child: Text(
                                  'Terms & Conditions',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: width * 0.035,
                                    fontWeight: FontWeight.bold,
                                    color: DefaultThemeColors.mainprimary,
                                  ),
                                ),
                              ),
                              Text(
                                " and ",
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: width * 0.035,
                                  color: context
                                      .onSurfaceVariantColor, // Theme-aware
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  print('Privacy Policy tapped');
                                },
                                child: Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: width * 0.035,
                                    fontWeight: FontWeight.bold,
                                    color: DefaultThemeColors.mainprimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),

                SizedBox(height: height * 0.025),

                // Sign Up Button
                PrimaryActionButton(
                  text: "Sign Up",
                  backgroundColor: DefaultThemeColors.mainprimary,
                  textColor: context.onPrimaryColor, // Theme-aware text color
                  isLoading: controller.isLoading.value,
                  onPressed: () {
                    if (controller.formKey.currentState!.validate() &&
                        controller.isChecked.value &&
                        !controller.isLoading.value) {
                      controller.onSubmit();
                    } else if (!controller.isChecked.value) {
                      HelperFunctions().showSnackBarError(
                          'Please accept terms & conditions');
                    }
                  },
                ),

                SizedBox(height: height * 0.03),

                // Divider with "Or sign in with"
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: context.outlineColor, // Theme-aware divider
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
                              context.onSurfaceVariantColor, // Theme-aware text
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: context.outlineColor, // Theme-aware divider
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

                // Sign In Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an Account?',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: width * 0.04,
                          color: context.onSurfaceVariantColor, // Theme-aware
                        ),
                      ),
                      SizedBox(width: width * 0.01),
                      InkWell(
                        onTap: () {
                          print('CLICKED ON CREATE AN ACCOUNT');
                          Get.toNamed(Routes.LOGIN);
                        },
                        child: Text(
                          'Sign In',
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
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
