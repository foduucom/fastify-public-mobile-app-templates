import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zouhi/app/data/category_index_service.dart';
import 'package:zouhi/app/data/models/product_model.dart';
import 'package:zouhi/app/modules/homepage/controllers/homepage_controller.dart';

class SearchsController extends GetxController with BaseController {
  RxMap<dynamic, dynamic> serachData = {}.obs;
  var searchFocusNode = FocusNode();

  var searchProduct = <Product>[].obs;
  var searchBlog = [].obs;
  var searchCategory = [].obs;
  var recentSearchList = [].obs;
  var recentProducts = [].obs;
  var box = GetStorage();
  final Map<String, _SearchCacheEntry> _productsSearchCache = {};

  // Discovery / Default content
  var featuredProducts = <Product>[].obs;
  var featuredBlogs = [].obs;
  var trendingCategoryProduct = [].obs;
  RxBool isDiscoverLoading = false.obs;
  bool isProcessingLike = false;
  bool isProcessingCart = false;

  static const int minQueryLength = 2;
  static const int productPageSize = 20;

  final TextEditingController searchTextController = TextEditingController();
  final ScrollController resultsScroll = ScrollController();

  /// Trimmed text currently in the search field (reactive, drives the view).
  final RxString query = ''.obs;
  final Rx<SearchTab> activeTab = SearchTab.all.obs;

  final RxBool isProductsLoading = false.obs;
  final RxBool isProductsMore = false.obs;
  final RxBool isCategoriesLoading = false.obs;
  final RxBool isBlogsLoading = false.obs;
  final RxInt productsTotal = 0.obs;
  bool hasMoreProducts = false;

  bool get isSearching =>
      isProductsLoading.value ||
      isCategoriesLoading.value ||
      isBlogsLoading.value;

  /// Index of the rotating placeholder shown while the field is empty.
  final RxInt hintIndex = 0.obs;
  Timer? _hintTimer;

  List<String> get placeholderHints {
    final names = trendingCategoryProduct
        .map((c) => c is Map ? (c['name'] ?? '').toString() : '')
        .where((n) => n.isNotEmpty)
        .take(5)
        .map((n) => 'Search $n')
        .toList();
    return names.isEmpty ? const ['Search products, categories, blogs...'] : names;
  }

  String get currentHint {
    final hints = placeholderHints;
    return hints[hintIndex.value % hints.length];
  }

  void clearRecentSearches() {
    recentSearchList.clear();
    box.write('recentSearch', []);
  }

  Timer? _debounce;
  int _token = 0;
  int _productPage = 1;
  List<Map> _allCategories = [];
  final CategoryIndexService _categoryIndex = CategoryIndexService();
  List<Map> _allBlogs = [];
  Future<void>? _categoriesLoad;
  Future<void>? _blogsLoad;

  @override
  void onInit() {
    getRecentSearch();
    super.onInit();
    getDiscoverData();
    // Build the full (nested) category index before the first keystroke and refresh in background
    _ensureCategories().then((_) {
      _ensureCategories(forceRefresh: true);
    });
    _hintTimer = Timer.periodic(const Duration(milliseconds: 2800), (_) {
      if (query.value.isEmpty) hintIndex.value++;
    });
    searchBlog.clear();
    searchProduct.clear();
    serachData.clear();

    resultsScroll.addListener(() {
      if (activeTab.value != SearchTab.products) return;
      if (resultsScroll.position.pixels >=
          resultsScroll.position.maxScrollExtent - 300) {
        loadMoreProducts();
      }
    });

    Future.delayed(Duration(milliseconds: 300), () {
      FocusScope.of(Get.context!).requestFocus(searchFocusNode);
    });
  }

  void getRecentSearch() {
    var recent = box.read('recentSearch');
    if (recent != null) {
      recentSearchList.addAll(recent);
    }
    var recentProds = box.read('recentProducts');
    if (recentProds != null) {
      recentProducts.addAll(recentProds);
    }
  }

  void addToRecentSearch(String text) {
    if (text.trim().isEmpty) return;
    final query = text.trim();

    // Check if query already exists (case-insensitive check)
    int index = recentSearchList.indexWhere((item) {
      if (item is Map) {
        return item['name']?.toString().toLowerCase() == query.toLowerCase();
      }
      return item.toString().toLowerCase() == query.toLowerCase();
    });

    if (index != -1) {
      recentSearchList.removeAt(index);
    }

    recentSearchList.insert(0, {'name': query});

    // Limit to 10 items
    if (recentSearchList.length > 10) {
      recentSearchList.removeLast();
    }

    box.write('recentSearch', recentSearchList);
  }

  void addToRecentlyViewed(dynamic item, String type) {
    if (item == null || item['_id'] == null) return;

    // Copy the item so we don't mutate reactive objects
    Map<String, dynamic> itemMap = Map<String, dynamic>.from(item);
    itemMap['recentlyViewedType'] = type;

    // Check if item already exists in the list (matching both _id and type)
    int index = recentProducts.indexWhere((existing) {
      if (existing is Map) {
        return existing['_id'] == item['_id'] &&
            existing['recentlyViewedType'] == type;
      }
      return false;
    });

    if (index != -1) {
      recentProducts.removeAt(index);
    }
    recentProducts.insert(0, itemMap);

    // Limit to 15 items
    if (recentProducts.length > 15) {
      recentProducts.removeLast();
    }
    box.write('recentProducts', recentProducts);
  }

  void addToRecentProducts(dynamic product) {
    addToRecentlyViewed(product, 'product');
  }

  /// Backend list endpoints answer with `[...]`, `{data: [...]}` or
  /// `{data: {data: [...]}}` depending on the route; handle all of them.
  List _extractList(dynamic r) {
    if (r is List) return r;
    if (r is Map) {
      final d = r['data'];
      if (d is List) return d;
      if (d is Map && d['data'] is List) return d['data'] as List;
      for (final k in const ['products', 'blogs', 'categories', 'items']) {
        if (r[k] is List) return r[k] as List;
      }
    }
    return const [];
  }

  List<Product> _toProducts(List raw) {
    final out = <Product>[];
    for (final e in raw) {
      if (e is Map) {
        try {
          out.add(Product.fromJson(Map<String, dynamic>.from(e)));
        } catch (err) {
          debugPrint('discover product parse error: $err');
        }
      }
    }
    return out;
  }

  /// Stale-while-revalidate: paint instantly from what the home screen already
  /// loaded/cached, then refresh from the network.
  ///
  /// NOTE: `category/featured` and `products?weekly_top_highlights=true` are
  /// not supported by the backend (null / empty), so discovery is built from
  /// `category/get-tree/product` and `products?sort_by=total_sales`.
  void _seedDiscoverFromCache() {
    try {
      final tree = box.read('home_category_tree');
      if (trendingCategoryProduct.isEmpty && tree is List) {
        trendingCategoryProduct.assignAll(tree);
      }
      final blogs = box.read('home_blogs');
      if (featuredBlogs.isEmpty && blogs is List) {
        featuredBlogs.assignAll(blogs);
      }
      if (Get.isRegistered<HomepageController>()) {
        final home = Get.find<HomepageController>();
        if (trendingCategoryProduct.isEmpty &&
            home.categoryTreeList.isNotEmpty) {
          trendingCategoryProduct.assignAll(home.categoryTreeList.toList());
        }
        if (featuredBlogs.isEmpty && home.blogList.isNotEmpty) {
          featuredBlogs.assignAll(home.blogList.toList());
        }
      }
    } catch (e) {
      debugPrint('discover cache seed error: $e');
    }
  }

  Future<void> getDiscoverData() async {
    _seedDiscoverFromCache();
    isDiscoverLoading.value = true;
    try {
      await Future.wait([
        _getFeaturedCategories(),
        _getFeaturedProducts(),
        _getFeaturedBlogs(),
      ]);
    } catch (e) {
      debugPrint('Error fetching discover data: $e');
    } finally {
      isDiscoverLoading.value = false;
      debugPrint('discover loaded: categories=${trendingCategoryProduct.length} '
          'products=${featuredProducts.length} blogs=${featuredBlogs.length}');
    }
  }

  Future<void> _getFeaturedCategories() async {
    try {
      final response = await BasicProvider('category/get-tree/product')
          .getRequest()
          .catchError(handleError);
      final list = _extractList(response)
          .where((c) => c is Map && (c['name'] ?? '').toString().isNotEmpty)
          .toList();
      if (list.isNotEmpty) trendingCategoryProduct.assignAll(list);
    } catch (e) {
      debugPrint('discover categories error: $e');
    }
  }

  Future<void> _getFeaturedProducts() async {
    try {
      // Best sellers; over-fetch because unpriced catalogue entries are skipped.
      final response = await BasicProvider('products').getRequest(queryParams: {
        'sort_by': 'total_sales',
        'sort_order': 'desc',
        'count': '24',
        'page': '1',
      }).catchError(handleError);
      final list = _toProducts(_extractList(response)).where((p) {
        final price = double.tryParse(p.price) ?? 0;
        final sale = double.tryParse(p.salePrice) ?? 0;
        return price > 0 || sale > 0;
      }).take(10).toList();
      if (list.isNotEmpty) featuredProducts.assignAll(list);
    } catch (e) {
      debugPrint('discover products error: $e');
    }
  }

  Future<void> _getFeaturedBlogs() async {
    try {
      final response =
          await BasicProvider('blogs').getRequest().catchError(handleError);
      final list = _extractList(response);
      if (list.isNotEmpty) featuredBlogs.assignAll(list);
    } catch (e) {
      debugPrint('featured blogs error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Search (individual APIs)
  //
  // Products   -> server side:  GET products?search=<q>&page=&count=
  // Categories -> client side:  category tree is fetched once, flattened and
  //                             filtered locally (backend has no search param)
  // Blogs      -> client side:  blog list is fetched once and filtered locally
  //
  // Every type has its own loading state and try/catch so that one failing
  // API never blanks the other sections, and a request token makes sure a
  // slow response for an old query can never overwrite the latest one.
  // ---------------------------------------------------------------------------

  /// Called on every keystroke. Debounced so the API is hit once per pause.
  void onQueryChanged(String value) {
    final text = value.trim();
    query.value = text;
    _debounce?.cancel();

    if (text.length < minQueryLength) {
      _token++; // invalidate in-flight requests
      _clearResults();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(text));
  }

  /// Runs immediately (keyboard "search", recent-search tap).
  void searchNow(String text) {
    final q = text.trim();
    query.value = q;
    _debounce?.cancel();
    if (q.length < minQueryLength) {
      _token++;
      _clearResults();
      return;
    }
    _search(q);
  }

  /// Kept for existing callers.
  void getSearchSuggestion({required String text}) => searchNow(text);

  void clearSearch() {
    _debounce?.cancel();
    _token++;
    searchTextController.clear();
    query.value = '';
    activeTab.value = SearchTab.all;
    _clearResults();
  }

  void _clearResults() {
    searchProduct.clear();
    searchBlog.clear();
    searchCategory.clear();
    productsTotal.value = 0;
    hasMoreProducts = false;
    isProductsLoading.value = false;
    isCategoriesLoading.value = false;
    isBlogsLoading.value = false;
  }

  Future<void> _search(String q) async {
    final token = ++_token;
    _productPage = 1;
    hasMoreProducts = false;
    isProductsLoading.value = true;
    isCategoriesLoading.value = true;
    isBlogsLoading.value = true;
    if (resultsScroll.hasClients) resultsScroll.jumpTo(0);

    await Future.wait([
      _searchProducts(q, token),
      _searchCategories(q, token),
      _searchBlogs(q, token),
    ]);
  }

  bool _isStale(int token) => token != _token;

  Future<void> _searchProducts(String q, int token) async {
    try {
      dynamic response;
      final cached = _productsSearchCache[q];
      if (cached != null && !cached.isExpired) {
        response = cached.data;
      } else {
        response = await BasicProvider('products')
            .getRequest(queryParams: {
          'search': q,
          'page': '1',
          'count': '$productPageSize',
        }).catchError(handleError);
        if (response != null) _productsSearchCache[q] = _SearchCacheEntry(response);
      }
      if (_isStale(token)) return;

      final page = _parseProductsPage(response);
      searchProduct.assignAll(page.items);
      productsTotal.value = page.total;
      hasMoreProducts = page.hasNext;
    } catch (e) {
      debugPrint('search products error: $e');
    } finally {
      if (!_isStale(token)) isProductsLoading.value = false;
    }
  }

  Future<void> loadMoreProducts() async {
    if (isProductsLoading.value ||
        isProductsMore.value ||
        !hasMoreProducts ||
        query.value.length < minQueryLength) {
      return;
    }
    final token = _token;
    final q = query.value;
    isProductsMore.value = true;
    try {
      final response = await BasicProvider('products').getRequest(queryParams: {
        'search': q,
        'page': '${_productPage + 1}',
        'count': '$productPageSize',
      }).catchError(handleError);
      if (_isStale(token)) return;
      if (response == null) return;
      final page = _parseProductsPage(response);
      _productPage++;
      final known = searchProduct.map((p) => p.id).toSet();
      searchProduct.addAll(page.items.where((p) => !known.contains(p.id)));
      hasMoreProducts = page.hasNext && page.items.isNotEmpty;
    } catch (e) {
      debugPrint('search more products error: $e');
    } finally {
      isProductsMore.value = false;
    }
  }

  _ProductsPage _parseProductsPage(dynamic response) {
    List raw = const [];
    bool? hasNext;
    int? total;
    if (response is List) {
      raw = response;
    } else if (response is Map) {
      if (response['data'] is List) {
        raw = response['data'];
      } else if (response['products'] is List) {
        raw = response['products'];
      }
      if (response['hasNextPage'] is bool) hasNext = response['hasNextPage'];
      total = int.tryParse('${response['total'] ?? ''}');
    }
    final items = <Product>[];
    for (final e in raw) {
      if (e is Map) {
        try {
          items.add(Product.fromJson(Map<String, dynamic>.from(e)));
        } catch (err) {
          debugPrint('search product parse error: $err');
        }
      }
    }
    return _ProductsPage(
      items: items,
      hasNext: hasNext ?? items.length >= productPageSize,
      total: total ?? items.length,
    );
  }

  // ---- Categories (client side) ---------------------------------------------

  Future<void> _searchCategories(String q, int token) async {
    try {
      await _ensureCategories();
      if (_isStale(token)) return;
      searchCategory.assignAll(_filterByName(_allCategories, q));
    } catch (e) {
      debugPrint('search categories error: $e');
    } finally {
      if (!_isStale(token)) isCategoriesLoading.value = false;
    }
  }

  Future<void> _ensureCategories({bool forceRefresh = false}) {
    if (_allCategories.isNotEmpty && !forceRefresh) return Future.value();
    return _categoriesLoad ??=
        _loadCategories(forceRefresh: forceRefresh).whenComplete(() {
      _categoriesLoad = null;
    });
  }

  Future<void> _loadCategories({bool forceRefresh = false}) async {
    final entries = await _categoryIndex.ensureLoaded(forceRefresh: forceRefresh);
    _allCategories = entries.map((e) => e.toMap()).toList();
  }

  /// Public helper to re-index categories (e.g. on pull-to-refresh)
  Future<void> refreshCategories() => _ensureCategories(forceRefresh: true);

  // ---- Blogs (client side) ----------------------------------------------------

  Future<void> _searchBlogs(String q, int token) async {
    try {
      await _ensureBlogs();
      if (_isStale(token)) return;
      searchBlog.assignAll(_filterByName(_allBlogs, q));
    } catch (e) {
      debugPrint('search blogs error: $e');
    } finally {
      if (!_isStale(token)) isBlogsLoading.value = false;
    }
  }

  Future<void> _ensureBlogs() {
    if (_allBlogs.isNotEmpty) return Future.value();
    return _blogsLoad ??= _loadBlogs().whenComplete(() {
      _blogsLoad = null;
    });
  }

  Future<void> _loadBlogs() async {
    final all = <Map>[];
    int page = 1;
    bool hasNext = true;
    // Safety cap so a huge blog list can't loop forever.
    while (hasNext && page <= 10) {
      final response = await BasicProvider('blogs').getRequest(queryParams: {
        'page': '$page',
        'count': '50',
      }).catchError(handleError);
      if (response == null) break;

      List raw = const [];
      hasNext = false;
      if (response is List) {
        raw = response;
      } else if (response is Map) {
        if (response['data'] is List) raw = response['data'];
        hasNext = response['hasNextPage'] == true;
      }
      for (final b in raw) {
        if (b is Map) all.add(b);
      }
      page++;
    }
    _allBlogs = all;
  }

  // ---- Local matching ---------------------------------------------------------

  /// Every query word must appear in the name or breadcrumb hierarchy;
  /// names starting with the query rank first, then names with a word starting
  /// with it, then breadcrumb matches.
  List _filterByName(List<Map> source, String q) {
    final tokens = q
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return const [];
    final lowerQ = q.toLowerCase();

    final scored = <MapEntry<int, Map>>[];
    for (final item in source) {
      final name =
          (item['name'] ?? item['title'] ?? '').toString().toLowerCase();
      final breadcrumb = (item['breadcrumb'] ?? '').toString().toLowerCase();
      final searchTarget = breadcrumb.isNotEmpty ? '$breadcrumb $name' : name;

      if (searchTarget.isEmpty || !tokens.every(searchTarget.contains)) continue;

      int score = 3;
      if (name.startsWith(lowerQ)) {
        score = 0;
      } else if (name.contains(' $lowerQ')) {
        score = 1;
      } else if (name.contains(lowerQ)) {
        score = 2;
      }
      scored.add(MapEntry(score, item));
    }
    scored.sort((a, b) => a.key.compareTo(b.key));
    return scored.map((e) => e.value).toList();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _hintTimer?.cancel();
    resultsScroll.dispose();
    searchTextController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }
}

enum SearchTab { all, products, categories, blogs }

class _ProductsPage {
  final List<Product> items;
  final bool hasNext;
  final int total;
  _ProductsPage(
      {required this.items, required this.hasNext, required this.total});
}

class _SearchCacheEntry {
  final dynamic data;
  final DateTime timestamp;

  _SearchCacheEntry(this.data) : timestamp = DateTime.now();

  bool get isExpired => DateTime.now().difference(timestamp).inSeconds > 60;
}
