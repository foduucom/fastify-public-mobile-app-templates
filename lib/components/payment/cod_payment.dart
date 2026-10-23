import 'package:flutter/foundation.dart';

class CODPayment {
  Future<void> processPayment({required double amount}) async {
    debugPrint("Processing COD payment of $amount");
  }
}
