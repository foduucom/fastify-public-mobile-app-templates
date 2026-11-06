import 'package:get/get.dart';
import 'package:zouhi/app/modules/coupons/controllers/coupons_controller.dart';

class CouponsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CouponsController>(() => CouponsController());
  }
}
