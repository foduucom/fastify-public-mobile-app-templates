import 'dart:async';

import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import 'package:get/get.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import '/app/modules/cart/controllers/cart_controller.dart';

class OrderSuccessController extends GetxController with BaseController {
  var item = {}.obs;
  final id = '0'.obs;
  final orderNo = ''.obs;
  var totalAmount = ''.obs;
  var address = {}.obs;
  var isLoading = true.obs;
  final detailsError = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    isLoading.value = true;
    final args = Get.arguments;
    if (args is Map) {
      if (args['order'] is Map) {
        item.assignAll(Map<String, dynamic>.from(args['order'] as Map));
        if (args['is_cash_order'] == true) {
          item['payment_method'] ??= 'cash';
        }
      }
      if (args['id'] != null) {
        id.value = args['id'].toString();
      } else if (args['order'] is Map) {
        final order = args['order'] as Map;
        id.value = (order['_id'] ?? order['id'] ?? order['order_id'] ?? '0')
            .toString();
      }
      if (args['order_no'] != null) {
        orderNo.value = args['order_no'].toString();
      } else if (item['order_no'] != null) {
        orderNo.value = item['order_no'].toString();
      }
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
    unawaited(_refreshCartAfterOrder());
  }

  /// Drop stale local cart copy and applied coupons so the cart tab reflects order placement
  Future<void> _refreshCartAfterOrder() async {
    try {
      if (Get.isRegistered<CartController>()) {
        final cart = Get.find<CartController>();
        cart.couponDetails.clear();
        cart.appliedCouponCode.value = '';
        cart.couponController.clear();
        cart.isCouponApply.value = false;
      }
      if (Get.isRegistered<CartService>()) {
        await CartService.to.fetchCart(useCache: false);
      }
    } catch (e) {
      printInfo(info: 'Post-order cart refresh failed: ${e.runtimeType}');
    }
  }

  Future<void> OrderDetail() async {
    if (id.value == '0' || id.value.isEmpty) {
      isLoading.value = false;
      detailsError.value = item.isEmpty;
      return;
    }
    try {
      isLoading.value = true;
      detailsError.value = false;
      var response = await BasicProvider("order/${id.value}")
          .getRequest()
          .catchError(handleError);

      if (response == null) return;

      dynamic orderData = response;
      for (var depth = 0; depth < 3 && orderData is Map; depth++) {
        if (orderData['order'] is Map) {
          orderData = orderData['order'];
        } else if (orderData['data'] is Map) {
          orderData = orderData['data'];
        } else {
          break;
        }
      }

      item
        ..clear()
        ..addAll(Map<String, dynamic>.from(orderData as Map));
      if (orderData['order_no'] != null && orderNo.value.isEmpty) {
        orderNo.value = orderData['order_no'].toString();
      }
      address.value = orderData['address'] ?? {};

      item.refresh();
      address.refresh();
    } catch (e) {
      detailsError.value = true;
      printInfo(info: 'Order detail refresh failed: ${e.runtimeType}');
    } finally {
      isLoading.value = false;
    }
  }
}
