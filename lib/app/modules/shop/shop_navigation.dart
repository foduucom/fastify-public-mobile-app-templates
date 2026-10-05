import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/modules/shop/controllers/shop_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:get/get.dart';

/// Index of the Shop tab in the bottom bar (Home=0, Account=1, Shop=2, Wishlist=3, Cart=4).
const int shopTabIndex = 2;

/// Opens the Shop tab, optionally pre-filtered by [args] (same map shape that
/// `ShopController.applyArguments` accepts). Falls back to pushing the
/// standalone shop route when the bottom bar isn't mounted.
void openShop([Map<String, dynamic>? args]) {
  if (!Get.isRegistered<BottombarController>()) {
    Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: args);
    return;
  }

  Get.find<BottombarController>().onTabChange(shopTabIndex);
  if (args != null) {
    final shop = Get.isRegistered<ShopController>()
        ? Get.find<ShopController>()
        : Get.put(ShopController());
    shop.applyArguments(args);
  }
  Get.until((route) => route.settings.name == Routes.BOTTOMBAR);
}
