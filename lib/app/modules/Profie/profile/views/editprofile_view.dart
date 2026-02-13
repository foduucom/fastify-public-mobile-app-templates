import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/controllers/profile_controller.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/views/change_password_view.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/check_internet_widget.dart';
import 'package:foduu_ecommerce/components/foduu_gender_widget.dart';
import 'package:foduu_ecommerce/components/foduuformtextfield.dart';
import 'package:foduu_ecommerce/components/open_image_picker_sheet.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';

class EditprofileView extends GetView<ProfileController> {
  const EditprofileView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profile".tr),
          elevation: 0.0,
          actions: [
            TextButton.icon(
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: () {
                Get.toNamed(Routes.DELETE_ACCOUNT);
              },
              label: const Text(
                "Delete Account",
                style: TextStyle(color: Colors.red),
              ),
            )
          ],
        ),
        body: GestureDetector(
          onTap: () {
            HelperFunctions().closeKeyboard(context);
          },
          child: FoduuCheckInternetBody(
            child: Form(
              key: controller.formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30.0),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Center(
                        child: EditProfileImageWidget(controller: controller)),
                  ),
                  Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PERSONAL DETAILS',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    color: Colors.black)),
                            const SizedBox(height: 30),
                            FoduuFormTextField(
                                fieldHintText: '',
                                title: 'Full Name'.tr,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z\s]'))
                                ],
                                keyType: TextInputType.text,
                                validationmsg: '',
                                controller: controller.nameController,
                                validCheck: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.length < 6) {
                                    return 'Please enter a name'.tr;
                                  } else if (value.trim().isEmpty) {
                                    return 'Name cannot start with a space'.tr;
                                  }
                                  return null;
                                }),
                            const SizedBox(height: 20.0),

                            // FoduuFormTextField(
                            //   fieldHintText: '',
                            //   title: 'Gender',
                            //   keyType: TextInputType.text,
                            //   validationmsg: '',
                            //   onsaved: (String? value) {},
                            //   controller: controller.genderController,
                            //   validCheck: (value) {
                            //     if (value == null ||
                            //         value.isEmpty ||
                            //         value.length < 6) {
                            //       return 'Please enter valid full name!';
                            //     }
                            //     return null;
                            //   },
                            // ),

                            Obx(
                              () => FoduuGenderWidget(
                                selectedGender: controller.gender
                                    .value, // require for editing purpose the value should be pre-filled
                                onChange: (value) {
                                  controller.gender.value = value;
                                },
                              ),
                            ),
                            const SizedBox(height: 10)
                          ],
                        ),
                      ),
                      Container(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 35),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SECURITY'.tr,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                  color: Colors.black),
                            ),
                            const SizedBox(height: 30.0),
                            FoduuFormTextField(
                              // onsaved: (String? value) {},
                              readOnly: true,
                              title: 'Mobile Number'.tr,
                              // suffixIcon: TextButtonCustom('CHANGE'.tr,
                              //     FontWeight.w500, () => null, themeRedColor, 14),
                              controller: controller.phoneController,
                              fieldHintText: "",
                              keyType: TextInputType.number,
                              validCheck: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length > 10 ||
                                    value.length < 10) {
                                  return 'Please enter valid mobile number!'.tr;
                                }
                                return null;
                              },
                              validationmsg: "",
                            ),
                            const SizedBox(height: 20.0),
                            FoduuFormTextField(
                              // onsaved: (String? value) {},
                              title: 'Email'.tr,
                              readOnly: true,
                              controller: controller.emailController,
                              fieldHintText: "Email ID".tr,
                              keyType: TextInputType.emailAddress,
                              validCheck: (value) {
                                if (value!.isEmpty ||
                                    !GetUtils.isEmail(value)) {
                                  return 'Enter a valid email!'.tr;
                                }
                                return null;
                              },
                              validationmsg: "",
                            ),
                            const SizedBox(height: 20.0),
                            // FoduuFormTextField(
                            //   fieldHintText: '',
                            //   title: 'Password',
                            //   suffixIcon: TextButtonCustom(
                            //       'CHANGE',
                            //       FontWeight.w500,
                            //       () => Get.to(const ChangePasswordView()),
                            //       Colors.red,
                            //       14),
                            //   keyType: TextInputType.text,
                            //   readOnly: true,
                            //   validationmsg: '',
                            //   controller: controller.passwordController,
                            //   validCheck: (value) {
                            //     // if (value == null ||
                            //     //     value.isEmpty ||
                            //     //     value.length < 6) {
                            //     //   return 'Please enter valid full name!';
                            //     // }
                            //     // return null;
                            //   },
                            // ),
                            isOtpLogin
                                ? Container()
                                : Align(
                                    alignment: Alignment.centerRight,
                                    // child: ElevatedButton(
                                    //     style: ElevatedButton.styleFrom(
                                    //         backgroundColor: Colors.white,
                                    //         foregroundColor: Colors.red,
                                    //         surfaceTintColor: Colors.white,
                                    //         disabledBackgroundColor: Colors.white,
                                    //         elevation: 0,
                                    //         disabledForegroundColor: Colors.white,
                                    //         shadowColor: Colors.white),
                                    //     onPressed: () {},
                                    //     child: Text('Change Password')),
                                    child: InkWell(
                                      onTap: () {
                                        Get.to(() => ChangePasswordView());
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.transparent),
                                        child: const Text(
                                          'Change Password',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                            const SizedBox(height: 40)
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(2, 2),
                                  blurRadius: 2,
                                  color: Colors.black)
                            ]),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 8),
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: Get.width * 0.45,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            Get.back();
                                            Get.back();
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              shadowColor: Colors.white,
                                              foregroundColor: Colors.white,
                                              elevation: 0.0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                              minimumSize: Size(Get.width, 50)),
                                          child: Text('CANCEL'.tr,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 17)))),
                                  SizedBox(
                                    width: Get.width * 0.45,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(),
                                        onPressed: () async {
                                          HelperFunctions().showOverlayLoader();
                                          await controller.sendFormData();
                                          //     then((value) {
                                          // Get.until(
                                          //     (route) => !Get.isDialogOpen!);
                                          //   Get.back();
                                          // Get.back();

                                          HelperFunctions().showSnackBarSuccess(
                                              'Profile update successfffully');
                                          // });
                                        },
                                        child: Text('SAVE DETAILS'.tr,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 17))),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      //const SizedBox(height: 10.0),
                    ],
                  ),
                ],
              ),
            ),

            // Positioned(
            //   bottom: 10,
            //   left: 0,
            //   right: 0,
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 10),
            //     decoration: const BoxDecoration(
            //       color: Colors.white,
            //     ),
            //     child: Obx(() {
            //       if (controller.isLoading.value) {
            //         return const CircularProgressIndicator(
            //           color: themePrimaryColor,
            //         );
            //       } else {
            //         return SizedBox(
            //           width: Get.width,
            //           child: FoduuButton(
            //             btnText: "Update Profile",
            //             onPressButton: () {
            //               HelperFunctions().closeKeyboard(context);
            //               controller.sendFormData();
            //             },
            //           ),
            //         );
            //       }
            //     }),
            //   ),
            // ),
          ),
        ),
      ),
    );
  }
}

class EditProfileImageWidget extends StatelessWidget {
  const EditProfileImageWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipOval(child: Obx(() {
          if (controller.imagePath.isNotEmpty &&
              !controller.imagePath.value.contains("http")) {
            return Image.file(
              File(controller.imagePath.value),
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            );
          } else if (controller.imagePath.value.contains("http") &&
              !controller.imagePath.value.contains(".svg")) {
            return Image.network(
              controller.imagePath.value,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            );
          } else {
            return CircleAvatar(
              radius: 50,
              backgroundColor: const Color.fromARGB(36, 206, 200, 200),
              child: controller.profiledata['featured_image'] == null
                  ? const Icon(
                      Icons.no_photography_outlined,
                      size: 35,
                      color: Colors.grey,
                    )
                  : CachedNetworkImage(
                      imageUrl: url +
                          controller.profiledata['featured_image']['filepath']),
            );
          }
        })),
        Positioned(
          right: 4,
          bottom: 2,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icon/editprofile.svg',
                height: 40,
              ),

              // const Icon(
              //   Icons.edit,
              //   size: 18,
              //   color: themeTextColor,
              // ),
              onPressed: () {
                openImagePickerSheet(controller);
              },
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Obx(() => controller.imagePath.value != ""
              ? CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey.shade300,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 13,
                    ),
                    onPressed: () {
                      controller.imagePath.value = "";
                    },
                  ),
                )
              : Container()),
        )
      ],
    );
  }
}
