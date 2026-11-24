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
    // Create the home controller while this route's bindings are being
    // installed. The home view lives inside the bottom bar's PageView, so a
    // lazy controller can otherwise be first created after GetX has finished
    // associating dependencies with the route that owns them.
    Get.put<HomepageController>(HomepageController());
    Get.lazyPut<ShopController>(() => ShopController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
