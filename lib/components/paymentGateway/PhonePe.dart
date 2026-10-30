import 'package:flutter/material.dart';

class PhonePePayment {
  final String clientId;
  final String clientSecret;
  final String clientVersion;
  final String environment;
  final String appScheme;

  PhonePePayment({
    required this.clientId,
    required this.clientSecret,
    required this.clientVersion,
    required this.environment,
    required this.appScheme,
  });

  Future<Map<String, dynamic>> processPayment({
    required double amount,
    Map<String, dynamic>? metadata,
  }) async {
    // The server must provide the signed PhonePe transaction payload before
    // the mobile SDK can be invoked. Keep the adapter's result typed while
    // that backend flow is configured.
    debugPrint(
      'PhonePe payment is not configured for client $clientId '
      '(version $clientVersion, environment $environment, scheme $appScheme).',
    );
    throw StateError(
      'PhonePe payment requires a signed transaction payload from the server.',
    );
  }
}
