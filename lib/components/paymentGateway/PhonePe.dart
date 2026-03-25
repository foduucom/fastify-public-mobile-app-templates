import 'package:flutter/material.dart';

class PhonePePayment {
  final String merchantId;

  PhonePePayment({required this.merchantId});

  Future<void> processPayment({
    required double amount,
    Map<String, dynamic>? metadata,
  }) async {
    // TODO: Implement PhonePe payment logic using the provided merchantId
    print(
        'Processing PhonePe payment of $amount with merchant ID: $merchantId');

    // Simulating a delay and success
    await Future.delayed(Duration(seconds: 2));
    return;
  }
}
