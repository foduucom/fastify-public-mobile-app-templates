import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/model.dart';
import '/app/data/basic_provider.dart';


class OrderDetailController extends GetxController {
  final Rx<OrderModel?> order     = Rx<OrderModel?>(null);
  final RxBool          isLoading = true.obs;
  final RxString        error     = ''.obs;

  // orderNo passed via Get.arguments
  String get _orderNo =>
      (Get.arguments as Map?)?['order_no']?.toString() ??
          (Get.arguments is OrderModel
              ? (Get.arguments as OrderModel).orderNo
              : '');

  @override
  void onInit() {
    super.onInit();
    // If a full OrderModel was passed, use it immediately
    // then refresh silently in background
    if (Get.arguments is OrderModel) {
      order.value = Get.arguments as OrderModel;
      isLoading(false);
    }
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    if (_orderNo.isEmpty) return;
    try {
      final result =
      await BasicProvider('order/$_orderNo').getRequest();
      if (result != null && result is Map) {
        order.value = OrderModel.fromJson(
            Map<String, dynamic>.from(result as Map));
      }
    } catch (e) {
      error.value = e.toString();
      debugPrint('Order detail error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> refresh() async {
    isLoading(true);
    error.value = '';
    await _fetchDetail();
  }
}
