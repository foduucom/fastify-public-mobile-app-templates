import 'package:flutter/material.dart';
import 'dart:async';

import '/constants/constants.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/core/foduuStudio/foduu_studio_layout_mixin.dart';
import '/models/blog_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/filter_model.dart';
import '../services/product_service.dart';

class SearchsController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  static const String pageSlug = 'search';

  /// Max categories / blogs previewed in the unified results.
  static const int _previewLimit = 10;

  var searchProduct = [].obs;
  final queryText = ''.obs;
  var searchCategories = [].obs;
  var searchBlogs = <BlogModel>[].obs;
  var recentSearchList = [].obs;

  var isSearching = false.obs; // True for initial load
  var isFetchingMore = false.obs; // True for pagination load

  // Brand state
  var brands = [].obs;
  var isBrandsLoading = false.obs;
  var selectedBrandSlug = "".obs;

  var box = GetStorage();
  late TextEditingController searchTextController;
  late ScrollController scrollController;

  // Filter state
  var activeFilter = const FilterModel.empty().obs;

  // Pagination Trackers
  int currentPage = 1;
  bool hasNextPage = false;

  Timer? _debounce;
  int _searchToken = 0;
  List<BlogModel>? _blogCache;

  // ── CMS-allotted entities ──
  // The backend CMS decides what the search bar covers: an entity is searched
  // only when its section (`products`, `categories`, `blog`) is part of the
  // `search` page layout. Without any layout we fall back to products only.
  bool get _hasLayout => sectionTypes.isNotEmpty;
  bool get searchesProducts => !_hasLayout || sectionTypes.contains('products');
  bool get searchesCategories => sectionTypes.contains('categories');
  bool get searchesBlogs => sectionTypes.contains('blog');

  /// Entity result groups in the order the CMS lays them out.
  List<String> get resultOrder {
    if (!_hasLayout) return const ['products'];
    return sectionTypes
        .where((t) => t == 'products' || t == 'categories' || t == 'blog')
        .toList();
  }

  /// CMS-authored hint for the search bar, with a fallback.
  String get searchPlaceholder {
    final placeholder = contentJsonFor('search')?['placeholder'];
    if (placeholder is String && placeholder.trim().isNotEmpty) {
      return placeholder;
    }
    final parts = <String>['products'];
    if (searchesCategories) parts.add('categories');
    if (searchesBlogs) parts.add('blogs');
    return 'Search ${parts.join(', ')}...';
  }

  @override
  void onInit() {
    searchTextController = TextEditingController();
    scrollController = ScrollController();

    // Listen to scrolling to trigger pagination
    scrollController.addListener(_scrollListener);

    getRecentSearch();
    loadAllProducts();
    fetchBrands();

    // The page renders its own search field above the CMS layout, so skip
    // any `search` block from the CMS to avoid a second search bar.
    excludeSectionTypes = const ['search'];
    fetchLayout(pageSlug);
    super.onInit();
  }

  @override
  void onClose() {
    _debounce?.cancel();
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

  // ── Typing entry point: debounced ──
  void onSearchChanged(String text) {
    queryText.value = text;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      getSearchSuggestion(text: text);
    });
  }

  // ── Search Load (Page 1) ──
  void getSearchSuggestion({required String text}) async {
    _debounce?.cancel();
    queryText.value = text;
    final token = ++_searchToken;

    if (text.trim().isEmpty) {
      searchCategories.clear();
      searchBlogs.clear();
      loadAllProducts();
      return;
    }

    // Categories and blogs run alongside products, only if the CMS allots them.
    final others = Future.wait([
      if (searchesCategories) _searchCategories(text, token),
      if (searchesBlogs) _searchBlogs(text, token),
    ]);
    if (!searchesCategories) searchCategories.clear();
    if (!searchesBlogs) searchBlogs.clear();
    if (!searchesProducts) {
      isSearching.value = true;
      searchProduct.clear();
      await others;
      if (token == _searchToken) isSearching.value = false;
      return;
    }

    try {
      selectedBrandSlug.value = ""; // Clear brand selection on search
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
      if (token != _searchToken) return; // a newer search superseded this one
      _parseAndSetProducts(response, isRefresh: true);
    } catch (e) {
      debugPrint('❌ search error: $e');
    } finally {
      await others;
      if (token == _searchToken) isSearching.value = false;
    }
  }

  // ── Categories ──
  Future<void> _searchCategories(String text, int token) async {
    try {
      final response = await BasicProvider('category').getRequest(
          queryParams: {'search': text.trim(), 'page': '1'}).catchError(handleError);
      if (token != _searchToken) return;
      final List data = response is List
          ? response
          : (response is Map && response['data'] is List
              ? response['data']
              : []);
      searchCategories.assignAll(data.take(_previewLimit).toList());
    } catch (e) {
      debugPrint('❌ search categories error: $e');
    }
  }

  // ── Blogs ──
  // The blogs endpoint has no server-side search, so fetch one page once and
  // match title / excerpt / author on the device (same rule as BlogController).
  Future<void> _searchBlogs(String text, int token) async {
    try {
      _blogCache ??= await _loadBlogs();
      if (token != _searchToken) return;
      final q = text.trim().toLowerCase();
      searchBlogs.assignAll(_blogCache!
          .where((b) =>
              b.title.toLowerCase().contains(q) ||
              b.cleanExcerpt.toLowerCase().contains(q) ||
              b.authorName.toLowerCase().contains(q))
          .take(_previewLimit)
          .toList());
    } catch (e) {
      debugPrint('❌ search blogs error: $e');
    }
  }

  Future<List<BlogModel>> _loadBlogs() async {
    final response = await BasicProvider('blogs?count=50&page=1')
        .getRequest()
        .catchError(handleError);
    Object? raw;
    if (response is Map) {
      final inner = response['data'];
      raw = inner is Map ? inner['data'] : inner;
    } else if (response is List) {
      raw = response;
    }
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => BlogModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ── Brand Fetching ──
  void fetchBrands() async {
    try {
      isBrandsLoading.value = true;
      var response =
          await BasicProvider('brands').getRequest().catchError(handleError);

      if (response != null && response is Map && response['data'] is List) {
        brands.assignAll(response['data']);

        // Default view: Show products for first brand if no products are loaded yet
        // OR if the user explicitly wants to show first brand by default
        /*
        if (brands.isNotEmpty && searchProduct.isEmpty) {
          fetchProductsByBrand(brands[0]['slug']);
        }
        */
      }
    } catch (e) {
      debugPrint('❌ fetchBrands error: $e');
    } finally {
      isBrandsLoading.value = false;
    }
  }

  // ── Products by Brand ──
  void fetchProductsByBrand(String slug) async {
    try {
      selectedBrandSlug.value = slug;
      searchTextController.clear();
      queryText.value = ''; // Clear search text when filtering by brand

      currentPage = 1;
      hasNextPage = false;
      isSearching.value = true;
      searchProduct.clear();

      var response = await BasicProvider('products')
          .getRequest(queryParams: {
        ...ProductService.buildQueryParams(page: 1, filter: activeFilter.value),
        'brand': slug,
      }).catchError(handleError);

      _parseAndSetProducts(response, isRefresh: true);
    } catch (e) {
      debugPrint('❌ fetchProductsByBrand error: $e');
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
              )..addAll(selectedBrandSlug.value.isEmpty
                  ? const {}
                  : {'brand': selectedBrandSlug.value}))
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
    debugPrint(
        '🔍 Filter applied: before=$before, after=${searchProduct.length}, trending=${f.trending}, recommended=${f.recommended}');
    if (searchProduct.isNotEmpty) {
      debugPrint(
          '🔍 Sample product flags → trending=${searchProduct[0]['trending']}, recommended=${searchProduct[0]['recommended']}');
    }
  }
}
