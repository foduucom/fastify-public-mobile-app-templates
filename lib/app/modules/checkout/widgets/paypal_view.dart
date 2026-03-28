import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:get/get.dart';

class PayPalPayment {
  final String clientId;
  final String secretKey;

  PayPalPayment({required this.clientId, required this.secretKey});

  Future<void> processPayment({
    required double amount,
    required Map<String, dynamic> metadata,
    String currency = 'USD',
  }) async {
    final completer = Completer<void>();

    await Get.to(() => PaypalCheckoutView(
      sandboxMode: true, // ← flip to false for production
      clientId: clientId,
      secretKey: secretKey,
      transactions: [
        {
          "amount": {
            "total": amount.toStringAsFixed(2),
            "currency": currency,
            "details": {
              "subtotal": amount.toStringAsFixed(2),
              "shipping": "0",
              "shipping_discount": 0,
            }
          },
          "description":
          "Order #${metadata['order_no'] ?? metadata['_id'] ?? ''}",
          "item_list": {
            "items": [
              {
                "name": "Order Payment",
                "quantity": 1,
                "price": amount.toStringAsFixed(2),
                "currency": currency,
              }
            ],
          }
        }
      ],
      note: "Contact us for any questions on your order.",
      onSuccess: (Map params) async {
        debugPrint("PayPal Success: $params");
        if (!completer.isCompleted) completer.complete();
      },
      onError: (error) {
        debugPrint("PayPal Error: $error");
        if (!completer.isCompleted) completer.completeError(error);
        Get.back(); // close the WebView on error
      },
      onCancel: () {
        debugPrint("PayPal Cancelled");
        if (!completer.isCompleted) {
          completer.completeError("PayPal payment was cancelled");
        }
      },
    ));

    return completer.future;
  }
}
