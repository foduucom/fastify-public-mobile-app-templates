import 'package:foduu_ecommerce/components/dialogs/out_of_stock_sheet.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foduu_ecommerce/helpers/dialog_helper.dart';
import '../widgets/paypal_view.dart';
import '/app/routes/app_pages.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/constants/helper_functions.dart';
import '/app/modules/cart/controllers/cart_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '/components/paymentGateway/Stripe.dart';
import '/components/paymentGateway/PhonePe.dart';
import '/components/paymentGateway/COD.dart';
import '/components/paymentGateway/RazorPay.dart';
import '/app/modules/address/controllers/address_list_controller.dart';
import '/constants/app_exceptions.dart';

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
  //var selectedAddress = "".obs;
  var savedCards = <String>[].obs;
  var selectedCardIndex = 0.obs;

  /// Holds the name of the secondary gateway chosen for COD prepayment
  /// (e.g. "stripe", "razorpay"). Empty when not applicable.
  var secondaryPaymentGateway = ''.obs;
  var isPaymentLoading = true.obs;
  final isPreparingCheckout = false.obs;
  final isSubmittingOrder = false.obs;
  final isChoosingCodPrepayment = false.obs;
  final isChoosingCodConfirmation = false.obs;
  Worker? _selectedAddressWorker;
  Worker? _addressListWorker;

  // Add these to CheckOutController
  var selectedAddressString = "".obs; // For displaying in UI
  final RxMap<String, dynamic> selectedAddressData =
      <String, dynamic>{}.obs; // Full currently selected delivery address

  var isEditingAddress = false.obs;
  var tempAddress = "".obs;

  // Method to load selected address from AddressListController
  // In CheckOutController, make sure loadSelectedAddress is properly setting selectedAddressData
  void loadSelectedAddress() {
    if (Get.isRegistered<AddressListController>()) {
      final addressController = Get.find<AddressListController>();
      final int selectedAddrIndex = addressController.selectAddress.value;
      if (selectedAddrIndex >= 0 &&
          addressController.userAddressList.isNotEmpty &&
          selectedAddrIndex < addressController.userAddressList.length) {
        // Store the full address data
        final addressData =
            addressController.userAddressList[selectedAddrIndex];
        // Make sure we're storing it as a Map
        if (addressData is Map) {
          selectedAddressData.assignAll(Map<String, dynamic>.from(addressData));
        } else {
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
          addressParts.add(userAddress['street'].toString());
        }
        if (userAddress['landmark'] != null &&
            userAddress['landmark'].toString().isNotEmpty) {
          addressParts.add(userAddress['landmark'].toString());
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
          locationParts.add(userAddress['state']['name'].toString());
        }
        if (userAddress['country'] != null &&
            userAddress['country'] is Map &&
            userAddress['country']['name'] != null) {
          locationParts.add(userAddress['country']['name'].toString());
        }

        if (locationParts.isNotEmpty) {
          if (fullAddress.isNotEmpty) fullAddress += ", ";
          fullAddress += locationParts.join(', ');
        }

        // Add postal code/pincode
        if (userAddress['postal_code'] != null &&
            userAddress['postal_code'].toString().isNotEmpty) {
          if (fullAddress.isNotEmpty) fullAddress += " - ";
          fullAddress += userAddress['postal_code'].toString();
        } else if (userAddress['pincode'] != null &&
            userAddress['pincode'].toString().isNotEmpty) {
          if (fullAddress.isNotEmpty) fullAddress += " - ";
          fullAddress += userAddress['pincode'].toString();
        }

        selectedAddressString.value = fullAddress;
      } else {
        selectedAddressData.clear();
        selectedAddressString.value = "";
      }
    } else {
      selectedAddressData.clear();
      selectedAddressString.value = "";
    }
  }

  void refreshAddress() {
    loadSelectedAddress();
  }

  String _addressId(dynamic address) {
    if (address is! Map) return '';
    final id = (address['_id'] ?? address['id'])?.toString().trim() ?? '';
    return id.isEmpty || id == 'null' ? '' : id;
  }

  String get selectedAddressId {
    if (Get.isRegistered<AddressListController>()) {
      final current = Get.find<AddressListController>().selectedAddress;
      if (current != null) return _addressId(current);
      return '';
    }
    return _addressId(selectedAddressData);
  }

  void updateAddressFromForm(Map<String, dynamic> updatedAddress) {
    selectedAddressData.assignAll(updatedAddress);
    final index = Get.isRegistered<AddressListController>()
        ? Get.find<AddressListController>().selectAddress.value
        : -1;
    if (Get.isRegistered<AddressListController>() && index >= 0) {
      final addresses = Get.find<AddressListController>().userAddressList;
      if (index < addresses.length) addresses[index] = updatedAddress;
    }
    loadSelectedAddress();
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
  void onInit() {
    super.onInit();
    getPaymentOption();
    if (Get.isRegistered<AddressListController>()) {
      final addressController = Get.find<AddressListController>();
      _selectedAddressWorker =
          ever(addressController.selectAddress, (_) => loadSelectedAddress());
      _addressListWorker =
          ever(addressController.userAddressList, (_) => loadSelectedAddress());
      loadSelectedAddress();
    }
  }

  @override
  void onClose() {
    secondaryPaymentGateway.value = '';
    _selectedAddressWorker?.dispose();
    _addressListWorker?.dispose();
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

  void _syncCodAliases() {
    final cod = paymentConfig['cod'] ??
        paymentConfig['cash'] ??
        paymentConfig['cash_on_delivery'];
    if (cod != null) paymentConfig['cod'] = cod;
  }

  void _appendPaymentOptions(List options) {
    for (final option in options) {
      if (option is! Map || option['name'] == null) continue;
      final rawName = option['name'].toString().trim().toLowerCase();
      final key = const {'cash', 'cash_on_delivery'}.contains(rawName)
          ? 'cod'
          : rawName;
      final registry = _gatewayRegistry.firstWhereOrNull(
        (entry) => entry['name'] == key,
      );
      if (registry == null ||
          (option.containsKey('enabled') && !_isEnabled(option['enabled'])) ||
          paymentOptions.any((existing) => existing['name'] == key)) {
        continue;
      }
      final config = Map<String, dynamic>.from(option);
      paymentOptions.add({
        ...config,
        'name': key,
        'method': registry['method'],
        'image': registry['image'],
      });
      if (key == 'cod') paymentConfig['cod'] = config;
    }
  }

  /// Fetches payment methods from the API and rebuilds the option list.
  Future<void> getPaymentOption() async {
    isPaymentLoading.value = true;
    try {
      _buildPaymentOptionsFromConfig();

      final response =
          await BasicProvider("payment-methods").getRequest(useCache: false);

      printInfo(
          info:
              'Loaded payment method configuration (${paymentOptions.length} options).');
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
    } catch (e) {
      printInfo(info: 'getPaymentOption error: $e');
      await handleError(e);
    } finally {
      isPaymentLoading.value = false;
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
                    .where((o) => o['name'] != 'cod' && o['name'] != 'cash')
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
    ).then((_) {
      isChoosingCodPrepayment.value = false;
    });
  }

  /// Shows confirmation dialog matching design when COD option is clicked
  void showCodConfirmationDialog({required VoidCallback onConfirm}) {
    final BuildContext? context = Get.context;
    if (context == null) {
      isChoosingCodConfirmation.value = false;
      onConfirm();
      return;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final double totalVal = cartController.total.value;
    final String formattedTotal = totalVal.toStringAsFixed(2);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colorScheme.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Confirm Your Order',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      isChoosingCodConfirmation.value = false;
                      Get.back();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.local_shipping_outlined,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'You have selected '),
                    TextSpan(
                      text: 'Cash On Delivery',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const TextSpan(text: '. Your order of '),
                    TextSpan(
                      text: '₹$formattedTotal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' will be placed right away and payable when it is delivered. Do you really want to place this order?',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        isChoosingCodConfirmation.value = false;
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        side: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'Cancel',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        isChoosingCodConfirmation.value = false;
                        Get.back();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Place Order',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      isChoosingCodConfirmation.value = false;
    });
  }

  Future<Map<String, dynamic>?> createOrder({String currency = 'INR'}) async {
    final String methodName = deliveryOption['name']?.toString() ?? '';
    final String addressId = selectedAddressId;

    try {
      if (addressId.isEmpty) {
        HelperFunctions().showSnackBarError(
            'Selected address is unavailable. Please select it again.');
        return null;
      }

      final bool isCod = methodName == 'cod' || methodName == 'cash';

      // Build the order form.
      var form = <String, String>{
        "address_id": addressId,
        "primary_method": isCod ? 'cod' : methodName,
        "payment_method": isCod ? 'cod' : methodName,
        "currency":
            currency, // ✅ tells backend which currency to use for payment gateway
      };

      final couponCode = cartController.appliedCouponCode.value.trim();
      if (couponCode.isNotEmpty && cartController.couponDetails.isNotEmpty) {
        form['coupon_code'] = couponCode;
        final discount = cartController.couponDetails['discount_amount'];
        final parsedDiscount = discount is num
            ? discount
            : num.tryParse(discount?.toString() ?? '');
        if (parsedDiscount != null) {
          form['coupon_discount'] = parsedDiscount.toString();
        }
      }

      if (isCod) {
        form['cod'] = 'true';
        form['cash'] = 'true';

        // Include the secondary gateway when COD prepayment applies.
        if (secondaryPaymentGateway.value.isNotEmpty) {
          form['secondary_method'] = secondaryPaymentGateway.value;
        }
      }

      printInfo(info: 'Creating order with payment method: $methodName');

      var response = await BasicProvider("order/create")
          .postRequest(form)
          .catchError((error) {
        if (_isOutOfStockError(error)) {
          _handleOutOfStockError(error);
          return null;
        }
        if (error is FetchDataException || error is BadRequestException) {
          HelperFunctions().showSnackBarError(
              "we’re currently experiencing issues with the payment method you selected. could you please use an alternative payment method to complete the transaction?");
        } else {
          handleError(error);
        }
        return null; // Ensure null is returned so orderResponse reflects failure
      });

      printInfo(info: 'Order create response received: ${response != null}');

      if (response != null) {
        return Map<String, dynamic>.from(response);
      }
    } catch (e) {
      printInfo(info: 'Error creating order: $e');
      Get.snackbar("Error", "Failed to create order");
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

  Map<String, dynamic> _orderRecord(Map<String, dynamic> response) {
    dynamic record = response['data'] ?? response;
    if (record is Map && record['order'] is Map) record = record['order'];
    return record is Map ? Map<String, dynamic>.from(record) : response;
  }

  String _orderDocumentId(Map<String, dynamic> order) =>
      (order['_id'] ?? order['id'] ?? order['order_id'] ?? '').toString();

  double _orderPaymentAmount(
    Map<String, dynamic> response,
    double fallback,
  ) {
    final order = _orderRecord(response);
    final value = order['total'] ??
        order['grand_total'] ??
        order['total_amount'] ??
        order['amount'];
    if (value is num) return value.toDouble();
    if (value != null) {
      final parsed = double.tryParse(value
          .toString()
          .replaceAll(',', '')
          .replaceAll('₹', '')
          .replaceAll(r'$', '')
          .trim());
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  Future<void> _executeOrderPlacement({
    required String methodName,
    required double amount,
  }) async {
    if (isSubmittingOrder.value) return;
    isSubmittingOrder.value = true;
    try {
      await _runOrderPlacement(methodName: methodName, amount: amount);
    } finally {
      isSubmittingOrder.value = false;
      secondaryPaymentGateway.value = '';
    }
  }

  Future<void> _runOrderPlacement({
    required String methodName,
    required double amount,
  }) async {
    HelperFunctions().showOverlayLoader();

    Map<String, dynamic>? orderResponse;
    try {
      orderResponse = await createOrder(
        currency: methodName == 'paypal' ? 'USD' : 'INR',
      );
      printInfo(info: 'Order response received: ${orderResponse != null}');
    } finally {
      HelperFunctions().hideOverlayLoader();
    }

    if (orderResponse == null) return;

    final order = _orderRecord(orderResponse);
    final String rawOrderId = _orderDocumentId(order);
    final String orderNo = (order['order_no'] ?? rawOrderId).toString();
    if (rawOrderId.isEmpty) {
      HelperFunctions().showSnackBarError(
        'The order was created, but its confirmation number is missing. Check your orders before trying again.',
      );
      return;
    }

    try {
      await _processGatewayPayment(
        methodName: methodName,
        amount: _orderPaymentAmount(orderResponse, amount),
        orderResponse: order,
        rawOrderId: rawOrderId,
      );

      Get.offAllNamed(
        Routes.ORDERSUCCESS,
        arguments: {
          'id': rawOrderId,
          'order_no': orderNo,
          'order': order,
          'is_cash_order': methodName == 'cod' || methodName == 'cash',
        },
      );
    } catch (e) {
      if (e.toString().contains('cancelled') ||
          e.toString().contains('Cancelled') ||
          e.toString().contains('cancel')) {
        HelperFunctions().showSnackBarError('Payment was cancelled');
      } else {
        HelperFunctions()
            .showSnackBarError('Failed to place order: ${e.toString()}');
      }
    }
  }

  Future<bool> _refreshCheckoutPrerequisites() async {
    isPreparingCheckout.value = true;
    try {
      if (Get.isRegistered<AddressListController>()) {
        final addressController = Get.find<AddressListController>();
        await addressController.refreshAddresses(useCache: false);
        if (addressController.loadError.value) {
          HelperFunctions().showSnackBarError(
            'Unable to refresh your delivery address. Please retry before placing your order.',
          );
          return false;
        }
        loadSelectedAddress();
      }
      if (selectedAddressId.isEmpty) {
        HelperFunctions().showSnackBarError(
          'Please select a valid delivery address before placing your order.',
        );
        return false;
      }

      await cartController.fetchCart(useCache: false);
      if (CartService.to.loadError.value) {
        HelperFunctions().showSnackBarError(
          'Unable to refresh your cart. Please try again before placing your order.',
        );
        return false;
      }
      if (CartService.to.cartItems.isEmpty) {
        HelperFunctions().showSnackBarError(
          'Your cart is empty. Add an item before placing your order.',
        );
        return false;
      }
      return true;
    } catch (error) {
      HelperFunctions().showSnackBarError(
        'Unable to prepare checkout. Please review your address and cart, then retry.',
      );
      return false;
    } finally {
      isPreparingCheckout.value = false;
    }
  }

  Future<void> processOrder() async {
    if (isPreparingCheckout.value ||
        isSubmittingOrder.value ||
        isChoosingCodPrepayment.value ||
        isChoosingCodConfirmation.value) {
      return;
    }
    if (deliveryOption.isEmpty) {
      HelperFunctions().showSnackBarError('Please select a payment method');
      return;
    }

    if (!await _refreshCheckoutPrerequisites()) {
      return;
    }

    final String methodName = deliveryOption['name'] ?? 'cod';
    final double amount = cartController.total.value;

    final bool isCod = methodName == 'cod' || methodName == 'cash';

    // ── COD flow ──
    if (isCod) {
      final codConfig = paymentConfig['cod'] ?? paymentConfig['cash'];
      final bool needsPrepayment = codConfig != null &&
          codConfig['cod_prepayment_type'] != null &&
          codConfig['cod_prepayment_ammount'] != null &&
          codConfig['cod_prepayment_ammount'].toString().isNotEmpty;

      if (needsPrepayment) {
        final onlineOptions = paymentOptions
            .where(
                (option) => option['name'] != 'cod' && option['name'] != 'cash')
            .toList();
        if (onlineOptions.isEmpty) {
          HelperFunctions().showSnackBarError(
            'COD prepayment is required, but no online payment method is available.',
          );
          return;
        }
        isChoosingCodPrepayment.value = true;
        final double prepaymentAmount =
            double.tryParse(codConfig['cod_prepayment_ammount'].toString()) ??
                0.0;
        if (prepaymentAmount <= 0 || prepaymentAmount > amount) {
          isChoosingCodPrepayment.value = false;
          HelperFunctions().showSnackBarError(
            'The configured COD prepayment amount is invalid. Please contact the store.',
          );
          return;
        }

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
              HelperFunctions().hideOverlayLoader();
            }

            if (orderResponse == null) {
              secondaryPaymentGateway.value = '';
              isSubmittingOrder.value = false;
              return;
            }

            final order = _orderRecord(orderResponse);
            final String rawOrderId = _orderDocumentId(order);
            final String orderNo = (order['order_no'] ?? rawOrderId).toString();
            if (rawOrderId.isEmpty) {
              secondaryPaymentGateway.value = '';
              isSubmittingOrder.value = false;
              HelperFunctions().showSnackBarError(
                'The order was created, but its confirmation number is missing. Check your orders before trying again.',
              );
              return;
            }

            try {
              await _processGatewayPayment(
                methodName: selectedOnlineMethod,
                amount: prepaymentAmount,
                orderResponse: order,
                rawOrderId: rawOrderId,
              );

              await CODPayment().processPayment(amount: amount);

              Get.offAllNamed(
                Routes.ORDERSUCCESS,
                arguments: {
                  'id': rawOrderId,
                  'order_no': orderNo,
                  'order': order,
                  'is_cash_order': true,
                },
              );
            } catch (e) {
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

      // Show COD confirmation dialog when user clicks Place Order
      isChoosingCodConfirmation.value = true;
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
          final signature = result.signature ?? '';
          if (paymentId.isEmpty || signature.isEmpty) {
            throw StateError('Razorpay did not return valid payment details.');
          }
          await confirmPayment(
            rawOrderId,
            orderResponse['payment_intent_id']?.toString() ?? '',
            paymentId: paymentId,
            razorpaySignature: signature,
          );
          break;

        case 'phonepe':
          final phonepeConfig = paymentConfig['phonepe'];
          if (phonepeConfig is! Map ||
              phonepeConfig['client_id'] == null ||
              phonepeConfig['client_secret'] == null) {
            throw StateError('PhonePe payment setup is incomplete.');
          }
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
          final paypalConfig = paymentConfig['paypal'];
          final clientId = paypalConfig is Map
              ? paypalConfig['client_id']?.toString() ?? ''
              : '';
          final secretKey = paypalConfig is Map
              ? paypalConfig['client_secret']?.toString() ?? ''
              : '';
          if (clientId.isEmpty || secretKey.isEmpty) {
            throw StateError('PayPal payment setup is incomplete.');
          }
          await PayPalPayment(
            clientId: clientId,
            secretKey: secretKey,
          ).processPayment(
            amount: amount,
            metadata: orderResponse,
            currency: 'USD',
          );
          break;

        case 'cod':
        case 'cash':
          await CODPayment().processPayment(amount: amount);
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
  void showPaymentSuccessDialog(String orderId) {
    DialogHelper.showSuccessDialog(
      title: "Payment Successfully Processed",
      description:
          "Thank you for your purchase! Your payment has been successfully processed. Sit back, relax, and enjoy your new items.",
      imagePath: "assets/images/success.png",
      buttonText: "Continue",
      onPressed: () {
        Get.back();
        // Navigate to order success page
        Get.offAllNamed(Routes.ORDERSUCCESS, arguments: orderId);
      },
    );
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
