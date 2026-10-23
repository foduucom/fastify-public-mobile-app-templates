import 'package:zouhi/app/modules/pages/home/controllers/page_controller.dart';
import 'package:get/get.dart';

class PageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PagesController>(
      () => PagesController(),
    );
  }
}
