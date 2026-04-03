import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/constants/helper_functions.dart'; // Make sure this is imported for loaders/snackbars

class AddressController extends GetxController with BaseController {
  var isLoading = false.obs;
  var addressList = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  // ── FETCH ADDRESSES ──
  Future<void> fetchAddresses() async {
    try {
      isLoading.value = true;
      var response = await BasicProvider("customer/addresses")
          .getRequest()
          .catchError(handleError);

      if (response != null && response is List) {
        addressList.assignAll(response);
      }
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── ADD ADDRESS ──
  // You can call this from your Add Address Screen
  Future<bool> addAddress(Map<String, dynamic> formData) async {
    try {
      HelperFunctions().showOverlayLoader(); // Show loading overlay
      var response = await BasicProvider("customer/addresses/add")
          .postRequest(formData)
          .catchError(handleError);

      Get.back(); // Close loader

      if (response != null) {
        // Refresh the list after adding
        await fetchAddresses();
        return true; // Success
      }
      return false;
    } catch (e) {
      Get.back(); // Close loader
      debugPrint('Error adding address: $e');
      return false;
    }
  }

  // ── REMOVE ADDRESS ──
  Future<void> removeAddress(String id) async {
    try {
      HelperFunctions().showOverlayLoader(); // Show loading overlay

      // Using postRequest with empty body as specified in your postman screenshot
      var response = await BasicProvider("customer/addresses/$id")
          .postRequest({})
          .catchError(handleError);

      Get.back(); // Close loader

      if (response != null) {
        // Optimistically remove from UI to make it feel instantly fast
        addressList.removeWhere((item) => (item['_id'] ?? item['id']) == id);
        // HelperFunctions().showSnackBarSuccess("Address removed successfully");
      }
    } catch (e) {
      Get.back(); // Close loader
      debugPrint('Error removing address: $e');
    }
  }

  // ── FORMAT ADDRESS HELPER ──
  String getFormattedAddress(Map<String, dynamic> item) {
    List<String> parts = [];
    if (item['street'] != null && item['street'].toString().isNotEmpty) {
      parts.add(item['street']);
    }
    if (item['landmark'] != null && item['landmark'].toString().isNotEmpty) {
      parts.add(item['landmark']);
    }
    if (item['state'] != null && item['state']['name'] != null) {
      parts.add(item['state']['name']);
    }
    if (item['country'] != null && item['country']['name'] != null) {
      parts.add(item['country']['name']);
    }

    String fullAddress = parts.join(', ');
    if (item['postal_code'] != null) {
      fullAddress += ' - ${item['postal_code']}';
    }
    return fullAddress;
  }
}