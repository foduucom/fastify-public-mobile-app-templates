import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import 'package:get/get.dart';
import '/core/services/cartServcie.dart';
import '/app/modules/cart/controllers/cart_controller.dart';

class OrderSuccessController extends GetxController with BaseController {
  var item = {}.obs;
  final id = '0'.obs;
  final orderNo = ''.obs;
  var totalAmount = ''.obs;
  var address = {}.obs;
  var isLoading = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    isLoading.value = true;
    final args = Get.arguments;
    if (args is Map) {
      if (args['id'] != null) id.value = args['id'].toString();
      if (args['order_no'] != null) orderNo.value = args['order_no'].toString();
    } else if (args is String) {
      id.value = args;
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
    _refreshCartAfterOrder();
  }

  /// The backend empties the cart when the order is created; drop the stale
  /// local copy (and any applied coupon) so the cart tab doesn't still show
  /// the items that were just ordered.
  void _refreshCartAfterOrder() {
    try {
      if (Get.isRegistered<CartController>()) {
        final cart = Get.find<CartController>();
        cart.couponDetails.clear();
        cart.isCouponApply.value = false;
      }
      if (Get.isRegistered<CartService>()) {
        CartService.to.fetchCart();
      }
    } catch (e) {
      print('Error refreshing cart after order: $e');
    }
  }

  Future<void> OrderDetail() async {
    if (id.value == '0' || id.value.isEmpty) {
      isLoading.value = false;
      return;
    }
    try {
      isLoading.value = true;
      var response = await BasicProvider("order/${id.value}")
          .getRequest()
          .catchError(handleError);

      printInfo(info: 'OrderDetail response: $response');

      if (response == null) return;

      var orderData = response.containsKey('data') && response['data'] is Map
          ? response['data']
          : response;

      item.value = response;
      if (orderData != null && orderData['order_no'] != null && orderNo.value.isEmpty) {
        orderNo.value = orderData['order_no'].toString();
      }
      address.value = (orderData != null ? orderData['address'] : null) ?? {};

      item.refresh();
      address.refresh();
    } catch (e) {
      print('Error in OrderDetail $e');
    } finally {
      isLoading.value = false;
    }
  }
}

