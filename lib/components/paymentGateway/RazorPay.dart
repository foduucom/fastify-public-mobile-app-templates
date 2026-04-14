import 'dart:async';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayPayment {
  final String keyId;
  late Razorpay _razorpay;
  Completer<void>? _completer;

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
    _completer = Completer<void>();

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
      _completer!.completeError('Could not open Razorpay: $e');
    }

    return _completer!.future;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Razorpay Success: ${response.paymentId}');
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Razorpay Error: ${response.code} - ${response.message}');
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(
        'Payment Failed: ${response.message ?? response.code}',
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('Razorpay External Wallet: ${response.walletName}');
    if (_completer != null && !_completer!.isCompleted) {
      // Treat external wallet selection as a cancellation from our flow
      _completer!.completeError('cancelled');
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
