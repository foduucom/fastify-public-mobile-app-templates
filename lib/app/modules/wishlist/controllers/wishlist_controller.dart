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
  var wishlistProductIds = <String>[].obs;
  var box = GetStorage();

  @override
  Future<void> onInit() async {
    super.onInit();
    await getwishlist();
    // wishlistProductIds.addAll(wishList[])
  }

  // Updated method to handle both add and remove
  Future<void> toggleWishlist(String productId) async {
    try {
      if (!AuthDetails.isUserLogin()) {
        // Handle local wishlist for non-logged in users
        if (wishlistProductIds.contains(productId)) {
          wishlistProductIds.remove(productId);
          // Remove from wishList if you have product data
          wishList.removeWhere((item) => item['product']['_id'] == productId);
        } else {
          wishlistProductIds.add(productId);
          // You might want to add product data to wishList here
          // This depends on your data structure
        }

        // Save to local storage
        box.write('wishlistProductIds', wishlistProductIds.toList());
        box.write('wishList', wishList.toList());

        // Update UI with specific IDs for each product
        update([
          productId
        ]); // This will update only the specific product's like button
      } else {
        // Handle logged-in users with API
        isLoading.value = true;

        if (wishlistProductIds.contains(productId)) {
          // Remove from wishlist
          var response = await BasicProvider('public/wishlist/remove')
              .postRequest({'product': productId}).catchError(handleError);
        } else {
          // Add to wishlist
          var response = await BasicProvider('public/wishlist/create')
              .postRequest({'product': productId}).catchError(handleError);
        }

        // Refresh wishlist
        await getwishlist();

        // Update UI with specific IDs for each product
        update([productId]);
        isLoading.value = false;
      }
    } catch (e) {
      print('wishlist error $e');
      isLoading.value = false;
    }
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
    await toggleWishlist(productid);
  }

  Future<void> getwishlist() async {
    isLoading.value = true;

    if (!AuthDetails.isUserLogin()) {
      // Load from local storage for non-logged in users
      var savedIds = box.read('wishlistProductIds') as List? ?? [];
      wishlistProductIds.value = savedIds.cast<String>();
      // Load wishList data if you have it stored
      var savedWishList = box.read('wishList') as List? ?? [];
      wishList.value = savedWishList;

      isLoading.value = false;
      update();
      return;
    }

    // API call for logged in users
    var response = await BasicProvider('public/wishlist')
        .getRequest()
        .catchError(handleError);

    if (response == null) {
      isLoading.value = false;
      return;
    }

    wishList.clear();
    wishlistProductIds.clear();

    if (response['data'] != null) {
      wishList.addAll(response['data']);
      wishList.forEach((element) {
        if (element['product'] != null && element['product']['_id'] != null) {
          wishlistProductIds.add(element['product']['_id']);
        }
      });
    }

    isLoading.value = false;
    update(); // Update all listeners
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
