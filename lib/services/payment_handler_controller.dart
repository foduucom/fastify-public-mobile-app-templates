import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart'; // Assuming this package is used
import 'package:foduu_ecommerce/services/payment_service.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart'; // For navigation
import 'package:get_storage/get_storage.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';

class PaymentHandlerController extends GetxController {
  // These would typically be passed to this controller when initiating the payment
  // For example, from your checkout screen or order creation process.
  String? _currentOrderId;
  String? _currentPaymentIntentId; // This is Razorpay's order_id

  late Razorpay _razorpay;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorpayPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorpayPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleRazorpayExternalWallet);
  }

  // Call this method to set the order details before initiating Razorpay
  void setOrderDetails(String orderId, String paymentIntentId) {
    _currentOrderId = orderId;
    _currentPaymentIntentId = paymentIntentId;
  }

  // Method to open Razorpay checkout with dynamic keyId
  void openRazorpayCheckout(
      String keyId, double amountInPaisa, String description) {
    if (_currentOrderId == null || _currentPaymentIntentId == null) {
      HelperFunctions()
          .showSnackBarError('Order details not set. Cannot initiate payment.');
      return;
    }

    final box = GetStorage();
    final String storeName = box.read('store_name') ?? 'My Watch';

    final user = AuthDetails.getUserDetails();
    final String userMobile =
        (user != null ? (user['mobile'] ?? user['phone'] ?? '') : '')
            .toString();
    final String userEmail =
        (user != null ? (user['email'] ?? '') : '').toString();

    var options = {
      'key': keyId, // Use the dynamically provided keyId
      'amount': amountInPaisa, // in paisa
      'name': storeName,
      'description': description,
      'order_id':
          _currentPaymentIntentId, // This is the Razorpay Order ID from your backend
      'prefill': {
        'contact': userMobile,
        'email': userEmail,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
      HelperFunctions()
          .showSnackBarError('Error initiating payment. Please try again.');
    }
  }

  void _handleRazorpayPaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('Razorpay Success: ${response.paymentId}');

    if (_currentOrderId == null || _currentPaymentIntentId == null) {
      HelperFunctions()
          .showSnackBarError('Payment context missing. Please try again.');
      return;
    }

    final String? paymentId = response.paymentId;
    final String? razorpaySignature = response.signature;

    if (paymentId != null && razorpaySignature != null) {
      HelperFunctions().showOverlayLoader();
      try {
        await PaymentService.to.confirmPayment(
          orderId: _currentOrderId!,
          paymentIntentId: _currentPaymentIntentId!,
          paymentId: paymentId,
          razorpaySignature: razorpaySignature,
        );

        HelperFunctions().hideOverlayLoader();

        // The ordersucess_view.dart will handle displaying the final status based on fetched order details.
        debugPrint(
            'Navigating to order response page for order: $_currentOrderId');
        Get.offAllNamed(Routes.ORDERSUCCESS, arguments: _currentOrderId);
      } catch (e) {
        HelperFunctions().hideOverlayLoader();
        debugPrint('An error occurred during payment confirmation: $e');
        HelperFunctions().showSnackBarError(
            'An error occurred during payment confirmation. Please try again.');
        Get.offAllNamed(Routes.ORDERSUCCESS, arguments: _currentOrderId);
      }
    } else {
      HelperFunctions()
          .showSnackBarError('Missing payment details from Razorpay.');
      Get.offAllNamed(Routes.ORDERSUCCESS, arguments: _currentOrderId);
    }
  }

  void _handleRazorpayPaymentError(PaymentFailureResponse response) {
    debugPrint(
        'Razorpay Error: Code ${response.code} - Description: ${response.message}');
    HelperFunctions().hideOverlayLoader();
    HelperFunctions().showSnackBarError(
        'Payment failed: ${response.message ?? "Unknown error"}');
    // Navigation to failure page removed. UI will remain on the checkout screen allowing the user to retry.
  }

  void _handleRazorpayExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    HelperFunctions().hideOverlayLoader();
    HelperFunctions().showSnackBarError(
        'Payment via external wallet: ${response.walletName}');
    // Handle external wallet specific logic if needed
  }

  @override
  void onClose() {
    _razorpay.clear(); // Important: clear listeners to prevent memory leaks
    super.onClose();
  }
}
