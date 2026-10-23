import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zouhi/app/modules/Profie/profile/controllers/profile_controller.dart';
import 'package:zouhi/components/foduu_gender_widget.dart';
import 'package:zouhi/components/foduu_name_initial_widget.dart';
import 'package:zouhi/components/open_image_picker_sheet.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:get/get.dart';
import 'dart:ui';

// Premium styled form field widget
class PremiumFormField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final bool readOnly;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? hintText;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;

  const PremiumFormField({
    Key? key,
    required this.title,
    required this.controller,
    this.readOnly = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.hintText,
    this.onTap,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            validator: validator,
            onTap: onTap,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hintText ?? '',
              hintStyle: TextStyle(
                color: context.themeSecondrytext.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: context.colors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class EditprofileView extends GetView<ProfileController> {
  EditprofileView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.ensureDataLoaded();
    });
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profile".tr),
          elevation: 0.0,
        ),
        body: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.colors.surface.withOpacity(0.4)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Form(
                key: controller.formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                        ),
                        child: Center(
                            child:
                                EditProfileImageWidget(controller: controller)),
                      ),
                      Column(
                        children: [
                        PremiumFormField(
                          title: 'Full Name'.tr,
                          controller: controller.nameController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\s]')),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a name'.tr;
                            }
                            if (value.trim().length < 3) {
                              return 'Name must be at least 3 characters!'.tr;
                            }
                            if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                              return 'Name can only contain letters and spaces!'
                                  .tr;
                            }
                            return null;
                          },
                        ),
                        PremiumFormField(
                          title: 'Date Of Birth'.tr,
                          controller: controller.dobController,
                          hintText: 'dd/mm/yyyy'.tr,
                          readOnly: true,
                          suffixIcon:
                              const Icon(Icons.calendar_today_outlined),
                          onTap: () => controller.selectDate(context),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your date of birth'.tr;
                            }
                            return null;
                          },
                        ),
                        Obx(() => FormField<String>(
                              initialValue: controller.gender.value,
                              validator: (_) {
                                if (controller.gender.value.isEmpty) {
                                  return 'Please select gender'.tr;
                                }
                                return null;
                              },
                              builder: (state) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FoduuGenderWidget(
                                      selectedGender: controller.gender.value,
                                      onChange: (value) {
                                        controller.gender.value = value;
                                        state.didChange(value);
                                      },
                                    ),
                                    if (state.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4, left: 4),
                                        child: Text(
                                          state.errorText!,
                                          style: TextStyle(
                                              color: context.themeRedColor,
                                              fontSize: 12),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            )),
                        PremiumFormField(
                          title: 'Mobile Number'.tr,
                          controller: controller.phoneController,
                          hintText: '10-digit number'.tr,
                          readOnly: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(15),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mobile number is required'.tr;
                            }
                            final digitsOnly =
                                value.replaceAll(RegExp(r'\D'), '');
                            if (digitsOnly.length < 10) {
                              return 'Minimum 10 digits required'.tr;
                            }
                            if (digitsOnly.length > 15) {
                              return 'Maximum 15 digits allowed'.tr;
                            }
                            return null;
                          },
                        ),
                        PremiumFormField(
                          title: 'Email'.tr,
                          controller: controller.emailController,
                          readOnly: true,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !GetUtils.isEmail(value)) {
                              return 'Enter a valid email!'.tr;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: context.colors.surface,
                          boxShadow: [
                            BoxShadow(
                                offset: const Offset(2, 2),
                                blurRadius: 2,
                                color: context.colors.outline.withOpacity(0.4))
                          ]),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 12),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: context.colors.surface,
                                        shadowColor: Colors.transparent,
                                        elevation: 0.0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                        minimumSize:
                                            const Size.fromHeight(50)),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text('CANCEL'.tr,
                                          style: TextStyle(
                                              color: context.themeTextColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            context.themePrimaryColor,
                                        elevation: 0.0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                        minimumSize:
                                            const Size.fromHeight(50)),
                                    onPressed: () async {
                                      if (!controller.formKey.currentState!
                                          .validate()) {
                                        return;
                                      }
                                      HelperFunctions().showOverlayLoader();
                                      await controller.sendFormData();
                                    },
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text('SAVE DETAILS'.tr,
                                          style: TextStyle(
                                              color: context.colors.onPrimary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15)),
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
              ),
            ),
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
            final nameVal = controller.nameController.text.isNotEmpty
                ? controller.nameController.text
                : controller.profiledata['name']?.toString();
            final featImage = controller.profiledata['featured_image'];
            final bool hasFeatImage =
                featImage != null && featImage.toString().trim().isNotEmpty;

            if (!hasFeatImage) {
              return FoduuNameInitialWidget(
                name: nameVal,
                size: 100,
              );
            }

            final String imgUrl = HelperFunctions()
                .getImage(featImage, moduleName: 'EditProfileView');
            final Uri? parsedUri = Uri.tryParse(imgUrl);
            final bool isValidUrl = parsedUri != null &&
                parsedUri.hasAuthority &&
                parsedUri.host.isNotEmpty;

            if (!isValidUrl) {
              return FoduuNameInitialWidget(
                name: nameVal,
                size: 100,
              );
            }

            return ClipOval(
              child: CachedNetworkImage(
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                imageUrl: imgUrl,
                errorWidget: (_, __, ___) => FoduuNameInitialWidget(
                  name: nameVal,
                  size: 100,
                ),
              ),
            );
          }
        })),
        Positioned(
          right: 4,
          bottom: 2,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: context.colors.surface,
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icon/editprofile.svg',
                height: 40,
                colorFilter: ColorFilter.mode(
                  context.themePrimaryColor,
                  BlendMode.srcIn,
                ),
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
                  backgroundColor: context.themegreyColor,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 13,
                      color: context.themeTextColor,
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
