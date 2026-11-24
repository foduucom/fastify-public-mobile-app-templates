import 'package:flutter/cupertino.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import 'package:get/get.dart';

class OrderSuccessController extends GetxController with BaseController {
  var item = {}.obs;
  final id = '0'.obs;
  var totalAmount = ''.obs;
  var address = {}.obs;
  var isLoading = false.obs;
  final detailsRefreshFailed = false.obs;
  final RxBool wasCashOrder = false.obs;

  bool get isCashOrder {
    final method = _normalizedValue(
        item['payment_method'] ?? item['primary_method'] ?? '');
    return wasCashOrder.value || method == 'cash' || method == 'cod';
  }

  bool get isPaymentConfirmed {
    final status = _normalizedValue(item['payment_status'] ?? '');
    return const {'paid', 'success', 'succeeded', 'captured', 'completed'}
        .contains(status);
  }

  bool get isPaymentFailed {
    final status = _normalizedValue(item['payment_status'] ?? '');
    return const {'failed', 'cancelled', 'canceled', 'declined'}
        .contains(status);
  }

  String _normalizedValue(dynamic value) {
    if (value is Map) {
      value = value['name'] ??
          value['label'] ??
          value['status'] ??
          value['method'] ??
          value['value'];
    }
    return value?.toString().trim().toLowerCase() ?? '';
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is String) {
      id.value = arguments;
    } else if (arguments is Map) {
      final order = arguments['order'];
      if (order is Map) {
        item.assignAll(Map<String, dynamic>.from(order));
        address.assignAll(order['address'] is Map
            ? Map<String, dynamic>.from(order['address'])
            : <String, dynamic>{});
      }
      if (arguments['order_no'] != null) {
        item.putIfAbsent('order_no', () => arguments['order_no']);
      }
      if (arguments['is_cash_order'] == true) {
        wasCashOrder.value = true;
        item.putIfAbsent('payment_method', () => 'cash');
      }
      final orderId = arguments['id'] ??
          (order is Map
              ? (order['_id'] ?? order['id'] ?? order['order_id'])
              : null);
      if (orderId != null && orderId.toString().isNotEmpty) {
        id.value = orderId.toString();
      }
    }
    await OrderDetail();
  }

  Future<void> OrderDetail() async {
    if (id.value == '0' || id.value.isEmpty || id.value == 'null') return;
    isLoading.value = true;
    detailsRefreshFailed.value = false;
    try {
      final response =
          await BasicProvider('order/${id.value}').getRequest(useCache: false);
      if (response is! Map) {
        detailsRefreshFailed.value = true;
        return;
      }

      final data = response['order'] is Map ? response['order'] : response;
      final order = Map<String, dynamic>.from(data as Map);
      item.assignAll(order);
      address.assignAll(order['address'] is Map
          ? Map<String, dynamic>.from(order['address'] as Map)
          : <String, dynamic>{});
    } catch (error) {
      detailsRefreshFailed.value = true;
      handleError(error);
    } finally {
      isLoading.value = false;
    }
  }
}
