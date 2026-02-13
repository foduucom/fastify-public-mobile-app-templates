import 'package:foduu_ecommerce/app/modules/blog/controller/blog_controller.dart';
import 'package:foduu_ecommerce/app/modules/blog/controller/blog_detail_controller.dart';
import 'package:get/get.dart';

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
