import 'package:flutter/material.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController with BaseController {
  var isLoading = false.obs;
  var isLoadMore = false.obs;
  var hasMore = true.obs;
  var orderList = <dynamic>[].obs;
  var currentPage = 1.obs;
  var maxPage = 1.obs;
  late ScrollController scrollController;

  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController = ScrollController();
    await Orders();
    fetchMoreOrdersOnScroll();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  /// The order list comes back as a bare list, `{docs: [...]}`,
  /// `{data: [...]}` or `{data: {docs: [...]}}`. Pagination metadata
  /// (`hasNextPage`, `totalPages`) is only present for the paginated shapes;
  /// a bare list is treated as the complete result so a backend that ignores
  /// `page` can never loop on repeated pages.
  List<dynamic> _applyResponse(dynamic response) {
    List<dynamic> docs = const [];
    Map? meta;

    if (response is List) {
      docs = response;
    } else if (response is Map) {
      if (response['docs'] is List) {
        docs = response['docs'];
        meta = response;
      } else if (response['data'] is List) {
        docs = response['data'];
        meta = response;
      } else if (response['data'] is Map && response['data']['docs'] is List) {
        docs = response['data']['docs'];
        meta = response['data'];
      }
    }

    hasMore.value = meta?['hasNextPage'] == true;
    final totalPages = meta?['totalPages'];
    if (totalPages is int) {
      maxPage.value = totalPages;
    }
    return docs;
  }

  Future<void> Orders() async {
    try {
      isLoading.value = true;
      hasMore.value = true;
      currentPage.value = 1;
      orderList.clear();

      var response = await BasicProvider("order").getRequest(queryParams: {
        "page": currentPage.value.toString(),
        "limit": "10",
      }).catchError(handleError);

      if (response != null) {
        orderList.addAll(_applyResponse(response));
      }
    } catch (e) {
      debugPrint('Orders error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void fetchMoreOrdersOnScroll() {
    scrollController.addListener(() async {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100.0) {
        if (!isLoading.value && !isLoadMore.value && hasMore.value) {
          await fetchNextPage();
        }
      }
    });
  }

  Future<void> fetchNextPage() async {
    try {
      isLoadMore.value = true;
      currentPage.value += 1;

      var response = await BasicProvider("order").getRequest(queryParams: {
        "page": currentPage.value.toString(),
        "limit": "10",
      }).catchError(handleError);

      if (response != null) {
        orderList.addAll(_applyResponse(response));
      } else {
        currentPage.value -= 1;
      }
    } catch (e) {
      currentPage.value -= 1;
      debugPrint('Load more orders error: $e');
    } finally {
      isLoadMore.value = false;
    }
  }

  void onRefresh() async {
    await Orders();
  }
}
