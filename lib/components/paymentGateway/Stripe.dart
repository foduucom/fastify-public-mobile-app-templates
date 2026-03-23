import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StripePayment {
  final String publicKey;

  StripePayment({required this.publicKey});

  Future<void> processPayment({
    required double amount,
    required String currency,
    String? clientSecret,
  }) async {
    try {
      Stripe.publishableKey = publicKey;
      await Stripe.instance.applySettings();
      if (clientSecret == null || clientSecret.isEmpty) {
        throw 'Client secret is missing from the order creation response.';
      }

      // 1. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Foduu Ecommerce',
          style: ThemeMode.light,
        ),
      );

      // 2. Display Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      print('Stripe payment weight: $amount $currency');
      return;
    } on StripeException catch (e) {
      print('Stripe Error: ${e.error.localizedMessage}');
      throw e.error.localizedMessage ?? 'Payment failed';
    } catch (e) {
      print('Payment failed: $e');
      throw 'Payment failed: $e';
    }
  }
}
