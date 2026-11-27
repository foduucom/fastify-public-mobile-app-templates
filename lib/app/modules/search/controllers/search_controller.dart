import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '/constants/constants.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/core/foduuStudio/foduu_studio_layout_mixin.dart';
import '/models/blog_model.dart';
import '/services/product_pagination.dart';
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
  final searchSubmitted = false.obs;
  final selectedResultType = 'all'.obs;
  var searchCategories = [].obs;
  var searchBlogs = <BlogModel>[].obs;
  final autocompleteProducts = <dynamic>[].obs;
  final autocompleteCategories = <dynamic>[].obs;
  final autocompleteBlogs = <dynamic>[].obs;
  final autocompleteBrands = <dynamic>[].obs;
  final isAutocompleteLoading = false.obs;
  var recentSearchList = [].obs;

  var isSearching = false.obs; // True for initial load
  var isFetchingMore = false.obs; // True for pagination load
  final searchError = ''.obs;
  final paginationError = ''.obs;

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
  int _autocompleteToken = 0;
  int _paginationToken = 0;
  bool _initialBrowseLoadStarted = false;
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

  int get totalResultCount =>
      searchProduct.length + searchCategories.length + searchBlogs.length;

  List<String> get visibleResultTypes => [
        'all',
        if (searchesProducts) 'products',
        if (searchesCategories) 'categories',
        if (searchesBlogs) 'blog',
      ];

  void selectResultType(String type) {
    selectedResultType.value = type;
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
    fetchBrands();

    // The page renders its own search field above the CMS layout, so skip
    // any `search` block from the CMS to avoid a second search bar.
    excludeSectionTypes = const ['search'];
    fetchLayout(pageSlug);
    super.onInit();
  }

  @override
  Future<dynamic> fetchLayout(String slug,
      {dynamic requestBody, bool silent = false}) async {
    final response =
        await super.fetchLayout(slug, requestBody: requestBody, silent: silent);
    if (slug == pageSlug) {
      final hydrated = _prehydrateProducts(response);
      final canLoadBrowseProducts = !searchSubmitted.value &&
          queryText.value.trim().isEmpty &&
          selectedBrandSlug.value.isEmpty &&
          !activeFilter.value.hasActiveFilters;
      if (hydrated) {
        _initialBrowseLoadStarted = true;
      } else if (canLoadBrowseProducts && !_initialBrowseLoadStarted) {
        _initialBrowseLoadStarted = true;
        loadAllProducts();
      }
    }
    return response;
  }

  bool _prehydrateProducts(dynamic response) {
    if (searchSubmitted.value ||
        queryText.value.trim().isNotEmpty ||
        selectedBrandSlug.value.isNotEmpty ||
        activeFilter.value.hasActiveFilters) {
      return false;
    }
    dynamic sections = response is Map ? response['sections'] : null;
    if (sections is! List) sections = rawSections;

    for (final section in sections) {
      if (section is! Map ||
          section['type']?.toString().toLowerCase() != 'products') {
        continue;
      }
      final content =
          section['content_json'] ?? section['contentJson'] ?? section['data'];
      if (content is! Map) continue;
      dynamic rawProducts = content['products'];
      rawProducts ??= content['data'];
      Map? pagination;
      if (rawProducts is Map) {
        pagination = rawProducts;
        rawProducts = rawProducts['data'] ??
            rawProducts['products'] ??
            rawProducts['docs'];
      }
      if (rawProducts is! List || rawProducts.isEmpty) continue;
      searchProduct
          .assignAll(ProductPagination.uniquePage(const [], rawProducts));
      hasNextPage = pagination == null
          ? false
          : ProductPagination.hasMore(pagination,
              itemCount: rawProducts.length, pageSize: 10);
      currentPage = pagination == null
          ? 1
          : ProductPagination.nextPage(pagination, defaultPage: 2) - 1;
      // The CMS payload is also the local suggestion cache. Invalidate a
      // concurrent browse request before it can replace this data.
      _searchToken++;
      isSearching.value = false;
      return true;
    }
    return false;
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
    if (scrollController.hasClients &&
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
      if (!isFetchingMore.value && hasNextPage) {
        loadNextPage();
      }
    }
  }

  void getRecentSearch() {
    var recent = box.read('recentSearch');
    if (recent != null) {
      if (recent is List) {
        recentSearchList.assignAll(recent
            .whereType<Map>()
            .map((entry) => Map<String, dynamic>.from(entry)));
      }
    }
  }

  void saveRecentSearch({
    required String id,
    required String name,
    required String type,
  }) {
    if (name.trim().isEmpty) return;
    recentSearchList.removeWhere((e) =>
        e is Map &&
        ((id.isNotEmpty &&
                e['productId']?.toString() == id &&
                e['type'] == type) ||
            (type == 'keyword' &&
                e['name']?.toString().toLowerCase() ==
                    name.trim().toLowerCase())));
    recentSearchList
        .insert(0, {'productId': id, 'name': name.trim(), 'type': type});
    if (recentSearchList.length > 10)
      recentSearchList.removeRange(10, recentSearchList.length);
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

  // ── Initial Load (Page 1) ──
  void loadAllProducts() async {
    _initialBrowseLoadStarted = true;
    final token = ++_searchToken;
    _paginationToken++;
    isFetchingMore.value = false;
    paginationError.value = '';
    try {
      searchError.value = '';
      currentPage = 1;
      hasNextPage = false;
      isSearching.value = true;
      searchProduct.clear();

      var response = await BasicProvider('products').getRequest(
          queryParams: ProductService.buildQueryParams(
        page: 1,
        filter: activeFilter.value,
      ));

      if (token == _searchToken) {
        _parseAndSetProducts(response, isRefresh: true);
      }
    } catch (e) {
      if (token != _searchToken) return;
      await handleError(e);
      searchError.value = e.toString();
    } finally {
      if (token == _searchToken) isSearching.value = false;
    }
  }

  // ── Typing entry point: debounced ──
  void onSearchChanged(String text) {
    queryText.value = text;
    searchSubmitted.value = false;
    selectedResultType.value = 'all';
    _searchToken++;
    _paginationToken++;
    isSearching.value = false;
    isFetchingMore.value = false;
    _autocompleteToken++;
    autocompleteProducts.clear();
    autocompleteCategories.clear();
    autocompleteBlogs.clear();
    autocompleteBrands.clear();
    searchError.value = '';
    paginationError.value = '';
    isAutocompleteLoading.value = false;
    _debounce?.cancel();
    if (text.trim().isEmpty) {
      selectedBrandSlug.value = '';
      isSearching.value = false;
      searchCategories.clear();
      searchBlogs.clear();
      loadAllProducts();
      return;
    }
    selectedBrandSlug.value = '';
    _debounce = Timer(const Duration(milliseconds: 250), () {
      fetchAutocomplete(text.trim());
    });
  }

  Future<void> fetchAutocomplete(String query) async {
    final token = ++_autocompleteToken;
    isAutocompleteLoading.value = true;
    try {
      final uri = Uri.parse(
          '${url}search/global?q=${Uri.encodeComponent(query)}&limit=6');
      final response = await http.get(uri, headers: {
        'accept': 'application/json',
        'access-key': ACCESS_KEY
      }).timeout(const Duration(seconds: 5));
      if (token != _autocompleteToken || query != queryText.value.trim())
        return;
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final payload = decoded is Map ? decoded['data'] : null;
        if (decoded is Map && decoded['success'] == true && payload is Map) {
          if (searchesProducts && payload['products'] is List)
            autocompleteProducts
                .assignAll((payload['products'] as List).take(6));
          if (searchesCategories && payload['categories'] is List)
            autocompleteCategories
                .assignAll((payload['categories'] as List).take(4));
          if (searchesBlogs && payload['blogs'] is List)
            autocompleteBlogs.assignAll((payload['blogs'] as List).take(4));
        }
      }
      _fillLocalBrandAutocomplete(query);
      if (autocompleteProducts.isEmpty &&
          autocompleteCategories.isEmpty &&
          autocompleteBlogs.isEmpty) {
        _fillLocalAutocomplete(query);
      }
    } catch (e) {
      debugPrint('Search autocomplete unavailable: $e');
      if (token == _autocompleteToken) _fillLocalAutocomplete(query);
    } finally {
      if (token == _autocompleteToken) isAutocompleteLoading.value = false;
    }
  }

  void _fillLocalAutocomplete(String query) {
    final q = query.toLowerCase();
    if (searchesProducts) {
      autocompleteProducts.assignAll(searchProduct.where((item) {
        if (item is! Map) return false;
        final nameMatch = (item['name'] ?? item['title'] ?? '')
            .toString()
            .toLowerCase()
            .contains(q);
        final rawBrand = item['brand'];
        final brandMatch =
            (rawBrand is Map ? rawBrand['name'] ?? '' : rawBrand ?? '')
                .toString()
                .toLowerCase()
                .contains(q);
        return nameMatch || brandMatch;
      }).take(6));
    }
    _fillLocalBrandAutocomplete(query);
    if (searchesBlogs && _blogCache != null) {
      autocompleteBlogs.assignAll(_blogCache!
          .where((blog) =>
              blog.title.toLowerCase().contains(q) ||
              blog.cleanExcerpt.toLowerCase().contains(q))
          .take(4)
          .map((blog) => {'title': blog.title, 'id': blog.id}));
    }
  }

  void _fillLocalBrandAutocomplete(String query) {
    final q = query.toLowerCase();
    autocompleteBrands.assignAll(brands
        .where((item) =>
            item is Map &&
            (item['name'] ?? '').toString().toLowerCase().contains(q))
        .take(4));
  }

  // ── Search Load (Page 1) ──
  void getSearchSuggestion({required String text}) async {
    _debounce?.cancel();
    _autocompleteToken++;
    isAutocompleteLoading.value = false;
    queryText.value = text;
    searchSubmitted.value = text.trim().isNotEmpty;
    selectedResultType.value = 'all';
    final token = ++_searchToken;
    _paginationToken++;
    isFetchingMore.value = false;
    autocompleteProducts.clear();
    autocompleteCategories.clear();
    autocompleteBlogs.clear();
    autocompleteBrands.clear();
    searchError.value = '';
    paginationError.value = '';
    if (text.trim().isNotEmpty)
      saveRecentSearch(id: '', name: text.trim(), type: 'keyword');

    if (text.trim().isEmpty) {
      searchCategories.clear();
      searchBlogs.clear();
      loadAllProducts();
      return;
    }
    searchCategories.clear();
    searchBlogs.clear();

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
      searchError.value = '';
      selectedBrandSlug.value = ""; // Clear brand selection on search
      currentPage = 1;
      hasNextPage = false;
      isSearching.value = true;
      searchProduct.clear();

      var response = await BasicProvider('products').getRequest(
          queryParams: ProductService.buildQueryParams(
        page: 1,
        search: text,
        filter: activeFilter.value,
      ));
      if (token != _searchToken) return; // a newer search superseded this one
      _parseAndSetProducts(response, isRefresh: true);
    } catch (e) {
      if (token != _searchToken) return;
      await handleError(e);
      searchError.value = e.toString();
    } finally {
      await others;
      if (token == _searchToken) isSearching.value = false;
    }
  }

  // ── Categories ──
  Future<void> _searchCategories(String text, int token) async {
    try {
      final response = await BasicProvider('category')
          .getRequest(queryParams: {'search': text.trim(), 'page': '1'});
      if (token != _searchToken) return;
      final data = _extractList(response, const [
            'data',
            'categories',
            'docs',
            'results',
          ]) ??
          const [];
      searchCategories.assignAll(data.take(_previewLimit).toList());
    } catch (e) {
      debugPrint('❌ search categories error: $e');
      if (token == _searchToken) await handleError(e);
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
      if (token == _searchToken) await handleError(e);
    }
  }

  Future<List<BlogModel>> _loadBlogs() async {
    final response = await BasicProvider('blogs?count=50&page=1').getRequest();
    final raw = _extractList(
        response, const ['data', 'blogs', 'articles', 'docs', 'results']);
    if (raw == null) return const [];
    return raw
        .whereType<Map>()
        .map((e) => BlogModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  List? _extractList(dynamic source, List<String> keys) {
    dynamic current = source;
    for (var depth = 0; depth < 4; depth++) {
      if (current is List) return current;
      if (current is! Map) return null;
      for (final key in keys) {
        if (current[key] is List) return current[key] as List;
      }
      final nested = current['data'];
      if (nested is Map) {
        current = nested;
      } else {
        return null;
      }
    }
    return null;
  }

  // ── Brand Fetching ──
  void fetchBrands() async {
    try {
      isBrandsLoading.value = true;
      final response = await BasicProvider('brands').getRequest();
      final loadedBrands =
          _extractList(response, const ['data', 'brands', 'docs', 'results']);
      if (loadedBrands != null) {
        brands.assignAll(loadedBrands);
        if (queryText.value.trim().isNotEmpty && !searchSubmitted.value) {
          _fillLocalBrandAutocomplete(queryText.value.trim());
        }
      }
    } catch (e) {
      debugPrint('❌ fetchBrands error: $e');
      await handleError(e);
    } finally {
      isBrandsLoading.value = false;
    }
  }

  // ── Products by Brand ──
  void fetchProductsByBrand(String slug) async {
    if (selectedBrandSlug.value == slug) {
      selectedBrandSlug.value = '';
      searchSubmitted.value = false;
      searchCategories.clear();
      searchBlogs.clear();
      loadAllProducts();
      return;
    }
    final token = ++_searchToken;
    _paginationToken++;
    isFetchingMore.value = false;
    paginationError.value = '';
    try {
      searchError.value = '';
      selectedBrandSlug.value = slug;
      searchTextController.clear();
      queryText.value = ''; // Clear search text when filtering by brand
      searchSubmitted.value = true;
      selectedResultType.value = 'all';
      searchCategories.clear();
      searchBlogs.clear();

      currentPage = 1;
      hasNextPage = false;
      isSearching.value = true;
      searchProduct.clear();

      var response = await BasicProvider('products').getRequest(queryParams: {
        ...ProductService.buildQueryParams(page: 1, filter: activeFilter.value),
        'brand': slug,
      });

      if (token == _searchToken)
        _parseAndSetProducts(response, isRefresh: true);
    } catch (e) {
      if (token != _searchToken) return;
      await handleError(e);
      searchError.value = e.toString();
    } finally {
      if (token == _searchToken) isSearching.value = false;
    }
  }

  // ── Pagination Load (Page 2+) ──
  void loadNextPage() async {
    if (isFetchingMore.value || !hasNextPage) return;
    final token = _searchToken;
    final pageToken = ++_paginationToken;
    final requestedPage = currentPage + 1;
    try {
      paginationError.value = '';
      isFetchingMore.value = true;
      currentPage = requestedPage;

      var response = await BasicProvider('products').getRequest(
          queryParams: ProductService.buildQueryParams(
        page: currentPage,
        search: searchTextController.text.trim().isEmpty
            ? null
            : searchTextController.text.trim(),
        filter: activeFilter.value,
      )..addAll(selectedBrandSlug.value.isEmpty
              ? const {}
              : {'brand': selectedBrandSlug.value}));

      if (token == _searchToken && pageToken == _paginationToken) {
        _parseAndSetProducts(response, isRefresh: false);
      }
    } catch (e) {
      debugPrint('❌ loadNextPage error: $e');
      if (token != _searchToken || pageToken != _paginationToken) return;
      await handleError(e);
      paginationError.value = e.toString();
      currentPage = requestedPage - 1;
    } finally {
      if (pageToken == _paginationToken) isFetchingMore.value = false;
    }
  }

  // ── Filter methods ──
  void applyFilter(FilterModel filter) {
    activeFilter.value = filter;
    // Re-fetch from page 1 with current search text + new filters
    final text = searchTextController.text.trim();
    if (text.isNotEmpty) {
      getSearchSuggestion(text: text);
    } else if (selectedBrandSlug.value.isNotEmpty) {
      fetchProductsByBrand(selectedBrandSlug.value);
    } else {
      loadAllProducts();
    }
  }

  void clearFilter() {
    applyFilter(const FilterModel.empty());
  }

  void retrySearch() {
    final query = searchTextController.text.trim();
    if (selectedBrandSlug.value.isNotEmpty) {
      fetchProductsByBrand(selectedBrandSlug.value);
    } else if (query.isNotEmpty) {
      getSearchSuggestion(text: query);
    } else {
      loadAllProducts();
    }
  }

  // ── Parser ──
  void _parseAndSetProducts(dynamic response, {required bool isRefresh}) {
    List? newItems;
    Map? pagination;
    if (response is Map) {
      dynamic current = response;
      for (var depth = 0; depth < 4; depth++) {
        if (current is! Map) break;
        final listKey = ['data', 'products', 'product', 'docs', 'results']
            .firstWhere((key) => current[key] is List, orElse: () => '');
        if (listKey.isNotEmpty) {
          newItems = current[listKey] as List;
          pagination = current;
          break;
        }
        if (current['data'] is Map) {
          current = current['data'];
        } else {
          break;
        }
      }
    } else if (response is List) {
      newItems = response;
    }

    if (newItems == null) {
      throw const FormatException('Unexpected product search response.');
    }
    hasNextPage = pagination == null
        ? false
        : ProductPagination.hasMore(pagination,
            itemCount: newItems.length, pageSize: 10);
    if (isRefresh && pagination != null) {
      currentPage = ProductPagination.nextPage(pagination, defaultPage: 2) - 1;
    }
    if (!isRefresh && newItems.isEmpty) hasNextPage = false;
    final uniqueItems = isRefresh
        ? ProductPagination.uniquePage(const [], newItems)
        : ProductPagination.uniquePage(searchProduct, newItems);
    if (isRefresh) {
      searchProduct.assignAll(uniqueItems);
    } else {
      searchProduct.addAll(uniqueItems);
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
