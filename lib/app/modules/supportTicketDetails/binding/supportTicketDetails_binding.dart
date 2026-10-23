import 'package:get/get.dart';
import 'package:zouhi/app/modules/supportTicketDetails/controller/supportTicketDetails_controller.dart';

class SupportTicketDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportTicketDetailsController>(
      () => SupportTicketDetailsController(),
    );
  }
}
