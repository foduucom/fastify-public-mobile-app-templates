import 'package:foddu/app/modules/address/controllers/address_list_controller.dart';
import 'package:foddu/app/modules/checkout/controllers/checkout_controllers.dart';
import 'package:get/get.dart';

class CheckOutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckOutController>(
      () => CheckOutController(),
    );
    Get.lazyPut<AddressListController>(
      () => AddressListController(),
    );
  }
}
