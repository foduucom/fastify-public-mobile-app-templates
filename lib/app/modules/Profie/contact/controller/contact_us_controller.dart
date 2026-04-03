import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants/helper_functions.dart';

class ContactUsController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final messageCtrl = TextEditingController();

  var isSubmitting = false.obs;

  Future<void> submitContactForm() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSubmitting.value = true;
      HelperFunctions().showOverlayLoader(); // Show your app's loader

      // TODO: Replace with your actual BasicProvider API call
      // var response = await BasicProvider('contact-us').postRequest({
      //   'name': nameCtrl.text,
      //   'email': emailCtrl.text,
      //   'message': messageCtrl.text,
      // });
      await Future.delayed(const Duration(seconds: 2)); // Simulating network

      Get.until((route) => !Get.isDialogOpen!); // Close overlay loader
      isSubmitting.value = false;

      Get.back(); // Close the BottomSheet

      Get.snackbar(
        'Message Sent',
        'Thank you for reaching out. We will contact you soon!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      // Clear fields
      nameCtrl.clear();
      emailCtrl.clear();
      messageCtrl.clear();

    } catch (e) {
      Get.until((route) => !Get.isDialogOpen!);
      isSubmitting.value = false;
      debugPrint('Error sending message: $e');
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    messageCtrl.dispose();
    super.onClose();
  }
}