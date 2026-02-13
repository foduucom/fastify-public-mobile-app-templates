import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/views/wishlist_view.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class WishlistController extends GetxController with BaseController {
  final count = 0.obs;
  RxBool isLoading = false.obs;
  var wishList = List<dynamic>.empty().obs;
  var wishlistProductIds = [];
  var box = GetStorage();

  @override
  Future<void> onInit() async {
    super.onInit();
    await getwishlist();
    // wishlistProductIds.addAll(wishList[])
  }

  Future<void> addProductToWishlist({required String productid}) async {
    // try {
    //   if (!AuthDetails.isUserLogin()) {
    //     wishlistProductIds.addIf(
    //         !wishlistProductIds.contains(productid), productid);
    //     box.write('wishList', wishList);
    //   } else {
    //     var response = await BasicProvider('public/wishlist/create')
    //         .postRequest({'product': productid}).catchError(handleError);
    //     getwishlist();
    //   }
    // } catch (e) {
    //   print('wishlist error $e');
    // }
  }

  Future<void> getwishlist() async {
    isLoading.value = true;
    // var response = await BasicProvider('public/wishlist')
    //     .getRequest()
    //     .catchError(handleError);

    // if (response == null) {
    //   isLoading.value = false;
    //   return;
    // }

    wishList.clear();
    wishlistProductIds.clear();

    // wishList.addAll(response['data']);
    wishList.forEach((element) {
      wishlistProductIds.add(element['product']['_id']);
    });
    update();
    isLoading.value = false;
  }
  // Future<void> fetchWishlist() async {
  //   isLoading.value = true;
  //   var response = await BasicProvider('public/product/get-wishlist')
  //       .getRequest()
  //       .catchError(handleError);
  //   print(response);
  //   if (response == null) {
  //     isLoading.value = false;
  //     return;
  //   }

  //   if (response is List) {
  //     wishList.addAll(response);
  //     print(wishList);
  //   } else if (response is Map<String, dynamic>) {
  //     response.forEach((key, value) {
  //       wishList.add(value);
  //     });
  //   }
  //   isLoading.value = false;
  // }
}
