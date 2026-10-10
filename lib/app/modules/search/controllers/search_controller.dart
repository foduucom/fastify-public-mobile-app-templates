import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_mixin.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SearchsController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  static const String pageSlug = 'search';

  /// Max categories / blogs previewed in the unified results.
  static const int _previewLimit = 10;

  var searchProduct = [].obs;
  final queryText = ''.obs;
  var searchCategories = [].obs;
  var searchBlogs = [].obs;
  var recentSearchList = [].obs;

  var isSearching = false.obs; // True for initial load
  var isFetchingMore = false.obs; // True for pagination load

  var box = GetStorage();
  late TextEditingController searchTextController;
  late ScrollController scrollController;

  // Pagination Trackers
  int currentPage = 1;
  bool hasNextPage = false;

  Timer? _debounce;
  int _searchToken = 0;
  List? _blogCache;

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
    // The page renders its own dedicated search field above the CMS
    // layout, so skip any `search` block from the CMS config to avoid
    // showing a second, redundant search bar.
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
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
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
    final exists = recentSearchList
        .any((e) => e['productId'] == id && e['type'] == type);
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
          .getRequest(queryParams: {'page': currentPage.toString()})
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
      currentPage = 1;
      hasNextPage = false;
      isSearching.value = true;
      searchProduct.clear();

      var response = await BasicProvider('products')
          .getRequest(queryParams: {'search': text, 'page': currentPage.toString()})
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
  // match name / excerpt on the device.
  Future<void> _searchBlogs(String text, int token) async {
    try {
      _blogCache ??= await _loadBlogs();
      if (token != _searchToken) return;
      final q = text.trim().toLowerCase();
      bool hit(dynamic v) => v?.toString().toLowerCase().contains(q) ?? false;
      searchBlogs.assignAll(_blogCache!
          .where((b) =>
              b is Map &&
              (hit(b['name']) || hit(b['title']) || hit(b['excerpt'])))
          .take(_previewLimit)
          .toList());
    } catch (e) {
      debugPrint('❌ search blogs error: $e');
    }
  }

  Future<List> _loadBlogs() async {
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
    return raw is List ? raw : const [];
  }

  // ── Pagination Load (Page 2+) ──
  void loadNextPage() async {
    try {
      isFetchingMore.value = true;
      currentPage++;

      // Check if we are searching or just browsing all
      String text = searchTextController.text.trim();
      Map<String, String> queryParams = {'page': currentPage.toString()};
      if (text.isNotEmpty) {
        queryParams['search'] = text;
      }

      var response = await BasicProvider('products')
          .getRequest(queryParams: queryParams)
          .catchError(handleError);

      _parseAndSetProducts(response, isRefresh: false);
    } catch (e) {
      debugPrint('❌ loadNextPage error: $e');
      currentPage--; // Revert page number on failure
    } finally {
      isFetchingMore.value = false;
    }
  }

  // ── Parser ──
  // API shape: { status, data: { data: [...], total, current_page, has_next } }
  void _parseAndSetProducts(dynamic response, {required bool isRefresh}) {
    if (response == null) return;

    if (response is Map) {
      // Unwrap outer { data: { data: [...], has_next } }
      final outer = response['data'];
      if (outer is Map) {
        final List newItems = (outer['data'] as List?) ?? [];
        if (isRefresh) {
          searchProduct.assignAll(newItems);
        } else {
          searchProduct.addAll(newItems);
        }
        hasNextPage = outer['has_next'] == true;
        return;
      }

      // Flat { data: [...] }
      if (response.containsKey('data') && response['data'] is List) {
        final List newItems = response['data'];
        if (isRefresh) {
          searchProduct.assignAll(newItems);
        } else {
          searchProduct.addAll(newItems);
        }
        hasNextPage = response['has_next'] == true || response['hasNextPage'] == true;
        return;
      }

      if (isRefresh) searchProduct.clear();
      hasNextPage = false;
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