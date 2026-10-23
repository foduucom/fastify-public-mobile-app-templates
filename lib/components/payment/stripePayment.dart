// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_stripe/flutter_stripe.dart';

// class StripePaymentService {
//   // Replace this with your Stripe Secret Key
//   final String _stripeSecretKey =
//       'sk_test_YOUR_STRIPE_TEST_SECRET_KEY';

//   Map<String, dynamic>? _paymentIntent;

//   /// Create a payment intent with the given amount and currency
//   Future<Map<String, dynamic>?> createPaymentIntent(
//       String amount, String currency) async {
//     try {
//       Map<String, dynamic> body = {
//         'amount':
//             amount, // Amount in the smallest currency unit (e.g., cents for USD)
//         'currency': currency,
//       };

//       var response = await http.post(
//         Uri.parse('https://api.stripe.com/v1/payment_intents'),
//         headers: {
//           'Authorization': 'Bearer $_stripeSecretKey',
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to create payment intent: ${response.body}');
//       }
//     } catch (err) {
//       throw Exception('Error creating payment intent: $err');
//     }
//   }

//   /// Initialize and display the payment sheet
//   Future<void> makePayment(String amount, String currency,
//       {required String merchantDisplayName}) async {
//     try {
//       // Step 1: Create Payment Intent
//       _paymentIntent = await createPaymentIntent(amount, currency);

//       if (_paymentIntent == null) throw Exception("Payment intent is null");

//       // Step 2: Initialize Payment Sheet
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: _paymentIntent!['client_secret'],
//           merchantDisplayName: merchantDisplayName,
//           style: ThemeMode.light,
//         ),
//       );

//       // Step 3: Display Payment Sheet
//       await Stripe.instance.presentPaymentSheet();

//       // Clear payment intent after successful payment
//       _paymentIntent = null;
//       print("Payment successful!");
//     } on StripeException catch (e) {
//       print("Stripe Exception: $e");
//       throw Exception("Stripe Payment Failed: $e");
//     } catch (e) {
//       print("General Error: $e");
//       throw Exception("Payment Error: $e");
//     }
//   }
// }

class StripePayment {
  final String publicKey;
  StripePayment({required this.publicKey});

  Future<void> processPayment({
    required double amount,
    required String currency,
    required String clientSecret,
  }) async {
    throw UnimplementedError("Stripe payment is not enabled/supported in this build.");
  }
}

