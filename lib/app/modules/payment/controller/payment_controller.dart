import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentController extends GetxController {

  final TextEditingController cardNumberController  = TextEditingController();
  final TextEditingController cardHolderController  = TextEditingController();
  final TextEditingController expiryController      = TextEditingController();
  final TextEditingController cvvController         = TextEditingController();

  final RxBool isLoading = false.obs;

  // ── Reactive: enable Checkout only when all fields filled ─────
  final RxBool isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    cardNumberController.addListener(_validate);
    cardHolderController.addListener(_validate);
    expiryController.addListener(_validate);
    cvvController.addListener(_validate);
  }

  @override
  void onClose() {
    cardNumberController.dispose();
    cardHolderController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    super.onClose();
  }

  void _validate() {
    isFormValid.value =
        cardNumberController.text.trim().length >= 16 &&
            cardHolderController.text.trim().isNotEmpty &&
            expiryController.text.trim().length == 5 &&
            cvvController.text.trim().length >= 3;
  }

  // ── Format card number with spaces ───────────────────────────
  void onCardNumberChanged(String value) {
    final digits = value.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    if (formatted != cardNumberController.text) {
      cardNumberController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  // ── Format expiry MM/YY ───────────────────────────────────────
  void onExpiryChanged(String value) {
    final digits = value.replaceAll('/', '');
    String formatted = digits;
    if (digits.length >= 3) {
      formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    } else if (digits.length == 2 && !value.contains('/')) {
      formatted = '$digits/';
    }
    if (formatted != expiryController.text) {
      expiryController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> onCheckout() async {
    isLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1)); // replace with real API
      Get.snackbar(
        '✅ Success', 'Payment method saved!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF1A1A1A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save payment method.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
    } finally {
      isLoading(false);
    }
  }
}
