import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/routes/app_pages.dart';

class PayPalPayment {
  final bool sandboxMode;
  final String clientId;
  final String secretKey;
  final String note;
  final String currency;

  PayPalPayment({
    this.sandboxMode = true,
    required this.clientId,
    required this.secretKey,
    this.note = '',
    this.currency = 'USD',
  });

  void startPayment({
    required String id,
    required double totalAmount,
    required String description,
    Function(Map params)? onSuccess,
    Function(dynamic error)? onError,
    VoidCallback? onCancel,
  }) {
    Get.to(
      PaypalCheckoutView(
        sandboxMode: sandboxMode,
        clientId: clientId,
        secretKey: secretKey,
        note: note,
        transactions: [
          {
            "amount": {
              "total": totalAmount.toStringAsFixed(2),
              "currency": currency,
            },
            "description": description,
          }
        ],
        onSuccess: (params) async {
          print('Success: ${params.toString()}');
          if (onSuccess != null) onSuccess(params);
          Get.toNamed(Routes.ORDERSUCCESS, arguments: {'id': id});
        },
        onError: (error) {
          print('Error: ${error.toString()}');
          if (onError != null) onError(error);
        },
        onCancel: () {
          print('Cancelled');
          if (onCancel != null) onCancel();
        },
      ),
    );
  }

  Future<void> processPayment({
    required double amount,
    required Map<String, dynamic> metadata,
    String currency = 'USD',
  }) async {
    final String orderNo = metadata['order_no'] ?? metadata['_id'] ?? "";
    final String rawOrderId = metadata['_id'] ?? metadata['order_no'] ?? "";
    startPayment(
      id: rawOrderId,
      totalAmount: amount,
      description: "Payment for Order #$orderNo",
    );
  }
}
