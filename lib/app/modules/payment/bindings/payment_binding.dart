import 'package:get/get.dart';

import '../../address/controllers/address_controller.dart';
import '../controllers/payment_controller.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressController>(
      () => AddressController(),
    );
    Get.lazyPut<PaymentController>(
      () => PaymentController(),
    );
  }
}
