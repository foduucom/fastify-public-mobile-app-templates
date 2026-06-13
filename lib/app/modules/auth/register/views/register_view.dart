// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/components/foduuformtextfield.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

import 'package:get/get.dart';
// import 'package:multicartapp/ants/ants.dart';

import '../controllers/register_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  RegisterController get controller => Get.find<RegisterController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          heroTag: 'register_fab',
          onPressed: () {
            print(controller.box.read('auth_preference'));
          },
        ),
        appBar: AppBar(
          leading: Transform.translate(
            offset: Offset(15, 0),
            child: Image.asset('assets/images/logo.png', width: 77),
          ),
          leadingWidth: 77,
          actions: [
            GestureDetector(
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
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            )
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: pageSurroundingPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.isOtpMode.value.toString()),

                /// ------------- Title -------------
                RichText(
                  text: TextSpan(
                    text: 'Hey,\n',
                    style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'Lato',
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                    children: const [
                      TextSpan(text: 'Sign Up'),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                /// ------------- FORM -------------
                Form(
                  key: _formKey, // ✔ Only ONE GlobalKey used
                  child: Column(
                    children: [
                      /// NAME (Always visible)
                      FoduuFormTextField(
                        title: 'Name',
                        fieldHintText: "Name",
                        controller: controller.nameController,
                        keyType: TextInputType.name,
                        validCheck: (value) {
                          if (value == null || value.trim().length < 2) {
                            return 'Enter valid name';
                          }
                          return null;
                        },
                        validationmsg: "Enter valid full name!",
                      ),
                      SizedBox(height: 20),

                      /// MOBILE (Always visible)
                      FoduuFormTextField(
                        fieldHintText: "Phone",
                        keyType: TextInputType.phone,
                        title: 'Phone',
                        controller: controller.mobileController,
                        // validCheck: (value) {
                        //   if (value == null || value.length != 10) {
                        //     return 'Enter valid mobile number';
                        //   }
                        //   return null;
                        // },
                        validationmsg: "Enter valid mobile number!",
                      ),
                      SizedBox(height: 20),

                      /// EMAIL (Always visible)
                      FoduuFormTextField(
                        fieldHintText: "Email",
                        title: 'Email',
                        controller: controller.emailController,
                        keyType: TextInputType.emailAddress,
                        validCheck: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email required";
                          }
                          if (!GetUtils.isEmail(value)) {
                            return "Enter valid email";
                          }
                          return null;
                        },
                        validationmsg: "Enter valid email address!",
                      ),
                      SizedBox(height: 20),

                      /// PASSWORD (Only for password registration)
                      Obx(() {
                        if (controller.isPasswordMode.value) {
                          return FoduuFormTextField(
                            fieldHintText: "Password",
                            obsecure: true,
                            keyType: TextInputType.visiblePassword,
                            title: 'Password',
                            controller: controller.passwordController,
                            validCheck: (value) {
                              if (value == null || value.length < 6) {
                                return "Password must be 6+ characters";
                              }
                              return null;
                            },
                            validationmsg: "Enter valid password!",
                          );
                        }
                        return SizedBox.shrink();
                      }),

                      SizedBox(height: 10),

                      /// TERMS CHECKBOX
                      Row(
                        children: [
                          Obx(
                            () => Checkbox(
                              // activeColor: themeRedColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              value: controller.isChecked.value,
                              onChanged: controller.onChecked,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed(Routes.TERMSANDCONDITION),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.grey.shade500),
                                children: [
                                  TextSpan(
                                    text: "I accept ",
                                    style: TextStyle(
                                        fontFamily: "Poppins", fontSize: 13),
                                  ),
                                  TextSpan(
                                    text: "Terms & Conditions",
                                    style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 13,
                                        decoration: TextDecoration.underline),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      Obx(() {
                        if (controller.isLoading.value) {
                          return const CircularProgressIndicator(
                              // color: themegreyColor,
                              );
                        } else {
                          return AppButton(
                            itemText: controller.isOtpMode.value
                                ? "Send OTP"
                                : "SIGN UP",
                            keypressEvent: () {
                              HelperFunctions().closeKeyboard(context);
                              controller.onSubmit(_formKey);
                            },
                          );
                        }
                      }),

                      SizedBox(height: 20),
                    ],
                  ),
                ),

                SizedBox(height: Get.height * 0.1),

                /// LOGIN redirect
                Center(
                  child: InkWell(
                    onTap: () => Get.offNamed(Routes.LOGIN),
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an Account? ",
                        style: TextStyle(
                            fontFamily: 'Lato',
                            color: Theme.of(context).colorScheme.onSurface),
                        children: [
                          TextSpan(
                            text: "Sign In",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              decoration: TextDecoration.underline,
                            ),
                          )
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
    );
  }
}
