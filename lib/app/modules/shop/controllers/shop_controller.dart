import 'package:flutter/material.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/app/modules/shop/controllers/shop_attribute_filter_mixin.dart';
import '/app/modules/shop/controllers/shop_category_filter_mixin.dart';
import '/app/modules/shop/controllers/shop_category_tree_filter_mixin.dart';
import 'package:get/get.dart';

enum ShopSortOption { featured, priceLowHigh, priceHighLow, newest, trending }

// Mixin order is append-only: new mixins are added at the end of this list
// to avoid shadowing symbols declared by earlier ones. Ported from SOURCE
// (fastify-public-mobile-app-templates) as part of PORT_AUDIT.md Phase 4 —
// TARGET's controller previously had no filter mixins wired in (filter code
// was commented out); this restores that logic while keeping TARGET's own
// simpler product-grid shop entry (no CMS layout on plain entry, unlike
// SOURCE's FoduuStudioLayoutMixin usage — TARGET's ShopView is always a
// filtered product grid, never a CMS layout page).
class ShopController extends GetxController
    with
        BaseController,
        ShopCategoryFilterMixin,
        ShopAttributeFilterMixin,
        ShopCategoryTreeFilterMixin {
  // ─── STATE VARIABLES ──────────────────────────────────────────
  var products = [].obs;
  var isLoading = true.obs;
  var isFetchingMore = false.obs;
  var isBrandsLoading = false.obs;
  var isCategoriesLoading = false.obs;
  var totalProducts = 0.obs;

  var availableBrands = [].obs;
  var availableCategories = [].obs;

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
  var isRecentlyViewed = false.obs;

  // Price Range
  var currentPriceRange = const RangeValues(0, 10000).obs;
  var minPrice = 0.0.obs;
  var maxPrice = 10000.0.obs;

  // Arrays for multi-select (Using Sets to prevent duplicates)
  var selectedCategories = <String>{}.obs;
  var selectedBrands = <String>{}.obs;

  // Sort By (header dropdown)
  var selectedSortOption = ShopSortOption.newest.obs;

  String get sortLabel {
    switch (selectedSortOption.value) {
      case ShopSortOption.featured:
        return "Featured";
      case ShopSortOption.priceLowHigh:
        return "Price: Low to High";
      case ShopSortOption.priceHighLow:
        return "Price: High to Low";
      case ShopSortOption.newest:
        return "Newest";
      case ShopSortOption.trending:
        return "Trending";
    }
  }

  int _fetchRequestToken = 0;

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

    fetchBrands();
    fetchCategories();
    fetchProducts(isRefresh: true);
  }

  void ensureFilterDataLoaded() {
    if (availableBrands.isEmpty && !isBrandsLoading.value) {
      fetchBrands();
    }
    if (availableCategories.isEmpty && !isCategoriesLoading.value) {
      fetchCategories();
    }
  }

  void _parseArguments() {
    dynamic args = Get.arguments;
    if (args != null && args is Map) {
      if (args['shopArguments'] != null) {
        args = args['shopArguments'];
      }
      applyArguments(args);
    }
  }

  void applyArguments(dynamic arguments) {
    if (arguments == null || arguments is! Map) return;

    // Reset current filters without triggering multiple network calls
    isFeatured.value = false;
    isHot.value = false;
    isTrending.value = false;
    isRecommended.value = false;
    isRecentlyViewed.value = false;
    selectedCategories.clear();
    selectedBrands.clear();
    selectedAttributes.clear();
    filterCurrentCategories.clear();
    minPrice.value = 0.0;
    maxPrice.value = 10000.0;
    currentPriceRange.value = const RangeValues(0, 10000);
    sortBy.value = "created_at";
    sortOrder.value = "desc";
    selectedSortOption.value = ShopSortOption.newest;

    final args = arguments;
    collectionName.value = args['name'] ?? "Shop";

    // TARGET's older args shape used 'categoryId'; keep accepting it
    // alongside SOURCE's 'categorySlug' so existing callers keep working.
    if (args['source'] == 'category' && args['children'] != null) {
      final slug = args['categorySlug'] ?? args['categoryId'];
      if (slug != null) {
        selectedCategories.add(slug.toString());
      }
      final rawChildren = args['children'];
      filterCurrentCategories.assignAll(rawChildren is List ? rawChildren : []);
    } else if (args['source'] == 'category' &&
        (args['categorySlug'] != null || args['categoryId'] != null) &&
        args['children'] == null) {
      final slug = (args['categorySlug'] ?? args['categoryId']).toString();
      selectedCategories.add(slug);
      fetchCategoryBySlug(slug).then((cat) {
        if (cat != null) {
          final children = cat['children'];
          if (children is List && children.isNotEmpty) {
            filterCurrentCategories.assignAll(children);
          }
        }
      });
    } else if (args['source'] == 'brand' && args['brandId'] != null) {
      selectedBrands.add(args['brandId'].toString());
    } else if (args['source'] == 'dashboard' && args['filterType'] != null) {
      final filterType = args['filterType'].toString();
      if (filterType == 'featured_products') {
        isFeatured.value = true;
        collectionName.value = args['name'] ?? "Featured Products";
      } else if (filterType == 'trending_products') {
        isTrending.value = true;
        collectionName.value = args['name'] ?? "Trending Products";
      } else if (filterType == 'recommended_products') {
        isRecommended.value = true;
        collectionName.value = args['name'] ?? "Recommended Products";
      } else if (filterType == 'recently_viewed') {
        isRecentlyViewed.value = true;
        collectionName.value = args['name'] ?? "Recently Viewed";
      }
    }

    ensureFilterDataLoaded();
    fetchProducts(isRefresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    categorySearchController.dispose();
    disposeAttributeFilterControllers();
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
    final requestToken = isRefresh ? ++_fetchRequestToken : _fetchRequestToken;
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
      if (isRecentlyViewed.value) queryParams['recently_viewed'] = 'true';

      if (minPrice.value > 0) {
        queryParams['min_price'] = minPrice.value.toStringAsFixed(0);
      }
      if (maxPrice.value < 10000) {
        queryParams['max_price'] = maxPrice.value.toStringAsFixed(0);
      }

      // NOTE (Phase 4 TODO, see PORT_AUDIT.md 0.2/0.3): TARGET's
      // `basic_provider.dart` builds the request Uri via a straight
      // `uri.replace(queryParameters: queryParams)` without SOURCE's
      // normalization step (which stringifies every Iterable element before
      // handing it to Uri). Dart's Uri already accepts `List<String>`
      // values directly (emitting repeated `?key=a&key=b` params), and
      // selectedCategories/selectedBrands/selectedAttributes are all
      // Set<String> here, so this works today — but if a non-string
      // multi-select value is ever added, normalize it before it reaches
      // this map, since TARGET's provider won't do it.
      if (selectedCategories.isNotEmpty) {
        queryParams['category'] = selectedCategories.toList();
      }
      if (selectedBrands.isNotEmpty) {
        queryParams['brand'] = selectedBrands.toList();
      }

      final material = selectedAttributes['material'];
      if (material != null && material.isNotEmpty) {
        queryParams['material'] = material.toList();
      }
      final style = selectedAttributes['style'];
      if (style != null && style.isNotEmpty) {
        queryParams['style'] = style.toList();
      }

      debugPrint('📡 Fetching products with params: $queryParams');

      // Fetch Data
      var response = await BasicProvider("products")
          .getRequest(queryParams: queryParams)
          .catchError(handleError);

      // Drop stale responses: a faster, more recent refresh may have
      // already superseded this one.
      if (isRefresh && requestToken != _fetchRequestToken) {
        return;
      }

      if (response != null) {
        List<dynamic> newProducts = [];

        if (response is Map<String, dynamic>) {
          if (response.containsKey('data') && response['data'] is List) {
            newProducts = response['data'] as List<dynamic>;
            totalProducts.value = response['total'] ?? products.length;
            hasNextPage = response['hasNextPage'] ?? false;
          } else if (response.containsKey('products') &&
              response['products'] is List) {
            newProducts = response['products'] as List<dynamic>;
            totalProducts.value = response['total'] ?? products.length;
            hasNextPage = response['hasNextPage'] ?? false;
          } else {
            final listKey = response.keys.firstWhere(
              (k) => response[k] is List,
              orElse: () => '',
            );
            if (listKey.isNotEmpty) {
              newProducts = response[listKey] as List<dynamic>;
            }
            hasNextPage = false;
          }
        } else if (response is List<dynamic>) {
          newProducts = response;
          hasNextPage = false;
          totalProducts.value = response.length;
        }

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

  // ─── FETCH BRANDS ─────────────────────────────────────────────
  Future<void> fetchBrands() async {
    try {
      isBrandsLoading.value = true;
      var response =
          await BasicProvider("brands").getRequest().catchError(handleError);

      if (response != null && response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          availableBrands.assignAll(response['data']);
        }
      } else if (response is List) {
        availableBrands.assignAll(response);
      }
      debugPrint('✅ Loaded ${availableBrands.length} brands');
    } catch (e) {
      debugPrint('❌ Fetch Brands Error: $e');
    } finally {
      isBrandsLoading.value = false;
    }
  }

  // ─── FETCH CATEGORIES ──────────────────────────────────────────
  Future<void> fetchCategories() async {
    try {
      isCategoriesLoading.value = true;
      var response =
          await BasicProvider("category").getRequest().catchError(handleError);

      if (response != null && response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          availableCategories.assignAll(response['data']);
        } else if (response.containsKey('docs') && response['docs'] is List) {
          availableCategories.assignAll(response['docs']);
        }
      } else if (response is List) {
        availableCategories.assignAll(response);
      }
      allCategories.assignAll(availableCategories);
      debugPrint('✅ Loaded ${availableCategories.length} categories');
    } catch (e) {
      debugPrint('❌ Fetch Categories Error: $e');
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  // ─── FILTER CONTROLS ───────────────────────────────────────
  void applyFiltersAndRefresh() {
    fetchProducts(isRefresh: true);
  }

  /// Kept for older call sites (bottom-sheet sort chips) that set
  /// sortBy/sortOrder directly instead of going through [applySortOption].
  void applySort(String by, String order) {
    sortBy.value = by;
    sortOrder.value = order;
    applyFiltersAndRefresh();
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

  void toggleRecentlyViewed() {
    isRecentlyViewed.toggle();
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

  void applySortOption(ShopSortOption option) {
    isFeatured.value = false;
    isHot.value = false;
    isTrending.value = false;
    switch (option) {
      case ShopSortOption.featured:
        isFeatured.value = true;
        sortBy.value = "created_at";
        sortOrder.value = "desc";
        break;
      case ShopSortOption.priceLowHigh:
        sortBy.value = "price";
        sortOrder.value = "asc";
        break;
      case ShopSortOption.priceHighLow:
        sortBy.value = "price";
        sortOrder.value = "desc";
        break;
      case ShopSortOption.newest:
        sortBy.value = "created_at";
        sortOrder.value = "desc";
        break;
      case ShopSortOption.trending:
        isTrending.value = true;
        break;
    }
    selectedSortOption.value = option;
    applyFiltersAndRefresh();
  }

  void clearAllFilters() {
    isFeatured.value = false;
    isHot.value = false;
    isTrending.value = false;
    isRecommended.value = false;
    isRecentlyViewed.value = false;
    selectedCategories.clear();
    selectedBrands.clear();
    selectedAttributes.clear();
    minPrice.value = 0.0;
    maxPrice.value = 10000.0;
    currentPriceRange.value = const RangeValues(0, 10000);
    sortBy.value = "created_at";
    sortOrder.value = "desc";
    selectedSortOption.value = ShopSortOption.newest;
    applyFiltersAndRefresh();
  }

  bool get hasActiveFilters {
    return isFeatured.value ||
        isHot.value ||
        isTrending.value ||
        isRecommended.value ||
        isRecentlyViewed.value ||
        selectedCategories.isNotEmpty ||
        selectedBrands.isNotEmpty ||
        selectedAttributes.values.any((s) => s.isNotEmpty) ||
        minPrice.value > 0 ||
        maxPrice.value < 10000;
  }

  int get activeFilterCount {
    int count = 0;
    count += selectedCategories.length;
    count += selectedBrands.length;
    // Counted per selected value, not per attribute key — e.g. 2 selected
    // materials contribute +2, matching how selectedCategories/selectedBrands
    // are counted above.
    count += selectedAttributes.values.fold<int>(0, (sum, s) => sum + s.length);
    if (minPrice.value > 0 || maxPrice.value < 10000) count++;
    return count;
  }
}
