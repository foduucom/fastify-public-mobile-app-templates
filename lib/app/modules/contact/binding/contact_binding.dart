import 'package:foduu_ecommerce/app/modules/contact/controller/contact_controller.dart';
import 'package:get/get.dart';

class ContactBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContactController>(
      () => ContactController(),
    );
  }
}
