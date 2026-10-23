import 'package:get/get.dart';
import 'package:zouhi/app/modules/support_ticket/controller/supportticket_controller.dart';

class SupportTicketBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportTicketController>(
      () => SupportTicketController(),
    );
  }
}
