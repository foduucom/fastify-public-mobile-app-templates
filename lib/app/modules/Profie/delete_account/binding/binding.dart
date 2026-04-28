import 'package:foduu_ecommerce/app/modules/Profie/delete_account/controller/delete_account_controller.dart';
import 'package:get/get.dart';

class DeleteAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeleteAccountController>(
      () => DeleteAccountController(),
    );
  }
}
