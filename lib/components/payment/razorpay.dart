import 'package:zouhi/app/controllers/currency_controller.dart';
import 'package:zouhi/app/modules/payment/controllers/payment_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'dart:async';

import 'package:get/get.dart';

class RazorPayService {
  final String razorPayKey;
  final String razorPaySecret;
  late Razorpay _razorpay;
  final String orderNo;
  final Completer<PaymentSuccessResponse> _completer =
      Completer<PaymentSuccessResponse>();

  RazorPayService(
      {required this.razorPayKey,
      required this.razorPaySecret,
      required this.orderNo}) {
    _razorpay = Razorpay();

    // Attach event listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<PaymentSuccessResponse> openCheckout(
      num amount, customer, String? razorpayOrderId) async {
    print('---------------------------------- ${amount.toString()}');
    var options = <String, dynamic>{
      'key': razorPayKey,
      'amount': (amount * 100).toInt(),
      'currency': Get.find<CurrencyController>().code,
      'name': appName,
      'description': 'Payment for Order',
      'prefill': {
        'name': customer['name'] ?? '',
        'email': customer['email'] ?? '',
        'contact': customer['mobile'] ?? '',
      },
      'notes': {
        'order_no': orderNo,
      },
      'theme': {'color': '#F37254'},
    };

    // Razorpay strictly expects order_id to start with 'order_'
    // If your backend creates a Razorpay order, pass it.
    // Otherwise, omit it and Razorpay will create a standard payment.
    if (razorpayOrderId != null && razorpayOrderId.startsWith('order_')) {
      options['order_id'] = razorpayOrderId;
    }

    try {
      printInfo(info: options.toString());
      _razorpay.open(options);
      return _completer.future;
    } catch (e) {
      print('Error opening Razorpay checkout: $e');
      _completer.completeError(e);
      return _completer.future;
    }
  }

  // Event Handlers
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    printInfo(info: 'Payment Successful: ${response.data.toString()}');
    printInfo(info: 'Payment order id: ${response.orderId.toString()}');

    printInfo(info: 'Payment paymentid: ${response.paymentId.toString()}');
    _razorpay.clear();
    if (!_completer.isCompleted) {
      _completer.complete(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _razorpay.clear();
    Get.find<PaymentController>().isOrderLoading.value = false;
    if (!_completer.isCompleted) {
      _completer.completeError(Exception(response.message ?? "Payment Failed"));
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // print('External Wallet Selected: ${response.walletName}');
    // Handle external wallet selection here
  }
}

class RazorPayPayment {
  final String keyId;
  RazorPayPayment({required this.keyId});

  Future<PaymentSuccessResponse> processPayment({
    required double amount,
    required Map<String, dynamic> metadata,
  }) async {
    final String orderId = metadata['order_no'] ?? metadata['_id'] ?? "";
    final String? razorpayOrderId = metadata['razorpay_order_id'];
    final customer = Get.find<BottombarController>().userData;

    final service = RazorPayService(
      razorPayKey: keyId,
      razorPaySecret: "",
      orderNo: orderId,
    );
    return await service.openCheckout(amount, customer, razorpayOrderId);
  }
}
