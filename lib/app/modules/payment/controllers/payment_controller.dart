import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/modules/address/controllers/address_controller.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/payment/razorpay.dart';
import 'package:zouhi/components/payment/cod_payment.dart';
import 'package:zouhi/components/payment/stripePayment.dart';
import 'package:zouhi/components/payment/phonePayPayment.dart';
import 'package:zouhi/components/payment/paypalPayment.dart';
import 'package:zouhi/components/payment/pesapalPayment.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:zouhi/components/dialogs/out_of_stock_sheet.dart';
import 'package:zouhi/constants/app_exceptions.dart';

class PaymentController extends GetxController with BaseController {
  // ── Observable state ──────────────────────────────────────────────────
  var deliveryOption = {}.obs;
  RxInt selectedIndex = 0.obs;
  var paymentOptions = [].obs;
  var isOrderLoading = false.obs;
  var shippingCharge = 0.0.obs;
  var tax = 0.0.obs;

  /// Holds the name of the secondary gateway chosen for COD prepayment
  /// (e.g. "stripe", "razorpay"). Empty when not applicable.
  var secondaryPaymentGateway = ''.obs;

  // The app has a single, app-wide currency (see CurrencyController).
  Map get selectedCurrency => Get.find<CurrencyController>().selectedCurrency;

  final box = GetStorage();
  final CartController cartController = Get.find<CartController>();
  final noteController = TextEditingController();

  // ── Payment configuration ─────────────────────────────────────────────
  /// Static defaults; updated at runtime from the `payment-methods` API.
  Map paymentConfig = {};

  /// Registry mapping gateway key → display info.
  static const List<Map<String, String>> _gatewayRegistry = [
    {"name": "stripe", "method": "Stripe", "image": "assets/icon/wallet.svg"},
    {
      "name": "phonepe",
      "method": "PhonePe",
      "image": "assets/icon/banking.svg"
    },
    {
      "name": "razorpay",
      "method": "Razorpay",
      "image": "assets/icon/wallet.svg"
    },
    {"name": "paypal", "method": "PayPal", "image": "assets/icon/wallet.svg"},
    {"name": "pesapal", "method": "Pesapal", "image": "assets/icon/wallet.svg"},
    {
      "name": "cod",
      "method": "Cash On Delivery",
      "image": "assets/icon/cashone.svg"
    },
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────

  @override
  void onInit() async {
    super.onInit();
    if (Get.arguments != null && Get.arguments['shippingCharge'] != null) {
      shippingCharge.value =
          (Get.arguments['shippingCharge'] as num).toDouble();
    }
    await getPaymentOption();
    _ensureAddressController();
  }

  void _ensureAddressController() {
    final AddressController addrCtrl;
    if (Get.isRegistered<AddressController>()) {
      addrCtrl = Get.find<AddressController>();
    } else {
      addrCtrl = Get.put(AddressController());
    }
    if (addrCtrl.userAddressList.isEmpty) {
      addrCtrl.getAddress();
    }
  }

  @override
  void onClose() {
    noteController.dispose();
    secondaryPaymentGateway.value = '';
    super.onClose();
  }

  // ── Payment options ───────────────────────────────────────────────────

  /// Populates [paymentOptions] from the current [paymentConfig].
  void _buildPaymentOptionsFromConfig() {
    paymentOptions.clear();
    for (final entry in _gatewayRegistry) {
      final key = entry['name']!;

      // Single-currency (USD) app: only Pesapal (and COD if enabled).
      if (key != 'pesapal' && key != 'cod') continue;

      if (paymentConfig[key]?['enabled'] == true) {
        paymentOptions.add({
          "name": key,
          "method": entry['method'],
          "image": entry['image'],
        });
      }
    }
  }

  /// Fetches payment methods from the API and rebuilds the option list.
  Future<void> getPaymentOption() async {
    // Build from static defaults first so the UI isn't empty.
    _buildPaymentOptionsFromConfig();

    var response = await BasicProvider("payment-methods")
        .getRequest()
        .catchError(handleError);

    printInfo(info: 'payment-methods response: $response');

    if (response != null) {
      if (response is Map) {
        // If the response is wrapped in a 'data' key (as seen in user's snippet), unwrap it.
        final Map actualData =
            response.containsKey('data') ? response['data'] : response;

        // Merge API data into local config.
        actualData.forEach((key, value) {
          paymentConfig[key] = value;
        });

        // Rebuild options with the updated config.
        _buildPaymentOptionsFromConfig();
      } else if (response is List) {
        for (var opt in response) {
          if (opt is Map && opt['name'] != null) {
            paymentConfig[opt['name']] = opt;
          }
          if (!paymentOptions.any((e) => e['name'] == opt['name'])) {
            paymentOptions.add(opt);
          }
        }
      }
    }

    // Select the first option by default.
    if (paymentOptions.isNotEmpty) {
      deliveryOption.value = paymentOptions[0];
      selectedIndex.value = 0;
    }
  }

  // ── COD prepayment dialog ─────────────────────────────────────────────

  /// Shows a dialog letting the user pick an online gateway for the
  /// required COD prepayment of [amount].
  void showCodPrepaymentDialog({
    required double amount,
    required Function(String) onMethodSelected,
  }) {
    final String symbol = selectedCurrency['symbol']?.toString() ?? '';
    Get.dialog(
      AlertDialog(
        title: const Text(
          'COD Prepayment Required',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To place an order with COD, you need to pay a required amount of $symbol${amount.toStringAsFixed(2)} in advance.',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Payment Method for Prepayment:',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: paymentOptions
                    .where((o) => o['name'] != 'cod')
                    .map((option) => ListTile(
                          leading: SvgPicture.asset(
                            option['image'] ?? 'assets/icon/wallet.svg',
                            width: 24,
                          ),
                          title: Text(
                            option['method'],
                            style: const TextStyle(fontFamily: 'Poppins'),
                          ),
                          onTap: () {
                            Get.back();
                            onMethodSelected(option['name']);
                          },
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel',
                style: TextStyle(color: Get.context!.themeSecondrytext)),
          ),
        ],
      ),
    );
  }

  /// Shows confirmation dialog matching design when COD option is clicked
  void showCodConfirmationDialog({required VoidCallback onConfirm}) {
    final BuildContext? context = Get.context;
    if (context == null) return;

    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;
    final bool isSmallScreen = screenWidth < 360;

    final String symbol =
        selectedCurrency['symbol']?.toString() ?? selectedCurrency['code']?.toString() ?? '';
    final double totalVal = double.tryParse(cartController.viewTotalAmount.value) ?? 0.0;
    final String formattedTotal = totalVal.toStringAsFixed(2);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.themeWhiteColor,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16.0 : 24.0,
          vertical: 24.0,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.85,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Confirm Your Order',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: context.themeTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => Get.back(),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.close,
                            color: context.themeSecondrytext,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 14 : 20),
                  Container(
                    width: isSmallScreen ? 58 : 70,
                    height: isSmallScreen ? 58 : 70,
                    decoration: BoxDecoration(
                      color: context.themeRedColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icon/dilevery.svg',
                        width: isSmallScreen ? 28 : 34,
                        height: isSmallScreen ? 28 : 34,
                        colorFilter: ColorFilter.mode(
                            context.themeRedColor, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 14 : 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: isSmallScreen ? 13 : 14,
                        color: context.themeSecondrytext,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'You have selected '),
                        TextSpan(
                          text: 'Cash On Delivery',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.themeTextColor,
                          ),
                        ),
                        const TextSpan(text: '. Your order of '),
                        TextSpan(
                          text: '$symbol $formattedTotal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.themeTextColor,
                          ),
                        ),
                        const TextSpan(
                          text:
                              ' will be placed right away and payable when it is delivered. Do you really want to place this order?',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 18 : 24),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 11 : 13,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: context.themegreyColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Cancel',
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: context.themeTextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Get.back();
                              onConfirm();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 11 : 13,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: context.themeTextColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Yes, Place Order',
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: context.themeWhiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> createOrder() async {
    final String methodName = deliveryOption['name'];
    String addressId = "";

    try {
      String name = "";
      String phone = "";
      String email = "";

      if (Get.isRegistered<AddressController>()) {
        final addressController = Get.find<AddressController>();
        if (addressController.userAddressList.isNotEmpty) {
          final selectAddressVal = addressController.selectAddress.value;
          if (selectAddressVal >= 0 &&
              selectAddressVal < addressController.userAddressList.length) {
            final selected =
                addressController.userAddressList[selectAddressVal];
            addressId =
                (selected['_id'] ?? selected['id'])?.toString() ?? "";
          }
        }
      }

      if (addressId.isEmpty) {
        Get.snackbar("Error", "Please select a delivery address");
        return null;
      }

      // Build the order form.
      String? couponCode;
      if (cartController.couponDetails.isNotEmpty &&
          cartController.couponDetails['code'] != null) {
        couponCode = cartController.couponDetails['code'].toString();
      } else if (cartController.viewCouponCode.value.isNotEmpty &&
          cartController.viewCouponCode.value != 'Apply Coupon') {
        couponCode = cartController.viewCouponCode.value;
      }

      var form = <String, dynamic>{
        "address_id": addressId,
        "payment_method": methodName,
        "primary_method": methodName,
        "notes": noteController.text.trim(),
        "coupon_code": couponCode,
        "currency_code": selectedCurrency['code']?.toString() ?? '',
        "exchange_rate": 1,
        "currency": selectedCurrency['symbol']?.toString() ?? '',
      };

      if (methodName == 'cod') {
        form['cod'] = 'true';

        // Include the secondary gateway when COD prepayment applies.
        if (secondaryPaymentGateway.value.isNotEmpty) {
          form['secondary_method'] = secondaryPaymentGateway.value;
        }
      }

      print("order/create form:: ${form}");

      dynamic response;
      try {
        response = await BasicProvider("order/create").postRequest(form);
      } catch (err) {
        if (_isOutOfStockError(err)) {
          await _handleOutOfStockError(err);
          return null;
        }
        await handleError(err);
        return null;
      }

      printInfo(info: 'createOrder response: $response');

      if (response != null) {
        return Map<String, dynamic>.from(response);
      }
    } catch (e) {
      printInfo(info: 'Error creating order: $e');
      Get.snackbar("Error", "Failed to create order");
    }
    return null;
  }

  /// Detects whether an error thrown during order creation is due to out-of-stock inventory.
  bool _isOutOfStockError(dynamic err) {
    final msg = errorMessageOf(err).toLowerCase();
    return msg.contains('out of stock') ||
        msg.contains('sold out') ||
        msg.contains('insufficient stock');
  }

  /// Presents the user with an interactive Out-of-Stock Resolution sheet.
  Future<void> _handleOutOfStockError(dynamic err) async {
    // Dismiss any active loading dialog/spinner
    if (Get.isDialogOpen ?? false) Get.back();

    final rawMessage = errorMessageOf(err);
    String detectedName = '';

    // Extract product name from message e.g., Product "Riser Breakout Cable" is out of stock.
    final match = RegExp(r'"([^"]+)"').firstMatch(rawMessage);
    if (match != null) {
      detectedName = match.group(1)?.trim() ?? '';
    }

    // Locate matching item in cartController
    final found = cartController.findCartItem(productName: detectedName);
    final cartItem = found?['item'] as Map<String, dynamic>?;
    final int itemIndex = (found?['index'] as int?) ?? 0;

    final productObj = cartItem?['product'] is Map
        ? cartItem!['product'] as Map
        : null;
    final productId =
        (productObj?['_id'] ?? cartItem?['product_id'])?.toString() ?? '';
    final variantObj = cartItem?['variant'] is Map
        ? cartItem!['variant'] as Map
        : null;
    final variantId =
        (variantObj?['_id'] ?? cartItem?['variant_id'])?.toString() ?? '';
    final itemId = cartItem?['_id']?.toString();
    final displayName = productObj?['name']?.toString() ??
        (detectedName.isNotEmpty ? detectedName : 'This product');

    await showOutOfStockBottomSheet(
      productName: displayName,
      cartItem: cartItem,
      onRemoveAndContinue: () async {
        return await _resolveOutOfStockAction(
          cartItem: cartItem,
          itemIndex: itemIndex,
          productId: productId,
          variantId: variantId,
          itemId: itemId,
          displayName: displayName,
          saveToWishlist: false,
        );
      },
      onSaveToWishlist: () async {
        return await _resolveOutOfStockAction(
          cartItem: cartItem,
          itemIndex: itemIndex,
          productId: productId,
          variantId: variantId,
          itemId: itemId,
          displayName: displayName,
          saveToWishlist: true,
        );
      },
      onReturnToCart: () {
        BottombarController.switchTab(2);
      },
    );
  }

  /// Executes item removal (and optional wishlist addition), updates totals,
  /// and handles redirection if the cart becomes empty.
  /// Returns `true` if removal succeeded, `false` otherwise.
  Future<bool> _resolveOutOfStockAction({
    Map<String, dynamic>? cartItem,
    required int itemIndex,
    required String productId,
    required String variantId,
    String? itemId,
    required String displayName,
    required bool saveToWishlist,
  }) async {
    bool removed = false;
    try {
      if (saveToWishlist && productId.isNotEmpty) {
        final wishlistController = Get.isRegistered<WishlistController>()
            ? Get.find<WishlistController>()
            : Get.put(WishlistController());

        // Skip adding if already present in wishlist to avoid duplicates
        if (!wishlistController.isProductInWishlist(productId)) {
          await wishlistController.addProductToWishlist(
            productid: productId,
            variant_id: variantId.isNotEmpty ? variantId : null,
          );
        }
      }

      if (cartItem != null && productId.isNotEmpty) {
        removed = await cartController.removeCartProduct(
          productId: productId,
          index: itemIndex,
          variantId: variantId,
          itemId: itemId,
          showSuccessDialog: false,
        );
      } else {
        await cartController.getCartProduct();
        removed = true;
      }
    } catch (e) {
      debugPrint('Error resolving out-of-stock item: $e');
      removed = false;
    }

    if (!removed) {
      HelperFunctions().showSnackBarError(
        'Failed to remove "$displayName" from order. Please check your internet connection and try again.',
      );
      return false;
    }

    if (cartController.cartItems.isEmpty) {
      HelperFunctions().showSnackBarError(
        'Your cart is now empty. Please add items to proceed.',
      );
      BottombarController.switchTab(0);
    } else {
      cartController.calculateCartTotals();
      cartController.updateOrderDetails();
      final actionText = saveToWishlist
          ? 'saved to your Wishlist and removed from order.'
          : 'removed from your order.';
      HelperFunctions().showSnackBarSuccess(
        '"$displayName" was $actionText Total updated.',
      );
    }
    return true;
  }

  // Future<Map<String, dynamic>?> createOrder() async {
  //   final String methodName = deliveryOption['name'];
  //   String addressId = "";
  //
  //   try {
  //     if (Get.isRegistered<AddressListController>()) {
  //       final addressController = Get.find<AddressListController>();
  //       final int selectedAddrIndex = addressController.selectAddress.value;
  //       if (addressController.userAddressList.isNotEmpty &&
  //           selectedAddrIndex < addressController.userAddressList.length) {
  //         addressId =
  //             addressController.userAddressList[selectedAddrIndex]['_id'];
  //       }
  //     }
  //
  //     if (addressId.isEmpty) {
  //       Get.snackbar("Error", "Selected address not found");
  //       return null;
  //     }
  //
  //     // Build the order form.
  //     var form = <String, String>{
  //       "address_id": addressId,
  //       "primary_method": methodName,
  //     };
  //
  //     if (methodName == 'cod') {
  //       form['cod'] = 'true';
  //
  //       // Include the secondary gateway when COD prepayment applies.
  //       if (secondaryPaymentGateway.value.isNotEmpty) {
  //         form['secondary_method'] = secondaryPaymentGateway.value;
  //       }
  //     }
  //
  //     var response = await BasicProvider("order/create")
  //         .postRequest(form)
  //         .catchError(handleError);
  //
  //     printInfo(info: 'createOrder response: $response');
  //
  //     if (response != null) {
  //       return Map<String, dynamic>.from(response);
  //     }
  //   } catch (e) {
  //     printInfo(info: 'Error creating order: $e');
  //     Get.snackbar("Error", "Failed to create order");
  //   }
  //   return null;
  // }

  // Future<void> confirmPayment(String orderId, String paymentIntentId) async {
  //   try {
  //     var form = {
  //       "order_id": orderId,
  //       "payment_intent_id": paymentIntentId,
  //     };

  //     var response = await BasicProvider("order/confirm-payment")
  //         .postRequest(form)
  //         .catchError(handleError);

  //     if (response != null) {
  //       printInfo(info: 'Payment confirmed: $response');
  //     } else {
  //       printInfo(info: 'Payment confirmation failed');
  //     }
  //   } catch (e) {
  //     printInfo(info: 'Error confirming payment: $e');
  //   }
  // }

  /// Tells the backend a payment finished so it can verify and mark the order
  /// paid. Razorpay also passes its payment id and signature for verification.
  /// A failure here is logged but never aborts the flow: the order exists and
  /// the success screen shows the status the server holds.
  Future<void> confirmPayment({
    required String orderId,
    required String paymentIntentId,
    String? razorpayPaymentId,
    String? razorpaySignature,
  }) async {
    try {
      final form = <String, dynamic>{
        "order_id": orderId,
        "payment_intent_id": paymentIntentId,
        if (razorpayPaymentId != null && razorpayPaymentId.isNotEmpty)
          "razorpay_payment_id": razorpayPaymentId,
        if (razorpaySignature != null && razorpaySignature.isNotEmpty)
          "razorpay_signature": razorpaySignature,
      };

      var response = await BasicProvider("order/confirm-payment")
          .postRequest(form)
          .catchError(handleError);

      printInfo(info: 'confirmPayment response: $response');
    } catch (e) {
      printInfo(info: 'Error confirming payment: $e');
    }
  }

  Future<void> _executeOrderPlacement({
    required String methodName,
    required double amount,
  }) async {
    HelperFunctions().showOverlayLoader();

    try {
      var orderResponse = await createOrder();
      printInfo(info: 'orderResponse: $orderResponse');

      if (orderResponse == null) {
        if (Get.isDialogOpen ?? false) Get.back();
        return;
      }

      final String orderId =
          orderResponse['order_no'] ?? orderResponse['_id'] ?? "";
      final String rawOrderId = orderResponse['_id'] ?? "";

      await _processGatewayPayment(
        methodName: methodName,
        amount: amount,
        orderResponse: orderResponse,
        rawOrderId: rawOrderId,
      );

      if (Get.isDialogOpen ?? false) Get.back();
      Get.offAllNamed(Routes.ORDERSUCCESS, arguments: {'id': rawOrderId, 'order_no': orderResponse['order_no']});
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      HelperFunctions().showSnackBarError('Failed to place order: $e');
    }
  }

  Future<void> processOrder() async {
    if (deliveryOption.isEmpty) {
      HelperFunctions().showSnackBarError('Please select a payment method');
      return;
    }

    final String methodName = deliveryOption['name'];
    final double amount = cartController.totalAmount.value;

    // ── COD flow ──
    if (methodName == 'cod') {
      final codConfig = paymentConfig['cod'];
      final bool needsPrepayment = codConfig != null &&
          codConfig['cod_prepayment_type'] != null &&
          codConfig['cod_prepayment_ammount'] != null &&
          codConfig['cod_prepayment_ammount'].toString().isNotEmpty;

      if (needsPrepayment) {
        final double rawPrepaymentAmount =
            double.tryParse(codConfig['cod_prepayment_ammount'].toString()) ??
                0.0;
        final double prepaymentAmount = rawPrepaymentAmount;

        showCodPrepaymentDialog(
          amount: prepaymentAmount,
          onMethodSelected: (selectedOnlineMethod) async {
            secondaryPaymentGateway.value = selectedOnlineMethod;

            HelperFunctions().showOverlayLoader();
            try {
              var orderResponse = await createOrder();
              if (orderResponse == null) {
                if (Get.isDialogOpen ?? false) Get.back();
                return;
              }

              final String orderId =
                  orderResponse['order_no'] ?? orderResponse['_id'] ?? "";
              final String rawOrderId = orderResponse['_id'] ?? "";

              await _processGatewayPayment(
                methodName: selectedOnlineMethod,
                amount: prepaymentAmount,
                orderResponse: orderResponse,
                rawOrderId: rawOrderId,
              );

              await CODPayment().processPayment(amount: amount);

              if (Get.isDialogOpen ?? false) Get.back();
              Get.offAllNamed(Routes.ORDERSUCCESS, arguments: {'id': rawOrderId, 'order_no': orderResponse['order_no']});
            } catch (e) {
              if (Get.isDialogOpen ?? false) Get.back();
              HelperFunctions().showSnackBarError('Prepayment failed: $e');
            } finally {
              secondaryPaymentGateway.value = '';
            }
          },
        );
        return;
      }

      // Show COD confirmation dialog when user clicks Pay Now
      showCodConfirmationDialog(
        onConfirm: () async {
          await _executeOrderPlacement(methodName: methodName, amount: amount);
        },
      );
      return;
    }

    // ── Standard flow for online payment methods ──
    await _executeOrderPlacement(methodName: methodName, amount: amount);
  }

  // Future<void> processOrder() async {
  //   if (deliveryOption.isEmpty) {
  //     HelperFunctions().showSnackBarError('Please select a payment method');
  //     return;
  //   }
  //
  //   final String methodName = deliveryOption['name'];
  //   final double amount = cartController.total.value;
  //
  //   // ── COD prepayment flow ──
  //   if (methodName == 'cod') {
  //     final codConfig = paymentConfig['cod'];
  //     final bool needsPrepayment = codConfig['cod_prepayment_type'] != null &&
  //         codConfig['cod_prepayment_ammount'] != null &&
  //         codConfig['cod_prepayment_ammount'].toString().isNotEmpty;
  //
  //     if (needsPrepayment) {
  //       final double prepaymentAmount =
  //           double.tryParse(codConfig['cod_prepayment_ammount'].toString()) ??
  //               0.0;
  //
  //       showCodPrepaymentDialog(
  //         amount: prepaymentAmount,
  //         onMethodSelected: (selectedOnlineMethod) async {
  //           // Store the chosen secondary gateway so createOrder() includes it.
  //           secondaryPaymentGateway.value = selectedOnlineMethod;
  //
  //           HelperFunctions().showOverlayLoader();
  //           try {
  //             var orderResponse = await createOrder();
  //             if (orderResponse == null) {
  //               if (Get.isDialogOpen ?? false) Get.back();
  //               return;
  //             }
  //
  //             final String orderId =
  //                 orderResponse['order_no'] ?? orderResponse['_id'] ?? "";
  //             final String rawOrderId = orderResponse['_id'] ?? "";
  //
  //             await _processGatewayPayment(
  //               methodName: selectedOnlineMethod,
  //               amount: prepaymentAmount,
  //               orderResponse: orderResponse,
  //               rawOrderId: rawOrderId,
  //             );
  //
  //             // Finalize as COD.
  //             await CODPayment().processPayment(amount: amount);
  //
  //             if (Get.isDialogOpen ?? false) Get.back();
  //             Get.offAllNamed(Routes.ORDERSUCCESS, arguments: orderId);
  //           } catch (e) {
  //             if (Get.isDialogOpen ?? false) Get.back();
  //             HelperFunctions().showSnackBarError('Prepayment failed: $e');
  //           } finally {
  //             secondaryPaymentGateway.value = '';
  //           }
  //         },
  //       );
  //       return; // Wait for dialog selection.
  //     }
  //   }
  //
  //   // ── Standard flow (no prepayment) ──
  //   HelperFunctions().showOverlayLoader();
  //
  //   try {
  //     var orderResponse = await createOrder();
  //     printInfo(info: 'orderResponse: $orderResponse');
  //
  //     if (orderResponse == null) {
  //       if (Get.isDialogOpen ?? false) Get.back();
  //       return;
  //     }
  //
  //     final String orderId =
  //         orderResponse['order_no'] ?? orderResponse['_id'] ?? "";
  //     final String rawOrderId = orderResponse['_id'] ?? "";
  //
  //     await _processGatewayPayment(
  //       methodName: methodName,
  //       amount: amount,
  //       orderResponse: orderResponse,
  //       rawOrderId: rawOrderId,
  //     );
  //
  //     if (Get.isDialogOpen ?? false) Get.back();
  //     Get.offAllNamed(Routes.ORDERSUCCESS, arguments: orderId);
  //   } catch (e) {
  //     if (Get.isDialogOpen ?? false) Get.back();
  //     HelperFunctions().showSnackBarError('Failed to place order: $e');
  //   }
  // }
  Future<void> _processGatewayPayment({
    required String methodName,
    required double amount,
    required Map<String, dynamic> orderResponse,
    required String rawOrderId,
  }) async {
    switch (methodName) {
      case 'stripe':
        final publicKey = paymentConfig['stripe']['publicKey'];
        final clientSecret = orderResponse['payment_client_secret'] ?? "";
        final paymentIntentId = orderResponse['payment_intent_id'] ?? "";
        await StripePayment(publicKey: publicKey).processPayment(
          amount: amount,
          currency: Get.find<CurrencyController>().code,
          clientSecret: clientSecret,
        );
        await confirmPayment(
          orderId: rawOrderId,
          paymentIntentId: paymentIntentId.toString(),
        );
        break;

      case 'razorpay':
        final razorpayConfig = paymentConfig['razorpay'];
        if (razorpayConfig == null) {
          throw Exception("Razorpay configuration is missing from backend.");
        }
        final keyId = razorpayConfig['key_id'] ?? razorpayConfig['key'] ?? '';
        if (keyId.isEmpty) {
          throw Exception("Razorpay key_id is empty in config.");
        }

        final paymentIntentId = orderResponse['payment_intent_id'] ??
            orderResponse['razorpay_order_id'] ??
            "";

        final List? paymentsList = orderResponse['payments'] is List
            ? orderResponse['payments']
            : null;
        final String? firstPaymentIntentId =
            (paymentsList != null && paymentsList.isNotEmpty)
                ? paymentsList[0]['payment_intent_id']?.toString()
                : null;
        // The Razorpay order id (payment_intent_id) the backend created.
        final String razorpayOrderId = firstPaymentIntentId ??
            (paymentIntentId.toString().trim().isNotEmpty
                ? paymentIntentId.toString().trim()
                : rawOrderId);

        // A cancelled/failed payment throws out of processPayment; the order
        // stays pending server-side and the error snackbar is shown upstream.
        final razorpayResponse =
            await RazorPayPayment(keyId: keyId).processPayment(
          amount: amount,
          metadata: orderResponse,
        );

        await confirmPayment(
          orderId: rawOrderId,
          paymentIntentId: razorpayResponse.orderId ?? razorpayOrderId,
          razorpayPaymentId: razorpayResponse.paymentId,
          razorpaySignature: razorpayResponse.signature,
        );

        break;

      case 'phonepe':
        final merchantId = paymentConfig['phonepe']['merchant_id'];
        await PhonePePayment(merchantId: merchantId).processPayment(
          amount: amount,
          metadata: orderResponse,
        );
        await confirmPayment(
          orderId: rawOrderId,
          paymentIntentId: (orderResponse['payment_intent_id'] ?? '').toString(),
        );
        break;

      // ✅ ADD THIS CASE
      case 'paypal':
        final clientId = paymentConfig['paypal']['client_id'];
        final secretKey = paymentConfig['paypal']['client_secret'];
        await PayPalPayment(
          clientId: clientId,
          secretKey: secretKey,
        ).processPayment(
          amount: amount,
          metadata: orderResponse,
          currency: Get.find<CurrencyController>().code,
        );
        break;

      case 'pesapal':
        final pesapalConfig = paymentConfig['pesapal'];
        if (pesapalConfig == null) {
          throw Exception("Pesapal configuration is missing from backend.");
        }
        final consumerKey = pesapalConfig['consumer_key'] ?? '';
        final consumerSecret = pesapalConfig['consumer_secret'] ?? '';
        print("consumerKey:: $consumerKey");
        print("consumerSecret:: $consumerSecret");
        final sandbox = pesapalConfig['sandbox']?.toString() == 'true';

        await PesapalPayment(
          consumerKey: consumerKey,
          consumerSecret: consumerSecret,
          sandbox: sandbox,
        ).processPayment(
          amount: amount,
          metadata: orderResponse,
        );
        break;

      case 'cod':
        await CODPayment().processPayment(amount: amount);
        break;

      default:
        printInfo(info: 'Unknown payment method: $methodName');
        await Future.delayed(const Duration(seconds: 1));
    }
  }

  // Future<void> _processGatewayPayment({
  //   required String methodName,
  //   required double amount,
  //   required Map<String, dynamic> orderResponse,
  //   required String rawOrderId,
  // }) async {
  //   switch (methodName) {
  //     case 'stripe':
  //       final publicKey = paymentConfig['stripe']['publicKey'];
  //       final clientSecret = orderResponse['payment_client_secret'] ?? "";
  //       final paymentIntentId = orderResponse['payment_intent_id'] ?? "";
  //
  //       await StripePayment(publicKey: publicKey).processPayment(
  //         amount: amount,
  //         currency: Get.find<CurrencyController>().code,
  //         clientSecret: clientSecret,
  //       );
  //       await confirmPayment(rawOrderId, paymentIntentId);
  //       break;
  //
  //     case 'razorpay':
  //       final keyId = paymentConfig['razorpay']['key_id'];
  //       await RazorPayPayment(keyId: keyId).processPayment(
  //         amount: amount,
  //         metadata: orderResponse,
  //       );
  //       break;
  //
  //     case 'phonepe':
  //       final merchantId = paymentConfig['phonepe']['merchant_id'];
  //       await PhonePePayment(merchantId: merchantId).processPayment(
  //         amount: amount,
  //         metadata: orderResponse,
  //       );
  //       break;
  //
  //     case 'cod':
  //       await CODPayment().processPayment(amount: amount);
  //       break;
  //
  //     default:
  //       printInfo(info: 'Unknown payment method: $methodName');
  //       await Future.delayed(const Duration(seconds: 1));
  //   }
  // }
}
