import 'package:get/get.dart';
import '../app/data/basic_provider.dart';
import '../constants/helper_functions.dart';
import '../app/controllers/api_exception_handle_controller.dart';

class PaymentService extends GetxService with BaseController {
  static PaymentService get to => Get.find();

  /// Confirms a payment with the backend.
  ///
  /// Takes payment details and sends them to the '/pos/order/confirm-payment' endpoint.
  /// Shows loading indicators and provides user feedback via snackbars.
  /// Returns the 'data' part of the successful response, or null on failure.
  Future<Map<String, dynamic>?> confirmPayment({
    required String orderId,
    required String paymentIntentId,
    required String paymentId,
    required String razorpaySignature,
  }) async {
    try {
      HelperFunctions().showOverlayLoader();

      final payload = {
        'order_id': orderId,
        'payment_intent_id': paymentIntentId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': razorpaySignature,
      };

      print("confirmPayment payload: $payload");
      final response = await BasicProvider('order/confirm-payment')
          .postRequest(payload)
          .catchError(handleError);
      HelperFunctions().hideOverlayLoader();
      if (response != null && response['status'] == 'success') {
        HelperFunctions().showSnackBarSuccess(
            response['message'] ?? 'Payment confirmed successfully');
        return Map<String, dynamic>.from(response['data']);
      } else {
        HelperFunctions().showSnackBarError(
            response['message'] ?? 'Payment confirmation failed');
        return null;
      }
    } catch (e) {
      HelperFunctions().hideOverlayLoader();
      HelperFunctions().showSnackBarError(
          'An error occurred during payment confirmation: $e');
      return null;
    }
  }
}
