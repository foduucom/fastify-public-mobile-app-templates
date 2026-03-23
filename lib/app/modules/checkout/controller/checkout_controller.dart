import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../cart/controller/cart_controller.dart';
import '/app/data/basic_provider.dart';

class CheckoutController extends GetxController {

  late final CartController _cart;

  // ── Static address ID for now (replace with real later) ───────
  static const String _staticAddressId = '69bcfe79c057ac52a72a6302';

  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;
  final RxDouble subTotal    = 0.0.obs;
  final RxDouble deliveryFee = 5.0.obs;
  final RxDouble total       = 0.0.obs;
  final RxDouble discount    = 0.0.obs;

  final RxString selectedPaymentMethod = ''.obs;
  final RxString selectedVoucher       = ''.obs;
  final RxBool   isPlacingOrder        = false.obs;

  // ── Display labels → API values ───────────────────────────────
  final List<String> paymentMethods = [
    'Credit / Debit Card',
    'Cash on Delivery',
    'UPI / Net Banking',
    'Wallet',
  ];

  // Maps display label → API primary_method value
  static const Map<String, String> _methodApiMap = {
    'Credit / Debit Card': 'stripe',
    'Cash on Delivery':    'cod',
    'UPI / Net Banking':   'upi',
    'Wallet':              'wallet',
  };

  final List<String> vouchers = [
    'SAVE10 — 10% off',
    'FLAT50 — \$50 off',
    'FREESHIP — Free delivery',
  ];

  @override
  void onInit() {
    super.onInit();
    _cart = Get.find<CartController>();
    _syncFromCart();
    ever(_cart.cartItems, (_) => _syncFromCart());
  }

  void _syncFromCart() {
    cartItems.assignAll(_cart.cartItems);
    subTotal.value = _cart.subTotal.value;
    _recalcTotal();
  }

  void _recalcTotal() {
    total.value = subTotal.value + deliveryFee.value - discount.value;
  }

  void applyVoucher(String voucher) {
    selectedVoucher.value = voucher;
    if (voucher.contains('SAVE10')) {
      discount.value = subTotal.value * 0.10;
    } else if (voucher.contains('FLAT50')) {
      discount.value = 50.0;
    } else if (voucher.contains('FREESHIP')) {
      deliveryFee.value = 0.0;
    }
    _recalcTotal();
  }

  // ── Place Order → POST /api/order/create ─────────────────────
  Future<void> placeOrder() async {
    // Validate payment method
    if (selectedPaymentMethod.value.isEmpty) {
      Get.snackbar(
        'Payment Required', 'Please select a payment method',
        snackPosition:   SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText:       Colors.white,
        margin:          const EdgeInsets.all(16),
        borderRadius:    12,
      );
      return;
    }

    isPlacingOrder(true);
    try {
      // Map display label → API value
      final apiMethod = _methodApiMap[selectedPaymentMethod.value]
          ?? 'stripe';

      // ✅ Exact body your API expects
      final body = {
        'address_id':     _staticAddressId,
        'primary_method': apiMethod,
      };

      debugPrint('🛒 Creating order: $body');

      // BasicProvider returns body["data"] directly
      final result =
      await BasicProvider('order/create').postRequest(body);

      if (result != null) {
        final orderNo = result['order_no']?.toString() ?? '';

        // Refresh cart
        _cart.fetchCart();

        // ✅ Go to Order Success screen with order data
        Get.offAllNamed('/order-success', arguments: {
          'order_no': orderNo,
        });
      }

    } catch (e) {
      debugPrint('Place order error: $e');
      Get.snackbar(
        '❌ Error', 'Failed to place order. Please try again.',
        snackPosition:   SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText:       Colors.white,
        margin:          const EdgeInsets.all(16),
        borderRadius:    12,
      );
    } finally {
      isPlacingOrder(false);
    }
  }

  String itemName(Map item)     => _cart.itemName(item);
  double itemPrice(Map item)    => _cart.itemPrice(item);
  String itemImage(Map item)    => _cart.itemImage(item);
  int    itemQuantity(Map item) => _cart.itemQuantity(item);
}
