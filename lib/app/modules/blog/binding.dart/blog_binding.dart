import 'package:zouhi/app/modules/blog/controller/blog_controller.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/modules/blog/controller/blog_details_controller.dart';

class BlogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlogController>(
      () => BlogController(),
    );
    Get.lazyPut<BlogDetailsController>(
      () => BlogDetailsController(),
    );
  }
}
