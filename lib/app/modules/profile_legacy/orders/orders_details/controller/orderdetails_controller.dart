import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foddu/app/controllers/api_exception_handle_controller.dart';
import 'package:foddu/app/data/basic_provider.dart';
import 'package:foddu/constants/constants.dart' show apiURL;
import 'package:foddu/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class OrderdetailController extends GetxController with BaseController {
  var item = {}.obs;
  final id = '0'.obs;
  var isLoading = false.obs;
  var downloading = false.obs;
  bool _detailRequestInFlight = false;

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
        item.value = Map<String, dynamic>.from(suppliedOrder);
        // Show the order immediately, then refresh if a database id is available.
        isLoading.value = false;
      }
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
      // The order API is singular: /api/order/{database order id}.
      final response = await BasicProvider("order/${id.value}").getRequest();
      if (response is! Map) {
        throw const FormatException('Unexpected order detail response');
      }
      final orderData = response['order'] is Map ? response['order'] : response;
      item.value = Map<String, dynamic>.from(orderData as Map);
    } catch (error) {
      errorMessage.value = 'Unable to load order details. Please try again.';
      handleError(error);
    } finally {
      isLoading.value = false;
      _detailRequestInFlight = false;
    }
  }

  Future<void> downloadAndSavePDF(String id) async {
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
    var response = await BasicProvider("reviews/product")
        .postRequest(form)
        .catchError(handleError);
    print('$response     $id');
    if (response == null) return;
    HelperFunctions().showSnackBarSuccess('Review Send Successfully');
  }
}
