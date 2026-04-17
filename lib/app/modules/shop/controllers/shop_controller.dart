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
  var isTrending = false.obs;
  var isRecommended = false.obs;

  // Price Range
  var currentPriceRange = const RangeValues(0, 10000).obs;
  var minPrice = 0.0.obs;
  var maxPrice = 10000.0.obs;

  // Arrays for multi-select
  var selectedCategories = <String>{}.obs;
  var selectedBrands = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);

    _parseArguments();

    // Sync price range with min/max
    ever(currentPriceRange, (RangeValues values) {
      minPrice.value = values.start;
      maxPrice.value = values.end;
    });

    fetchProducts(isRefresh: true);
  }

  void _parseArguments() {
    if (Get.arguments != null) {
      final args = Get.arguments as Map;
      collectionName.value = args['name'] ?? "Shop";

      if (args['source'] == 'category' && args['categorySlug'] != null) {
        print("category slug ${args['categorySlug']}");
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
      if (!isFetchingMore.value && hasNextPage && !isLoading.value) {
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
        hasNextPage = false;
        products.clear();
      } else {
        if (isFetchingMore.value) return;
        isFetchingMore.value = true;
        currentPage++;
      }

      // Build Query Parameters
      Map<String, dynamic> queryParams = {
        'page': currentPage.toString(),
        'count': '10',
      };

      if (sortBy.value.isNotEmpty) {
        queryParams['sort_by'] = sortBy.value;
      }
      if (sortOrder.value.isNotEmpty) {
        queryParams['sort_order'] = sortOrder.value;
      }

      if (isFeatured.value) queryParams['featured'] = 'true';
      if (isHot.value) queryParams['hot'] = 'true';
      if (isTrending.value) queryParams['trending'] = 'true';
      if (isRecommended.value) queryParams['recommended'] = 'true';

      if (minPrice.value > 0) {
        queryParams['min_price'] = minPrice.value.toStringAsFixed(0);
      }
      if (maxPrice.value < 10000) {
        queryParams['max_price'] = maxPrice.value.toStringAsFixed(0);
      }

      if (selectedCategories.isNotEmpty) {
        queryParams['category'] = selectedCategories.toList();
      }
      if (selectedBrands.isNotEmpty) {
        queryParams['brand'] = selectedBrands.toList();
      }

      debugPrint('📡 Fetching products with params: $queryParams');

      // Fetch Data
      var response = await BasicProvider("products")
          .getRequest(queryParams: queryParams)
          .catchError(handleError);

      // ✅ FIXED: Parse Response correctly
      if (response != null) {
        List<dynamic> newProducts = [];

        // Check if response is a Map (paginated response)
        if (response is Map<String, dynamic>) {
          // Extract data array from the response map
          if (response.containsKey('data') && response['data'] is List) {
            newProducts = response['data'] as List<dynamic>;
            totalProducts.value = response['total'] ?? products.length;
            hasNextPage = response['hasNextPage'] ?? false;
          }
          // If response has products directly without data wrapper
          else if (response.containsKey('products') &&
              response['products'] is List) {
            newProducts = response['products'] as List<dynamic>;
            totalProducts.value = response['total'] ?? products.length;
            hasNextPage = response['hasNextPage'] ?? false;
          }
          // If response is just a map but not paginated
          else {
            // Try to find any List in the response
            final listKey = response.keys.firstWhere(
              (k) => response[k] is List,
              orElse: () => '',
            );
            if (listKey.isNotEmpty) {
              newProducts = response[listKey] as List<dynamic>;
            }
            hasNextPage = false;
          }
        }
        // If response is directly a List
        else if (response is List<dynamic>) {
          newProducts = response;
          hasNextPage = false;
          totalProducts.value = response.length;
        }

        // ✅ Apply products to the list
        if (isRefresh) {
          products.assignAll(newProducts);
        } else {
          products.addAll(newProducts);
        }

        debugPrint(
            '✅ Loaded ${newProducts.length} products, total: ${products.length}, hasNextPage: $hasNextPage');
      }
    } catch (e) {
      debugPrint('❌ Fetch Products Error: $e');
      if (!isRefresh && currentPage > 1) {
        currentPage--;
      }
    } finally {
      isLoading.value = false;
      isFetchingMore.value = false;
    }
  }

  // ─── FILTER CONTROLS ───────────────────────────────────────
  void applyFiltersAndRefresh() {
    fetchProducts(isRefresh: true);
  }

  void toggleFeatured() {
    isFeatured.toggle();
    applyFiltersAndRefresh();
  }

  void toggleHot() {
    isHot.toggle();
    applyFiltersAndRefresh();
  }

  void toggleTrending() {
    isTrending.toggle();
    applyFiltersAndRefresh();
  }

  void toggleRecommended() {
    isRecommended.toggle();
    applyFiltersAndRefresh();
  }

  void toggleCategory(String slug) {
    if (selectedCategories.contains(slug)) {
      selectedCategories.remove(slug);
    } else {
      selectedCategories.add(slug);
    }
    applyFiltersAndRefresh();
  }

  void toggleBrand(String slug) {
    if (selectedBrands.contains(slug)) {
      selectedBrands.remove(slug);
    } else {
      selectedBrands.add(slug);
    }
    applyFiltersAndRefresh();
  }

  void updatePriceRange(RangeValues values) {
    currentPriceRange.value = values;
    minPrice.value = values.start;
    maxPrice.value = values.end;
    applyFiltersAndRefresh();
  }

  void updateSort(String by, String order) {
    sortBy.value = by;
    sortOrder.value = order;
    applyFiltersAndRefresh();
  }

  void clearAllFilters() {
    isFeatured.value = false;
    isHot.value = false;
    isTrending.value = false;
    isRecommended.value = false;
    selectedCategories.clear();
    selectedBrands.clear();
    minPrice.value = 0.0;
    maxPrice.value = 10000.0;
    currentPriceRange.value = const RangeValues(0, 10000);
    sortBy.value = "created_at";
    sortOrder.value = "desc";
    applyFiltersAndRefresh();
  }

  bool get hasActiveFilters {
    return isFeatured.value ||
        isHot.value ||
        isTrending.value ||
        isRecommended.value ||
        selectedCategories.isNotEmpty ||
        selectedBrands.isNotEmpty ||
        minPrice.value > 0 ||
        maxPrice.value < 10000 ||
        sortBy.value != "created_at";
  }

  int get activeFilterCount {
    int count = 0;
    if (isFeatured.value) count++;
    if (isHot.value) count++;
    if (isTrending.value) count++;
    if (isRecommended.value) count++;
    count += selectedCategories.length;
    count += selectedBrands.length;
    if (minPrice.value > 0 || maxPrice.value < 10000) count++;
    if (sortBy.value != "created_at") count++;
    return count;
  }
}
