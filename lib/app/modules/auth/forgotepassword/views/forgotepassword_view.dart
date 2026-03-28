import 'package:flutter/material.dart';
// import '/app/modules/auth/resetpassword/views/resetpassword_view.dart';
import '/app/routes/app_pages.dart';
import '/components/buttons/appbutton.dart';
import '/constants/constants.dart';
import 'package:get/get.dart';
import '../controllers/forgotepassword_controller.dart';

class ForgotepasswordView extends GetView<ForgotepasswordController> {
  const ForgotepasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            leading: Transform.translate(
              offset: const Offset(15, 0),
              child: Image.asset('assets/images/logo.png', width: 77),
            ),
            leadingWidth: 77,
            actions: [
              InkWell(
                  onTap: () {},
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Text(
                        'SKIP',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Lato'),
                      ),
                    ),
                  ))
            ],
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
                      'Forgot Password',
                      style: TextStyle(
                          fontSize: 25,
                          fontFamily: 'Lato',
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    // const AppFormTextField(
                    //   fieldHintText: "Email Address",
                    // ),
                    const SizedBox(height: 20),
                    AppButton(
                        itemText: 'Send Otp',
                        keypressEvent: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       // builder: (context) => ResetpasswordView()
                          //       ),
                          // );
                        }),
                    const SizedBox(height: 20),
                    Center(
                      child: InkWell(
                        onTap: () {
                          isOtpLogin
                              ? Get.offAllNamed(Routes.MOBILELOGIN)
                              : Get.offAllNamed(Routes.LOGIN);
                        },
                        child: RichText(
                            text: const TextSpan(
                                text: 'Back to ',
                                style: TextStyle(
                                    // color: themeSecondrytext,
                                    fontFamily: 'Lato'),
                                children: [
                              TextSpan(
                                  text: 'Sign In',
                                  style: TextStyle(
                                      color: Color(0xFF222222),
                                      decoration: TextDecoration.underline))
                            ])),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
