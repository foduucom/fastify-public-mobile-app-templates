import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/app/modules/contact/controller/contact_controller.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/components/check_internet_widget.dart';
import 'package:foduu_ecommerce/components/foduuformtextfield.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';

class ContactView extends GetView<ContactController> {
  const ContactView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var logoAssetsPath = 'assets/icon/logo.svg';
    return Scaffold(
      appBar: AppBar(title: const Text('Contact us'), elevation: 0.0),
      body: GestureDetector(
        onTap: () {
          HelperFunctions().closeKeyboard(context);
        },
        child: FoduuCheckInternetBody(
          child: Center(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // if (logoAssetsPath != null &&
                      //     logoAssetsPath.toString().contains(".svg"))
                      //   SizedBox(
                      //     width: double.infinity,
                      //     height: MediaQuery.of(context).size.width * 0.2,
                      //     child: SvgPicture.asset(logoAssetsPath!),
                      //   ),
                      // if (logoAssetsPath != null &&
                      //     (logoAssetsPath.toString().contains(".jpg") ||
                      //         logoAssetsPath.toString().contains(".png")))
                      SizedBox(
                        width: 200,
                        height: 100,
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      if (logoAssetsPath != null) const SizedBox(height: 20.0),
                      // const Text(
                      //   "CONTACT US",
                      //   style: TextStyle(
                      //       fontWeight: FontWeight.w600,
                      //       fontSize: 16,
                      //       fontFamily: "Poppins"),
                      // ),
                      const SizedBox(height: 20.0),
                      if (controller.boxUserData.isEmpty)
                        Column(
                          children: [
                            FoduuFormTextField(
                              // onsaved: (String? value) {},
                              title: 'Enter Full Name',
                              controller: controller.nameController,
                              fieldHintText: "",
                              validCheck: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length < 6) {
                                  return 'Please enter valid full name!';
                                }
                                return null;
                              },
                              validationmsg: "",
                            ),
                            const SizedBox(height: 15.0),
                            FoduuFormTextField(
                              // onsaved: (String? value) {},
                              title: 'Enter Email ID',
                              controller: controller.emailController,
                              fieldHintText: "",
                              keyType: TextInputType.emailAddress,
                              validCheck: (value) {
                                if (value!.isEmpty ||
                                    !GetUtils.isEmail(value)) {
                                  return 'Enter a valid email!';
                                }
                                return null;
                              },
                              validationmsg: "",
                            ),
                            const SizedBox(height: 15.0),
                            FoduuFormTextField(
                              //  onsaved: (String? value) {},
                              title: 'Enter Mobile No.',
                              controller: controller.phoneController,
                              fieldHintText: "",
                              keyType: TextInputType.number,
                              validCheck: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length > 10 ||
                                    value.length < 10) {
                                  return 'Please enter valid mobile number!';
                                }
                                return null;
                              },
                              validationmsg: "",
                            ),
                            const SizedBox(height: 15.0),
                          ],
                        ),
                      FoduuFormTextField(
                          title: 'Message',
                          controller: controller.messageController,
                          fieldHintText: "",
                          keyType: TextInputType.multiline,
                          maxLine: 5,
                          validCheck: (value) {
                            if (value == null || value.length <= 3) {
                              return 'Please enter message greater than 3 characters';
                            }
                            return null;
                          },
                          validationmsg: ""),
                      const SizedBox(height: 20.0),
                      Obx(() {
                        if (controller.isLoading.value) {
                          return const CircularProgressIndicator();
                        } else {
                          return AppButton(
                            itemText: "SUBMIT",
                            // radius: 12,
                            keypressEvent: () {
                              HelperFunctions().closeKeyboard(context);
                              controller.sendFormData();
                            },
                          );
                        }
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
