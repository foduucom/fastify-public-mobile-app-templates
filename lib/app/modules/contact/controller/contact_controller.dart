import 'dart:io';

import 'package:flutter/cupertino.dart';
import '/app/data/basic_provider.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../controllers/api_exception_handle_controller.dart';

class ContactController extends GetxController with BaseController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController nameController,
      emailController,
      phoneController,
      messageController;
  final isLoading = false.obs;
  var box = GetStorage();
  var boxUserData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    messageController = TextEditingController();
    boxUserData.value = box.read('userDetails')['userData '] ?? {};
    if (boxUserData.isEmpty) {
      nameController = TextEditingController();
      emailController = TextEditingController();
      phoneController = TextEditingController();
    }
  }

  @override
  void onClose() {
    super.onClose();
    messageController.dispose();
    if (boxUserData.isEmpty) {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
    }
  }

  Future<void> sendFormData() async {
    if (formKey.currentState!.validate()) {
      if (messageController.text == "") {
        return;
      }
      isLoading(true);

      var form;
      if (boxUserData.isNotEmpty) {
        form = FormData({
          'name': boxUserData["user"]["name"],
          'email': boxUserData["user"]["email"],
          'mobile': boxUserData["user"]["mobile"],
          'content': messageController.text,
          'type': Platform.isAndroid ? 'Android App' : 'iOS App',
          'customer_id': boxUserData["type"] == "customer"
              ? boxUserData["user"]["id"]
              : null,
          'vendor_id': boxUserData["type"] == "vendor"
              ? boxUserData["user"]["id"]
              : null,
        });
      } else {
        form = FormData({
          'name': nameController.text,
          'email': emailController.text,
          'mobile': phoneController.text,
          'content': messageController.text,
          'type': Platform.isAndroid ? 'Android App' : 'iOS App',
          'customer_id': null,
          'vendor_id': null,
        });
      }

      var response = await BasicProvider("frontend/contact/create")
          .postRequest(form)
          .catchError(handleError);
      if (response == null) return;
      isLoading(false);
      Get.back();
      Get.back();

      HelperFunctions().showSnackBarSuccess(response);
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      messageController.clear();
    }
  }
}
