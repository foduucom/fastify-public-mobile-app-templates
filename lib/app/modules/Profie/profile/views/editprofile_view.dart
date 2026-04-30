import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../components/app_bar.dart';
import '/app/modules/Profie/profile/controllers/profile_controller.dart';
import '/components/check_internet_widget.dart';
import '/components/open_image_picker_sheet.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';

class EditprofileView extends GetView<ProfileController> {
  const EditprofileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(title: 'Edit Profile'),
      body: GestureDetector(
        onTap: () => HelperFunctions().closeKeyboard(context),
        child: FoduuCheckInternetBody(
          child: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Banner + Avatar ───────────────────────────────
                  _ProfileHeaderWidget(controller: controller),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── First Name ──────────────────────────────
                        _fieldLabel('First Name', textTheme),
                        const SizedBox(height: 8),
                        _inputField(
                          context: context,
                          controller: controller.nameController,
                          hintText: 'First Name',
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\s]')),
                          ],
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 2) {
                              return 'Please enter first name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ── Last Name ───────────────────────────────
                        _fieldLabel('Last Name', textTheme),
                        const SizedBox(height: 8),
                        _inputField(
                          context: context,
                          controller: controller.lastNameController,
                          hintText: 'Last Name',
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\s]')),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── E-mail ──────────────────────────────────
                        _fieldLabel('E-mail', textTheme),
                        const SizedBox(height: 8),
                        _inputField(
                          context: context,
                          controller: controller.emailController,
                          hintText: 'Email address',
                          readOnly: true,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !GetUtils.isEmail(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),

                        //const SizedBox(height: 16),

                        // // ── Date of Birth ───────────────────────────
                        // _fieldLabel('Date of Birth', textTheme),
                        // const SizedBox(height: 8),
                        // Obx(() => GestureDetector(
                        //   onTap: () async {
                        //     final picked = await showDatePicker(
                        //       context: context,
                        //       initialDate: controller.selectedDob.value ??
                        //           DateTime(1996, 2, 24),
                        //       firstDate: DateTime(1900),
                        //       lastDate: DateTime.now(),
                        //       builder: (context, child) => Theme(
                        //         data: Theme.of(context)
                        //             .copyWith(colorScheme: colorScheme),
                        //         child: child!,
                        //       ),
                        //     );
                        //     if (picked != null) {
                        //       controller.selectedDob.value = picked;
                        //     }
                        //   },
                        //   child: Container(
                        //     padding: const EdgeInsets.symmetric(
                        //         horizontal: 18, vertical: 16),
                        //     decoration: BoxDecoration(
                        //       color: colorScheme.surface,
                        //       border: Border.all(
                        //           color: colorScheme.primary, width: 1.2),
                        //       borderRadius: BorderRadius.circular(30),
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment:
                        //       MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Text(
                        //           controller.selectedDob.value != null
                        //               ? '${controller.selectedDob.value!.day} '
                        //               '${_monthName(controller.selectedDob.value!.month)} '
                        //               '${controller.selectedDob.value!.year}'
                        //               : '24 february 1996',
                        //           style: textTheme.bodyMedium?.copyWith(
                        //             color: colorScheme.onSurface,
                        //           ),
                        //         ),
                        //         Icon(Icons.calendar_month_outlined,
                        //             color: colorScheme.primary, size: 22),
                        //       ],
                        //     ),
                        //   ),
                        // )),

                        // const SizedBox(height: 16),

                        // // ── Gender ──────────────────────────────────
                        // _fieldLabel('Gender', textTheme),
                        // const SizedBox(height: 10),
                        // Obx(() => Row(
                        //   children: [
                        //     _genderOption(
                        //       context: context,
                        //       label: 'Male',
                        //       isSelected:
                        //       controller.selectedGender.value == 'Male',
                        //       onTap: () =>
                        //       controller.selectedGender.value = 'Male',
                        //     ),
                        //     const SizedBox(width: 14),
                        //     _genderOption(
                        //       context: context,
                        //       label: 'Female',
                        //       isSelected:
                        //       controller.selectedGender.value == 'Female',
                        //       onTap: () =>
                        //       controller.selectedGender.value = 'Female',
                        //     ),
                        //   ],
                        // )),

                        // const SizedBox(height: 16),

                        // // ── Location ────────────────────────────────
                        // _fieldLabel('Location', textTheme),
                        // const SizedBox(height: 8),
                        // Container(
                        //   decoration: BoxDecoration(
                        //     color: colorScheme.surface,
                        //     border: Border.all(
                        //         color: colorScheme.primary, width: 1.2),
                        //     borderRadius: BorderRadius.circular(16),
                        //   ),
                        //   child: TextFormField(
                        //     controller: controller.addressController,
                        //     maxLines: 4,
                        //     keyboardType: TextInputType.multiline,
                        //     style: textTheme.bodyMedium
                        //         ?.copyWith(color: colorScheme.onSurface),
                        //     decoration: InputDecoration(
                        //       hintText: 'Enter your location',
                        //       hintStyle: TextStyle(
                        //           color: colorScheme.onSurfaceVariant,
                        //           fontSize: 14),
                        //       border: InputBorder.none,
                        //       contentPadding: const EdgeInsets.all(16),
                        //     ),
                        //   ),
                        // ),

                        //const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ── Save Changes ────────────────────────────────────────────────
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () async {
              HelperFunctions().showOverlayLoader();
              await controller.sendFormData();
              HelperFunctions()
                  .showSnackBarSuccess('Profile updated successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: Text(
              'Save Changes',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Field Label ────────────────────────────────────────────────────
  Widget _fieldLabel(String label, TextTheme textTheme) {
    return Builder(
        builder: (context) => Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ));
  }

  // ── Reusable Input Field ───────────────────────────────────────────
  Widget _inputField({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: colorScheme.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: colorScheme.error, width: 1.8),
        ),
      ),
    );
  }

  // ── Gender Option Button ───────────────────────────────────────────
  Widget _genderOption({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surface,
            border: Border.all(color: colorScheme.primary, width: 1.2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color:
                      isSelected ? colorScheme.onPrimary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected ? Colors.transparent : colorScheme.outline,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 16, color: colorScheme.primary)
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Month Name Helper ──────────────────────────────────────────────
  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }
}

// ── Profile Header: Banner + Avatar ──────────────────────────────────────────
class _ProfileHeaderWidget extends StatelessWidget {
  final ProfileController controller;
  const _ProfileHeaderWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Banner ─────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 150,
                color: colorScheme.surfaceContainerHighest,
                child: controller.profiledata['banner_image'] != null
                    ? CachedNetworkImage(
                        imageUrl: HelperFunctions()
                            .getImage(controller.profiledata['banner_image']),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/profile_banner.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Image.asset(
                        'assets/images/profile_banner.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
              ),
            ),
          ),

          // ── Banner Edit FAB ────────────────────────────────────────
          Positioned(
            top: 10,
            right: 26,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/icon/edit.png',
                  width: 16,
                  height: 16,
                  color: colorScheme.onPrimary,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ── Avatar ─────────────────────────────────────────────────
          Positioned(
            bottom: 5,
            left: 136,
            child: Stack(
              children: [
                ClipOval(
                  child: Obx(() {
                    if (controller.imagePath.isNotEmpty &&
                        !controller.imagePath.value.contains('http')) {
                      return Image.file(
                        File(controller.imagePath.value),
                        height: 89,
                        width: 89,
                        fit: BoxFit.cover,
                      );
                    } else if (controller.imagePath.value.contains('http') &&
                        !controller.imagePath.value.contains('.svg')) {
                      return Image.network(
                        controller.imagePath.value,
                        height: 89,
                        width: 89,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return CircleAvatar(
                        radius: 40,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        child: controller.profiledata['featured_image'] == null
                            ? Icon(Icons.person,
                                size: 35, color: colorScheme.onSurface)
                            : CachedNetworkImage(
                                imageUrl: HelperFunctions().getImage(
                                    controller.profiledata['featured_image']),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.person,
                                  size: 35,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                      );
                    }
                  }),
                ),

                // ── Avatar Edit FAB ───────────────────────────────
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => openImagePickerSheet(controller),
                    child: Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: colorScheme.surface, width: 2),
                      ),
                      child: Image.asset(
                        'assets/icon/edit.png',
                        width: 12,
                        height: 12,
                        color: colorScheme.onPrimary,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // ── Clear Image ───────────────────────────────────
                Obx(() => controller.imagePath.value.isNotEmpty
                    ? Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => controller.imagePath.value = '',
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: colorScheme.onSurfaceVariant,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close,
                                size: 13, color: colorScheme.surface),
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
