// lib/app/modules/explore/bindings/explore_binding.dart

import 'package:get/get.dart';

import '../controller/explore_controller.dart';


class ExploreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExploreController>(() => ExploreController(),
        fenix: true
    );
  }
}
