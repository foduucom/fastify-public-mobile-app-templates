import 'dart:convert';

import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:get/get.dart';

class ProductvariantController extends GetxController with BaseController {
  final count = 0.obs;
  var productDetials = {}.obs;
  var productVariantOptions = List<dynamic>.empty().obs;
  var colorList = List<dynamic>.empty().obs;
  var sizeList = List<dynamic>.empty().obs;
  var getSelectedSize = 0.obs;
  var getYourSize = "S".obs;
  var productVariant = {}.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await getProductDetials();
  }

  Future<void> getProductDetials() async {
    var response = await BasicProvider("productdetail/${Get.arguments["slug"]}")
        .getRequest()
        .catchError(handleError);
    if (response == null) return;
    productDetials.value = response;
    if (productDetials['variant_ids'] != null) {
      productVariant.addAll(productDetials['variant_ids']);
    }
    if (productDetials['variant_option'] != null) {
      productVariantOptions
          .addAll(jsonDecode(productDetials['variant_option']));
    }
    for (var i = 0; i < productVariantOptions.length; i++) {
      if (productVariantOptions[i]['name'] == 'Color') {
        colorList.value = productVariantOptions[i]['value'];
      }
      if (productVariantOptions[i]['name'] == 'size') {
        sizeList.value = productVariantOptions[i]['value'];
      }
    }
  }

  void sizeOnSubmit() {
    getYourSize.value = sizeList[getSelectedSize.value]['value'];
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
