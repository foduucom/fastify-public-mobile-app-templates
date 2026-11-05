import 'package:foddu/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foddu/app/modules/shop/controllers/shop_controller.dart';
import 'package:foddu/app/routes/app_pages.dart';
import 'package:get/get.dart';

/// Parent-aligned bottom bar order: Home, Shop, Wishlist, Cart, Account/Login.
const int homeTabIndex = 0;
const int shopTabIndex = 1;
const int wishlistTabIndex = 2;
const int cartTabIndex = 3;
const int accountTabIndex = 4;

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
