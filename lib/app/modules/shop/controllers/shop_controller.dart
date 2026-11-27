import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/shop/controllers/shop_attribute_filter_mixin.dart';
import 'package:foduu_ecommerce/app/modules/shop/controllers/shop_category_filter_mixin.dart';
import 'package:foduu_ecommerce/app/modules/shop/controllers/shop_category_tree_filter_mixin.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_mixin.dart';
import 'package:foduu_ecommerce/services/product_pagination.dart';
import 'package:get/get.dart';

enum ShopSortOption { featured, priceLowHigh, priceHighLow, newest, trending }

// Mixin order is append-only: new mixins are added at the end of this list
// to avoid shadowing symbols declared by earlier ones.
class ShopController extends GetxController
    with
        BaseController,
        ShopCategoryFilterMixin,
        ShopAttributeFilterMixin,
        FoduuStudioLayoutMixin,
        ShopCategoryTreeFilterMixin {
  static const String pageSlug = 'shop';

  /// True when ShopView was opened plainly (bottom-tab entry, no filter
  /// args) — renders the CMS dynamic layout instead of the filtered grid.
  var isPlainShopEntry = true.obs;

  /// Layout toggle: false = 2-column grid, true = 1-column list
  var isListView = false.obs;
  // ─── STATE VARIABLES ──────────────────────────────────────────
  var products = [].obs;
  var isLoading = true.obs;
  var isFetchingMore = false.obs;
  var isBrandsLoading = false.obs;
  var isCategoriesLoading = false.obs;
  var totalProducts = 0.obs;
  final productsError = ''.obs;
  final paginationError = ''.obs;

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

  // Arrays for multi-select
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

    // Load the CMS shop sections for both plain Shop entry and filtered
    // collections. ShopView keeps promotional sections above the product list.
    fetchLayout(pageSlug);

    if (!isPlainShopEntry.value) {
      fetchBrands();
      fetchCategories();
      fetchProducts(isRefresh: true);
    }
  }

  void ensureFilterDataLoaded() {
    if (availableBrands.isEmpty && !isBrandsLoading.value) {
      fetchBrands();
    }
    if (availableCategories.isEmpty && !isCategoriesLoading.value) {
      fetchCategories();
    }
  }

  /// Restore the CMS Shop tab after Studio routes back to the Shop tab.
  void resetToPlainShop() {
    clearAllFilters();
    // clearAllFilters refreshes the filtered catalog; override its mode switch
    // after clearing so the Studio Shop canvas is the visible destination.
    isPlainShopEntry.value = true;
    isListView.value = false;
    collectionName.value = 'Shop';
    filterCategoryStack.clear();
    filterRootCategories.clear();
    filterCurrentCategories.clear();
    fetchLayout(pageSlug);
  }

  void _syncCmsProductMetadata() {
    if (!isPlainShopEntry.value) return;
    final cmsJson = contentJsonFor('products');
    if (cmsJson == null) return;
    final raw = cmsJson['products'] ?? cmsJson['product'];
    if (raw is! Map) return;
    final total = raw['total'];
    if (total != null) {
      totalProducts.value =
          int.tryParse(total.toString()) ?? totalProducts.value;
    }
    final data = raw['data'];
    if (products.isEmpty && data is List && data.isNotEmpty) {
      products.assignAll(data);
      isLoading.value = false;
    }
  }

  @override
  void buildLayout(List sections) {
    super.buildLayout(sections);
    _syncCmsProductMetadata();
  }

  @override
  Future<dynamic> fetchLayout(String slug,
      {dynamic requestBody, bool silent = false}) async {
    final result =
        await super.fetchLayout(slug, requestBody: requestBody, silent: silent);
    _syncCmsProductMetadata();
    return result;
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
    filterCategoryStack.clear();
    filterRootCategories.clear();
    filterCurrentCategories.clear();
    minPrice.value = 0.0;
    maxPrice.value = 10000.0;
    currentPriceRange.value = const RangeValues(0, 10000);
    sortBy.value = "created_at";
    sortOrder.value = "desc";
    selectedSortOption.value = ShopSortOption.newest;

    final args = arguments;
    isPlainShopEntry.value = false;
    collectionName.value = args['name'] ?? "Shop";

    if (args['source'] == 'category' && args['children'] != null) {
      if (args['categorySlug'] != null) {
        selectedCategories.add(args['categorySlug']);
      }
      final rawChildren = args['children'];
      seedCategoryContext({'children': rawChildren});
    } else if (args['source'] == 'category' &&
        args['categorySlug'] != null &&
        args['children'] == null) {
      selectedCategories.add(args['categorySlug']);
      fetchCategoryBySlug(args['categorySlug']).then((cat) {
        if (cat != null) {
          seedCategoryContext(cat);
        }
      });
    } else if (args['source'] == 'brand' && args['brandId'] != null) {
      selectedBrands.add(args['brandId']);
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
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    if (position.maxScrollExtent > 200 &&
        position.pixels > 80 &&
        position.pixels >= position.maxScrollExtent - 250) {
      if (!isFetchingMore.value && hasNextPage && !isLoading.value) {
        fetchProducts(isRefresh: false);
      }
    }
  }

  // ─── THE CORE API FETCH ───────────────────────────────────────
  Future<void> fetchProducts({required bool isRefresh}) async {
    if (!isRefresh && (isFetchingMore.value || isLoading.value)) return;
    final requestToken = isRefresh ? ++_fetchRequestToken : _fetchRequestToken;
    final requestedPage = isRefresh ? 1 : currentPage;
    try {
      if (isRefresh) {
        isLoading.value = true;
        isFetchingMore.value = false;
        productsError.value = '';
        paginationError.value = '';
        currentPage = 1;
        hasNextPage = false;
        products.clear();
      } else {
        isFetchingMore.value = true;
        paginationError.value = '';
      }

      // Build Query Parameters
      Map<String, dynamic> queryParams = {
        'page': requestedPage.toString(),
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
      if (requestToken != _fetchRequestToken) return;

      if (response == null) {
        throw StateError('The products response was empty.');
      }

      List<dynamic> newProducts = [];
      if (response is Map) {
        final candidate = response['data'] ??
            response['products'] ??
            response['product'] ??
            response['docs'];
        if (candidate is List) {
          newProducts = candidate;
          totalProducts.value = int.tryParse(
                '${response['total'] ?? response['totalDocs'] ?? ''}',
              ) ??
              (isRefresh
                  ? newProducts.length
                  : products.length + newProducts.length);
          hasNextPage = ProductPagination.hasMore(
            response,
            itemCount: newProducts.length,
            pageSize: 10,
          );
          currentPage = ProductPagination.nextPage(
            response,
            defaultPage: requestedPage + 1,
          );
        } else {
          final listKey = response.keys.cast<dynamic>().firstWhere(
                (key) => response[key] is List,
                orElse: () => null,
              );
          if (listKey != null) newProducts = response[listKey] as List;
          hasNextPage = false;
          currentPage = requestedPage + 1;
          totalProducts.value = isRefresh
              ? newProducts.length
              : products.length + newProducts.length;
        }
      } else if (response is List) {
        newProducts = response;
        hasNextPage = false;
        currentPage = requestedPage + 1;
        totalProducts.value =
            isRefresh ? response.length : products.length + response.length;
      } else {
        throw StateError('The products response has an unsupported shape.');
      }

      if (isRefresh) {
        products.assignAll(ProductPagination.uniquePage([], newProducts));
      } else {
        products.addAll(ProductPagination.uniquePage(products, newProducts));
      }

      debugPrint(
          '✅ Loaded ${newProducts.length} products, total: ${products.length}, hasNextPage: $hasNextPage');
    } catch (e) {
      debugPrint('❌ Fetch Products Error: $e');
      if (requestToken == _fetchRequestToken) {
        if (isRefresh) {
          productsError.value = e.toString();
          hasNextPage = false;
        } else {
          paginationError.value = e.toString();
        }
      }
    } finally {
      if (requestToken == _fetchRequestToken) {
        isLoading.value = false;
        isFetchingMore.value = false;
      }
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

  // ─── VIEW MODE CONTROLS ───────────────────────────────────────
  void setViewMode(bool isList) {
    if (isListView.value == isList) return;
    final wasPlainShop = isPlainShopEntry.value;
    isListView.value = isList;
    if (wasPlainShop && isList) {
      // CMS product sections may contain only a preloaded slice. Fetch the
      // catalog API on list entry so regular pagination is available.
      ensureFilterDataLoaded();
      fetchProducts(isRefresh: true);
    } else if (products.isEmpty && !isLoading.value) {
      ensureFilterDataLoaded();
      fetchProducts(isRefresh: true);
    }
  }

  // ─── FILTER CONTROLS ───────────────────────────────────────
  void applyFiltersAndRefresh() {
    // Any filter/sort action means the user wants the filtered product grid,
    // not the CMS layout — switch entry mode even when triggered from the
    // plain Shop tab (which never called fetchProducts on init).
    isPlainShopEntry.value = false;
    fetchProducts(isRefresh: true);
  }

  void toggleFeatured() {
    isFeatured.toggle();
    applyFiltersAndRefresh();
  }

  void removeFeaturedFilter() {
    isFeatured.value = false;
    if (selectedSortOption.value == ShopSortOption.featured) {
      selectedSortOption.value = ShopSortOption.newest;
      sortBy.value = 'created_at';
      sortOrder.value = 'desc';
    }
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

  void removeTrendingFilter() {
    isTrending.value = false;
    if (selectedSortOption.value == ShopSortOption.trending) {
      selectedSortOption.value = ShopSortOption.newest;
      sortBy.value = 'created_at';
      sortOrder.value = 'desc';
    }
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

  void clearPriceFilter() {
    currentPriceRange.value = const RangeValues(0, 10000);
    minPrice.value = 0;
    maxPrice.value = 10000;
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
        minPrice.value > 0 ||
        maxPrice.value < 10000 ||
        sortBy.value != "created_at";
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
