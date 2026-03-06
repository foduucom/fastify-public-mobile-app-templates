import 'package:flutter/cupertino.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
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
    if (Get.arguments != null && Get.arguments['id'] != null) {
      id.value = Get.arguments['id'];
    }
    await OrderDetail();
  }

  Future<void> OrderDetail() async {
    isLoading.value = true;
    var response = await BasicProvider("orders/show/$id")
        .getRequest()
        .catchError(handleError);

    if (response == null) return;
    item.clear();
    item.value = response;
    address.value = response['address'];
    // totalAmount.value = item['']
    isLoading.value = false;
  }
}
