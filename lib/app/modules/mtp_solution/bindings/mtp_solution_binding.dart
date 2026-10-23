import 'package:get/get.dart';
import '../controllers/mtp_solution_controller.dart';

class MtpSolutionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MtpSolutionController>(
      () => MtpSolutionController(),
    );
  }
}
