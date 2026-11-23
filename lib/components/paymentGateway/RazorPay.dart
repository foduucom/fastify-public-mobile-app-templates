import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayPayment {
  final String keyId;
  late Razorpay _razorpay;
  Completer<PaymentSuccessResponse>? _paymentCompleter;

  RazorPayPayment({required this.keyId}) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<PaymentSuccessResponse> processPayment({
    required double amount,
    Map<String, dynamic>? metadata,
  }) async {
    if (_paymentCompleter != null) {
      throw StateError('A Razorpay payment is already in progress.');
    }
    final completer = Completer<PaymentSuccessResponse>();
    _paymentCompleter = completer;

    var options = {
      'key': keyId,
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Foduu Ecommerce',
      'description': 'Order Payment',
      if ((metadata?['payment_intent_id'] ?? metadata?['razorpay_order_id']) !=
          null)
        'order_id':
            metadata?['payment_intent_id'] ?? metadata?['razorpay_order_id'],
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
      try {
        _razorpay.open(options);
      } catch (e) {
        print('Error opening Razorpay: $e');
        throw StateError('Could not open Razorpay: $e');
      }
      return await completer.future;
    } finally {
      _paymentCompleter = null;
      _razorpay.clear();
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Razorpay Success: ${response.paymentId}');
    final completer = _paymentCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Razorpay Error: ${response.code} - ${response.message}');
    final completer = _paymentCompleter;
    if (completer != null && !completer.isCompleted) {
      final message = response.code == 2
          ? 'Payment was cancelled'
          : 'Payment failed: ${response.message ?? 'Unknown error'}';
      completer.completeError(StateError(message));
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('Razorpay External Wallet: ${response.walletName}');
    final completer = _paymentCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(
        StateError('External wallet ${response.walletName} was not completed.'),
      );
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
