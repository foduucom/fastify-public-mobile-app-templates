import 'package:new_fastify_template/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:new_fastify_template/app/modules/shop/controllers/shop_controller.dart';
import 'package:new_fastify_template/app/routes/app_pages.dart';
import 'package:get/get.dart';

/// Index of the Shop tab in the bottom bar (Home=0, Shop=1, Cart=2, Wishlist=3, Profile=4).
const int shopTabIndex = 1;

/// Opens the Shop tab, optionally pre-filtered by [args] (same map shape that
/// `ShopController.applyArguments` accepts). Falls back to pushing the
/// standalone shop route when the bottom bar isn't mounted.
void openShop([Map<String, dynamic>? args]) {
  if (!Get.isRegistered<BottombarController>()) {
    Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: args);
    return;
  }

  Get.find<BottombarController>().onTabChange(shopTabIndex);
  final shop = Get.isRegistered<ShopController>()
      ? Get.find<ShopController>()
      : Get.put(ShopController());
  if (args != null && args.isNotEmpty) {
    shop.applyArguments(args);
  } else {
    shop.resetToPlainShop();
  }
  Get.until((route) => route.settings.name == Routes.BOTTOMBAR);
}
