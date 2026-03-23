import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../components/app_bar/custom_app_bar.dart';
import 'controller/personal_info_controller.dart';

class PersonalInfoView extends StatelessWidget {
  const PersonalInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PersonalInfoController());

    return Scaffold(
      backgroundColor: const Color(0xFFEEECE8),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            AppTopBar(title: 'Edit Profile'),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Avatar Picker ───────────────────────
                    _AvatarPicker(controller: controller),
                    const SizedBox(height: 32),

                    // ── Full Name ───────────────────────────
                    const _FieldLabel(label: 'Full Name'),
                    const SizedBox(height: 10),
                    _InputField(
                      controller: controller.nameController,
                      hint: 'Enter your full name',
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),

                    // ── Phone Number ────────────────────────
                    const _FieldLabel(label: 'Phone Number'),
                    const SizedBox(height: 10),
                    _InputField(
                      controller: controller.mobileController,
                      hint: 'Enter phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    // ✅ NEW — Interest ──────────────────────
                    const _FieldLabel(label: 'Interest'),
                    const SizedBox(height: 10),
                    _InputField(
                      controller: controller.interestController,
                      hint: 'e.g. Furniture, Decor, Lighting',
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 20),

                    // ✅ NEW — Address ───────────────────────
                    const _FieldLabel(label: 'Address'),
                    const SizedBox(height: 10),
                    _InputField(
                      controller: controller.addressController,
                      hint: 'Enter your full address',
                      keyboardType: TextInputType.streetAddress,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,                // ✅ multiline for address
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ── Update Button ──────────────────────────────────
            Obx(() => _buildUpdateButton(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton(PersonalInfoController controller) {
    final active = controller.hasInput && !controller.isLoading.value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: active ? controller.onUpdate : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: active
                ? const Color(0xFF1A1A1A)
                : const Color(0xFFD0CFC9),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFD0CFC9),
            disabledForegroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50)),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
              width: 22, height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: Colors.white))
              : const Text('Update',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// ── Avatar Picker ─────────────────────────────────────────────────
class _AvatarPicker extends StatelessWidget {
  final PersonalInfoController controller;
  const _AvatarPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: controller.pickImage,
        child: Obx(() {
          final file = controller.pickedImage.value;
          return Stack(
            children: [
              Container(
                width: 96, height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD9D9D9),
                ),
                clipBehavior: Clip.antiAlias,
                child: file != null
                    ? Image.file(file, fit: BoxFit.cover)
                    : const Icon(Icons.person,
                    size: 48, color: Color(0xFF9E9E9E)),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 28, height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit,
                      size: 14, color: Colors.white),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Field Label ───────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A)));
  }
}

// ── Input Field ───────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines; // ✅ NEW — supports multiline

  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1, // ✅ default single line
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        // ✅ pill for single line, rounded rect for multiline
        borderRadius: BorderRadius.circular(maxLines > 1 ? 20 : 50),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        maxLines: maxLines,         // ✅ NEW
        style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontSize: 15,
              color: Color(0xFFB0AEAB),
              fontWeight: FontWeight.w400),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 18),
        ),
      ),
    );
  }
}
