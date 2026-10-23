import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/data/category_filter_service.dart';
import 'package:get/get.dart';

class ShopController extends GetxController with BaseController {
  final box = GetStorage();
  // ─── STATE VARIABLES ──────────────────────────────────────────
  var products = [].obs;
  var isLoading = true.obs;
  var isFetchingMore = false.obs;
  var isBrandsLoading = false.obs;
  var isCategoriesLoading = false.obs;
  var totalProducts = 0.obs;

  var availableBrands = [].obs;
  var availableCategories = [].obs;
  var allCategories = [].obs;

  late ScrollController scrollController;
  int currentPage = 1;
  bool hasNextPage = false;

  // ─── ACTIVE FILTERS & SORTING ─────────────────────────────────
  var collectionName = "All Products".obs;

  // Sorting
  var sortBy = "created_at".obs;
  var sortOrder = "desc".obs;

  // Booleans
  var isBackToSchool = false.obs;
  var isSeasonalItems = false.obs;
  var isWeeklyTopHighlights = false.obs;
  var isTodaysTopPick = false.obs;
  var isRecommended = false.obs;

  // Price Range
  var currentPriceRange = const RangeValues(100, 5000).obs;
  var minPrice = 100.0.obs;
  var maxPrice = 5000.0.obs;
  var absoluteMinPrice = 100.0.obs;
  var absoluteMaxPrice = 5000.0.obs;
  var isLoadingBounds = false.obs;
  late TextEditingController minPriceTextController;
  late TextEditingController maxPriceTextController;

  // Arrays for multi-select
  var selectedCategories = <String>{}.obs;
  // Slug of a parent category (e.g. a drawer featured collection). Its products
  // live under child categories, so it must be sent as `parentCategory`.
  final parentCategoryFilter = ''.obs;
  var selectedBrands = <String>{}.obs;

  // Dynamic Attributes
  var availableAttributes = <String, List<dynamic>>{}.obs;
  var selectedAttributes = <String, Set<String>>{}.obs;
  var isAttributesLoading = false.obs;
  var visibleAttributeCount = <String, int>{}.obs;

  // Context-aware attributes and brands (filtered to selected category)
  var contextAttributes = <String, List<dynamic>>{}.obs;
  var contextBrands = [].obs;

  // Unified Filter Data Caching
  var filterDataCategories = <dynamic>[].obs;
  var filterDataBrands = <dynamic>[].obs;
  var filterDataPriceRange = <String, dynamic>{}.obs;
  var filterDataProductFilters = <dynamic>[].obs;
  var isFilterDataLoading = false.obs;

  // Base-to-display currency exchange rate (min/max price fields are stored
  // and sent to the backend in base currency; this only converts for display).
  double get _currencyRate {
    if (Get.isRegistered<CurrencyController>()) {
      final selected = Get.find<CurrencyController>().selectedCurrency;
      if (selected.isNotEmpty && selected['exchange_rate'] != null) {
        return double.tryParse(selected['exchange_rate'].toString()) ?? 1.0;
      }
    }
    return 1.0;
  }

  double? _parseNumberDecimal(dynamic val) {
    if (val == null) return null;
    if (val is Map) {
      return double.tryParse(val['\$numberDecimal']?.toString() ?? '');
    }
    return double.tryParse(val.toString());
  }

  // Search & expansion state for Filter Page
  var categorySearchQuery = "".obs;
  var brandSearchQuery = "".obs;

  late TextEditingController categorySearchController;
  late TextEditingController brandSearchController;

  // ─── CATEGORY / MATERIAL / STYLE TREES (filter drawer) ───────
  // Backed by `category/get-category-types` and `category/get-tree/{type}`.
  static const _kCategoryTreeTypes = [
    'product'
  ]; // instead of 'style', 'material' and 'product'
  final _categoryFilterService = CategoryFilterService();
  final categoryTypes = <String>[].obs;
  final categoryTreeByType = <String, List<CategoryTreeNode>>{}.obs;
  final categoryTreeErrorByType = <String, bool>{}.obs;
  var isCategoryTreeLoading = false.obs;
  final _loadedTreeTypes = <String>{};

  /// Bumped every time the filter drawer opens so it can re-seed its staged
  /// selections from the live filters.
  var filterDrawerOpenTick = 0.obs;

  // Product search (shop hero search bar)
  var searchQuery = "".obs;
  late TextEditingController productSearchController;
  Timer? _productSearchDebouncer;

  Timer? _categoryDebouncer;
  Timer? _brandDebouncer;
  Timer? _filterDebouncer;
  bool _pendingResetSelection = false;
  bool _pendingCategoryChanged = false;

  final _categorySearchCache = <String, List<Map<String, dynamic>>>{};

  var isCategoriesDropdownExpanded = false.obs;
  var isBrandsDropdownExpanded = false.obs;
  var expandedAttributes = <String, bool>{}.obs;

  // ─── FILTER PAGE CATEGORY BROWSE STATE ───────────────────────
  var filterCategoryStack = <Map<String, dynamic>>[].obs;
  var filterCurrentCategories = <Map<String, dynamic>>[].obs;
  var categoryCountCache = <String, int>{}.obs;
  var isCountLoading = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);

    minPriceTextController = TextEditingController();
    maxPriceTextController = TextEditingController();

    categorySearchController = TextEditingController();
    brandSearchController = TextEditingController();
    productSearchController = TextEditingController();

    categorySearchController.addListener(() {
      _categoryDebouncer?.cancel();
      _categoryDebouncer = Timer(const Duration(milliseconds: 300), () {
        categorySearchQuery.value = categorySearchController.text;
      });
    });

    brandSearchController.addListener(() {
      _brandDebouncer?.cancel();
      _brandDebouncer = Timer(const Duration(milliseconds: 300), () {
        brandSearchQuery.value = brandSearchController.text;
      });
    });

    _parseArguments();

    // Sync price range with min/max
    ever(currentPriceRange, (RangeValues values) {
      minPrice.value = values.start;
      maxPrice.value = values.end;
      final displayMin = formatPriceForInput(values.start);
      final displayMax = formatPriceForInput(values.end);
      if (minPriceTextController.text != displayMin) {
        minPriceTextController.text = displayMin;
      }
      if (maxPriceTextController.text != displayMax) {
        maxPriceTextController.text = displayMax;
      }
    });

    ensureCategoriesLoaded();
    fetchPriceRangeBounds(resetSelection: true);
    fetchProducts(isRefresh: true);
  }

  void applyArguments(dynamic arguments, {bool refresh = true}) {
    if (arguments == null) return;
    resetFiltersOnly();

    if (arguments is Map) {
      collectionName.value = arguments['name'] ?? "Shop";

      if (arguments['source'] == 'category' ||
          arguments['source'] == 'featured_collections' ||
          arguments['categorySlug'] != null ||
          arguments['category'] != null ||
          arguments['id'] != null) {
        final slug = arguments['categorySlug'] ??
            arguments['slug'] ??
            arguments['category'] ??
            arguments['id'] ??
            arguments['productId'];
        if (slug != null && slug.toString().isNotEmpty) {
          final s = slug.toString();
          selectedCategories.add(s);
          if (arguments['source'] == 'featured_collections' ||
              isParentCategory(s)) {
            parentCategoryFilter.value = s;
          }
        }
      }

      if (arguments['source'] == 'brand' && arguments['brandId'] != null) {
        selectedBrands.add(arguments['brandId']);
      } else if (arguments['source'] == 'dashboard') {
        String productType =
            arguments['productType'] ?? arguments['productype'] ?? '';
        if (productType == 'popular_products' ||
            productType == 'weekly_top_highlights' ||
            productType == 'weekly_highlights') {
          isWeeklyTopHighlights.value = true;
        } else if (productType == 'editors-choice' ||
            productType == 'todays_top_pick' ||
            productType == 'todays-top-pick') {
          isTodaysTopPick.value = true;
        } else if (productType == 'back_to_school' ||
            productType == 'back-to-school' ||
            productType == 'backToSchool') {
          isBackToSchool.value = true;
        } else if (productType == 'seasonal' ||
            productType == 'seasonal_items' ||
            productType == 'seasonal-items') {
          isSeasonalItems.value = true;
        } else if (productType == 'recommended') {
          isRecommended.value = true;
        }
      }
    }

    initFilterCategories();

    if (refresh) {
      fetchProducts(isRefresh: true);
    }
  }

  void _parseArguments() {
    if (Get.arguments != null) {
      applyArguments(Get.arguments, refresh: false);
    }
  }

  @override
  void onClose() {
    _categoryDebouncer?.cancel();
    _brandDebouncer?.cancel();
    _filterDebouncer?.cancel();
    _productSearchDebouncer?.cancel();
    productSearchController.dispose();
    categorySearchController.dispose();
    brandSearchController.dispose();
    scrollController.dispose();
    minPriceTextController.dispose();
    maxPriceTextController.dispose();
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

  String formatPriceForInput(double val) {
    final converted = val * _currencyRate;
    final formattedStr = converted.toStringAsFixed(2);
    if (formattedStr.endsWith('.00')) {
      return converted.round().toString();
    }
    return formattedStr;
  }

  void _adjustMinPriceBoundFromProducts() {
    if (products.isEmpty) return;
    double? lowestEffective;
    for (var p in products) {
      if (p is! Map) continue;
      final variants = (p['variants'] ?? p['variant_ids'] ?? []) as List;
      final productType = p['type']?.toString() ?? '';
      if (productType == 'simple') {
        Map? defaultVariant;
        for (var v in variants) {
          if (v is Map && v['is_default'] == true) {
            defaultVariant = v;
            break;
          }
        }
        defaultVariant ??= (variants.isNotEmpty && variants.first is Map)
            ? variants.first as Map
            : null;
        double? pPrice;
        double? pSale;
        if (defaultVariant != null) {
          pPrice = double.tryParse(defaultVariant['price']?.toString() ?? '');
          pSale =
              double.tryParse(defaultVariant['sale_price']?.toString() ?? '');
        } else {
          pPrice = double.tryParse(p['price']?.toString() ?? '');
          pSale = double.tryParse(p['sale_price']?.toString() ?? '');
        }
        double eff = (pSale != null && pSale > 0) ? pSale : (pPrice ?? 0);
        if (eff > 0 && (lowestEffective == null || eff < lowestEffective)) {
          lowestEffective = eff;
        }
      } else {
        for (var v in variants) {
          if (v is! Map) continue;
          double vP = double.tryParse(v['price']?.toString() ?? '') ?? 0;
          double? vSP = double.tryParse(v['sale_price']?.toString() ?? '');
          double eff = (vSP != null && vSP > 0) ? vSP : vP;
          if (eff > 0 && (lowestEffective == null || eff < lowestEffective)) {
            lowestEffective = eff;
          }
        }
      }
    }

    if (lowestEffective != null && lowestEffective < absoluteMinPrice.value) {
      final oldMin = absoluteMinPrice.value;
      absoluteMinPrice.value = lowestEffective;
      if (minPrice.value == oldMin || currentPriceRange.value.start == oldMin) {
        minPrice.value = lowestEffective;
        currentPriceRange.value =
            RangeValues(lowestEffective, currentPriceRange.value.end);
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

      if (searchQuery.value.trim().isNotEmpty) {
        queryParams['search'] = searchQuery.value.trim();
      }

      if (sortBy.value.isNotEmpty) {
        queryParams['sort_by'] = sortBy.value;
      }
      if (sortOrder.value.isNotEmpty) {
        queryParams['sort_order'] = sortOrder.value;
      }

      if (isBackToSchool.value) queryParams['back_to_school'] = 'true';
      if (isSeasonalItems.value) queryParams['seasonal_items'] = 'true';
      if (isWeeklyTopHighlights.value) {
        queryParams['weekly_top_highlights'] = 'true';
      }
      if (isTodaysTopPick.value) queryParams['todays_top_pick'] = 'true';
      if (isRecommended.value) queryParams['recommended'] = 'true';

      if (minPrice.value > absoluteMinPrice.value) {
        final formattedMin = minPrice.value.toStringAsFixed(2);
        queryParams['min_price'] = formattedMin.endsWith('.00')
            ? minPrice.value.toStringAsFixed(0)
            : formattedMin;
      }
      if (maxPrice.value < absoluteMaxPrice.value) {
        final formattedMax = maxPrice.value.toStringAsFixed(2);
        queryParams['max_price'] = formattedMax.endsWith('.00')
            ? maxPrice.value.toStringAsFixed(0)
            : formattedMax;
      }

      String effectiveParentCategory = parentCategoryFilter.value;
      if (effectiveParentCategory.isEmpty && selectedCategories.isNotEmpty) {
        effectiveParentCategory =
            resolveParentCategory(selectedCategories) ?? '';
      }

      if (effectiveParentCategory.isNotEmpty) {
        queryParams['parentCategory'] = effectiveParentCategory;
      } else if (selectedCategories.isNotEmpty) {
        if (selectedCategories.length == 1) {
          queryParams['category'] = selectedCategories.first;
        } else {
          queryParams['category'] = selectedCategories.toList();
        }
      }
      if (selectedBrands.isNotEmpty) {
        queryParams['brand'] = selectedBrands.toList();
      }

      selectedAttributes.forEach((key, values) {
        if (values.isNotEmpty) {
          if (values.length == 1) {
            queryParams[key.toLowerCase()] = values.first;
          } else {
            queryParams[key.toLowerCase()] = values.toList();
          }
        }
      });

      debugPrint('📡 Fetching products with params: $queryParams');
      // Fetch Data
      var response = await BasicProvider("products")
          .getRequest(queryParams: queryParams)
          .catchError(handleError);

      if (response != null) {
        List<dynamic> newProducts = [];

        if (response is Map) {
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

        _deriveAttributesFromProducts();
        _deriveBrandsFromProducts();
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

  Future<void> ensureCategoriesLoaded() async {
    if (allCategories.isNotEmpty) return;
    try {
      isCategoriesLoading.value = true;
      final cached = box.read('home_category_tree');
      if (cached is List && cached.isNotEmpty) {
        allCategories.assignAll(cached);
        availableCategories.assignAll(cached);
        filterDataCategories.assignAll(cached);
        initFilterCategories();
      }
      final response =
          await BasicProvider("category/get-tree/product").getRequest();
      if (response != null) {
        List data = [];
        if (response is List) {
          data = response;
        } else if (response is Map) {
          if (response['data'] is List) {
            data = response['data'] as List;
          } else if (response['data'] is Map &&
              response['data']['data'] is List) {
            data = response['data']['data'] as List;
          }
        }
        if (data.isNotEmpty) {
          allCategories.assignAll(data);
          availableCategories.assignAll(data);
          filterDataCategories.assignAll(data);
          box.write('home_category_tree', data);
          initFilterCategories();
        }
      }
    } catch (e) {
      debugPrint("ℹ️ Category tree load info: $e");
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  // ─── FETCH UNIFIED FILTER DATA ────────────────────────────────
  Future<void> fetchFilterData() async {
    try {
      isFilterDataLoading.value = true;
      isBrandsLoading.value = true;
      if (allCategories.isEmpty && availableCategories.isEmpty) {
        isCategoriesLoading.value = true;
      }
      isAttributesLoading.value = true;

      await ensureCategoriesLoaded();

      // Safely attempt background filter-data endpoint if supported; never trigger user-facing snackbars
      try {
        Map<String, dynamic> queryParams = {};
        if (selectedCategories.isNotEmpty) {
          queryParams['category'] = selectedCategories.first;
        }

        var response = await BasicProvider("products/filter-data")
            .getRequest(queryParams: queryParams);

        if (response != null && response is Map) {
          if (response.containsKey('categories') &&
              response['categories'] is List &&
              (response['categories'] as List).isNotEmpty) {
            allCategories.assignAll(response['categories']);
            filterDataCategories.assignAll(response['categories']);
            availableCategories.assignAll(response['categories']);
          }

          if (response.containsKey('brands') && response['brands'] is List) {
            filterDataBrands.assignAll(response['brands']);
            availableBrands.assignAll(response['brands']);
          }
          if (response.containsKey('priceRange') &&
              response['priceRange'] is Map) {
            filterDataPriceRange
                .assignAll(Map<String, dynamic>.from(response['priceRange']));
          }
          if (response.containsKey('product_filters') &&
              response['product_filters'] is List) {
            filterDataProductFilters.assignAll(response['product_filters']);

            Map<String, List<dynamic>> temp = {};
            for (var filter in response['product_filters']) {
              if (filter is Map) {
                String name = filter['name']?.toString() ?? '';
                List<dynamic> options = filter['options'] ?? [];
                if (name.isNotEmpty) {
                  String normalizedKey =
                      name.trim().capitalizeFirst ?? name.trim();
                  temp[normalizedKey] = List<dynamic>.from(options);
                }
              }
            }
            availableAttributes.assignAll(temp);
          }
          debugPrint('✅ Filter data fetched successfully');
        }
      } catch (e) {
        debugPrint('ℹ️ Filter data endpoint not supported or unavailable: $e');
      }
    } catch (e) {
      debugPrint('ℹ️ Fetch Filter Data Error: $e');
    } finally {
      isFilterDataLoading.value = false;
      isBrandsLoading.value = false;
      isCategoriesLoading.value = false;
      isAttributesLoading.value = false;
    }
  }

  // ─── FILTER PAGE CATEGORY BROWSE METHODS ─────────────────────

  bool _findCategoryPath(
    List<dynamic> list,
    String targetSlug,
    List<Map<String, dynamic>> currentStack,
  ) {
    for (var item in list) {
      if (item is! Map) continue;
      final slug = item['slug']?.toString() ?? '';
      final id = item['_id']?.toString() ?? item['id']?.toString() ?? '';
      final name = item['name']?.toString() ?? '';

      if (slug == targetSlug ||
          id == targetSlug ||
          (targetSlug.isNotEmpty &&
              name.toLowerCase() == targetSlug.toLowerCase())) {
        final levelCategories = list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        currentStack.add(<String, dynamic>{
          'cat': Map<String, dynamic>.from(item),
          'level': levelCategories,
        });
        return true;
      }
      final childrenRaw = item['children'];
      final childrenList = childrenRaw is List ? childrenRaw : null;
      if (childrenList != null && childrenList.isNotEmpty) {
        final levelCategories = list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        currentStack.add(<String, dynamic>{
          'cat': Map<String, dynamic>.from(item),
          'level': levelCategories,
        });

        final childrenMapped = childrenList
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        if (_findCategoryPath(childrenMapped, targetSlug, currentStack)) {
          return true;
        }

        currentStack.removeLast();
      }
    }
    return false;
  }

  void initFilterCategories() {
    filterCategoryStack.clear();
    final root =
        (allCategories.isNotEmpty ? allCategories : availableCategories)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

    if (selectedCategories.isNotEmpty) {
      final List<Map<String, dynamic>> tempStack = [];
      if (_findCategoryPath(root, selectedCategories.first, tempStack)) {
        if (tempStack.isNotEmpty) {
          var parentCat = tempStack.last['cat'] as Map;
          final childrenRaw = parentCat['children'];
          final childrenList = childrenRaw is List ? childrenRaw : null;
          var children = childrenList
                  ?.whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList() ??
              [];
          if (children.isEmpty) {
            tempStack.removeLast();
            if (tempStack.isNotEmpty) {
              parentCat = tempStack.last['cat'] as Map;
              final subChildrenRaw = parentCat['children'];
              final subChildrenList =
                  subChildrenRaw is List ? subChildrenRaw : null;
              children = subChildrenList
                      ?.whereType<Map>()
                      .map((e) => Map<String, dynamic>.from(e))
                      .toList() ??
                  [];
            } else {
              filterCategoryStack.clear();
              filterCurrentCategories.assignAll(root);
              _prefetchCounts(root);
              return;
            }
          }
          filterCategoryStack.assignAll(tempStack);
          filterCurrentCategories.assignAll(children);
          _prefetchCounts(children);
          return;
        }
      }
    }

    filterCurrentCategories.assignAll(root);
    _prefetchCounts(root);
  }

  void selectCategoryAndFilter(Map<String, dynamic> cat) {
    final slug = cat['slug']?.toString() ?? '';
    if (slug.isEmpty) return;
    toggleCategory(slug);
  }

  void drillIntoCategory(Map<String, dynamic> cat) {
    final childrenRaw = cat['children'];
    final childrenList = childrenRaw is List ? childrenRaw : null;
    final children = childrenList
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        [];

    if (children.isNotEmpty) {
      // Push current level onto stack for back navigation
      filterCategoryStack.add(<String, dynamic>{
        'cat': cat,
        'level': filterCurrentCategories
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
      });
      filterCurrentCategories.assignAll(children);
      _prefetchCounts(children);
    } else {
      toggleCategory(cat['slug']?.toString() ?? '');
    }
  }

  void goUpFilterCategory() {
    if (filterCategoryStack.isEmpty) return;
    final prev = filterCategoryStack.removeLast();
    final prevLevelRaw = prev['level'];
    final prevLevelList = prevLevelRaw is List ? prevLevelRaw : [];
    final prevLevel = prevLevelList
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    filterCurrentCategories.assignAll(prevLevel);
  }

  List<Map<String, dynamic>> getSearchedCategories(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    final currentStackSlug = filterCategoryStack.isEmpty
        ? ""
        : (filterCategoryStack.last['cat'] as Map)['slug']?.toString() ?? "";
    final cacheKey = "${currentStackSlug}_$cleanQuery";

    if (_categorySearchCache.containsKey(cacheKey)) {
      _prefetchCounts(_categorySearchCache[cacheKey]!);
      return _categorySearchCache[cacheKey]!;
    }

    final lastCat = filterCategoryStack.isEmpty
        ? null
        : filterCategoryStack.last['cat'] as Map?;
    final childrenRaw = lastCat != null ? lastCat['children'] : null;
    final List<dynamic> baseList = filterCategoryStack.isEmpty
        ? (allCategories.isNotEmpty ? allCategories : availableCategories)
        : (childrenRaw is List ? childrenRaw : []);

    final List<Map<String, dynamic>> results = [];
    void helper(List<dynamic> list) {
      for (var item in list) {
        if (item is! Map) continue;
        final name = item['name']?.toString() ?? '';
        if (name.toLowerCase().contains(cleanQuery)) {
          results.add(Map<String, dynamic>.from(item));
        }
        final subChildrenRaw = item['children'];
        final subChildrenList = subChildrenRaw is List ? subChildrenRaw : null;
        if (subChildrenList != null && subChildrenList.isNotEmpty) {
          helper(subChildrenList);
        }
      }
    }

    helper(baseList);
    _prefetchCounts(results);
    _categorySearchCache[cacheKey] = results;
    return results;
  }

  Future<void> fetchPriceRangeBounds({bool resetSelection = false}) async {
    try {
      isLoadingBounds.value = true;

      double minVal = _parseNumberDecimal(filterDataPriceRange['min']) ?? 0.0;
      final maxVal =
          _parseNumberDecimal(filterDataPriceRange['max']) ?? 10000.0;

      if (products.isNotEmpty) {
        double? lowestEffective;
        for (var p in products) {
          if (p is! Map) continue;
          final variants = (p['variants'] ?? p['variant_ids'] ?? []) as List;
          final productType = p['type']?.toString() ?? '';
          if (productType == 'simple') {
            Map? defaultVariant;
            for (var v in variants) {
              if (v is Map && v['is_default'] == true) {
                defaultVariant = v;
                break;
              }
            }
            defaultVariant ??= (variants.isNotEmpty && variants.first is Map)
                ? variants.first as Map
                : null;
            double? pPrice;
            double? pSale;
            if (defaultVariant != null) {
              pPrice =
                  double.tryParse(defaultVariant['price']?.toString() ?? '');
              pSale = double.tryParse(
                  defaultVariant['sale_price']?.toString() ?? '');
            } else {
              pPrice = double.tryParse(p['price']?.toString() ?? '');
              pSale = double.tryParse(p['sale_price']?.toString() ?? '');
            }
            double eff = (pSale != null && pSale > 0) ? pSale : (pPrice ?? 0);
            if (eff > 0 && (lowestEffective == null || eff < lowestEffective)) {
              lowestEffective = eff;
            }
          } else {
            for (var v in variants) {
              if (v is! Map) continue;
              double vP = double.tryParse(v['price']?.toString() ?? '') ?? 0;
              double? vSP = double.tryParse(v['sale_price']?.toString() ?? '');
              double eff = (vSP != null && vSP > 0) ? vSP : vP;
              if (eff > 0 &&
                  (lowestEffective == null || eff < lowestEffective)) {
                lowestEffective = eff;
              }
            }
          }
        }
        if (lowestEffective != null && lowestEffective < minVal) {
          minVal = lowestEffective;
        }
      }

      absoluteMinPrice.value = minVal;
      absoluteMaxPrice.value = maxVal;

      if (resetSelection) {
        currentPriceRange.value = RangeValues(minVal, maxVal);
        minPrice.value = minVal;
        maxPrice.value = maxVal;
      } else {
        // Clamp existing selection within the absolute bounds
        double start = currentPriceRange.value.start;
        double end = currentPriceRange.value.end;
        if (start < minVal || start > maxVal) start = minVal;
        if (end < minVal || end > maxVal) end = maxVal;
        if (start > end) {
          start = minVal;
          end = maxVal;
        }
        currentPriceRange.value = RangeValues(start, end);
        minPrice.value = start;
        maxPrice.value = end;
      }
      debugPrint(
          '✅ Price range bounds updated from unified filter data: Min: $minVal, Max: $maxVal');
    } catch (e) {
      debugPrint('❌ Fetch Price Range Bounds Error: $e');
    } finally {
      isLoadingBounds.value = false;
    }
  }

  void _prefetchCounts(List<Map<String, dynamic>> cats) {
    for (final cat in cats) {
      final slug = cat['slug']?.toString() ?? '';
      if (slug.isEmpty || categoryCountCache.containsKey(slug)) continue;
      isCountLoading[slug] = true;
      isCountLoading.refresh();

      final Map<String, dynamic> params = {
        'count': '1',
        isParentCategory(slug) ? 'parentCategory' : 'category': slug,
      };
      if (selectedBrands.isNotEmpty) {
        params['brand'] = selectedBrands.toList();
      }
      if (minPrice.value > absoluteMinPrice.value) {
        final formattedMin = minPrice.value.toStringAsFixed(2);
        params['min_price'] = formattedMin.endsWith('.00')
            ? minPrice.value.toStringAsFixed(0)
            : formattedMin;
      }
      if (maxPrice.value < absoluteMaxPrice.value) {
        final formattedMax = maxPrice.value.toStringAsFixed(2);
        params['max_price'] = formattedMax.endsWith('.00')
            ? maxPrice.value.toStringAsFixed(0)
            : formattedMax;
      }
      if (isBackToSchool.value) params['back_to_school'] = 'true';
      if (isSeasonalItems.value) params['seasonal_items'] = 'true';
      if (isWeeklyTopHighlights.value) params['weekly_top_highlights'] = 'true';
      if (isTodaysTopPick.value) params['todays_top_pick'] = 'true';
      if (isRecommended.value) params['recommended'] = 'true';

      selectedAttributes.forEach((key, values) {
        if (values.isNotEmpty) {
          if (values.length == 1) {
            params[key.toLowerCase()] = values.first;
          } else {
            params[key.toLowerCase()] = values.toList();
          }
        }
      });

      BasicProvider("products")
          .getRequest(queryParams: params)
          .then((response) {
        if (response != null && response is Map) {
          categoryCountCache[slug] = (response['total'] as num?)?.toInt() ?? 0;
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

  void _deriveBrandsFromProducts() {
    if (selectedCategories.isEmpty) {
      contextBrands.clear();
      return;
    }
    final Set<String> brandIdentifiers = {};
    for (final product in products) {
      if (product is! Map) continue;
      final brand = product['brand'];
      if (brand is Map) {
        final slug = brand['slug']?.toString() ?? '';
        final id = brand['_id']?.toString() ?? '';
        if (slug.isNotEmpty) brandIdentifiers.add(slug);
        if (id.isNotEmpty) brandIdentifiers.add(id);
      } else if (brand is String && brand.isNotEmpty) {
        brandIdentifiers.add(brand);
      }
    }
    final filtered = availableBrands.where((b) {
      if (b is! Map) return false;
      final slug = b['slug']?.toString() ?? '';
      final id = b['_id']?.toString() ?? '';
      return brandIdentifiers.contains(slug) || brandIdentifiers.contains(id);
    }).toList();
    contextBrands.assignAll(filtered);
  }

  void _deriveAttributesFromProducts() {
    final Map<String, Set<dynamic>> temp = {};
    for (final product in products) {
      if (product is! Map) continue;
      final variants =
          (product['variants'] ?? product['variant_ids'] ?? []) as List;
      for (final variant in variants) {
        if (variant is! Map) continue;
        final attrs = variant['attributes'];
        if (attrs is! Map) continue;
        attrs.forEach((key, value) {
          final normalized =
              key.toString().trim().capitalizeFirst ?? key.toString();
          if (normalized.isEmpty || value == null) return;
          temp.putIfAbsent(normalized, () => <dynamic>{}).add(value.toString());
        });
      }
    }
    final result = <String, List<dynamic>>{};
    for (final entry in temp.entries) {
      result[entry.key] = entry.value.toList();
    }
    contextAttributes.assignAll(result);
  }

  void toggleAttribute(String attributeName, String option) {
    final currentSet = selectedAttributes[attributeName] ?? {};
    if (currentSet.contains(option)) {
      currentSet.remove(option);
    } else {
      currentSet.add(option);
    }
    selectedAttributes[attributeName] = Set<String>.from(currentSet);
    selectedAttributes.refresh();
    applyFiltersAndRefresh(resetSelection: true);
  }

  // ─── FILTER CONTROLS ───────────────────────────────────────
  void applyFiltersAndRefresh(
      {bool resetSelection = false, bool categoryChanged = false}) {
    if (resetSelection) _pendingResetSelection = true;
    if (categoryChanged) _pendingCategoryChanged = true;

    _filterDebouncer?.cancel();
    _filterDebouncer = Timer(const Duration(milliseconds: 300), () {
      final runReset = _pendingResetSelection;
      final runCategoryChanged = _pendingCategoryChanged;
      _pendingResetSelection = false;
      _pendingCategoryChanged = false;

      _executeFiltersAndRefresh(
          resetSelection: runReset, categoryChanged: runCategoryChanged);
    });
  }

  void _executeFiltersAndRefresh(
      {required bool resetSelection, required bool categoryChanged}) {
    if (!categoryChanged) {
      categoryCountCache.clear();
      _prefetchCounts(filterCurrentCategories);
    }

    if (resetSelection) {
      fetchPriceRangeBounds(resetSelection: true).then((_) {
        fetchProducts(isRefresh: true);
      });
    } else {
      fetchProducts(isRefresh: true);
    }
  }

  void toggleBackToSchool() {
    isBackToSchool.toggle();
    applyFiltersAndRefresh(resetSelection: true);
  }

  void toggleSeasonalItems() {
    isSeasonalItems.toggle();
    applyFiltersAndRefresh(resetSelection: true);
  }

  void toggleWeeklyTopHighlights() {
    isWeeklyTopHighlights.toggle();
    applyFiltersAndRefresh(resetSelection: true);
  }

  void toggleTodaysTopPick() {
    isTodaysTopPick.toggle();
    applyFiltersAndRefresh(resetSelection: true);
  }

  void toggleRecommended() {
    isRecommended.toggle();
    applyFiltersAndRefresh(resetSelection: true);
  }

  bool isParentCategory(String slugOrId) {
    if (slugOrId.isEmpty) return false;

    // 1. Check loaded category tree root nodes
    final rootNodes = categoryTreeByType['product'];
    if (rootNodes != null && rootNodes.isNotEmpty) {
      for (var node in rootNodes) {
        if (node.slug == slugOrId || node.id == slugOrId) {
          return true;
        }
      }
    }

    // 2. Check allCategories / availableCategories
    final searchSource =
        allCategories.isNotEmpty ? allCategories : availableCategories;

    for (var item in searchSource) {
      if (item is! Map) continue;
      final slug = item['slug']?.toString() ?? '';
      final id = item['_id']?.toString() ?? item['id']?.toString() ?? '';
      if (slug == slugOrId || id == slugOrId) {
        final parentCat = item['parentCategory'] ?? item['parent_id'];
        if (parentCat == null || parentCat.toString().isEmpty) {
          return true;
        }
        final childrenRaw = item['children'];
        if (childrenRaw is List && childrenRaw.isNotEmpty) {
          return true;
        }
      }
    }
    return false;
  }

  String? resolveParentCategory(Iterable<String> categories) {
    for (final cat in categories) {
      if (isParentCategory(cat)) return cat;
    }
    return null;
  }

  bool get isSelectedCategoryParent {
    if (selectedCategories.isEmpty) return false;
    return isParentCategory(selectedCategories.first);
  }

  void toggleCategory(String slug) {
    if (selectedCategories.contains(slug)) {
      selectedCategories.remove(slug);
      if (parentCategoryFilter.value == slug) {
        parentCategoryFilter.value =
            resolveParentCategory(selectedCategories) ?? '';
      }
    } else {
      selectedCategories.clear();
      selectedCategories.add(slug);
      if (isParentCategory(slug)) {
        parentCategoryFilter.value = slug;
      } else {
        parentCategoryFilter.value = '';
      }
    }

    if (selectedCategories.length == 1) {
      collectionName.value = treeNodeName('product', selectedCategories.first);
    } else if (selectedCategories.isEmpty) {
      collectionName.value = "All Products";
    }

    if (isSelectedCategoryParent) {
      selectedAttributes.clear();
      expandedAttributes.clear();
    }
    applyFiltersAndRefresh(resetSelection: true, categoryChanged: true);
  }

  void toggleBrand(String slug) {
    if (selectedBrands.contains(slug)) {
      selectedBrands.remove(slug);
    } else {
      selectedBrands.add(slug);
    }
    applyFiltersAndRefresh(resetSelection: true);
  }

  void updatePriceRange(RangeValues values) {
    currentPriceRange.value = values;
    minPrice.value = values.start;
    maxPrice.value = values.end;
    applyFiltersAndRefresh();
  }

  void ensureFilterDataLoaded() {
    if (allCategories.isEmpty) {
      ensureCategoriesLoaded();
    }
  }

  Future<void> ensureCategoryTreeLoaded() async {
    if (isCategoryTreeLoading.value) return;
    final pending = _kCategoryTreeTypes
        .where((t) => !_loadedTreeTypes.contains(t))
        .toList();
    if (pending.isEmpty) return;

    isCategoryTreeLoading.value = true;
    try {
      if (categoryTypes.isEmpty) {
        try {
          categoryTypes
              .assignAll(await _categoryFilterService.getCategoryTypes());
        } catch (e) {
          debugPrint('❌ getCategoryTypes error: $e');
        }
      }
      // Sequential: one failed type must not blank out the other sections.
      for (final type in pending) {
        try {
          final nodes = await _categoryFilterService.getTree(type);
          categoryTreeByType[type] = nodes;
          categoryTreeErrorByType[type] = false;
          _loadedTreeTypes.add(type);
        } catch (e) {
          debugPrint('❌ ensureCategoryTreeLoaded($type) error: $e');
          categoryTreeErrorByType[type] = true;
        }
      }
    } finally {
      isCategoryTreeLoading.value = false;
    }
  }

  Future<void> retryCategoryTreeType(String type) async {
    _loadedTreeTypes.remove(type);
    categoryTreeErrorByType[type] = false;
    await ensureCategoryTreeLoaded();
  }

  /// Display name for a slug from a loaded tree (falls back to the slug).
  String treeNodeName(String type, String slug) {
    String? find(List<CategoryTreeNode> nodes) {
      for (final n in nodes) {
        if (n.slug == slug) return n.name;
        final r = find(n.children);
        if (r != null) return r;
      }
      return null;
    }

    return find(categoryTreeByType[type] ?? const []) ?? slug;
  }

  /// Commits the drawer's staged selections and refreshes the product list.
  void applyStagedFilters({
    required Set<String> categories,
    // required Set<String> materials,
    // required Set<String> styles,
    // required Set<String> brands,
    required RangeValues priceRange,
  }) {
    final categoriesChanged =
        !(categories.length == selectedCategories.length &&
            categories.every(selectedCategories.contains));

    selectedCategories
      ..clear()
      ..addAll(categories);

    final parentSlug = resolveParentCategory(categories);
    if (parentSlug != null) {
      parentCategoryFilter.value = parentSlug;
    } else if (categories.isEmpty) {
      parentCategoryFilter.value = '';
    } else if (!categories.contains(parentCategoryFilter.value)) {
      parentCategoryFilter.value = '';
    }

    if (selectedCategories.length == 1) {
      collectionName.value = treeNodeName('product', selectedCategories.first);
    } else if (selectedCategories.isEmpty) {
      collectionName.value = "All Products";
    }

    // selectedAttributes['material'] = Set<String>.from(materials);
    // selectedAttributes['style'] = Set<String>.from(styles);
    selectedAttributes.refresh();
    // selectedBrands
    //   ..clear()
    //   ..addAll(brands);
    currentPriceRange.value = priceRange;
    minPrice.value = priceRange.start;
    maxPrice.value = priceRange.end;
    applyFiltersAndRefresh(categoryChanged: true);
    if (categoriesChanged) fetchFilterData();
  }

  /// Debounced product search used by the shop hero search bar.
  void onProductSearchChanged(String value) {
    _productSearchDebouncer?.cancel();
    _productSearchDebouncer = Timer(const Duration(milliseconds: 400), () {
      final q = value.trim();
      if (q == searchQuery.value) return;
      searchQuery.value = q;
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

  void updateSort(String by, String order) {
    sortBy.value = by;
    sortOrder.value = order;
    applyFiltersAndRefresh();
  }

  void onMinPriceTextChanged(String val) {
    double? typedMin = double.tryParse(val);
    if (typedMin != null) {
      double newMin = typedMin / _currencyRate;
      double absMin = absoluteMinPrice.value;
      double absMax = absoluteMaxPrice.value;
      if (newMin < absMin) newMin = absMin;
      if (newMin > absMax) newMin = absMax;

      double currentEnd = currentPriceRange.value.end;
      if (newMin > currentEnd) {
        newMin = currentEnd;
      }

      currentPriceRange.value = RangeValues(newMin, currentEnd);
      minPrice.value = newMin;
    }
  }

  void onMaxPriceTextChanged(String val) {
    double? typedMax = double.tryParse(val);
    if (typedMax != null) {
      double newMax = typedMax / _currencyRate;
      double absMin = absoluteMinPrice.value;
      double absMax = absoluteMaxPrice.value;
      if (newMax < absMin) newMax = absMin;
      if (newMax > absMax) newMax = absMax;

      double currentStart = currentPriceRange.value.start;
      if (newMax < currentStart) {
        newMax = currentStart;
      }

      currentPriceRange.value = RangeValues(currentStart, newMax);
      maxPrice.value = newMax;
    }
  }

  void resetFiltersOnly() {
    collectionName.value = "All Products";
    isBackToSchool.value = false;
    isSeasonalItems.value = false;
    isWeeklyTopHighlights.value = false;
    isTodaysTopPick.value = false;
    isRecommended.value = false;
    selectedCategories.clear();
    parentCategoryFilter.value = '';
    selectedBrands.clear();
    selectedAttributes.clear();
    _productSearchDebouncer?.cancel();
    if (productSearchController.text.isNotEmpty)
      productSearchController.clear();
    searchQuery.value = "";
    sortBy.value = "created_at";
    sortOrder.value = "desc";
    // Reset filter category browse to root
    initFilterCategories();
    contextAttributes.clear();
    contextBrands.clear();
    if (categorySearchController.text.isNotEmpty)
      categorySearchController.clear();
    if (brandSearchController.text.isNotEmpty) brandSearchController.clear();
    categorySearchQuery.value = "";
    brandSearchQuery.value = "";
    expandedAttributes.clear();
    visibleAttributeCount.clear();

    // Reset price values immediately to avoid using old values
    minPrice.value = absoluteMinPrice.value;
    maxPrice.value = absoluteMaxPrice.value;
    currentPriceRange.value =
        RangeValues(absoluteMinPrice.value, absoluteMaxPrice.value);

    // Cancel pending filters
    _filterDebouncer?.cancel();
    _pendingResetSelection = false;
    _pendingCategoryChanged = false;
  }

  void clearAllFilters() {
    resetFiltersOnly();

    // Set loading state immediately so UI updates instantly
    isLoading.value = true;
    products.clear();

    _executeFiltersAndRefresh(resetSelection: true, categoryChanged: false);
  }

  bool get hasActiveFilters {
    bool hasAttributes = selectedAttributes.values.any((set) => set.isNotEmpty);
    return searchQuery.value.isNotEmpty ||
        isBackToSchool.value ||
        isSeasonalItems.value ||
        isWeeklyTopHighlights.value ||
        isTodaysTopPick.value ||
        isRecommended.value ||
        selectedCategories.isNotEmpty ||
        selectedBrands.isNotEmpty ||
        minPrice.value > absoluteMinPrice.value ||
        maxPrice.value < absoluteMaxPrice.value ||
        sortBy.value != "created_at" ||
        hasAttributes;
  }

  int get activeFilterCount {
    int count = 0;
    if (searchQuery.value.isNotEmpty) count++;
    if (isBackToSchool.value) count++;
    if (isSeasonalItems.value) count++;
    if (isWeeklyTopHighlights.value) count++;
    if (isTodaysTopPick.value) count++;
    if (isRecommended.value) count++;
    count += selectedCategories.length;
    count += selectedBrands.length;
    if (minPrice.value > absoluteMinPrice.value ||
        maxPrice.value < absoluteMaxPrice.value) count++;
    if (sortBy.value != "created_at") count++;
    selectedAttributes.values.forEach((set) {
      count += set.length;
    });
    return count;
  }
}
