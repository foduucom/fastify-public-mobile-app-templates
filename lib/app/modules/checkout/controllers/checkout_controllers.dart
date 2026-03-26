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

    if (response != null && response is Map) {
      // Merge API data into local config.
      for (final key in response.keys) {
        paymentConfig[key] = response[key];
      }
      // Rebuild options with the updated config.
      _buildPaymentOptionsFromConfig();
    } else if (response != null && response is List) {
      for (var opt in response) {
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
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> createOrder({String currency = 'INR'}) async {
    final String methodName = deliveryOption['name'];
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

      // Build the order form.
      var form = <String, String>{
        "address_id": addressId,
        "primary_method": methodName,
        "currency":
            currency, // ✅ tells backend which currency to use for payment gateway
      };

      if (methodName == 'cod') {
        form['cod'] = 'true';

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

  Future<void> processOrder() async {
    if (deliveryOption.isEmpty) {
      HelperFunctions().showSnackBarError('Please select a payment method');
      return;
    }

    final String methodName = deliveryOption['name'];
    final double amount = cartController.total.value;

    // ── COD prepayment flow ──
    if (methodName == 'cod') {
      final codConfig = paymentConfig['cod'];
      final bool needsPrepayment = codConfig['cod_prepayment_type'] != null &&
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
                HelperFunctions().hideOverlayLoader();
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

              HelperFunctions().hideOverlayLoader();
              if (Get.isDialogOpen ?? false) Get.back();

              // ✅ Show success dialog after successful payment
              showPaymentSuccessDialog(orderId);
            } catch (e) {
              HelperFunctions().hideOverlayLoader();
              if (Get.isDialogOpen ?? false) Get.back();

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
            }
          },
        );
        return;
      }
    }

    // ── Standard flow ──
    HelperFunctions().showOverlayLoader();

    try {
      var orderResponse = await createOrder(
        currency: methodName == 'paypal' ? 'USD' : 'INR',
      );
      printInfo(info: 'orderResponse: $orderResponse');

      if (orderResponse == null) {
        HelperFunctions().hideOverlayLoader();
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

      HelperFunctions().hideOverlayLoader();

      // ✅ Show success dialog after successful payment
      showPaymentSuccessDialog(orderId);
    } catch (e) {
      HelperFunctions().hideOverlayLoader();

      // Show appropriate error message
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
          final merchantId = paymentConfig['phonepe']['merchant_id'];
          await PhonePePayment(merchantId: merchantId).processPayment(
            amount: amount,
            metadata: orderResponse,
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
}
