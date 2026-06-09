import 'package:foduu_ecommerce/app/modules/address/controllers/address_list_controller.dart';
import 'package:foduu_ecommerce/services/payment_handler_controller.dart';
import 'package:get/get.dart';

import '../controllers/checkout_controller.dart';

class CheckOutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckOutController>(
      () => CheckOutController(),
    );
    Get.lazyPut<AddressListController>(
      () => AddressListController(),
    );
    Get.lazyPut<PaymentHandlerController>(
      () => PaymentHandlerController(),
    );
  }
}
