import 'package:flutter/material.dart';
import 'package:zouhi/app/modules/auth/mobile_number/controller.dart/mobileLogin_contgroller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/CustomTextField.dart';
import 'package:zouhi/components/buttons/appbutton.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:get/get.dart';

class MobileNoLoginView extends StatefulWidget {
  const MobileNoLoginView({Key? key}) : super(key: key);

  @override
  State<MobileNoLoginView> createState() => _MobileNoLoginViewState();
}

class _MobileNoLoginViewState extends State<MobileNoLoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final MobileNoLoginController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<MobileNoLoginController>()) {
      controller = Get.find<MobileNoLoginController>();
    } else {
      controller = Get.put(MobileNoLoginController());
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
      body: GestureDetector(
        onTap: () {
          HelperFunctions().closeKeyboard(context);
        },
        child: Padding(
          padding: pageSurroundingPadding,
          child: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                        text: TextSpan(
                            text: 'Hey, \n',
                            style: TextStyle(
                                fontSize: 25,
                                color: context.colors.onSurface,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins'),
                            children: const [TextSpan(text: 'Login Now')])),
                    const SizedBox(height: 60),
                    // if (isOtpLogin == true)
                    CartTextField(
                        fieldHintText: '',
                        title: 'Mobile Number'.tr,
                        validationmsg: '',
                        maxLength: 10,
                        validCheck: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 10) {
                            return "Please enter a valid phone number".tr;
                          }
                          return null;
                        },
                        keyType: TextInputType.number,
                        controller: controller.moibileNocontroller),
                    // PhoneFormFieldHint(
                    //   controller: controller.usernameController,
                    //   inputFormatters: [RemoveEmojiInputFormatter()],
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
                    //         borderRadius: BorderRadius.circular(8),
                    //         borderSide: BorderSide(
                    //           color: greyBorder,
                    //           width: 1,
                    //         ),
                    //       ),
                    //       hintText: "enterno.".tr,
                    //       labelText: 'num'.tr,
                    //       labelStyle:
                    //           TextStyle(fontSize: 18, color: greyTextColor),
                    //       hintStyle: const TextStyle(
                    //           fontSize: 16, color: Colors.grey)),
                    //   validator: (value) {
                    //     if (value == null ||
                    //         value.isEmpty ||
                    //         value.length < 10) {
                    //       return "validnum".tr;
                    //     }
                    //     return null;
                    //   },
                    // ),
                    // SizedBox(
                    //     height:
                    //         !isOtpLogin ? Get.height * 0.5 : Get.height * 0.05),
                    const SizedBox(
                      height: 20,
                    ),
                    AppButton(
                        itemText: "signin".tr,
                        // radius: 8,
                        keypressEvent: () async {
                          HelperFunctions().closeKeyboard(context);
                          // if (isOtpLogin) {
                          //   controller.sendOtp();
                          // } else {
                          await controller.onSubmit(
                              mobileNo: int.parse(
                                  controller.moibileNocontroller.text),
                              formKey: _formKey);
                          // }
                        }),
                    SizedBox(height: Get.height * 0.04),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          HelperFunctions().closeKeyboard(context);
                          Get.toNamed(Routes.MOBILEREGISTER);
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'For New User '.tr,
                            style: TextStyle(
                                color: context.themeTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'create now'.tr,
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
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          HelperFunctions().closeKeyboard(context);
                          Get.toNamed(Routes.HELPANDSUPPORT);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Icon(
                                Icons.headset_mic_outlined,
                                size: 18,
                                color: context.themePrimaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Need help? '.tr,
                                style: TextStyle(
                                  color: context.themeSecondrytext,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Contact Support'.tr,
                                style: TextStyle(
                                  color: context.themePrimaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
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
