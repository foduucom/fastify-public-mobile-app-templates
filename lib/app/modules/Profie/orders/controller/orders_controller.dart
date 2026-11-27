import 'package:flutter/material.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController with BaseController {
  static const int _pageSize = 10;

  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;
  final orderList = <dynamic>[].obs;
  final currentPage = 0.obs;
  final maxPage = 1.obs;
  final ScrollController scrollController = ScrollController();
  int _requestToken = 0;
  bool _hasMore = true;
  bool _paginationFailed = false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    Orders(refresh: true);
  }

  @override
  void onClose() {
    _requestToken++;
    scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !_paginationFailed) {
      loadMore();
    }
  }

  Future<void> Orders({bool refresh = false}) async {
    if (refresh) {
      _requestToken++;
      _hasMore = true;
      _paginationFailed = false;
      currentPage.value = 0;
      maxPage.value = 1;
      isLoadingMore.value = false;
    } else if (isLoading.value || isLoadingMore.value || !_hasMore) {
      return;
    }

    final requestedPage = refresh ? 1 : currentPage.value + 1;
    final token = ++_requestToken;
    try {
      if (requestedPage == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      errorMessage.value = '';
      final response = await BasicProvider('order').getRequest(
        queryParams: {
          'page': requestedPage.toString(),
          'limit': _pageSize.toString(),
        },
        useCache: false,
      );
      if (token != _requestToken) return;

      final page = _parseOrderPage(response);
      if (page == null) {
        throw const FormatException('Unexpected order list response');
      }

      if (requestedPage == 1) {
        orderList.assignAll(page.orders);
      } else {
        final knownIds = orderList
            .whereType<Map>()
            .map(_orderIdentity)
            .where((id) => id.isNotEmpty)
            .toSet();
        final newOrders = page.orders.where((order) {
          if (order is! Map) return false;
          final id = _orderIdentity(order);
          return id.isEmpty || knownIds.add(id);
        }).toList();
        orderList.addAll(newOrders);
        if (newOrders.isEmpty) {
          _hasMore = false;
        }
      }

      currentPage.value = requestedPage;
      _hasMore = _hasMore && (page.hasMore ?? page.orders.length >= _pageSize);
      _paginationFailed = false;
      maxPage.value = _hasMore ? requestedPage + 1 : requestedPage;
      errorMessage.value = '';
    } catch (error) {
      if (token == _requestToken) {
        _paginationFailed = requestedPage > 1;
        errorMessage.value = orderList.isEmpty
            ? 'Unable to load your orders. Please try again.'
            : 'Unable to load more orders. Please try again.';
        handleError(error);
      }
    } finally {
      if (token == _requestToken) {
        isLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> loadMore() => Orders();

  Future<void> retryLoadMore() {
    _paginationFailed = false;
    return Orders();
  }

  Future<void> retry() => _paginationFailed ? retryLoadMore() : onRefresh();

  String _orderIdentity(Map order) =>
      (order['_id'] ?? order['id'] ?? order['order_no'] ?? '').toString();

  _OrderPage? _parseOrderPage(dynamic response) {
    if (response is List) return _OrderPage(response);
    if (response is! Map) return null;

    dynamic payload = response;
    for (var depth = 0; depth < 3 && payload is Map; depth++) {
      final hasOrders = payload['docs'] is Iterable ||
          payload['orders'] is Iterable ||
          payload['data'] is List;
      if (hasOrders || payload['data'] is! Map) break;
      payload = payload['data'];
    }
    final docs = payload['docs'] ??
        payload['orders'] ??
        (payload['data'] is List ? payload['data'] : null);
    if (docs is! Iterable) return null;

    final hasNext = response['hasNextPage'] ?? payload['hasNextPage'];
    final totalPages = response['totalPages'] ?? payload['totalPages'];
    final reportedPage = response['page'] ?? payload['page'];
    final bool? hasMore = hasNext is bool
        ? hasNext
        : totalPages is num && reportedPage is num
            ? reportedPage < totalPages
            : null;
    return _OrderPage(docs.whereType<Map>().toList(), hasMore: hasMore);
  }

  Future<void> onRefresh() => Orders(refresh: true);
}

class _OrderPage {
  const _OrderPage(this.orders, {this.hasMore});

  final List<dynamic> orders;
  final bool? hasMore;
}
