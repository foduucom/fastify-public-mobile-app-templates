import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

/// PhonePe Standard Checkout (SDK v3) integration.
///
/// The `payment-methods` API only exposes `client_id`/`client_secret`/
/// `client_version` — the backend does not mint a per-order PhonePe SDK
/// token server-side. Because of that, this class performs the PhonePe
/// OAuth + "create SDK order" calls directly from the device using
/// `client_secret`. PhonePe's own guidance is that the secret should never
/// leave the server; this is a stopgap until the backend exposes an
/// endpoint that returns an order-scoped SDK token instead of raw
/// credentials, and until then anyone who decompiles the app can extract
/// this secret.
class PhonePePayment {
  final String clientId;
  final String clientSecret;
  final String clientVersion;
  final String environment; // 'PRODUCTION' | 'SANDBOX'
  final String appScheme;

  PhonePePayment({
    required this.clientId,
    required this.clientSecret,
    required this.clientVersion,
    this.environment = 'PRODUCTION',
    required this.appScheme,
  });

  static bool _sdkInitialized = false;

  String get _oauthUrl => environment == 'PRODUCTION'
      ? 'https://api.phonepe.com/apis/identity-manager/v1/oauth/token'
      : 'https://api-preprod.phonepe.com/apis/pg-sandbox/v1/oauth/token';

  String get _orderUrl => environment == 'PRODUCTION'
      ? 'https://api.phonepe.com/apis/pg/checkout/v2/sdk/order'
      : 'https://api-preprod.phonepe.com/apis/pg-sandbox/checkout/v2/sdk/order';

  Future<void> _ensureInit() async {
    if (_sdkInitialized) return;
    await PhonePePaymentSdk.init(
      environment,
      clientId,
      'CheckoutFlow',
      environment != 'PRODUCTION',
    );
    _sdkInitialized = true;
  }

  Future<String> _fetchAccessToken() async {
    final res = await http.post(
      Uri.parse(_oauthUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': clientId,
        'client_version': clientVersion,
        'client_secret': clientSecret,
        'grant_type': 'client_credentials',
      },
    );
    if (res.statusCode != 200) {
      throw 'PhonePe auth failed: ${res.statusCode} ${res.body}';
    }
    final data = jsonDecode(res.body);
    final token = data['access_token']?.toString();
    if (token == null || token.isEmpty) {
      throw 'PhonePe auth response missing access_token';
    }
    return token;
  }

  Future<Map<String, dynamic>> _createSdkOrder({
    required String accessToken,
    required String merchantOrderId,
    required int amountPaise,
  }) async {
    final res = await http.post(
      Uri.parse(_orderUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'O-Bearer $accessToken',
      },
      body: jsonEncode({
        'merchantOrderId': merchantOrderId,
        'amount': amountPaise,
        'paymentFlow': {'type': 'PG_CHECKOUT'},
      }),
    );
    if (res.statusCode != 200) {
      throw 'PhonePe order creation failed: ${res.statusCode} ${res.body}';
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Starts a PhonePe payment for [amount] (in the main currency unit, e.g.
  /// rupees). [metadata] is the response returned by the app's own
  /// `order/create` call, used to derive a stable `merchantOrderId`.
  ///
  /// Returns identifiers on SDK-reported success. Throws a String error on
  /// failure or cancellation (the caller's existing catch blocks already
  /// handle that the same way they handle Stripe/Razorpay errors).
  Future<Map<String, dynamic>> processPayment({
    required double amount,
    required Map<String, dynamic> metadata,
  }) async {
    await _ensureInit();

    final String merchantOrderId = (metadata['order_no'] ??
            metadata['_id'] ??
            DateTime.now().millisecondsSinceEpoch.toString())
        .toString();

    final accessToken = await _fetchAccessToken();
    final orderData = await _createSdkOrder(
      accessToken: accessToken,
      merchantOrderId: merchantOrderId,
      amountPaise: (amount * 100).round(),
    );

    final String? phonePeOrderId = orderData['orderId']?.toString();
    final String? sdkToken = orderData['token']?.toString();
    if (phonePeOrderId == null || sdkToken == null) {
      throw 'PhonePe order response missing orderId/token';
    }

    final requestJson = jsonEncode({
      'orderId': phonePeOrderId,
      'merchantId': clientId,
      'token': sdkToken,
      'paymentMode': {'type': 'PAY_PAGE'},
    });

    final response =
        await PhonePePaymentSdk.startTransaction(requestJson, appScheme);

    final status = response?['status']?.toString();
    if (status != 'SUCCESS') {
      final err = response?['error']?.toString() ?? 'unknown';
      if (err.toLowerCase().contains('cancel')) {
        throw 'Payment was cancelled';
      }
      throw 'PhonePe payment failed: $err';
    }

    return {
      'transactionId': merchantOrderId,
      'phonePeOrderId': phonePeOrderId,
    };
  }
}
