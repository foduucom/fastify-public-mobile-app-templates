import 'package:foddu/app/modules/profile_legacy/delete_account/controller/delete_account_controller.dart';
import 'package:get/get.dart';

class DeleteAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeleteAccountController>(
      () => DeleteAccountController(),
    );
  }
}
