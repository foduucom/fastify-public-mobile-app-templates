import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/model.dart';
import '/app/data/basic_provider.dart';


class OrderHistoryController extends GetxController {

  final RxList<OrderModel> allOrders       = <OrderModel>[].obs;
  final RxBool             isLoading        = false.obs;
  final RxBool             isLoadingMore    = false.obs;
  final RxInt              selectedTab      = 0.obs;

  // Pagination
  int  _page      = 1;
  bool _hasMore   = true;
  static const int _limit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  // ── GET /api/order ────────────────────────────────────────
  Future<void> fetchOrders({bool refresh = false}) async {
    if (refresh) {
      _page    = 1;
      _hasMore = true;
      allOrders.clear();
    }
    if (!_hasMore) return;

    _page == 1 ? isLoading(true) : isLoadingMore(true);

    try {
      final result = await BasicProvider('order').getRequest(
        queryParams: {
          'page':  _page.toString(),
          'limit': _limit.toString(),
        },
      );

      if (result != null && result is Map) {
        final docs = (result['docs'] as List? ?? []);
        final orders = docs
            .map((e) => OrderModel.fromJson(
            Map<String, dynamic>.from(e as Map)))
            .toList();

        allOrders.addAll(orders);

        // Pagination flags from API
        _hasMore = result['hasNextPage'] == true;
        _page    = (result['page'] as num?)?.toInt() ?? _page;
        if (_hasMore) _page++;

        debugPrint('✅ Orders loaded: ${allOrders.length}');
      }
    } catch (e) {
      debugPrint('Fetch orders error: $e');
    } finally {
      isLoading(false);
      isLoadingMore(false);
    }
  }

  // ── Filtered lists for tabs ────────────────────────────────
  List<OrderModel> get trackingOrders =>
      allOrders.where((o) => !o.isCompleted).toList();

  List<OrderModel> get completedOrders =>
      allOrders.where((o) => o.isCompleted).toList();

  List<OrderModel> get currentTabOrders =>
      selectedTab.value == 0 ? trackingOrders : completedOrders;
}
