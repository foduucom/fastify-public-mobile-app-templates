import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/app/modules/Profie/profile/controllers/profile_controller.dart';
import '/app/modules/Profie/profile/views/change_password_view.dart';
import '/app/routes/app_pages.dart';
import '/components/check_internet_widget.dart';
import '/components/foduuformtextfield.dart';
import '/components/open_image_picker_sheet.dart';
import '/components/buttons/primary_action_button.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';

class EditprofileView extends GetView<ProfileController> {
  const EditprofileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: SizedBox(
            width: width * 0.4,
            child: Text(
              "Profile".tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: height * 0.025,
                fontWeight: FontWeight.w700,
                height: 1.6,
              ),
            ),
          ),
          elevation: 0.0,
        ),
        body: GestureDetector(
          onTap: () {
            HelperFunctions().closeKeyboard(context);
          },
          child: FoduuCheckInternetBody(
            child: Form(
              key: controller.formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05,
                  vertical: height * 0.02,
                ),
                children: [
                  SizedBox(height: height * 0.015),
                  Container(
                    width: width * 0.92,
                    padding: EdgeInsets.only(
                      top: height * 0.03,
                      left: width * 0.03,
                      right: width * 0.03,
                      bottom: height * 0.015,
                    ),
                    // decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.circular(height * 0.015),
                    //   border: Border.all(color: Colors.grey.shade300),
                    // ),
                    child: Column(
                      children: [
                        // Profile Image Section
                        Container(
                          width: height * 0.1125,
                          height: height * 0.1125,
                          alignment: Alignment.center,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipOval(
                                child: Obx(() {
                                  if (controller.imagePath.isNotEmpty &&
                                      !controller.imagePath.value
                                          .contains("http")) {
                                    return Image.file(
                                      File(controller.imagePath.value),
                                      height: height * 0.1125,
                                      width: height * 0.1125,
                                      fit: BoxFit.cover,
                                    );
                                  } else if (controller.imagePath.value
                                          .contains("http") &&
                                      !controller.imagePath.value
                                          .contains(".svg")) {
                                    return Image.network(
                                      controller.imagePath.value,
                                      height: height * 0.1125,
                                      width: height * 0.1125,
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return CircleAvatar(
                                      radius: height * 0.05625,
                                      backgroundColor: Colors.grey.shade200,
                                      child: controller.profiledata[
                                                  'featured_image'] ==
                                              null
                                          ? Icon(
                                              Icons.person,
                                              size: height * 0.04375,
                                              color: Colors.grey.shade600,
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: HelperFunctions()
                                                  .getImage(
                                                      controller.profiledata[
                                                          'featured_image']),
                                              fit: BoxFit.cover,
                                            ),
                                    );
                                  }
                                }),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    openImagePickerSheet(controller);
                                  },
                                  child: Container(
                                    width: height * 0.0375,
                                    height: height * 0.0375,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icon/editprofile.svg',
                                        height: height * 0.0225,
                                        width: height * 0.0225,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Obx(() => controller.imagePath.value != ""
                                  ? Positioned(
                                      right: 0,
                                      top: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          controller.imagePath.value = "";
                                        },
                                        child: Container(
                                          width: height * 0.028,
                                          height: height * 0.028,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.shade300,
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.close,
                                              size: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox()),
                            ],
                          ),
                        ),

                        SizedBox(height: height * 0.02),

                        // Full Name Field
                        _profileFieldRow(
                          title: 'Full Name'.tr,
                          value: controller.nameController.text,
                          icon: Icons.person_outline,
                          enabled: true,
                          onTap: () {
                            _showEditDialog(context, 'Full Name'.tr,
                                controller.nameController);
                          },
                        ),

                        SizedBox(height: height * 0.015),

                        // Email Field (Read Only)
                        _profileFieldRow(
                          title: 'Email'.tr,
                          value: controller.emailController.text,
                          icon: Icons.email_outlined,
                          enabled: false,
                        ),

                        SizedBox(height: height * 0.015),

                        // Phone Number Field (Read Only)
                        _profileFieldRow(
                          title: 'Mobile Number'.tr,
                          value: controller.phoneController.text,
                          icon: Icons.call_outlined,
                          enabled: false,
                        ),

                        SizedBox(height: height * 0.015),

                        // Password Field
                        _profileFieldRow(
                          title: 'Password'.tr,
                          value: '••••••••',
                          icon: Icons.lock_outline,
                          enabled: true,
                          onTap: () {
                            Get.to(const ChangePasswordView());
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.only(bottom: 20.0, left: 16.0, right: 16.0),
          child: PrimaryActionButton(
            text: 'SAVE DETAILS'.tr,
            onPressed: () async {
              HelperFunctions().showOverlayLoader();
              await controller.sendFormData();
              HelperFunctions().showSnackBarSuccess(
                'Profile update successfully'.tr,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _profileFieldRow({
    required String title,
    required String value,
    required IconData icon,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    final width = Get.width;
    final height = Get.height;

    return Padding(
      padding: const EdgeInsets.only(bottom: 1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.86,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: height * 0.015,
                fontWeight: FontWeight.w600,
                height: 2,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(height: height * 0.005),
          GestureDetector(
            onTap: enabled ? onTap : null,
            child: Container(
              width: width * 0.86,
              height: height * 0.065,
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height * 0.01),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: height * 0.025,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: width * 0.04),
                  Expanded(
                    child: Text(
                      value.isEmpty ? 'Not set'.tr : value,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: height * 0.018,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: enabled ? Colors.black87 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  if (enabled)
                    Icon(
                      Icons.chevron_right,
                      size: height * 0.025,
                      color: Colors.grey.shade400,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, String title, TextEditingController controller) {
    final height = Get.height;
    final width = Get.width;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter $title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(height * 0.01),
              ),
            ),
            inputFormatters: title == 'Full Name'.tr
                ? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))]
                : null,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL'.tr),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('SAVE'.tr),
            ),
          ],
        );
      },
    );
  }
}
