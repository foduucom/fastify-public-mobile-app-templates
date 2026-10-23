import 'package:get/get.dart';
import '../controllers/my_quotes_request_controller.dart';

class MyQuotesRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyQuotesRequestController>(
      () => MyQuotesRequestController(),
    );
  }
}
