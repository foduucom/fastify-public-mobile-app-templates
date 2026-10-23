import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:zouhi/constants/constants.dart';

class PesapalPayment {
  final String consumerKey;
  final String consumerSecret;
  final bool sandbox;

  PesapalPayment({
    required this.consumerKey,
    required this.consumerSecret,
    required this.sandbox,
  });

  Future<void> processPayment({
    required double amount,
    required Map<String, dynamic> metadata,
  }) async {
    String? paymentUrl;
    String? paymentIntentId;
    String? merchantReference;
    String? cardinalJwt;

    if (metadata.containsKey('payments') &&
        metadata['payments'] is List &&
        metadata['payments'].isNotEmpty) {
      final firstPayment = metadata['payments'][0];
      if (firstPayment is Map) {
        if (firstPayment.containsKey('client_secret')) {
          paymentUrl = firstPayment['client_secret']?.toString();
        }
        paymentIntentId = firstPayment['payment_intent_id']?.toString();
        merchantReference = firstPayment['merchant_reference']?.toString();
        cardinalJwt = firstPayment['cardinal_jwt']?.toString();
      }
    }

    paymentUrl ??= metadata['payment_url']?.toString() ??
        metadata['redirect_url']?.toString() ??
        metadata['payment_link']?.toString();

    paymentIntentId ??= metadata['payment_intent_id']?.toString();
    merchantReference ??= metadata['merchant_reference']?.toString();
    cardinalJwt ??= metadata['cardinal_jwt']?.toString();

    if (paymentUrl == null || paymentUrl.isEmpty) {
      throw Exception("Pesapal payment URL is missing from order response.");
    }

    // Await the WebView page. Once closed (either automatically or manually),
    // proceed to the success/status check screen in payment controller.
    await Get.to(() => PesapalWebViewPage(
          paymentUrl: paymentUrl!,
          paymentIntentId: paymentIntentId ?? '',
          merchantReference: merchantReference ?? '',
          cardinalJwt: cardinalJwt,
        ));
  }
}

class PesapalWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final String paymentIntentId;
  final String merchantReference;
  final String? cardinalJwt;

  const PesapalWebViewPage({
    Key? key,
    required this.paymentUrl,
    required this.paymentIntentId,
    required this.merchantReference,
    this.cardinalJwt,
  }) : super(key: key);

  @override
  State<PesapalWebViewPage> createState() => _PesapalWebViewPageState();
}

class _PesapalWebViewPageState extends State<PesapalWebViewPage> {
  bool _isLoading = true;
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(result: false),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.paymentUrl)),
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              javaScriptEnabled: true,
              domStorageEnabled: true, // Required for Cardinal scripts
              databaseEnabled: true, // Required for HTML5 databases
              thirdPartyCookiesEnabled: true, // Required for 3DS bank frames
              cacheEnabled: true,
              allowsInlineMediaPlayback: true,
              allowFileAccess: true,
              mixedContentMode: MixedContentMode
                  .MIXED_CONTENT_ALWAYS_ALLOW, // Avoid blocking asset loads
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) async {
              setState(() {
                _isLoading = true;
              });

              if (url != null) {
                final urlStr = url.toString().toLowerCase();
                final host = url.host.toLowerCase();
                print("WEBVIEW_LOAD_START: $urlStr (Host: $host)");

                bool isCallback = false;
                if (!urlStr.contains('pesapaliframe')) {
                  isCallback = urlStr.contains('mern.foduu.com') ||
                      urlStr.contains('success') ||
                      urlStr.contains('callback') ||
                      urlStr.contains('completed') ||
                      urlStr.contains('confirm') ||
                      urlStr.contains('fail') ||
                      urlStr.contains('cancel') ||
                      urlStr.contains('ordertrackingid') ||
                      urlStr.contains('ordermerchantreference') ||
                      (!host.contains('pesapal.com') &&
                          !host.contains('cardinalcommerce.com') &&
                          !host.contains('online-metrix.net') &&
                          !host.contains('fpjs.io') &&
                          !host.contains('bank') &&
                          !host.contains('visa') &&
                          !host.contains('mastercard') &&
                          !host.contains('securecode') &&
                          (urlStr.contains('tracking') ||
                              urlStr.contains('reference') ||
                              urlStr.contains('order') ||
                              urlStr.contains('payment')));
                }

                if (isCallback) {
                  print("PESAPAL_CALLBACK_DETECTED on load start: $urlStr");
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) Get.back(result: true);
                  });
                }
              }
            },
            onLoadStop: (controller, url) {
              setState(() {
                _isLoading = false;
              });
            },
            onProgressChanged: (controller, progress) {
              if (progress == 100) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onConsoleMessage: (controller, consoleMessage) {
              print(
                  "WEBVIEW_CONSOLE: [${consoleMessage.messageLevel}] ${consoleMessage.message}");
            },
            onReceivedError: (controller, request, error) {
              print(
                  "WEBVIEW_ERROR: for ${request.url} - Code: ${error.type}, Description: ${error.description}");
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final uri = navigationAction.request.url;
              if (uri != null) {
                final urlStr = uri.toString().toLowerCase();
                final host = uri.host.toLowerCase();
                print("WEBVIEW_NAVIGATION: $urlStr");

                bool isCallback = false;
                // if (!urlStr.contains('pesapaliframe')) {
                //   isCallback = urlStr.contains('success') ||
                //       urlStr.contains('callback') ||
                //       urlStr.contains('completed') ||
                //       urlStr.contains('confirm') ||
                //       urlStr.contains('fail') ||
                //       urlStr.contains('cancel') ||
                //       urlStr.contains('ordertrackingid') ||
                //       urlStr.contains('ordermerchantreference') ||
                //       (!host.contains('pesapal.com') &&
                //           !host.contains('cardinalcommerce.com') &&
                //           !host.contains('online-metrix.net') &&
                //           !host.contains('fpjs.io') &&
                //           !host.contains('bank') &&
                //           !host.contains('visa') &&
                //           !host.contains('mastercard') &&
                //           !host.contains('securecode') &&
                //           (urlStr.contains('tracking') ||
                //               urlStr.contains('reference') ||
                //               urlStr.contains('order') ||
                //               urlStr.contains('payment')));
                // }

                // if (isCallback) {
                //   print("PESAPAL_CALLBACK_DETECTED on shouldOverride: $urlStr");
                //   Future.delayed(const Duration(seconds: 2), () {
                //     if (mounted) Get.back(result: true);
                //   });
                //   return NavigationActionPolicy.ALLOW;
                // }

                if (uri.scheme == 'http' || uri.scheme == 'https') {
                  return NavigationActionPolicy.ALLOW;
                }
              }
              return NavigationActionPolicy.CANCEL;
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(themeRedColor),
              ),
            ),
        ],
      ),
    );
  }
}
