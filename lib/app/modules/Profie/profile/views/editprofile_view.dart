import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/controllers/profile_controller.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/views/change_password_view.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/check_internet_widget.dart';
import 'package:foduu_ecommerce/components/foduuformtextfield.dart';
import 'package:foduu_ecommerce/components/open_image_picker_sheet.dart';
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
                    child: Center(
                        child: EditProfileImageWidget(controller: controller)),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 35),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PERSONAL DETAILS',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                )),
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
                            FoduuFormTextField(
                              title: 'Mobile Number'.tr,
                              controller: controller.phoneController,
                              fieldHintText: "",
                              keyType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validCheck: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length != 10) {
                                  return 'Please enter valid mobile number!'.tr;
                                }
                                return null;
                              },
                              validationmsg: "",
                            ),
                            const SizedBox(height: 20.0),
                            FoduuFormTextField(
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
                            // ─── Gender ───
                            Obx(() => DropdownButtonFormField<String>(
                              value: controller.gender.value.isEmpty
                                  ? null
                                  : controller.gender.value,
                              decoration: InputDecoration(
                                floatingLabelAlignment:
                                    FloatingLabelAlignment.start,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                label: RichText(
                                  text: TextSpan(
                                    text: 'Gender',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                  ),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'male', child: Text('Male')),
                                DropdownMenuItem(
                                    value: 'female', child: Text('Female')),
                                DropdownMenuItem(
                                    value: 'other', child: Text('Other')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  controller.gender.value = value;
                                }
                              },
                            )),
                            const SizedBox(height: 20.0),
                            // ─── Date of Birth ───
                            FoduuFormTextField(
                              title: 'Date of Birth',
                              controller: controller.dobController,
                              fieldHintText: 'Select your date of birth',
                              readOnly: true,
                              keyType: TextInputType.datetime,
                              validationmsg: '',
                              onTap: () => controller.selectDate(context),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today_outlined),
                                onPressed: () =>
                                    controller.selectDate(context),
                              ),
                              validCheck: (value) => null,
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
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                    offset: const Offset(2, 2),
                    blurRadius: 2,
                    color: Theme.of(context).shadowColor.withOpacity(0.1))
              ]),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                SizedBox(
                    width: Get.width * 0.45,
                    child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            shadowColor: Colors.transparent,
                            foregroundColor:
                                Theme.of(context).colorScheme.onSurface,
                            elevation: 0.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            minimumSize: Size(Get.width, 50)),
                        child: Text('CANCEL'.tr,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 17)))),
                SizedBox(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () async {
                        HelperFunctions().showOverlayLoader();
                        try {
                          await controller.sendFormData();
                        } catch (e) {
                          debugPrint("Error updating profile: $e");
                        } finally {
                          HelperFunctions().hideOverlayLoader();
                        }
                      },
                      child: Text('SAVE DETAILS'.tr,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 17))),
                ),
              ],
            ),
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
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: controller.profiledata['featured_image'] == null
                  ? Icon(
                      Icons.person,
                      size: 35,
                      color: Theme.of(context).colorScheme.onSurface,
                    )
                  : CachedNetworkImage(
                      imageUrl: HelperFunctions()
                          .getImage(controller.profiledata['featured_image'])),
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
