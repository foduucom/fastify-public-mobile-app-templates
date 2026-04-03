import 'package:flutter/material.dart';

class CODPayment {
  Future<void> processPayment({
    required double amount,
  }) async {
    // TODO: Implement COD logic (e.g., just confirming the order)
    print('Processing COD payment of $amount');

    // Simulating a delay and success
    await Future.delayed(Duration(seconds: 1));
    return;
  }
}
