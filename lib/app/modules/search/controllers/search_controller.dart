import 'package:flutter/material.dart';
import '/constants/constants.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/filter_model.dart';
import '../services/product_service.dart';

class SearchsController extends GetxController with BaseController {
  var searchProduct = [].obs;
  var recentSearchList = [].obs;

  var isSearching = false.obs; // True for initial load
  var isFetchingMore = false.obs; // True for pagination load

  var box = GetStorage();
  late TextEditingController searchTextController;
  late ScrollController scrollController;

  // Filter state
  var activeFilter = const FilterModel.empty().obs;

  // Pagination Trackers
  int currentPage = 1;
  bool hasNextPage = false;

  @override
  void onInit() {
    searchTextController = TextEditingController();
    scrollController = ScrollController();

    // Listen to scrolling to trigger pagination
    scrollController.addListener(_scrollListener);

    getRecentSearch();
    loadAllProducts();
    super.onInit();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    // If we are near the bottom of the page, NOT already fetching, and there is a next page
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isFetchingMore.value && hasNextPage) {
        loadNextPage();
      }
    }
  }

  void getRecentSearch() {
    var recent = box.read('recentSearch');
    if (recent != null) {
      recentSearchList.addAll(List.from(recent));
    }
  }

  void saveRecentSearch({
    required String id,
    required String name,
    required String type,
  }) {
    final exists =
        recentSearchList.any((e) => e['productId'] == id && e['type'] == type);
    if (!exists) {
      recentSearchList.add({'productId': id, 'name': name, 'type': type});
      box.write('recentSearch', recentSearchList.toList());
    }
  }

  // ── Initial Load (Page 1) ──
  void loadAllProducts() async {
    try {
      currentPage = 1;
      hasNextPage = false;
      isSearching.value = true;
      searchProduct.clear();

      var response = await BasicProvider('products')
          .getRequest(
              queryParams: ProductService.buildQueryParams(
            page: 1,
            filter: activeFilter.value,
          ))
          .catchError(handleError);

      _parseAndSetProducts(response, isRefresh: true);
    } catch (e) {
      debugPrint('❌ loadAllProducts error: $e');
    } finally {
      isSearching.value = false;
    }
  }

  // ── Search Load (Page 1) ──
  void getSearchSuggestion({required String text}) async {
    if (text.trim().isEmpty) {
      loadAllProducts();
      return;
    }

    try {
      currentPage = 1;
      hasNextPage = false;
      isSearching.value = true;
      searchProduct.clear();

      var response = await BasicProvider('products')
          .getRequest(
              queryParams: ProductService.buildQueryParams(
            page: 1,
            search: text,
            filter: activeFilter.value,
          ))
          .catchError(handleError);
      debugPrint('response search $response');
      _parseAndSetProducts(response, isRefresh: true);
    } catch (e) {
      debugPrint('❌ search error: $e');
    } finally {
      isSearching.value = false;
    }
  }

  // ── Pagination Load (Page 2+) ──
  void loadNextPage() async {
    try {
      isFetchingMore.value = true;
      currentPage++;

      var response = await BasicProvider('products')
          .getRequest(
              queryParams: ProductService.buildQueryParams(
            page: currentPage,
            search: searchTextController.text.trim().isEmpty
                ? null
                : searchTextController.text.trim(),
            filter: activeFilter.value,
          ))
          .catchError(handleError);

      _parseAndSetProducts(response, isRefresh: false);
    } catch (e) {
      debugPrint('❌ loadNextPage error: $e');
      currentPage--; // Revert page number on failure
    } finally {
      isFetchingMore.value = false;
    }
  }

  // ── Filter methods ──
  void applyFilter(FilterModel filter) {
    activeFilter.value = filter;
    // Re-fetch from page 1 with current search text + new filters
    final text = searchTextController.text.trim();
    if (text.isNotEmpty) {
      getSearchSuggestion(text: text);
    } else {
      loadAllProducts();
    }
  }

  void clearFilter() {
    applyFilter(const FilterModel.empty());
  }

  // ── Parser ──
  void _parseAndSetProducts(dynamic response, {required bool isRefresh}) {
    if (response == null) return;

    if (response is Map) {
      // Check if it's the paginated format
      if (response.containsKey('data') && response['data'] is List) {
        final List newItems = response['data'];
        if (isRefresh) {
          searchProduct.assignAll(newItems);
        } else {
          searchProduct.addAll(newItems);
        }
        // Grab pagination flags from API
        hasNextPage = response['hasNextPage'] ?? false;
      }
      // Direct map but not paginated wrapper
      else {
        if (isRefresh) searchProduct.clear();
        hasNextPage = false;
      }
    }
    // Direct array format
    else if (response is List) {
      if (isRefresh) {
        searchProduct.assignAll(response);
      } else {
        searchProduct.addAll(response);
      }
      hasNextPage = false; // No pagination data attached
    }

    _applyClientSideFilter();
  }

  // ── Client-side flag filtering ──
  // Filters products locally since the backend has no API support for
  // trending/recommended params. Handles bool true, string "true", and int 1.
  bool _isFlagTrue(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    return value.toString().toLowerCase() == 'true';
  }

  void _applyClientSideFilter() {
    final f = activeFilter.value;
    if (!f.featured && !f.hot && !f.trending && !f.recommended) return;

    final before = searchProduct.length;
    searchProduct.value = searchProduct.where((product) {
      if (f.featured && !_isFlagTrue(product['featured'])) return false;
      if (f.hot && !_isFlagTrue(product['hot'])) return false;
      if (f.trending && !_isFlagTrue(product['trending'])) return false;
      if (f.recommended && !_isFlagTrue(product['recommended'])) return false;
      return true;
    }).toList();
    debugPrint('🔍 Filter applied: before=$before, after=${searchProduct.length}, trending=${f.trending}, recommended=${f.recommended}');
    if (searchProduct.isNotEmpty) {
      debugPrint('🔍 Sample product flags → trending=${searchProduct[0]['trending']}, recommended=${searchProduct[0]['recommended']}');
    }
  }
}
