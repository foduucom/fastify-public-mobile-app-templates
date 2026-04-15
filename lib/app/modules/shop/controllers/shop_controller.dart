import 'package:flutter/material.dart';
import '/constants/constants.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import 'package:get/get.dart';

class ShopController extends GetxController with BaseController {
  // ─── STATE VARIABLES ──────────────────────────────────────────
  var products = [].obs;
  var isLoading = true.obs;
  var isFetchingMore = false.obs;
  var totalProducts = 0.obs;

  late ScrollController scrollController;
  int currentPage = 1;
  bool hasNextPage = false;

  // ─── ACTIVE FILTERS & SORTING ─────────────────────────────────
  var collectionName = "All Products".obs;

  // Sorting
  var sortBy = "created_at".obs;
  var sortOrder = "desc".obs;

  // Booleans
  var isFeatured = false.obs;
  var isHot = false.obs;

  // Price Range
  var currentPriceRange = const RangeValues(0, 10000).obs;
  var minPrice = 0.0.obs;
  var maxPrice = 10000.0.obs;

  // Arrays for multi-select (Using Sets to prevent duplicates)
  var selectedCategories = <String>{}.obs;
  var selectedBrands = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);

    _parseArguments();
    fetchProducts(isRefresh: true);
  }

  void _parseArguments() {
    if (Get.arguments != null) {
      final args = Get.arguments as Map;
      collectionName.value = args['name'] ?? "Shop";

      // If we arrived here from a specific category or brand banner
      if (args['source'] == 'category' && args['categorySlug'] != null) {
        selectedCategories.add(args['categorySlug']);
      } else if (args['source'] == 'brand' && args['brandId'] != null) {
        selectedBrands.add(args['brandId']);
      }
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isFetchingMore.value && hasNextPage) {
        fetchProducts(isRefresh: false);
      }
    }
  }

  // ─── THE CORE API FETCH ───────────────────────────────────────
  Future<void> fetchProducts({required bool isRefresh}) async {
    try {
      if (isRefresh) {
        isLoading.value = true;
        currentPage = 1;
        products.clear();
      } else {
        isFetchingMore.value = true;
        currentPage++;
      }

      // 1. Build Query Parameters based on your exact API Docs
      Map<String, dynamic> queryParams = {
        'page': currentPage.toString(),
        'count': '10',
        'sort_by': sortBy.value,
        'sort_order': sortOrder.value,
      };

      if (isFeatured.value) queryParams['featured'] = 'true';
      if (isHot.value) queryParams['hot'] = 'true';

      // Only apply price filter if they moved the sliders from default
      if (minPrice.value > 0)
        queryParams['min_price'] = minPrice.value.toString();
      if (maxPrice.value < 10000)
        queryParams['max_price'] = maxPrice.value.toString();

      // Dio automatically handles List<String> by passing multiple parameters
      // e.g., ?category=electronics&category=phones
      if (selectedCategories.isNotEmpty) {
        queryParams['category'] = selectedCategories.toList();
      }
      if (selectedBrands.isNotEmpty) {
        queryParams['brand'] = selectedBrands.toList();
      }

      // 2. Fetch Data
      var response = await BasicProvider("products")
          .getRequest(queryParams: queryParams)
          .catchError(handleError);

      // 3. Parse Response
      if (response != null && response is Map) {
        final List newProducts =
            (response['data'] is List) ? response['data'] : [];

        if (isRefresh) {
          products.assignAll(newProducts);
        } else {
          products.addAll(newProducts);
        }

        totalProducts.value = response['total'] is int
            ? response['total']
            : int.tryParse(response['total']?.toString() ?? '') ??
                products.length;

        hasNextPage = response['hasNextPage'] == true;
      }
    } catch (e) {
      debugPrint('❌ Fetch Products Error: $e');
      if (!isRefresh) currentPage--;
    } finally {
      isLoading.value = false;
      isFetchingMore.value = false;
    }
  }

  // ─── FILTER CONTROLS ──────────────────────────────────────────
  void applySort(String by, String order) {
    sortBy.value = by;
    sortOrder.value = order;
    fetchProducts(isRefresh: true);
  }

  void toggleCategory(String slug) {
    if (selectedCategories.contains(slug)) {
      selectedCategories.remove(slug);
    } else {
      selectedCategories.add(slug);
    }
  }

  void toggleBrand(String slug) {
    if (selectedBrands.contains(slug)) {
      selectedBrands.remove(slug);
    } else {
      selectedBrands.add(slug);
    }
  }

  void clearAllFilters() {
    isFeatured.value = false;
    isHot.value = false;
    selectedCategories.clear();
    selectedBrands.clear();
    minPrice.value = 0.0;
    maxPrice.value = 10000.0;
    currentPriceRange.value = const RangeValues(0, 10000);
    sortBy.value = "created_at";
    sortOrder.value = "desc";
    fetchProducts(isRefresh: true);
  }
}
