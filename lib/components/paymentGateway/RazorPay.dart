import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayPayment {
  final String keyId;
  late Razorpay _razorpay;

  RazorPayPayment({required this.keyId}) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> processPayment({
    required double amount,
    Map<String, dynamic>? metadata,
  }) async {
    var options = {
      'key': keyId,
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Foduu Ecommerce',
      'description': 'Order Payment',
      'prefill': {
        'contact': metadata?['user_phone'] ?? '',
        'email': metadata?['user_email'] ?? '',
      },
      'external': {
        'wallets': ['paytm']
      },
      'notes': {
        'order_id': metadata?['_id'] ?? '',
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay: $e');
      throw 'Could not open Razorpay: $e';
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Razorpay Success: ${response.paymentId}');
    HelperFunctions()
        .showSnackBarSuccess('Payment Successful: ${response.paymentId}');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Razorpay Error: ${response.code} - ${response.message}');
    HelperFunctions().showSnackBarError('Payment Failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('Razorpay External Wallet: ${response.walletName}');
    HelperFunctions()
        .showSnackBarError('Payment Failed: ${response.walletName}');
  }

  void dispose() {
    _razorpay.clear();
  }
}
