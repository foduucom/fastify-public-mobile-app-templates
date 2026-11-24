import 'dart:async';

import 'package:foddu/components/dialogs/out_of_stock_sheet.dart';
import 'package:foddu/core/services/wishlistService.dart';
import 'package:foddu/core/services/cartServcie.dart';
import 'package:foddu/constants/app_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foddu/helpers/dialog_helper.dart';
import '../widgets/paypal_view.dart';
import '/app/routes/app_pages.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/constants/helper_functions.dart';
import '/constants/constants.dart' show url;
import '/app/modules/cart/controllers/cart_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '/components/paymentGateway/Stripe.dart';
import '/components/paymentGateway/PhonePe.dart';
import '/components/paymentGateway/RazorPay.dart';
import '/app/modules/address/controllers/address_list_controller.dart';

/// 'SANDBOX' for testing, 'PRODUCTION' for a real release build.
const String kPhonePeEnvironment = 'SANDBOX';

/// Custom URL scheme PhonePe uses to redirect back into this app.
/// Placeholder — must be unique per deployed app and match the scheme
/// registered in AndroidManifest.xml / Info.plist.
const String kPhonePeAppScheme = 'foduuecommerceapp2';

class CheckOutController extends GetxController with BaseController {
  // ── Observable state ──────────────────────────────────────────────────
  var deliveryOption = {}.obs;
  RxInt selectedIndex = 0.obs;
  var paymentOptions = [].obs;
  final RxBool isLoadingPaymentMethods = true.obs;
  final RxBool isSubmittingOrder = false.obs;
  final RxBool isChoosingCodPrepayment = false.obs;
  //var selectedAddress = "".obs;
  var savedCards = <String>[].obs;
  var selectedCardIndex = 0.obs;

  /// Holds the name of the secondary gateway chosen for COD prepayment
  /// (e.g. "stripe", "razorpay"). Empty when not applicable.
  var secondaryPaymentGateway = ''.obs;

  // Add these to CheckOutController
  var selectedAddressString = "".obs; // For displaying in UI
  final RxMap<String, dynamic> selectedAddressData =
      <String, dynamic>{}.obs; // For storing the full address object

  var isEditingAddress = false.obs;
  var tempAddress = "".obs;

  // Method to load selected address from AddressListController
  // In CheckOutController, make sure loadSelectedAddress is properly setting selectedAddressData
  void loadSelectedAddress() {
    print('Loading selected address...'); // Debug print

    if (Get.isRegistered<AddressListController>()) {
      final addressController = Get.find<AddressListController>();
      final int selectedAddrIndex = addressController.selectAddress.value;

      print('Selected index: $selectedAddrIndex');
      print('Address list length: ${addressController.userAddressList.length}');

      if (selectedAddrIndex >= 0 &&
          addressController.userAddressList.isNotEmpty &&
          selectedAddrIndex < addressController.userAddressList.length) {
        // Store the full address data
        final addressData =
            addressController.userAddressList[selectedAddrIndex];
        print('Address data type: ${addressData.runtimeType}');
        print('Address data: $addressData');

        // Make sure we're storing it as a Map
        if (addressData is Map) {
          selectedAddressData.assignAll(Map<String, dynamic>.from(addressData));
        } else {
          print('Error: addressData is not a Map');
          selectedAddressData.clear();
        }

        final userAddress = selectedAddressData;

        // Build the full address string
        String fullAddress = "";

        // Add name if exists
        if (userAddress['name'] != null &&
            userAddress['name'].toString().isNotEmpty) {
          fullAddress = userAddress['name'].toString().capitalizeFirst ?? '';
        }

        // Add street and landmark
        List<String> addressParts = [];
        if (userAddress['street'] != null &&
            userAddress['street'].toString().isNotEmpty) {
          addressParts.add(userAddress['street']);
        }
        if (userAddress['landmark'] != null &&
            userAddress['landmark'].toString().isNotEmpty) {
          addressParts.add(userAddress['landmark']);
        }

        if (addressParts.isNotEmpty) {
          if (fullAddress.isNotEmpty) fullAddress += ", ";
          fullAddress += addressParts.join(', ');
        }

        // Add state and country
        List<String> locationParts = [];
        if (userAddress['state'] != null &&
            userAddress['state'] is Map &&
            userAddress['state']['name'] != null) {
          locationParts.add(userAddress['state']['name']);
        }
        if (userAddress['country'] != null &&
            userAddress['country'] is Map &&
            userAddress['country']['name'] != null) {
          locationParts.add(userAddress['country']['name']);
        }

        if (locationParts.isNotEmpty) {
          if (fullAddress.isNotEmpty) fullAddress += ", ";
          fullAddress += locationParts.join(', ');
        }

        // Add postal code/pincode
        if (userAddress['postal_code'] != null &&
            userAddress['postal_code'].toString().isNotEmpty) {
          if (fullAddress.isNotEmpty) fullAddress += " - ";
          fullAddress += userAddress['postal_code'];
        } else if (userAddress['pincode'] != null &&
            userAddress['pincode'].toString().isNotEmpty) {
          if (fullAddress.isNotEmpty) fullAddress += " - ";
          fullAddress += userAddress['pincode'];
        }

        selectedAddressString.value = fullAddress;
        print('Full address string: $fullAddress');
      } else {
        print('No address found');
        selectedAddressData.clear();
        selectedAddressString.value = "";
      }
    } else {
      print('AddressListController not registered');
    }
  }

  void refreshAddress() {
    loadSelectedAddress();
  }

  String _addressId(dynamic address) {
    if (address is! Map) return '';
    final value = (address['_id'] ?? address['id'])?.toString().trim() ?? '';
    return value.isEmpty || value == 'null' ? '' : value;
  }

  void updateAddressFromForm(Map<String, dynamic> updatedAddress) {
    selectedAddressData.assignAll(updatedAddress);
    loadSelectedAddress(); // This will rebuild the display string
  }

  final box = GetStorage();
  final CartController cartController = Get.find<CartController>();

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
    await getPaymentOption();
    // Use a short delay to ensure AddressListController has loaded data
    Future.delayed(const Duration(milliseconds: 100), () {
      loadSelectedAddress();

      // Reactively listen to address changes if controller is available
      if (Get.isRegistered<AddressListController>()) {
        final addressController = Get.find<AddressListController>();
        ever(addressController.selectAddress, (_) => loadSelectedAddress());
        ever(addressController.userAddressList, (_) => loadSelectedAddress());
      }
    });
  }

  @override
  void onClose() {
    secondaryPaymentGateway.value = '';
    super.onClose();
  }

  // ── Payment options ───────────────────────────────────────────────────

  /// Populates [paymentOptions] from the current [paymentConfig].
  void _buildPaymentOptionsFromConfig() {
    paymentOptions.clear();
    for (final entry in _gatewayRegistry) {
      final key = entry['name']!;
      final config = _paymentConfigFor(key);
      if (config is Map && _isEnabled(config['enabled'])) {
        paymentOptions.add({
          "name": key,
          "method": entry['method'],
          "image": entry['image'],
        });
      }
    }
  }

  dynamic _paymentConfigFor(String key) {
    if (key != 'cod') return paymentConfig[key];
    return paymentConfig['cod'] ??
        paymentConfig['cash'] ??
        paymentConfig['cash_on_delivery'];
  }

  bool _isEnabled(dynamic value) =>
      value == true ||
      const {'true', '1', 'yes', 'enabled'}
          .contains(value?.toString().trim().toLowerCase());

  dynamic _unwrapPaymentMethods(dynamic response) {
    dynamic methods = response;
    for (var depth = 0; depth < 3; depth++) {
      if (methods is! Map) return methods;
      final nested = methods['payment_methods'] ??
          methods['paymentMethods'] ??
          methods['data'];
      if (nested == null) return methods;
      methods = nested;
    }
    return methods;
  }

  /// Fetches payment methods from the API and rebuilds the option list.
  Future<void> getPaymentOption() async {
    isLoadingPaymentMethods.value = true;
    try {
      // Build from static defaults first so the UI isn't empty.
      _buildPaymentOptionsFromConfig();

      final response =
          await BasicProvider("payment-methods").getRequest(useCache: false);

      printInfo(info: 'payment-methods response: $response');

      final methods = _unwrapPaymentMethods(response);
      if (methods is Map) {
        for (final key in methods.keys) {
          paymentConfig[key.toString()] = methods[key];
        }
        _syncCodAliases();
        _buildPaymentOptionsFromConfig();
      } else if (methods is List) {
        _appendPaymentOptions(methods);
      }

      // Select the first option by default.
      if (paymentOptions.isNotEmpty) {
        deliveryOption.value = paymentOptions[0];
        selectedIndex.value = 0;
      }
    } catch (error) {
      printInfo(info: 'getPaymentOption error: $error');
      await handleError(error);
    } finally {
      // An empty or unexpected response is a completed load, not an ongoing
      // request. Let the view show an empty state instead of spinning forever.
      isLoadingPaymentMethods.value = false;
    }
  }

  void _syncCodAliases() {
    final cod = paymentConfig['cod'] ??
        paymentConfig['cash'] ??
        paymentConfig['cash_on_delivery'];
    if (cod != null) paymentConfig['cod'] = cod;
  }

  void _appendPaymentOptions(List options) {
    for (final opt in options) {
      if (opt is! Map || opt['name'] == null) continue;
      final rawName = opt['name'].toString().trim().toLowerCase();
      final key = const {'cash', 'cash_on_delivery'}.contains(rawName)
          ? 'cod'
          : rawName;
      final registry = _gatewayRegistry.firstWhereOrNull(
        (entry) => entry['name'] == key,
      );
      if (registry == null ||
          (opt.containsKey('enabled') && !_isEnabled(opt['enabled'])) ||
          paymentOptions.any((option) => option['name'] == key)) {
        continue;
      }
      final config = Map<String, dynamic>.from(opt);
      paymentOptions.add({
        ...config,
        'name': key,
        'method': registry['method'],
        'image': registry['image'],
      });
      if (key == 'cod') paymentConfig['cod'] = config;
    }
  }

  // ── COD prepayment dialog ─────────────────────────────────────────────

  /// Shows a dialog letting the user pick an online gateway for the
  /// required COD prepayment of [amount].
  void showCodPrepaymentDialog({
    required double amount,
    required Function(String) onMethodSelected,
  }) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'COD Prepayment Required',
          style: TextStyle(fontFamily: 'lato', fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To place an order with COD, you need to pay a required amount of \u{20B9}$amount in advance.',
              style: const TextStyle(fontFamily: 'lato'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Payment Method for Prepayment:',
              style: TextStyle(
                fontFamily: 'lato',
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
                            style: const TextStyle(fontFamily: 'lato'),
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
            onPressed: () {
              isChoosingCodPrepayment.value = false;
              Get.back();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<Map<String, dynamic>?> createOrder({String currency = 'INR'}) async {
    final String methodName = deliveryOption['name'];
    String addressId = "";
    var phase = 'validating checkout details';
    final stopwatch = Stopwatch()..start();

    try {
      // Prioritize retrieving addressId from selectedAddressData which is already in this controller
      if (selectedAddressData.isNotEmpty) {
        addressId = _addressId(selectedAddressData);
      }

      // Fallback/Validation with AddressListController if addressId is still empty
      if (addressId.isEmpty && Get.isRegistered<AddressListController>()) {
        final addressController = Get.find<AddressListController>();
        final int selectedAddrIndex = addressController.selectAddress.value;
        if (selectedAddrIndex >= 0 &&
            addressController.userAddressList.isNotEmpty &&
            selectedAddrIndex < addressController.userAddressList.length) {
          final addr = addressController.userAddressList[selectedAddrIndex];
          addressId = _addressId(addr);
        }
      }

      if (addressId.isEmpty) {
        Get.snackbar("Error", "Selected address not found");
        return null;
      }

      // Build the order form.
      final isCash = methodName == 'cod' || methodName == 'cash';
      final form = <String, dynamic>{
        "address_id": addressId,
        "primary_method": isCash ? 'cash' : methodName,
        "secondary_method": isCash && secondaryPaymentGateway.value.isNotEmpty
            ? secondaryPaymentGateway.value
            : null,
        "notes": "",
        "coupon_code": null,
        "coupon_discount": 0,
      };

      if (!isCash) {
        form['currency'] = currency;
      }

      if (cartController.couponDetails.isNotEmpty &&
          cartController.couponController.text.trim().isNotEmpty) {
        form['coupon_code'] = cartController.couponController.text.trim();
        final discount = cartController.couponDetails['discount_amount'];
        form['coupon_discount'] = num.tryParse(discount?.toString() ?? '') ?? 0;
      }

      printInfo(
        info: 'Checkout order request prepared (cash=$isCash, '
            'addressPresent=${addressId.isNotEmpty}, '
            'secondaryMethod=${secondaryPaymentGateway.value.isNotEmpty})',
      );

      final orderProvider = isCash
          ? BasicProvider('checkout/place-order', baseUrl: url)
          : BasicProvider('order/create');
      Map<String, String>? csrfHeaders;
      if (isCash) {
        phase = 'loading checkout security';
        csrfHeaders = await _fetchWebCheckoutCsrfHeaders();
      }

      phase = 'submitting order';
      final orderPath = Uri.parse(orderProvider.fetchUrl()).path;
      printInfo(info: 'Submitting checkout order to $orderPath.');
      final response = await orderProvider.postRequest(
        form,
        extraHeaders: csrfHeaders,
      );

      printInfo(
        info: 'Checkout order response received after '
            '${stopwatch.elapsedMilliseconds}ms '
            '(shape=${response is Map ? response.keys.join(',') : response.runtimeType})',
      );

      if (response != null) {
        return Map<String, dynamic>.from(response);
      }
    } catch (error) {
      final status = error is AppException && error.statusCode != null
          ? ', httpStatus=${error.statusCode}'
          : '';
      printInfo(
        info: 'Checkout order failed during "$phase" after '
            '${stopwatch.elapsedMilliseconds}ms (${error.runtimeType}$status)',
      );
      if (_isOutOfStockError(error)) {
        _handleOutOfStockError(error);
      } else if (error is AppException) {
        await handleError(error);
      } else if (phase == 'loading checkout security') {
        HelperFunctions().showSnackBarError(
          'Could not initialize secure checkout. Please try again.',
        );
      } else if (error is TimeoutException) {
        HelperFunctions().showSnackBarError(
          'The order request timed out. Check your orders before trying again.',
        );
      } else {
        HelperFunctions().showSnackBarError(
          'The order could not be confirmed. Check your orders before retrying.',
        );
      }
    }
    return null;
  }

  Future<Map<String, String>> _fetchWebCheckoutCsrfHeaders() async {
    final stopwatch = Stopwatch()..start();
    final provider = BasicProvider('', baseUrl: url);
    final headers = provider.headerType();
    headers['accept'] = 'text/html';

    printInfo(info: 'Checkout security bootstrap started.');
    final response = await http.get(Uri.parse(url), headers: headers).timeout(
          const Duration(seconds: 20),
        );
    printInfo(
      info: 'Checkout security page returned HTTP ${response.statusCode} '
          'after ${stopwatch.elapsedMilliseconds}ms.',
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
          'Unable to initialize checkout security (HTTP ${response.statusCode}).');
    }

    final csrfToken = _csrfTokenFromHtml(response.body);
    final cookies = _cookiesFromSetCookieHeader(
      response.headers['set-cookie'] ?? '',
    );
    final csrfCookie = cookies['_csrf'];

    if (csrfToken == null ||
        csrfToken.isEmpty ||
        csrfCookie == null ||
        csrfCookie.isEmpty) {
      throw StateError('The checkout page did not provide its security token.');
    }

    // Keep the full cookie set from the same bootstrap response. Some store
    // deployments bind the CSRF secret to a session cookie as well as _csrf.
    return {
      'cookie': cookies.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('; '),
      'x-csrf-token': csrfToken,
    };
  }

  Map<String, String> _cookiesFromSetCookieHeader(String setCookieHeader) {
    const cookieAttributes = {
      'domain',
      'expires',
      'httponly',
      'max-age',
      'path',
      'priority',
      'samesite',
      'secure',
    };
    final cookies = <String, String>{};
    final cookiePattern = RegExp(r'(?:^|,\s*)([A-Za-z0-9_.-]+)=([^;,]*)');
    for (final match in cookiePattern.allMatches(setCookieHeader)) {
      final name = match.group(1)!.trim();
      if (!cookieAttributes.contains(name.toLowerCase())) {
        cookies[name] = match.group(2)!.trim();
      }
    }
    return cookies;
  }

  String? _csrfTokenFromHtml(String html) {
    final metaTags = RegExp(r'<meta\b[^>]*>', caseSensitive: false);
    final nameAttribute = RegExp(
      r'''\bname\s*=\s*["']([^"']+)["']''',
      caseSensitive: false,
    );
    final contentAttribute = RegExp(
      r'''\bcontent\s*=\s*["']([^"']+)["']''',
      caseSensitive: false,
    );

    for (final match in metaTags.allMatches(html)) {
      final tag = match.group(0)!;
      final name = nameAttribute.firstMatch(tag)?.group(1);
      if (name?.toLowerCase() != 'csrf-token') continue;
      return contentAttribute.firstMatch(tag)?.group(1);
    }
    return null;
  }

  Future<void> addNewCard() async {}

  Future<void> confirmPayment(
    String orderId,
    String paymentIntentId, {
    String? paymentId,
    String? razorpaySignature,
  }) async {
    if (orderId.isEmpty || paymentIntentId.isEmpty) {
      throw StateError('Payment confirmation details are incomplete.');
    }

    final form = <String, dynamic>{
      'order_id': orderId,
      'payment_intent_id': paymentIntentId,
      if (paymentId != null && paymentId.isNotEmpty)
        'razorpay_payment_id': paymentId,
      if (razorpaySignature != null && razorpaySignature.isNotEmpty)
        'razorpay_signature': razorpaySignature,
    };

    final response = await BasicProvider('order/confirm-payment')
        .postRequest(form)
        .catchError(handleError);
    if (response is! Map) {
      throw StateError('The payment could not be confirmed by the server.');
    }

    final status = response['status']?.toString().toLowerCase();
    final paymentStatus = response['payment_status']?.toString().toLowerCase();
    if (status != 'success' && paymentStatus != 'paid') {
      throw StateError(
        response['message']?.toString() ??
            'The payment could not be confirmed by the server.',
      );
    }
  }

  Future<void> processOrder() async {
    if (deliveryOption.isEmpty) {
      HelperFunctions().showSnackBarError('Please select a payment method');
      return;
    }

    if (selectedAddressData.isEmpty) {
      HelperFunctions()
          .showSnackBarError('Please select a delivery address first');
      return;
    }

    // Revalidate the cart immediately before creating an order. Checkout must
    // use current server quantities and pricing, never a stale cached snapshot.
    if (isSubmittingOrder.value) return;
    isSubmittingOrder.value = true;
    try {
      await CartService.to.fetchCart(useCache: false);
      if (CartService.to.loadError.value) {
        HelperFunctions().showSnackBarError(
          'Unable to refresh your cart. Please try again before placing your order.',
        );
        return;
      }
      if (CartService.to.cartItems.isEmpty) {
        HelperFunctions().showSnackBarError(
          'Your cart is empty. Add an item before placing your order.',
        );
        return;
      }
    } finally {
      isSubmittingOrder.value = false;
    }

    final String methodName = deliveryOption['name'];
    final bool isCashMethod = methodName == 'cod' || methodName == 'cash';
    final double amount = cartController.total.value;

    // ── COD prepayment flow ──
    if (isCashMethod) {
      final codConfig = paymentConfig['cod'] ?? paymentConfig['cash'] ?? {};
      final bool needsPrepayment = codConfig['cod_prepayment_type'] != null &&
          codConfig['cod_prepayment_ammount'] != null &&
          codConfig['cod_prepayment_ammount'].toString().isNotEmpty;

      if (needsPrepayment) {
        if (isChoosingCodPrepayment.value) return;
        isChoosingCodPrepayment.value = true;
        final double prepaymentAmount =
            double.tryParse(codConfig['cod_prepayment_ammount'].toString()) ??
                0.0;

        showCodPrepaymentDialog(
          amount: prepaymentAmount,
          onMethodSelected: (selectedOnlineMethod) async {
            isChoosingCodPrepayment.value = false;
            if (isSubmittingOrder.value) return;
            isSubmittingOrder.value = true;
            secondaryPaymentGateway.value = selectedOnlineMethod;

            HelperFunctions().showOverlayLoader();

            Map<String, dynamic>? orderResponse;
            try {
              orderResponse = await createOrder(
                currency: selectedOnlineMethod == 'paypal' ? 'USD' : 'INR',
              );
            } finally {
              // Hide overlay before gateway opens its own screen.
              HelperFunctions().hideOverlayLoader();
            }

            if (orderResponse == null) {
              secondaryPaymentGateway.value = '';
              isSubmittingOrder.value = false;
              return;
            }

            final String rawOrderId = _orderDocumentId(orderResponse);

            try {
              await _processGatewayPayment(
                methodName: selectedOnlineMethod,
                amount: prepaymentAmount,
                orderResponse: orderResponse,
                rawOrderId: rawOrderId,
              );

              await cartController.fetchCart();
              navigateToOrderSuccess(orderResponse);
            } catch (e) {
              // Show appropriate message
              if (e.toString().contains('cancelled') ||
                  e.toString().contains('Cancelled') ||
                  e.toString().contains('cancel')) {
                HelperFunctions().showSnackBarError('Payment was cancelled');
              } else {
                HelperFunctions()
                    .showSnackBarError('Prepayment failed: ${e.toString()}');
              }
            } finally {
              secondaryPaymentGateway.value = '';
              isSubmittingOrder.value = false;
            }
          },
        );
        return;
      }
    }

    // ── Standard flow ──
    if (isSubmittingOrder.value) return;
    isSubmittingOrder.value = true;
    HelperFunctions().showOverlayLoader();

    Map<String, dynamic>? orderResponse;
    try {
      orderResponse = await createOrder(
        currency: methodName == 'paypal' ? 'USD' : 'INR',
      );
      printInfo(info: 'orderResponse: $orderResponse');
    } finally {
      // Always hide the overlay before the gateway opens its own screen.
      // Keeping Get.dialog() open while calling Get.to() blocks navigation.
      HelperFunctions().hideOverlayLoader();
    }

    if (orderResponse == null) {
      isSubmittingOrder.value = false;
      return;
    }

    if (isCashMethod) {
      await cartController.fetchCart();
      isSubmittingOrder.value = false;
      navigateToOrderSuccess(orderResponse);
      return;
    }

    final String orderId =
        orderResponse['order_no'] ?? orderResponse['_id'] ?? "";
    final String rawOrderId = _orderDocumentId(orderResponse);
    final double paymentAmount = _orderPaymentAmount(orderResponse, amount);

    // Gateway handles its own UI — no overlay needed here.
    try {
      await _processGatewayPayment(
        methodName: methodName,
        amount: paymentAmount,
        orderResponse: orderResponse,
        rawOrderId: rawOrderId,
      );

      await cartController.fetchCart();
      // ✅ Show success dialog after successful payment
      showPaymentSuccessDialog(orderId, orderResponse: orderResponse);
    } catch (e) {
      // Show appropriate error message
      if (e.toString().contains('cancelled') ||
          e.toString().contains('Cancelled') ||
          e.toString().contains('cancel')) {
        HelperFunctions().showSnackBarError('Payment was cancelled');
      } else {
        HelperFunctions()
            .showSnackBarError('Failed to place order: ${e.toString()}');
      }
    } finally {
      isSubmittingOrder.value = false;
    }
  }

  void navigateToOrderSuccess(Map<String, dynamic> orderResponse) {
    final orderId = (orderResponse['order_no'] ??
            orderResponse['order_id'] ??
            orderResponse['_id'] ??
            '')
        .toString();
    _openOrderSuccess(orderResponse, orderId, isCashOrder: true);
  }

  Future<void> _processGatewayPayment({
    required String methodName,
    required double amount,
    required Map<String, dynamic> orderResponse,
    required String rawOrderId,
  }) async {
    try {
      switch (methodName) {
        case 'stripe':
          final stripeConfig = paymentConfig['stripe'];
          final publicKey = stripeConfig is Map
              ? stripeConfig['publicKey']?.toString() ?? ''
              : '';
          final clientSecret =
              orderResponse['payment_client_secret']?.toString() ?? '';
          final paymentIntentId =
              orderResponse['payment_intent_id']?.toString() ?? '';
          if (publicKey.isEmpty || clientSecret.isEmpty) {
            throw StateError('Stripe payment setup is incomplete.');
          }

          try {
            await StripePayment(publicKey: publicKey).processPayment(
              amount: amount,
              currency: 'INR',
              clientSecret: clientSecret,
            );

            await confirmPayment(rawOrderId, paymentIntentId);
          } catch (e) {
            // Check if this is a cancellation (Stripe often throws PlatformException with code 'cancelled')
            if (e.toString().toLowerCase().contains('cancel') ||
                (e is PlatformException && e.code == 'cancelled')) {
              throw Exception('Payment was cancelled by user');
            }
            rethrow;
          }
          break;

        case 'razorpay':
          final razorpayConfig = paymentConfig['razorpay'];
          final keyId = razorpayConfig is Map
              ? razorpayConfig['key_id']?.toString() ?? ''
              : '';
          if (keyId.isEmpty) {
            throw StateError('Razorpay payment setup is incomplete.');
          }
          final result = await RazorPayPayment(keyId: keyId).processPayment(
            amount: amount,
            metadata: orderResponse,
          );
          final paymentId = result.paymentId ?? '';
          final razorpaySignature = result.signature ?? '';
          if (paymentId.isEmpty || razorpaySignature.isEmpty) {
            throw StateError('Razorpay did not return valid payment details.');
          }
          await confirmPayment(
            rawOrderId,
            orderResponse['payment_intent_id']?.toString() ?? '',
            paymentId: paymentId,
            razorpaySignature: razorpaySignature,
          );
          break;

        case 'phonepe':
          final phonepeConfig = paymentConfig['phonepe'];
          final result = await PhonePePayment(
            clientId: phonepeConfig['client_id'],
            clientSecret: phonepeConfig['client_secret'],
            clientVersion: phonepeConfig['client_version']?.toString() ?? '1',
            environment: kPhonePeEnvironment,
            appScheme: kPhonePeAppScheme,
          ).processPayment(
            amount: amount,
            metadata: orderResponse,
          );
          await confirmPayment(
            rawOrderId,
            (result['phonePeOrderId'] ?? result['transactionId'] ?? '')
                .toString(),
          );
          break;

        case 'paypal':
          final clientId = paymentConfig['paypal']['client_id'];
          final secretKey = paymentConfig['paypal']['client_secret'];
          await PayPalPayment(
            clientId: clientId,
            secretKey: secretKey,
          ).processPayment(
            amount: amount,
            metadata: orderResponse,
            currency: 'USD',
          );
          break;

        default:
          throw StateError('Unsupported payment method: $methodName');
      }
    } catch (e) {
      // Log the error for debugging
      printInfo(info: 'Payment error in $methodName: $e');
      rethrow;
    }
  }

  // Add this method to CheckOutController
  void showPaymentSuccessDialog(
    String orderId, {
    required Map<String, dynamic> orderResponse,
  }) {
    DialogHelper.showSuccessDialog(
      title: "Payment Successfully Processed",
      description:
          "Thank you for your purchase! Your payment has been successfully processed. Sit back, relax, and enjoy your new items.",
      imagePath: "assets/images/success.png",
      buttonText: "Continue",
      onPressed: () {
        Get.back();
        _openOrderSuccess(orderResponse, orderId);
      },
    );
  }

  void _openOrderSuccess(
    Map<String, dynamic> orderResponse,
    String orderNo, {
    bool isCashOrder = false,
  }) {
    final internalId = _orderDocumentId(orderResponse);
    final orderData = Map<String, dynamic>.from(orderResponse);
    if (isCashOrder) {
      orderData.putIfAbsent('payment_method', () => 'cash');
    }
    Get.offAllNamed(
      Routes.ORDERSUCCESS,
      arguments: {
        'id': internalId,
        'order_no': orderNo,
        'order': orderData,
        'is_cash_order': isCashOrder,
      },
    );
  }

  String _orderDocumentId(Map<String, dynamic> orderResponse) =>
      (orderResponse['_id'] ??
              orderResponse['id'] ??
              orderResponse['order_id'] ??
              '')
          .toString();

  double _orderPaymentAmount(
    Map<String, dynamic> orderResponse,
    double fallback,
  ) {
    final order = orderResponse['order'] is Map
        ? Map<String, dynamic>.from(orderResponse['order'] as Map)
        : orderResponse;
    final rawAmount = order['total'] ??
        order['grand_total'] ??
        order['total_amount'] ??
        order['amount'];
    if (rawAmount is num) return rawAmount.toDouble();
    if (rawAmount != null) {
      final parsed = double.tryParse(
        rawAmount
            .toString()
            .replaceAll(',', '')
            .replaceAll('₹', '')
            .replaceAll(r'$', '')
            .trim(),
      );
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  bool _isOutOfStockError(dynamic err) {
    final msg = (err is AppException ? (err.message ?? '') : err.toString())
        .toLowerCase();
    return msg.contains('out of stock') ||
        msg.contains('sold out') ||
        msg.contains('insufficient stock');
  }

  Future<void> _handleOutOfStockError(dynamic err) async {
    if (Get.isDialogOpen ?? false) Get.back();

    final rawMessage =
        err is AppException ? (err.message ?? '') : err.toString();
    String detectedName = '';

    final match = RegExp(r'"([^"]+)"').firstMatch(rawMessage);
    if (match != null) {
      detectedName = match.group(1)?.trim() ?? '';
    }

    final cartCtrl =
        Get.isRegistered<CartController>() ? Get.find<CartController>() : null;
    final found = cartCtrl?.findCartItem(productName: detectedName);
    final cartItem = found?['item'] as Map<String, dynamic>?;

    final productObj = cartItem?['product_id'] is Map
        ? cartItem!['product_id'] as Map
        : (cartItem?['product'] is Map ? cartItem!['product'] as Map : null);
    final productId =
        (productObj?['_id'] ?? productObj?['id'] ?? cartItem?['product_id'])
                ?.toString() ??
            '';
    final variantObj = cartItem?['variant_id'] is Map
        ? cartItem!['variant_id'] as Map
        : (cartItem?['variant'] is Map ? cartItem!['variant'] as Map : null);
    final variantSlug = (variantObj?['slug'] ??
                variantObj?['name'] ??
                cartItem?['variant_slug'] ??
                cartItem?['variant_name'] ??
                '')
            ?.toString() ??
        '';
    final variantId =
        (variantObj?['_id'] ?? variantObj?['id'] ?? cartItem?['variant_id'])
            ?.toString();
    final displayName = productObj?['name']?.toString() ??
        (detectedName.isNotEmpty ? detectedName : 'This product');

    await showOutOfStockBottomSheet(
      productName: displayName,
      cartItem: cartItem,
      onRemoveAndContinue: () async {
        await _resolveOutOfStockAction(
          productId: productId,
          variantSlug: variantSlug,
          variantId: variantId,
          displayName: displayName,
          saveToWishlist: false,
        );
      },
      onSaveToWishlist: () async {
        await _resolveOutOfStockAction(
          productId: productId,
          variantSlug: variantSlug,
          variantId: variantId,
          displayName: displayName,
          saveToWishlist: true,
        );
      },
      onReturnToCart: () {
        Get.until(
            (route) => route.settings.name == Routes.CART || route.isFirst);
      },
    );
  }

  Future<void> _resolveOutOfStockAction({
    required String productId,
    required String variantSlug,
    String? variantId,
    required String displayName,
    required bool saveToWishlist,
  }) async {
    HelperFunctions().showOverlayLoader();
    try {
      if (saveToWishlist && productId.isNotEmpty) {
        await WishListService.to.addWishlist(
          productId: productId,
          variantSlug: variantSlug,
          variantId: variantId,
        );
      }

      if (productId.isNotEmpty) {
        await CartService.to.removeFromCart(
          productId: productId,
          variantSlug: variantSlug,
        );
      } else {
        await CartService.to.fetchCart();
      }
    } catch (e) {
      debugPrint('Error resolving out of stock: $e');
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
    }

    if (CartService.to.cartItems.isEmpty) {
      HelperFunctions().showSnackBarError(
        'Your cart is now empty. Please add items to proceed.',
      );
      Get.offAllNamed(Routes.HOME);
    } else {
      final actionText = saveToWishlist
          ? 'saved to your Wishlist and removed from order.'
          : 'removed from your order.';
      HelperFunctions().showSnackBarSuccess(
        '"$displayName" was $actionText Total updated.',
      );
    }
  }
}
