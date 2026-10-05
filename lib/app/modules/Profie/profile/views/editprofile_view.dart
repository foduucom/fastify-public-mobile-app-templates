import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/app/modules/Profie/profile/controllers/profile_controller.dart';
import '/components/check_internet_widget.dart';
import '/components/open_image_picker_sheet.dart';
import '/components/buttons/primary_action_button.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';

class EditprofileView extends GetView<ProfileController> {
  const EditprofileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Profile".tr,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
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
                vertical: height * 0.015,
              ),
              children: [
                SizedBox(height: height * 0.01),
                Center(
                  child: Container(
                    width: width * 0.92,
                    padding: EdgeInsets.only(
                      top: height * 0.02,
                      bottom: height * 0.015,
                    ),
                    child: Column(
                      children: [
                        // Profile Image Section
                        _buildAvatarSection(context, colorScheme, isDark, height),
                        SizedBox(height: height * 0.03),

                        // Form Field Cards
                        GetBuilder<ProfileController>(
                          builder: (_) {
                            return Column(
                              children: [
                                // Full Name Field
                                _profileFieldRow(
                                  context: context,
                                  title: 'Full Name'.tr,
                                  value: controller.nameController.text,
                                  icon: Icons.person_outline,
                                  enabled: true,
                                  onTap: () {
                                    _showEditDialog(
                                      context,
                                      'Full Name'.tr,
                                      controller.nameController,
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),

                                // Email Field
                                _profileFieldRow(
                                  context: context,
                                  title: 'Email'.tr,
                                  value: controller.emailController.text,
                                  icon: Icons.email_outlined,
                                  enabled: true,
                                  onTap: () {
                                    _showEditDialog(
                                      context,
                                      'Email'.tr,
                                      controller.emailController,
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),

                                // Phone Number Field
                                _profileFieldRow(
                                  context: context,
                                  title: 'Mobile Number'.tr,
                                  value: controller.phoneController.text,
                                  icon: Icons.phone_outlined,
                                  enabled: true,
                                  onTap: () {
                                    _showEditDialog(
                                      context,
                                      'Mobile Number'.tr,
                                      controller.phoneController,
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),

                                // Gender Field
                                Obx(
                                  () => _profileFieldRow(
                                    context: context,
                                    title: 'Gender'.tr,
                                    value: controller.selectedGender.value,
                                    icon: Icons.wc_outlined,
                                    enabled: true,
                                    onTap: () {
                                      _showGenderSelection(context);
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
          child: PrimaryActionButton(
            text: 'SAVE DETAILS'.tr,
            onPressed: () async {
              HelperFunctions().showOverlayLoader();
              try {
                await controller.sendFormData();
              } finally {
                HelperFunctions().hideOverlayLoader();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
    double height,
  ) {
    final avatarSize = height * 0.125;

    return Container(
      width: avatarSize,
      height: avatarSize,
      alignment: Alignment.center,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.55),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Obx(() {
                final imagePath = controller.imagePath.value;
                final hasImagePath = imagePath.isNotEmpty;
                final isNetworkImage = imagePath.contains("http");

                Widget buildFallback() {
                  final name = controller.nameController.text.trim();
                  String initials = '';
                  if (name.isNotEmpty) {
                    final parts = name.split(RegExp(r'\s+'));
                    if (parts.length >= 2 &&
                        parts[0].isNotEmpty &&
                        parts[1].isNotEmpty) {
                      initials =
                          '${parts[0][0]}${parts[1][0]}'.toUpperCase();
                    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
                      initials = parts[0][0].toUpperCase();
                    }
                  }

                  if (initials.isNotEmpty) {
                    return Container(
                      width: avatarSize,
                      height: avatarSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withOpacity(0.78),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: avatarSize * 0.40,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  }

                  return Container(
                    width: avatarSize,
                    height: avatarSize,
                    alignment: Alignment.center,
                    color: colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.person_rounded,
                      size: avatarSize * 0.55,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  );
                }

                // Case 1: Local file image
                if (hasImagePath && !isNetworkImage) {
                  try {
                    final file = File(imagePath);
                    if (file.existsSync()) {
                      return Image.file(
                        file,
                        height: avatarSize,
                        width: avatarSize,
                        fit: BoxFit.cover,
                      );
                    }
                  } catch (e) {
                    debugPrint("Error loading local image: $e");
                  }
                }

                // Case 2: Network image
                if (isNetworkImage) {
                  return CachedNetworkImage(
                    imageUrl: imagePath,
                    height: avatarSize,
                    width: avatarSize,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: colorScheme.surfaceVariant,
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => buildFallback(),
                  );
                }

                return buildFallback();
              }),
            ),
          ),
          // Camera/Edit Icon
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                openImagePickerSheet(controller);
              },
              child: Container(
                width: height * 0.040,
                height: height * 0.040,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.camera_alt,
                    size: height * 0.021,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
          // Delete/Clear image button
          Obx(
            () => controller.imagePath.value != ""
                ? Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        controller.imagePath.value = "";
                      },
                      child: Container(
                        width: height * 0.030,
                        height: height * 0.030,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.error,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: 15,
                            color: colorScheme.onError,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _profileFieldRow({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(isDark ? 0.35 : 0.6),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(isDark ? 0.20 : 0.10),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 19,
                      color: isDark
                          ? colorScheme.primary.withOpacity(0.9)
                          : colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value.isEmpty ? 'Not set'.tr : value,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: value.isEmpty
                          ? colorScheme.onSurfaceVariant.withOpacity(0.5)
                          : colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (enabled)
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    TextEditingController textController,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final tempController = TextEditingController(text: textController.text);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Edit $title',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: TextField(
            controller: tempController,
            style: TextStyle(color: colorScheme.onSurface),
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter $title',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withOpacity(0.7),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
            inputFormatters: title == 'Full Name'.tr
                ? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))]
                : null,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL'.tr,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                textController.text = tempController.text.trim();
                controller.update();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('SAVE'.tr),
            ),
          ],
        );
      },
    );
  }

  void _showGenderSelection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    "Select Gender".tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Divider(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                  height: 1,
                ),
                ListTile(
                  leading: Icon(Icons.male, color: colorScheme.primary),
                  title: Text(
                    'Male'.tr,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  trailing: controller.selectedGender.value == 'Male'
                      ? Icon(Icons.check_circle, color: colorScheme.primary)
                      : null,
                  onTap: () {
                    controller.selectedGender.value = 'Male';
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.female, color: colorScheme.primary),
                  title: Text(
                    'Female'.tr,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  trailing: controller.selectedGender.value == 'Female'
                      ? Icon(Icons.check_circle, color: colorScheme.primary)
                      : null,
                  onTap: () {
                    controller.selectedGender.value = 'Female';
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.transgender, color: colorScheme.primary),
                  title: Text(
                    'Other'.tr,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  trailing: controller.selectedGender.value == 'Other'
                      ? Icon(Icons.check_circle, color: colorScheme.primary)
                      : null,
                  onTap: () {
                    controller.selectedGender.value = 'Other';
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
