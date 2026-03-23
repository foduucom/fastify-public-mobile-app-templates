import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '/app/data/basic_provider.dart';

class PersonalInfoController extends GetxController {

  final TextEditingController nameController     = TextEditingController();
  final TextEditingController mobileController   = TextEditingController();
  final TextEditingController interestController = TextEditingController();
  final TextEditingController addressController  = TextEditingController();

  final Rx<File?> pickedImage = Rx<File?>(null);
  final RxBool    isLoading   = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    interestController.dispose();
    addressController.dispose();
    super.onClose();
  }

  bool get hasInput =>
      nameController.text.trim().isNotEmpty     ||
          mobileController.text.trim().isNotEmpty   ||
          interestController.text.trim().isNotEmpty ||
          addressController.text.trim().isNotEmpty;

  // ── Fetch Profile ─────────────────────────────────────────────
  // BasicProvider already returns body["data"], so result IS the object
  Future<void> fetchProfile() async {
    isLoading(true);
    try {
      // ✅ FIX 1: correct variable name (was 'response', unused)
      final result =
      await BasicProvider('auth/customer/profile').getRequest();

      // ✅ FIX 2: result IS the data object — no ['data'] key needed
      if (result != null && result is Map) {
        nameController.text     = result['name']?.toString()     ?? '';
        mobileController.text   = result['mobile']?.toString()   ??
            result['phone']?.toString()    ?? '';
        interestController.text = result['interest']?.toString() ?? '';
        addressController.text  = result['address']?.toString()  ?? '';
      }
    } catch (e) {
      debugPrint('Fetch profile error: $e');
    } finally {
      isLoading(false);
    }
  }

  // ── Pick Image ────────────────────────────────────────────────
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) pickedImage.value = File(picked.path);
  }

  // ── Update Profile ────────────────────────────────────────────
  Future<void> onUpdate() async {
    if (!hasInput && pickedImage.value == null) {
      Get.snackbar(
        'Nothing to update',
        'Please fill in at least one field',
        snackPosition:   SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText:       Colors.white,
        margin:          const EdgeInsets.all(16),
        borderRadius:    12,
      );
      return;
    }

    isLoading(true);
    try {
      dynamic result;

      if (pickedImage.value != null) {
        // ── Multipart (has image) ─────────────────────────
        final fields = <String, String>{};
        if (nameController.text.trim().isNotEmpty)
          fields['name']     = nameController.text.trim();
        if (mobileController.text.trim().isNotEmpty)
          fields['mobile']   = mobileController.text.trim();
        if (interestController.text.trim().isNotEmpty)
          fields['interest'] = interestController.text.trim();
        if (addressController.text.trim().isNotEmpty)
          fields['address']  = addressController.text.trim();

        // ✅ FIX 3: correct endpoint
        result = await BasicProvider('auth/customer/profile/update')
            .multipartRequest(
          'POST',
          fields: fields,
          files:  {'featured_image': pickedImage.value!.path},
        );
      } else {
        // ── JSON (no image) ───────────────────────────────
        final body = <String, dynamic>{
          if (nameController.text.trim().isNotEmpty)
            'name':     nameController.text.trim(),
          if (mobileController.text.trim().isNotEmpty)
            'mobile':   mobileController.text.trim(),
          if (interestController.text.trim().isNotEmpty)
            'interest': interestController.text.trim(),
          if (addressController.text.trim().isNotEmpty)
            'address':  addressController.text.trim(),
        };

        // ✅ FIX 3: correct endpoint
        result = await BasicProvider('auth/customer/profile/update')
            .postRequest(body);
      }

      if (result != null) {
        Get.snackbar(
          '✅ Success', 'Profile updated successfully',
          snackPosition:   SnackPosition.TOP,
          backgroundColor: const Color(0xFF1A1A1A),
          colorText:       Colors.white,
          margin:          const EdgeInsets.all(16),
          borderRadius:    12,
          duration:        const Duration(seconds: 2),
        );
        // ✅ Go back so ProfileView re-fetches
        Get.back(result: true);
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      Get.snackbar(
        '❌ Error', 'Failed to update profile. Please try again.',
        snackPosition:   SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText:       Colors.white,
        margin:          const EdgeInsets.all(16),
        borderRadius:    12,
        duration:        const Duration(seconds: 3),
      );
    } finally {
      isLoading(false);
    }
  }
}
