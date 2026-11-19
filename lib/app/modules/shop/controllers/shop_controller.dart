import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/data/category_filter_service.dart';
import 'package:foduu_ecommerce/app/modules/shop/controllers/shop_attribute_filter_mixin.dart';
import 'package:foduu_ecommerce/app/modules/shop/controllers/shop_category_filter_mixin.dart';
import 'package:foduu_ecommerce/app/modules/shop/controllers/shop_category_tree_filter_mixin.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_mixin.dart';
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

  // Search & Filter Drawer Synchronization
  var filterDrawerOpenTick = 0.obs;
  var searchQuery = "".obs;
  late TextEditingController productSearchController;
  Timer? _productSearchDebouncer;

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
    productSearchController = TextEditingController();

    _parseArguments();

    // Sync price range with min/max
    ever(currentPriceRange, (RangeValues values) {
      minPrice.value = values.start;
      maxPrice.value = values.end;
    });

    // When opened plainly (bottom-tab, no filter args), show the full
    // CMS canvas from api/mobile-app/shop.
    // When opened with filter/category args, load the filtered catalog grid.
    if (isPlainShopEntry.value) {
      ensureFilterDataLoaded();
      ensureCategoryTreeLoaded();
      fetchLayout(pageSlug);
    } else {
      fetchBrands();
      fetchCategories();
      fetchProducts(isRefresh: true);
    }
  }

  @override
  Future<dynamic> fetchLayout(String slug,
      {dynamic requestBody, bool silent = false}) async {
    final response = await super
        .fetchLayout(slug, requestBody: requestBody, silent: silent);
    _syncCmsProductMetadata();
    return response;
  }

  void _syncCmsProductMetadata() {
    final cmsJson = contentJsonFor('products');
    if (cmsJson != null) {
      final prodData = cmsJson['products'] ?? cmsJson['product'];
      if (prodData is Map) {
        final total = prodData['total'];
        if (total != null) {
          totalProducts.value =
              int.tryParse(total.toString()) ?? totalProducts.value;
        }
        final dataList = prodData['data'];
        if (dataList is List && dataList.isNotEmpty && products.isEmpty) {
          products.assignAll(dataList);
          isLoading.value = false;
        }
      }
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
    isPlainShopEntry.value = false;
    collectionName.value = args['name'] ?? "Shop";

    if (args['source'] == 'category' && args['children'] != null) {
      if (args['categorySlug'] != null) {
        selectedCategories.add(args['categorySlug']);
      }
      final rawChildren = args['children'];
      filterCurrentCategories.assignAll(rawChildren is List ? rawChildren : []);
    } else if (args['source'] == 'category' &&
        args['categorySlug'] != null &&
        args['children'] == null) {
      selectedCategories.add(args['categorySlug']);
      fetchCategoryBySlug(args['categorySlug']).then((cat) {
        if (cat != null) {
          final children = cat['children'];
          if (children is List && children.isNotEmpty) {
            filterCurrentCategories.assignAll(children);
          }
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
    _productSearchDebouncer?.cancel();
    productSearchController.dispose();
    scrollController.dispose();
    categorySearchController.dispose();
    disposeAttributeFilterControllers();
    super.onClose();
  }

  void _scrollListener() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    if (pos.maxScrollExtent > 200 &&
        pos.pixels > 80 &&
        pos.pixels >= pos.maxScrollExtent - 250) {
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

      if (searchQuery.value.trim().isNotEmpty) {
        queryParams['search'] = searchQuery.value.trim();
      }

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
        // The products endpoint distinguishes a parent category from an
        // explicit category selection. Match the conventions used by the
        // homepage products widget: parentCategory for a parent, and
        // `specific` with category IDs for selected categories.
        try {
          await ensureCategoryTreeLoaded();
        } catch (e) {
          // A category-tree outage should not prevent the product request;
          // unresolved selections use the legacy category parameter below.
          debugPrint('ℹ️ Unable to resolve product category tree: $e');
        }
        final selectedNodes = selectedCategories
            .map(_findProductCategoryNode)
            .toList(growable: false);

        if (selectedCategories.length == 1 && selectedNodes.first != null) {
          final node = selectedNodes.first!;
          if (node.children.isNotEmpty) {
            queryParams['parentCategory'] =
                node.slug.isNotEmpty ? node.slug : node.id;
          } else if (node.id.isNotEmpty) {
            queryParams['specific'] = [node.id];
          } else {
            queryParams['category'] = selectedCategories.toList();
          }
        } else if (selectedNodes
            .every((node) => node != null && node.id.isNotEmpty)) {
          queryParams['specific'] =
              selectedNodes.map((node) => node!.id).toList();
        } else {
          // Preserve legacy behavior when the category tree cannot resolve a
          // value (for example, a stale deep link or an unavailable tree API).
          queryParams['category'] = selectedCategories.toList();
        }
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

      // ✅ Parse Response correctly
      if (response != null) {
        List<dynamic> newProducts = [];

        // Check if response is a Map (paginated response)
        if (response is Map) {
          final resMap = Map<String, dynamic>.from(response);

          if (resMap.containsKey('data') && resMap['data'] is List) {
            newProducts = List<dynamic>.from(resMap['data']);
            totalProducts.value = int.tryParse(resMap['total']?.toString() ?? '') ??
                totalProducts.value;
            hasNextPage = resMap['hasNextPage'] == true;
          } else if (resMap.containsKey('data') && resMap['data'] is Map) {
            final innerData = Map<String, dynamic>.from(resMap['data']);
            if (innerData['data'] is List) {
              newProducts = List<dynamic>.from(innerData['data']);
            }
            totalProducts.value = int.tryParse(innerData['total']?.toString() ?? '') ??
                totalProducts.value;
            hasNextPage = innerData['hasNextPage'] == true;
          } else if (resMap.containsKey('products') &&
              resMap['products'] is List) {
            newProducts = List<dynamic>.from(resMap['products']);
            totalProducts.value = int.tryParse(resMap['total']?.toString() ?? '') ??
                totalProducts.value;
            hasNextPage = resMap['hasNextPage'] == true;
          } else {
            final listKey = resMap.keys.firstWhere(
              (k) => resMap[k] is List,
              orElse: () => '',
            );
            if (listKey.isNotEmpty) {
              newProducts = List<dynamic>.from(resMap[listKey]);
            }
            hasNextPage = false;
          }
        }
        // If response is directly a List
        else if (response is List) {
          newProducts = List<dynamic>.from(response);
          hasNextPage = false;
          totalProducts.value = newProducts.length;
        }

        // ✅ Apply products to the list
        if (isRefresh) {
          products.assignAll(newProducts);
        } else {
          products.addAll(newProducts);
        }

        _adjustMinPriceBoundFromProducts();

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

  CategoryTreeNode? _findProductCategoryNode(String slug) {
    CategoryTreeNode? find(List<CategoryTreeNode> nodes) {
      for (final node in nodes) {
        if (node.slug == slug || node.id == slug) return node;
        final child = find(node.children);
        if (child != null) return child;
      }
      return null;
    }

    return find(categoryTreeByType['product'] ?? const <CategoryTreeNode>[]);
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
      prefetchCounts(availableCategories);
      debugPrint('✅ Loaded ${availableCategories.length} categories');
    } catch (e) {
      debugPrint('❌ Fetch Categories Error: $e');
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  // ─── SEARCH & PREFETCH CONTROLS ─────────────────────────────
  void onProductSearchChanged(String value) {
    _productSearchDebouncer?.cancel();
    _productSearchDebouncer = Timer(const Duration(milliseconds: 400), () {
      final q = value.trim();
      if (q == searchQuery.value) return;
      searchQuery.value = q;
      isPlainShopEntry.value = false;
      applyFiltersAndRefresh();
    });
  }

  void clearProductSearch() {
    _productSearchDebouncer?.cancel();
    productSearchController.clear();
    if (searchQuery.value.isEmpty) return;
    searchQuery.value = "";
    applyFiltersAndRefresh();
  }

  String formatPriceForInput(double val) {
    final formattedStr = val.toStringAsFixed(2);
    if (formattedStr.endsWith('.00')) {
      return val.round().toString();
    }
    return formattedStr;
  }

  void _adjustMinPriceBoundFromProducts() {
    if (products.isEmpty) return;
    double? lowestEffective;
    double? highestEffective;
    for (var p in products) {
      if (p is! Map) continue;
      final variants = (p['variants'] ?? p['variant_ids'] ?? []) as List;
      final pPrice = double.tryParse(p['price']?.toString() ?? '');
      final pSale = double.tryParse(p['sale_price']?.toString() ?? '');
      double eff = (pSale != null && pSale > 0) ? pSale : (pPrice ?? 0);
      for (var v in variants) {
        if (v is Map) {
          final vP = double.tryParse(v['price']?.toString() ?? '') ?? 0;
          final vSP = double.tryParse(v['sale_price']?.toString() ?? '');
          final vEff = (vSP != null && vSP > 0) ? vSP : vP;
          if (vEff > 0 && (lowestEffective == null || vEff < lowestEffective)) {
            lowestEffective = vEff;
          }
          if (vEff > (highestEffective ?? 0)) {
            highestEffective = vEff;
          }
        }
      }
      if (eff > 0 && (lowestEffective == null || eff < lowestEffective)) {
        lowestEffective = eff;
      }
      if (eff > (highestEffective ?? 0)) {
        highestEffective = eff;
      }
    }
    if (lowestEffective != null && lowestEffective < absoluteMinPrice.value) {
      absoluteMinPrice.value = lowestEffective;
    }
    if (highestEffective != null && highestEffective > absoluteMaxPrice.value) {
      absoluteMaxPrice.value = highestEffective;
    }
  }

  void prefetchCounts(List<dynamic> cats) {
    for (final cat in cats) {
      if (cat is! Map) continue;
      final slug = cat['slug']?.toString() ?? cat['_id']?.toString() ?? '';
      if (slug.isEmpty || categoryCountCache.containsKey(slug)) continue;
      isCountLoading[slug] = true;
      isCountLoading.refresh();

      final Map<String, dynamic> params = {
        'count': '1',
        'category': slug,
      };

      BasicProvider("products").getRequest(queryParams: params).then((response) {
        if (response != null && response is Map) {
          int count = 0;
          if (response['total'] != null) {
            count = int.tryParse(response['total'].toString()) ?? 0;
          } else if (response['data'] is Map && response['data']['total'] != null) {
            count = int.tryParse(response['data']['total'].toString()) ?? 0;
          }
          categoryCountCache[slug] = count;
          categoryCountCache.refresh();
        }
        isCountLoading.remove(slug);
        isCountLoading.refresh();
      }).catchError((_) {
        isCountLoading.remove(slug);
        isCountLoading.refresh();
      });
    }
  }

  // ─── VIEW MODE CONTROLS ───────────────────────────────────────
  void setViewMode(bool isList) {
    if (isListView.value == isList && !isPlainShopEntry.value) return;

    isListView.value = isList;

    if (isPlainShopEntry.value) {
      isPlainShopEntry.value = false;
      ensureFilterDataLoaded();
      fetchProducts(isRefresh: true);
    } else if (products.isEmpty && !isLoading.value) {
      fetchProducts(isRefresh: true);
    }
  }

  // ─── FILTER CONTROLS ───────────────────────────────────────
  void applyFiltersAndRefresh() {
    // Applying filters exits the CMS canvas and shows the filtered grid.
    if (isPlainShopEntry.value) {
      isPlainShopEntry.value = false;
      ensureFilterDataLoaded();
    }
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
    searchQuery.value = "";
    productSearchController.clear();
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
    return searchQuery.value.isNotEmpty ||
        isFeatured.value ||
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
    if (searchQuery.value.isNotEmpty) count++;
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
