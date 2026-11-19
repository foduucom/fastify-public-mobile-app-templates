import 'package:foddu/app/modules/profile_legacy/profile/controllers/profile_controller.dart';
import 'package:foddu/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:foddu/app/modules/shop/controllers/shop_controller.dart';
import 'package:get/get.dart';

import '../controllers/bottombar_controller.dart';

class BottombarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottombarController>(
      () => BottombarController(),
    );
    Get.lazyPut<HomepageController>(() => HomepageController());
    Get.lazyPut<ShopController>(() => ShopController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
