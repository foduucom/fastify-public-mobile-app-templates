import 'package:get/get.dart';
import '../controllers/support_ticket_controller.dart';

class SupportTicketBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportTicketController>(
      () => SupportTicketController(),
    );
  }
}
