import 'package:flutter/cupertino.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/modules/address/controllers/address_controller.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';

class OrderSuccessController extends GetxController with BaseController {
  var item = {}.obs;
  final id = '0'.obs;
  var totalAmount = ''.obs;
  var address = {}.obs;
  var isLoading = true.obs;

  final orderNo = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    isLoading.value = true;
    final args = Get.arguments;
    if (args is Map) {
      if (args['id'] != null) id.value = args['id'].toString();
      if (args['order_no'] != null) orderNo.value = args['order_no'].toString();
    }
    try {
      await OrderDetail();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
    // onInit runs while the route is building; touching CartController's
    // observables there throws "markNeedsBuild() called during build".
    _refreshCartAfterOrder();
  }

  /// The backend empties the cart when the order is created; drop the stale
  /// local copy (and any applied coupon) so the cart tab doesn't still show
  /// the items that were just ordered.
  void _refreshCartAfterOrder() {
    if (!Get.isRegistered<CartController>()) return;
    try {
      final cart = Get.find<CartController>();
      cart.clearCoupon();
      cart.getCartProduct();
    } catch (e) {
      print('Error refreshing cart after order: $e');
    }
  }

  Future<void> OrderDetail() async {
    try {
      isLoading.value = true;
      var response =
          await BasicProvider("order/$id").getRequest().catchError(handleError);

      printInfo(info: 'order Details ${response.toString()}');

      if (response == null) return;

      // Populate item and address right away so order details are ready
      var orderData =
          response.containsKey('data') ? response['data'] : response;
      item.value = response;
      address.value = (orderData != null ? orderData['address'] : null) ?? {};

      // Resolve address IDs to names if available
      if (orderData != null && orderData['address'] != null) {
        try {
          final addressController = Get.isRegistered<AddressController>()
              ? Get.find<AddressController>()
              : Get.put(AddressController());

          var addr = orderData['address'];
          if (addr is Map) {
            await addressController.resolveAddressesNames([addr]);
          }
        } catch (addrErr) {
          print('Error resolving address names in OrderDetail: $addrErr');
        }
      }

      // Refresh observables so UI updates with resolved names
      item.refresh();
      address.refresh();
    } catch (e) {
      print('Error in OrderDetail $e');
    } finally {
      isLoading.value = false;
    }
  }
}
