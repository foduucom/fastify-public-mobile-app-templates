import 'package:get/get.dart';
import '../controllers/support_ticket_details_controller.dart';

class SupportTicketDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportTicketDetailsController>(
      () => SupportTicketDetailsController(),
    );
  }
}
