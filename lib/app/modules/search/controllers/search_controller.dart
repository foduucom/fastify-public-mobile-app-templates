import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '/constants/constants.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/core/foduuStudio/foduu_studio_layout_mixin.dart';
import '/models/blog_model.dart';
import '../services/product_service.dart';

/// Defines the three primary UI states for the Search screen
enum SearchMode {
  browse, // State 1: Zero-query First Appearance (CMS Studio layout)
  autocomplete, // State 2: Live Predictive Autocomplete overlay (while typing)
  results, // State 3: Submitted search results (entity tabs, product grid, filters)
}

class SearchsController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  static const String pageSlug = 'search';

  /// Max categories / blogs previewed in results
  static const int _previewLimit = 10;

  // ── Search State ──
  final searchMode = SearchMode.browse.obs;
  final queryText = ''.obs;
  final selectedTabIndex =
      0.obs; // 0: All, 1: Products, 2: Categories, 3: Blogs
  final selectedSort =
      'relevance'.obs; // relevance, price_asc, price_desc, newest

  // ── Results Data ──
  var searchProduct = [].obs;
  var searchCategories = [].obs;
  var searchBlogs = <BlogModel>[].obs;
  var recentSearchList = [].obs;

  // ── Autocomplete / Predictive Suggestions (Parent Web API) ──
  var autocompleteProducts = [].obs;
  var autocompleteCategories = [].obs;
  var autocompleteBlogs = [].obs;
  var isAutocompleteLoading = false.obs;

  bool get hasAutocompleteResults =>
      autocompleteProducts.isNotEmpty ||
      autocompleteCategories.isNotEmpty ||
      autocompleteBlogs.isNotEmpty;

  // ── Loading & Pagination ──
  var isSearching = false.obs; // True during full search results fetch
  var isFetchingMore = false.obs; // True for pagination fetch
  int currentPage = 1;
  bool hasNextPage = false;

  // ── Brands ──
  var brands = [].obs;
  var isBrandsLoading = false.obs;
  var selectedBrandSlug = "".obs;

  // ── Storage & Controllers ──
  var box = GetStorage();
  late TextEditingController searchTextController;
  late ScrollController scrollController;

  Timer? _debounce;
  Timer? _autocompleteDebounce;
  int _searchToken = 0;
  int _autocompleteToken = 0;
  List<BlogModel>? _blogCache;

  // ── Computed Properties ──
  bool get _hasLayout => sectionTypes.isNotEmpty;
  bool get searchesProducts => !_hasLayout || sectionTypes.contains('products');
  bool get searchesCategories => sectionTypes.contains('categories');
  bool get searchesBlogs => sectionTypes.contains('blog');

  int get totalResultCount =>
      searchProduct.length + searchCategories.length + searchBlogs.length;

  List<String> get resultOrder {
    if (!_hasLayout) return const ['products'];
    return sectionTypes
        .where((t) => t == 'products' || t == 'categories' || t == 'blog')
        .toList();
  }

  /// CMS-authored placeholder for the search bar, with parent web fallback
  String get searchPlaceholder {
    final placeholder = contentJsonFor('search')?['placeholder'];
    if (placeholder is String && placeholder.trim().isNotEmpty) {
      return placeholder;
    }
    return 'Search Product, Categories And Blogs';
  }

  @override
  void onInit() {
    super.onInit();
    searchTextController = TextEditingController();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);

    getRecentSearch();
    fetchBrands();

    // The page renders its own search field above the CMS layout, so skip
    // any `search` block from the CMS to avoid duplicate search bars.
    excludeSectionTypes = const ['search'];
    _loadCmsLayoutAndPreHydrate();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _autocompleteDebounce?.cancel();
    searchTextController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ── Single initial layout fetch (no duplicate loadAllProducts) ──
  Future<void> _loadCmsLayoutAndPreHydrate() async {
    try {
      final response = await fetchLayout(pageSlug);
      if (response != null && response is Map) {
        final sections = response['sections'];
        if (sections is List) {
          for (final section in sections) {
            if (section is Map && section['type'] == 'products') {
              final cj = section['content_json'];
              if (cj is Map && cj['products'] != null) {
                final p = cj['products'];
                if (p is Map && p['data'] is List) {
                  // Pre-hydrate products for instant discovery if user enters results mode
                  searchProduct.assignAll(p['data']);
                  hasNextPage = p['hasNextPage'] ?? false;
                } else if (p is List) {
                  searchProduct.assignAll(p);
                  hasNextPage = false;
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error pre-hydrating CMS search layout: $e');
    }
  }

  void _scrollListener() {
    if (scrollController.hasClients &&
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
      if (!isFetchingMore.value && hasNextPage) {
        loadNextPage();
      }
    }
  }

  // ── Recent Searches ──
  void getRecentSearch() {
    var recent = box.read('recentSearch');
    if (recent != null) {
      recentSearchList.assignAll(List.from(recent));
    }
  }

  void saveRecentSearch({
    required String id,
    required String name,
    required String type,
  }) {
    if (name.trim().isEmpty) return;
    recentSearchList.removeWhere((e) =>
        (e is Map &&
            e['name']?.toString().toLowerCase() == name.trim().toLowerCase()) ||
        (e is Map && e['productId'] == id && id.isNotEmpty));

    recentSearchList
        .insert(0, {'productId': id, 'name': name.trim(), 'type': type});
    if (recentSearchList.length > 10) {
      recentSearchList.removeRange(10, recentSearchList.length);
    }
    box.write('recentSearch', recentSearchList.toList());
  }

  void removeRecentItem(dynamic item) {
    recentSearchList.remove(item);
    box.write('recentSearch', recentSearchList.toList());
  }

  void clearRecentSearches() {
    recentSearchList.clear();
    box.remove('recentSearch');
  }

  // ── Typing Handler ──
  void onSearchChanged(String text) {
    final trimmed = text.trim();
    queryText.value = text;
    _autocompleteDebounce?.cancel();

    if (trimmed.isEmpty) {
      autocompleteProducts.clear();
      autocompleteCategories.clear();
      autocompleteBlogs.clear();
      if (selectedBrandSlug.isEmpty) {
        searchMode.value = SearchMode.browse;
      }
      return;
    }

    // Enter autocomplete predictive state
    searchMode.value = SearchMode.autocomplete;

    // For instant responsive feel, trigger debounced autocomplete
    _autocompleteDebounce = Timer(const Duration(milliseconds: 200), () {
      fetchAutocomplete(trimmed);
    });
  }

  // ── Smart Local Autocomplete Fallback ──
  // Matches against pre-hydrated CMS products, brands, and blogs so single-letter
  // queries like "a" or network drops never leave the user with an empty screen.
  void _localAutocomplete(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return;

    // Match products from pre-hydrated CMS layout
    final matchedProducts = searchProduct
        .where((p) {
          if (p is Map) {
            final name =
                (p['name'] ?? p['title'] ?? '').toString().toLowerCase();
            final brand = (p['brand'] ?? '').toString().toLowerCase();
            return name.contains(q) || brand.contains(q);
          }
          return false;
        })
        .take(6)
        .toList();

    // Match brands
    final matchedBrands = brands
        .where((b) {
          if (b is Map) {
            final name = (b['name'] ?? '').toString().toLowerCase();
            return name.contains(q);
          }
          return false;
        })
        .take(4)
        .toList();

    // Match blogs if cached
    List matchedBlogs = [];
    if (_blogCache != null && _blogCache!.isNotEmpty) {
      matchedBlogs = _blogCache!
          .where((b) =>
              b.title.toLowerCase().contains(q) ||
              b.cleanExcerpt.toLowerCase().contains(q) ||
              b.authorName.toLowerCase().contains(q))
          .take(4)
          .map((b) => b.toJson())
          .toList();
    }

    if (matchedProducts.isNotEmpty ||
        matchedBrands.isNotEmpty ||
        matchedBlogs.isNotEmpty) {
      autocompleteProducts.assignAll(matchedProducts);
      autocompleteCategories.assignAll(matchedBrands);
      autocompleteBlogs.assignAll(matchedBlogs);
    }
  }

  // ── Predictive Autocomplete using Parent Web's /search/global API ──
  Future<void> fetchAutocomplete(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final token = ++_autocompleteToken;
    isAutocompleteLoading.value = true;

    try {
      // 1. Try public global search endpoint directly with proper headers
      final uri = Uri.parse(
          '${url}search/global?q=${Uri.encodeComponent(trimmed)}&limit=6');
      final response = await http.get(uri, headers: {
        'accept': 'application/json',
        'access-key': ACCESS_KEY,
      }).timeout(const Duration(seconds: 4));

      if (token != _autocompleteToken) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['success'] == true && data['data'] is Map) {
          final resData = data['data'];
          final products = resData['products'] ?? [];
          final categories = resData['categories'] ?? [];
          final blogs = resData['blogs'] ?? [];

          if (products.isNotEmpty ||
              categories.isNotEmpty ||
              blogs.isNotEmpty) {
            autocompleteProducts.assignAll(products);
            autocompleteCategories.assignAll(categories);
            autocompleteBlogs.assignAll(blogs);
            return;
          }
        }
      }
      // If remote returned empty (e.g. single-letter stop-word like "a"), fallback to local
      _localAutocomplete(trimmed);
    } catch (_) {
      // Fallback: If network endpoint fails, perform quick local matching from cached lists
      _localAutocomplete(trimmed);
    } finally {
      if (token == _autocompleteToken) {
        isAutocompleteLoading.value = false;
      }
    }
  }

  // ── Full Search Submission (State 3: Results Mode) ──
  void submitSearch([String? text]) {
    final query = (text ?? searchTextController.text).trim();
    if (text != null && text != searchTextController.text) {
      searchTextController.text = text;
    }
    queryText.value = query;
    _debounce?.cancel();
    _autocompleteDebounce?.cancel();

    if (query.isEmpty && selectedBrandSlug.isEmpty) {
      searchMode.value = SearchMode.browse;
      return;
    }

    searchMode.value = SearchMode.results;
    if (query.isNotEmpty) {
      saveRecentSearch(id: '', name: query, type: 'keyword');
    }
    getSearchSuggestion(text: query);
  }

  void clearSearch() {
    searchTextController.clear();
    queryText.value = '';
    selectedBrandSlug.value = '';
    autocompleteProducts.clear();
    autocompleteCategories.clear();
    autocompleteBlogs.clear();
    searchMode.value = SearchMode.browse;
  }

  // ── Sorting ──
  void setSort(String sortKey) {
    selectedSort.value = sortKey;
    final text = searchTextController.text.trim();
    if (searchMode.value == SearchMode.results) {
      getSearchSuggestion(text: text);
    }
  }

  // ── Fetch Full Search Results (Page 1) ──
  void getSearchSuggestion({required String text}) async {
    _debounce?.cancel();
    queryText.value = text;
    final token = ++_searchToken;

    if (text.trim().isEmpty && selectedBrandSlug.isEmpty) {
      searchCategories.clear();
      searchBlogs.clear();
      searchMode.value = SearchMode.browse;
      return;
    }

    final others = Future.wait([
      if (searchesCategories && text.isNotEmpty) _searchCategories(text, token),
      if (searchesBlogs && text.isNotEmpty) _searchBlogs(text, token),
    ]);
    if (!searchesCategories) searchCategories.clear();
    if (!searchesBlogs) searchBlogs.clear();

    try {
      currentPage = 1;
      hasNextPage = false;
      isSearching.value = true;
      searchProduct.clear();

      final params = ProductService.buildQueryParams(
        page: 1,
        search: text.isEmpty ? null : text,
      );

      if (selectedBrandSlug.value.isNotEmpty) {
        params['brand'] = selectedBrandSlug.value;
      }

      // Add sort params
      if (selectedSort.value == 'price_asc') {
        params['sortBy'] = 'price';
        params['sortOrder'] = 'asc';
      } else if (selectedSort.value == 'price_desc') {
        params['sortBy'] = 'price';
        params['sortOrder'] = 'desc';
      } else if (selectedSort.value == 'newest') {
        params['sortBy'] = 'created_at';
        params['sortOrder'] = 'desc';
      }

      var response = await BasicProvider('products')
          .getRequest(queryParams: params)
          .catchError(handleError);

      if (token != _searchToken) return;
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
      final response = await BasicProvider('category').getRequest(queryParams: {
        'search': text.trim(),
        'page': '1'
      }).catchError(handleError);
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

  // ── Brands ──
  void fetchBrands() async {
    try {
      isBrandsLoading.value = true;
      var response =
          await BasicProvider('brands').getRequest().catchError(handleError);

      if (response != null && response is Map && response['data'] is List) {
        brands.assignAll(response['data']);
      }
    } catch (e) {
      debugPrint('❌ fetchBrands error: $e');
    } finally {
      isBrandsLoading.value = false;
    }
  }

  void fetchProductsByBrand(String slug) {
    if (selectedBrandSlug.value == slug) {
      // Toggle off
      selectedBrandSlug.value = "";
      if (searchTextController.text.trim().isEmpty) {
        searchMode.value = SearchMode.browse;
        return;
      }
    } else {
      selectedBrandSlug.value = slug;
    }

    searchMode.value = SearchMode.results;
    getSearchSuggestion(text: searchTextController.text.trim());
  }

  // ── Pagination Load (Page 2+) ──
  void loadNextPage() async {
    try {
      isFetchingMore.value = true;
      currentPage++;

      final params = ProductService.buildQueryParams(
        page: currentPage,
        search: searchTextController.text.trim().isEmpty
            ? null
            : searchTextController.text.trim(),
      );

      if (selectedBrandSlug.value.isNotEmpty) {
        params['brand'] = selectedBrandSlug.value;
      }

      var response = await BasicProvider('products')
          .getRequest(queryParams: params)
          .catchError(handleError);

      _parseAndSetProducts(response, isRefresh: false);
    } catch (e) {
      debugPrint('❌ loadNextPage error: $e');
      currentPage--;
    } finally {
      isFetchingMore.value = false;
    }
  }

  // ── Parser ──
  void _parseAndSetProducts(dynamic response, {required bool isRefresh}) {
    if (response == null) return;

    if (response is Map) {
      if (response.containsKey('data') && response['data'] is List) {
        final List newItems = response['data'];
        if (isRefresh) {
          searchProduct.assignAll(newItems);
        } else {
          searchProduct.addAll(newItems);
        }
        hasNextPage = response['hasNextPage'] ?? false;
      } else {
        if (isRefresh) searchProduct.clear();
        hasNextPage = false;
      }
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
