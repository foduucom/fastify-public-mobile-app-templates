import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

/// 'SANDBOX' for testing, 'PRODUCTION' for a real release build.
///
/// SECURITY NOTE: PhonePePayment performs OAuth token fetch + SDK order
/// creation directly from the device using a client_secret sourced from
/// the `payment-methods` API response. This mirrors the SOURCE app's
/// current production behavior, which its own author flagged as a
/// stopgap until the backend exposes a server-side token-minting
/// endpoint instead of raw client credentials. Keep this at 'SANDBOX'
/// until that backend change lands or the risk is explicitly accepted.
const String kPhonePeEnvironment = 'SANDBOX';

/// Custom URL scheme PhonePe uses to redirect back into this app.
/// Must be unique per deployed app and match the scheme registered in
/// android/app/src/main/AndroidManifest.xml (and Info.plist if/when an
/// iOS project is added).
const String kPhonePeAppScheme = 'newfastifytemplateapp1';

class CheckOutController extends GetxController with BaseController {
  // ── Observable state ──────────────────────────────────────────────────
  var deliveryOption = {}.obs;
  RxInt selectedIndex = 0.obs;
  var paymentOptions = [].obs;

  /// Holds the name of the secondary gateway chosen for COD prepayment
  /// (e.g. "stripe", "razorpay"). Empty when not applicable.
  var secondaryPaymentGateway = ''.obs;

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
  }

  @override
  void onClose() {
    secondaryPaymentGateway.value = '';
    super.onClose();
  }

  var isPaymentLoading = true.obs;

  // ── Payment options ───────────────────────────────────────────────────

  /// Populates [paymentOptions] from the current [paymentConfig].
  void _buildPaymentOptionsFromConfig() {
    paymentOptions.clear();
    for (final entry in _gatewayRegistry) {
      final key = entry['name']!;
      dynamic cfg = paymentConfig[key];
      // Support COD aliases (backend can return 'cash', 'cod', or 'cash_on_delivery')
      if (cfg == null && (key == 'cod' || key == 'cash')) {
        cfg = paymentConfig['cod'] ??
            paymentConfig['cash'] ??
            paymentConfig['cash_on_delivery'];
      }
      final bool isEnabled = cfg != null &&
          (cfg['enabled'] == true ||
              cfg['enabled']?.toString().toLowerCase() == 'true' ||
              cfg['enabled']?.toString() == '1');
      if (isEnabled) {
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
    isPaymentLoading.value = true;
    try {
      // Build from static defaults first so the UI isn't empty if preconfigured.
      _buildPaymentOptionsFromConfig();

      var response = await BasicProvider("payment-methods")
          .getRequest()
          .catchError(handleError);

      printInfo(info: 'payment-methods response: $response');

      if (response != null) {
        if (response is Map) {
          // Unwrap data key if backend wraps it
          final Map actualData =
              response.containsKey('data') && response['data'] is Map
                  ? response['data']
                  : response;

          // Merge API data into local config.
          actualData.forEach((key, value) {
            paymentConfig[key] = value;
          });

          // Ensure COD aliases are synchronized
          if (paymentConfig.containsKey('cash')) {
            paymentConfig['cod'] = paymentConfig['cash'];
          }
          if (paymentConfig.containsKey('cod')) {
            paymentConfig['cash'] = paymentConfig['cod'];
          }

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
    } catch (e) {
      printInfo(info: 'getPaymentOption error: $e');
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
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> createOrder({String currency = 'INR'}) async {
    final String methodName = deliveryOption['name'] ?? 'cod';
    String addressId = "";

    try {
      if (Get.isRegistered<AddressListController>()) {
        final addressController = Get.find<AddressListController>();
        final int selectedAddrIndex = addressController.selectAddress.value;
        if (addressController.userAddressList.isNotEmpty &&
            selectedAddrIndex < addressController.userAddressList.length) {
          addressId =
              addressController.userAddressList[selectedAddrIndex]['_id'];
        }
      }

      if (addressId.isEmpty) {
        Get.snackbar("Error", "Selected address not found");
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

      if (isCod) {
        form['cod'] = 'true';
        form['cash'] = 'true';

        // Include the secondary gateway when COD prepayment applies.
        if (secondaryPaymentGateway.value.isNotEmpty) {
          form['secondary_method'] = secondaryPaymentGateway.value;
        }
      }

      var response = await BasicProvider("order/create")
          .postRequest(form)
          .catchError(handleError);

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

  Future<void> confirmPayment(String orderId, String paymentIntentId) async {
    try {
      var form = {
        "order_id": orderId,
        "payment_intent_id": paymentIntentId,
      };

      var response = await BasicProvider("order/confirm-payment")
          .postRequest(form)
          .catchError(handleError);

      if (response != null) {
        printInfo(info: 'Payment confirmed: $response');
      } else {
        printInfo(info: 'Payment confirmation failed');
      }
    } catch (e) {
      printInfo(info: 'Error confirming payment: $e');
    }
  }

  /// Shows confirmation dialog matching design when COD option is clicked
  void showCodConfirmationDialog({required VoidCallback onConfirm}) {
    final BuildContext? context = Get.context;
    if (context == null) {
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
                    onTap: () => Get.back(),
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
                      onPressed: () => Get.back(),
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
    );
  }

  Future<void> _executeOrderPlacement({
    required String methodName,
    required double amount,
  }) async {
    HelperFunctions().showOverlayLoader();

    try {
      var orderResponse = await createOrder(
        currency: methodName == 'paypal' ? 'USD' : 'INR',
      );
      printInfo(info: 'orderResponse: $orderResponse');

      if (orderResponse == null) {
        if (Get.isDialogOpen ?? false) Get.back();
        return;
      }

      final String rawOrderId =
          (orderResponse['_id'] ?? orderResponse['id'] ?? "").toString();
      final String orderNo =
          (orderResponse['order_no'] ?? rawOrderId).toString();

      await _processGatewayPayment(
        methodName: methodName,
        amount: amount,
        orderResponse: orderResponse,
        rawOrderId: rawOrderId,
      );

      if (Get.isDialogOpen ?? false) Get.back();
      Get.offAllNamed(
        Routes.ORDERSUCCESS,
        arguments: {'id': rawOrderId, 'order_no': orderNo},
      );
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
        final double prepaymentAmount =
            double.tryParse(codConfig['cod_prepayment_ammount'].toString()) ??
                0.0;

        showCodPrepaymentDialog(
          amount: prepaymentAmount,
          onMethodSelected: (selectedOnlineMethod) async {
            secondaryPaymentGateway.value = selectedOnlineMethod;

            HelperFunctions().showOverlayLoader();
            try {
              var orderResponse = await createOrder(
                currency: selectedOnlineMethod == 'paypal' ? 'USD' : 'INR',
              );
              if (orderResponse == null) {
                if (Get.isDialogOpen ?? false) Get.back();
                return;
              }

              final String rawOrderId =
                  (orderResponse['_id'] ?? orderResponse['id'] ?? "").toString();
              final String orderNo =
                  (orderResponse['order_no'] ?? rawOrderId).toString();

              await _processGatewayPayment(
                methodName: selectedOnlineMethod,
                amount: prepaymentAmount,
                orderResponse: orderResponse,
                rawOrderId: rawOrderId,
              );

              await CODPayment().processPayment(amount: amount);

              if (Get.isDialogOpen ?? false) Get.back();
              Get.offAllNamed(
                Routes.ORDERSUCCESS,
                arguments: {'id': rawOrderId, 'order_no': orderNo},
              );
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

      // Show COD confirmation dialog when user clicks Place Order
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
    switch (methodName) {
      case 'stripe':
        final publicKey = paymentConfig['stripe']['publicKey'];
        final clientSecret = orderResponse['payment_client_secret'] ?? "";
        final paymentIntentId = orderResponse['payment_intent_id'] ?? "";
        await StripePayment(publicKey: publicKey).processPayment(
          amount: amount,
          currency: 'INR',
          clientSecret: clientSecret,
        );
        await confirmPayment(rawOrderId, paymentIntentId);
        break;

      case 'razorpay':
        final keyId = paymentConfig['razorpay']['key_id'];
        await RazorPayPayment(keyId: keyId).processPayment(
          amount: amount,
          metadata: orderResponse,
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
          currency: 'USD',
        );
        break;

      case 'cod':
      case 'cash':
        await CODPayment().processPayment(amount: amount);
        break;

      default:
        printInfo(info: 'Unknown payment method: $methodName');
        await Future.delayed(const Duration(seconds: 1));
    }
  }
}
