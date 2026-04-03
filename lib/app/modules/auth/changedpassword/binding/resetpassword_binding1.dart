import 'package:get/get.dart';

import '../controller/change_password.dart';


class ResetpasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResetpasswordController>(
          () => ResetpasswordController(),
      fenix: true, // ✅ prevents disposed controller reuse on back navigation
    );
  }
}