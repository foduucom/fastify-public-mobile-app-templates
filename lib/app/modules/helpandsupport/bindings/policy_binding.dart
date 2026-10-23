import 'package:get/get.dart';
import 'package:zouhi/app/modules/helpandsupport/controllers/policy_controller.dart';

class PolicyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PolicyController>(
      () => PolicyController(),
    );
  }
}
