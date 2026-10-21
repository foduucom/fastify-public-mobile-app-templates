import 'package:foduu_ecommerce/components/dialogs/out_of_stock_sheet.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:foduu_ecommerce/constants/app_exceptions.dart';
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

  // Add these to CheckOutController
  var selectedAddressString = "".obs; // For displaying in UI
  var selectedAddressData = {}.obs; // For storing the full address object

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

      if (addressController.userAddressList.isNotEmpty &&
          selectedAddrIndex < addressController.userAddressList.length) {
        // Store the full address data
        final addressData =
            addressController.userAddressList[selectedAddrIndex];
        print('Address data type: ${addressData.runtimeType}');
        print('Address data: $addressData');

        // Make sure we're storing it as a Map
        if (addressData is Map) {
          selectedAddressData.value = Map.from(addressData);
        } else if (addressData is Map<String, dynamic>) {
          selectedAddressData.value = addressData;
        } else {
          print('Error: addressData is not a Map');
          selectedAddressData.value = {};
        }

        final userAddress = selectedAddressData.value;

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
        selectedAddressData.value = {};
        selectedAddressString.value = "";
      }
    } else {
      print('AddressListController not registered');
    }
  }

  void refreshAddress() {
    loadSelectedAddress();
  }

  void updateAddressFromForm(Map<String, dynamic> updatedAddress) {
    selectedAddressData.value = updatedAddress;
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
    Future.delayed(Duration(milliseconds: 100), () {
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
      // Build from static defaults first so the UI isn't empty.
      _buildPaymentOptionsFromConfig();

      var response = await BasicProvider("payment-methods")
          .getRequest()
          .catchError(handleError);

      printInfo(info: 'payment-methods response: $response');

      if (response != null && response is Map) {
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
      } else if (response != null && response is List) {
        for (var opt in response) {
          if (opt is Map && opt['name'] != null) {
            paymentConfig[opt['name']] = opt;
          }
          if (!paymentOptions.any((e) => e['name'] == opt['name'])) {
            paymentOptions.add(opt);
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
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
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

  Future<Map<String, dynamic>?> createOrder({String currency = 'INR'}) async {
    final String methodName = deliveryOption['name'];
    String addressId = "";

    try {
      // Prioritize retrieving addressId from selectedAddressData which is already in this controller
      if (selectedAddressData.isNotEmpty) {
        addressId =
            (selectedAddressData['_id'] ?? selectedAddressData['id'] ?? "")
                .toString();
      }

      // Fallback/Validation with AddressListController if addressId is still empty
      if (addressId.isEmpty && Get.isRegistered<AddressListController>()) {
        final addressController = Get.find<AddressListController>();
        final int selectedAddrIndex = addressController.selectAddress.value;
        if (addressController.userAddressList.isNotEmpty &&
            selectedAddrIndex < addressController.userAddressList.length) {
          final addr = addressController.userAddressList[selectedAddrIndex];
          addressId = (addr['_id'] ?? addr['id'] ?? "").toString();
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

      print("Order Create :$form");

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

  Future<void> addNewCard() async {}

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

  Future<void> _executeOrderPlacement({
    required String methodName,
    required double amount,
  }) async {
    HelperFunctions().showOverlayLoader();

    Map<String, dynamic>? orderResponse;
    try {
      orderResponse = await createOrder(
        currency: methodName == 'paypal' ? 'USD' : 'INR',
      );
      printInfo(info: 'orderResponse: $orderResponse');
    } finally {
      HelperFunctions().hideOverlayLoader();
    }

    if (orderResponse == null) return;

    final String rawOrderId =
        (orderResponse['_id'] ?? orderResponse['id'] ?? "").toString();
    final String orderNo =
        (orderResponse['order_no'] ?? rawOrderId).toString();

    try {
      await _processGatewayPayment(
        methodName: methodName,
        amount: amount,
        orderResponse: orderResponse,
        rawOrderId: rawOrderId,
      );

      Get.offAllNamed(
        Routes.ORDERSUCCESS,
        arguments: {'id': rawOrderId, 'order_no': orderNo},
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
              return;
            }

            final String rawOrderId =
                (orderResponse['_id'] ?? orderResponse['id'] ?? "").toString();
            final String orderNo =
                (orderResponse['order_no'] ?? rawOrderId).toString();

            try {
              await _processGatewayPayment(
                methodName: selectedOnlineMethod,
                amount: prepaymentAmount,
                orderResponse: orderResponse,
                rawOrderId: rawOrderId,
              );

              await CODPayment().processPayment(amount: amount);

              Get.offAllNamed(
                Routes.ORDERSUCCESS,
                arguments: {'id': rawOrderId, 'order_no': orderNo},
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
    try {
      switch (methodName) {
        case 'stripe':
          final publicKey = paymentConfig['stripe']['publicKey'];
          final clientSecret = orderResponse['payment_client_secret'] ?? "";
          final paymentIntentId = orderResponse['payment_intent_id'] ?? "";

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
    final msg = (err is AppException ? (err.message ?? '') : err.toString()).toLowerCase();
    return msg.contains('out of stock') ||
        msg.contains('sold out') ||
        msg.contains('insufficient stock');
  }

  Future<void> _handleOutOfStockError(dynamic err) async {
    if (Get.isDialogOpen ?? false) Get.back();

    final rawMessage = err is AppException ? (err.message ?? '') : err.toString();
    String detectedName = '';

    final match = RegExp(r'"([^"]+)"').firstMatch(rawMessage);
    if (match != null) {
      detectedName = match.group(1)?.trim() ?? '';
    }

    final cartCtrl = Get.isRegistered<CartController>() ? Get.find<CartController>() : null;
    final found = cartCtrl?.findCartItem(productName: detectedName);
    final cartItem = found?['item'] as Map<String, dynamic>?;

    final productObj = cartItem?['product_id'] is Map
        ? cartItem!['product_id'] as Map
        : (cartItem?['product'] is Map ? cartItem!['product'] as Map : null);
    final productId = (productObj?['_id'] ?? productObj?['id'] ?? cartItem?['product_id'])?.toString() ?? '';
    final variantObj = cartItem?['variant_id'] is Map
        ? cartItem!['variant_id'] as Map
        : (cartItem?['variant'] is Map ? cartItem!['variant'] as Map : null);
    final variantSlug = (variantObj?['slug'] ?? variantObj?['name'] ?? cartItem?['variant_slug'] ?? cartItem?['variant_name'] ?? '')?.toString() ?? '';
    final variantId = (variantObj?['_id'] ?? variantObj?['id'] ?? cartItem?['variant_id'])?.toString();
    final displayName = productObj?['name']?.toString() ?? (detectedName.isNotEmpty ? detectedName : 'This product');

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
        Get.until((route) => route.settings.name == Routes.CART || route.isFirst);
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
