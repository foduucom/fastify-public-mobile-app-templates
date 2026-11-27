import 'dart:io';
import '/constants/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class OrderdetailController extends GetxController with BaseController {
  var item = {}.obs;
  final id = '0'.obs;
  var isLoading = false.obs;
  var downloading = false.obs;
  final errorMessage = ''.obs;
  bool _detailRequestInFlight = false;

  final List<String> stages = [
    'Order Placed',
    'Processing',
    'Shipped',
    'Out for Delivery',
    'Delivered',
  ];

  @override
  Future<void> onInit() async {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Map) {
      final suppliedOrder = arguments['order'];
      id.value = (arguments['id'] ??
              arguments['order_id'] ??
              arguments['_id'] ??
              (suppliedOrder is Map
                  ? suppliedOrder['_id'] ?? suppliedOrder['id']
                  : null) ??
              '')
          .toString()
          .trim();
      if (suppliedOrder is Map) {
        item.assignAll(Map<String, dynamic>.from(suppliedOrder));
      }
    } else if (arguments is String) {
      id.value = arguments.trim();
    }

    if (id.value.isNotEmpty && id.value != '0' && id.value != 'null') {
      await OrderDetail();
    } else if (item.isEmpty) {
      errorMessage.value =
          'Order could not be identified. Please reopen it from your orders.';
    }
  }

  Future<void> OrderDetail() async {
    if (_detailRequestInFlight) return;
    if (id.value.isEmpty || id.value == '0' || id.value == 'null') {
      errorMessage.value =
          'Order could not be identified. Please reopen it from your orders.';
      isLoading.value = false;
      return;
    }

    _detailRequestInFlight = true;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await BasicProvider('order/${id.value}').getRequest();
      if (response is! Map) {
        throw const FormatException('Unexpected order detail response');
      }
      dynamic orderData = response;
      for (var depth = 0; depth < 3 && orderData is Map; depth++) {
        if (orderData['order'] is Map) {
          orderData = orderData['order'];
        } else if (orderData['data'] is Map) {
          orderData = orderData['data'];
        } else {
          break;
        }
      }
      item.assignAll(Map<String, dynamic>.from(orderData as Map));
    } catch (error) {
      errorMessage.value = 'Unable to load order details. Please try again.';
      handleError(error);
    } finally {
      isLoading.value = false;
      _detailRequestInFlight = false;
    }
  }

  /// Returns the current stage index (1-based) based on order status.
  String get currentOrderStatus {
    final orderData =
        item.containsKey('data') && item['data'] is Map ? item['data'] : item;
    final rawStatus = orderData['order_status'] ?? orderData['status'] ?? '';
    if (rawStatus is Map) {
      return (rawStatus['name'] ?? rawStatus['status'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
    }
    return rawStatus.toString().trim().toLowerCase();
  }

  int getCurrentStage() {
    final status = currentOrderStatus;
    if (status.contains('cancel') ||
        status.contains('fail') ||
        status.contains('return')) return 0;
    if (status.contains('delivered') || status.contains('complete')) return 5;
    if (status.contains('out for delivery') ||
        status.contains('out_for_delivery')) return 4;
    if (status.contains('shipped') || status.contains('dispatch')) return 3;
    if (status.contains('processing') ||
        status.contains('confirm') ||
        status.contains('pack')) return 2;
    return 1; // Order Placed
  }

  Future<void> downloadAndSavePDF(String id) async {
    final orderData =
        item.containsKey('data') && item['data'] is Map ? item['data'] : item;
    final paymentMethod =
        (orderData['payment_method'] ?? '').toString().toLowerCase();
    final paymentStatus =
        (orderData['payment_status'] ?? '').toString().toLowerCase();
    final isPaid =
        const {'paid', 'success', 'completed'}.contains(paymentStatus);
    if ((paymentMethod == 'cod' || paymentMethod == 'cash') && !isPaid) {
      HelperFunctions().showSnackBarError(
          'Invoice will be available after payment is completed on delivery.');
      return;
    }
    final orderId = id.trim();
    if (orderId.isEmpty) {
      HelperFunctions().showSnackBarError('Order number is missing');
      return;
    }

    downloading.value = true;
    try {
      final endpoint =
          '${apiURL}public/orders/exporttopdf/${Uri.encodeComponent(orderId)}';
      final response = await Dio().get<List<int>>(
        endpoint,
        options: Options(
          responseType: ResponseType.bytes,
          headers: BasicProvider('').headerType(),
        ),
      );
      final bytes = response.data;
      if (response.statusCode != 200 || bytes == null || bytes.isEmpty) {
        throw StateError('The invoice response was empty.');
      }

      final directory = await getApplicationDocumentsDirectory();
      final safeOrderId = orderId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
      final file = File('${directory.path}/invoice_$safeOrderId.pdf');
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        text: 'Order invoice',
      );
    } catch (error) {
      debugPrint('Invoice download failed: $error');
      HelperFunctions().showSnackBarError('Failed to download invoice');
    } finally {
      downloading.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> postReview(
      {required String summary, required int rating}) async {
    final products = item['products'];
    if (products is! List || products.isEmpty || products.first is! Map) {
      HelperFunctions().showSnackBarError('No product is available to review');
      return;
    }
    final firstProduct = products.first as Map;
    final product = firstProduct['product_id'] ?? firstProduct['product'];
    final productId = product is Map
        ? (product['_id'] ?? product['id'])?.toString()
        : product?.toString();
    if (productId == null || productId.isEmpty) {
      HelperFunctions().showSnackBarError('No product is available to review');
      return;
    }
    var form = {
      'product': productId,
      'rating': rating,
      'summary': summary,
    };
    var response = await BasicProvider("public/reviews/product")
        .postRequest(form)
        .catchError(handleError);
    print('$response     $id');
    if (response == null) return;
    HelperFunctions().showSnackBarSuccess('Review Send Successfully');
  }
}
