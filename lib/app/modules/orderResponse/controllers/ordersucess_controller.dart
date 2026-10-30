import 'package:flutter/cupertino.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import 'package:get/get.dart';

class OrderSuccessController extends GetxController with BaseController {
  var item = {}.obs;
  final id = '0'.obs;
  var totalAmount = ''.obs;
  var address = {}.obs;
  var isLoading = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    if (Get.arguments != null) {
      // If arguments is a String (order_no), use it directly. If it's a Map, look for 'id'.
      if (Get.arguments is String) {
        id.value = Get.arguments;
      } else if (Get.arguments['id'] != null) {
        id.value = Get.arguments['id'];
      }
    }
    await OrderDetail();
  }

  Future<void> OrderDetail() async {
    if (id.value == '0') return;
    isLoading.value = true;
    var response = await BasicProvider("order/${id.value}")
        .getRequest()
        .catchError(handleError);

    print('response $response');

    if (response == null) {
      isLoading.value = false;
      return;
    }

    if (response != null) {
      var data = response;
      item.clear();
      item.value = data;
      address.value = data['address'];
    }
    isLoading.value = false;
  }
}