import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SearchsController extends GetxController with BaseController {
  var searchProduct = [].obs;
  var recentSearchList = [].obs;

  var isSearching = false.obs; // True for initial load
  var isFetchingMore = false.obs; // True for pagination load

  var box = GetStorage();
  late TextEditingController searchTextController;
  late ScrollController scrollController;

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
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
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
    final exists = recentSearchList
        .any((e) => e['productId'] == id && e['type'] == type);
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
          .getRequest(queryParams: {'page': currentPage.toString()})
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
          .getRequest(queryParams: {'search': text, 'page': currentPage.toString()})
          .catchError(handleError);

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

      // Check if we are searching or just browsing all
      String text = searchTextController.text.trim();
      Map<String, String> queryParams = {'page': currentPage.toString()};
      if (text.isNotEmpty) {
        queryParams['search'] = text;
      }

      var response = await BasicProvider('products')
          .getRequest(queryParams: queryParams)
          .catchError(handleError);

      _parseAndSetProducts(response, isRefresh: false);
    } catch (e) {
      debugPrint('❌ loadNextPage error: $e');
      currentPage--; // Revert page number on failure
    } finally {
      isFetchingMore.value = false;
    }
  }

  // ── Parser ──
  // API shape: { status, data: { data: [...], total, current_page, has_next } }
  void _parseAndSetProducts(dynamic response, {required bool isRefresh}) {
    if (response == null) return;

    if (response is Map) {
      // Unwrap outer { data: { data: [...], has_next } }
      final outer = response['data'];
      if (outer is Map) {
        final List newItems = (outer['data'] as List?) ?? [];
        if (isRefresh) {
          searchProduct.assignAll(newItems);
        } else {
          searchProduct.addAll(newItems);
        }
        hasNextPage = outer['has_next'] == true;
        return;
      }

      // Flat { data: [...] }
      if (response.containsKey('data') && response['data'] is List) {
        final List newItems = response['data'];
        if (isRefresh) {
          searchProduct.assignAll(newItems);
        } else {
          searchProduct.addAll(newItems);
        }
        hasNextPage = response['has_next'] == true || response['hasNextPage'] == true;
        return;
      }

      if (isRefresh) searchProduct.clear();
      hasNextPage = false;
    } else if (response is List) {
      if (isRefresh) {
        searchProduct.assignAll(response);
      } else {
        searchProduct.addAll(response);
      }
      hasNextPage = false;
    }
  }
}