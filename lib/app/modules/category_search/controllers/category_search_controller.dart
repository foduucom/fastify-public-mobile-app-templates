import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/app/modules/category/views/category_dialog.dart';
import '/app/routes/app_pages.dart';

class CategorySearchController extends GetxController with BaseController {
  // ─── Lists ───────────────────────────────────────────────────────────────
  var categories = [].obs;
  var parentCategories = [].obs;

  // ─── Loading States ───────────────────────────────────────────────────────
  var isLoading = false.obs;
  var isFetchingMore = false.obs;
  var isParentsLoading = false.obs;

  // ─── Result Count ─────────────────────────────────────────────────────────
  var totalCount = 0.obs;

  // ─── Filter State ─────────────────────────────────────────────────────────
  var showOnlyParents = false.obs;
  var showOnlyChildren = false.obs;
  var selectedType = 'all'.obs; // 'all' | 'product' | 'home_category'
  var selectedParentSlug = ''.obs;
  var searchTxt = ''.obs;

  // ─── Pagination ───────────────────────────────────────────────────────────
  int currentPage = 1;
  bool hasNextPage = false;

  // ─── Controllers ─────────────────────────────────────────────────────────
  late TextEditingController searchTextController;
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void onInit() {
    searchTextController = TextEditingController();
    scrollController = ScrollController()..addListener(_scrollListener);
    fetchParentCategories();
    fetchCategories(isRefresh: true);
    super.onInit();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchTextController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ─── Scroll Listener ──────────────────────────────────────────────────────
  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isFetchingMore.value && hasNextPage) {
        loadNextPage();
      }
    }
  }

  // ─── Fetch Parent Categories (for dropdown) ───────────────────────────────
  Future<void> fetchParentCategories() async {
    try {
      isParentsLoading.value = true;
      final response = await BasicProvider('category').getRequest(
          queryParams: {'parentCategory': 'true'}).catchError(handleError);
      if (response == null) return;

      final List data = response is List
          ? response
          : (response is Map && response['data'] is List
              ? response['data']
              : []);
      parentCategories.assignAll(data);
    } catch (e) {
      debugPrint('❌ fetchParentCategories error: $e');
    } finally {
      isParentsLoading.value = false;
    }
  }

  // ─── Fetch Categories ─────────────────────────────────────────────────────
  Future<void> fetchCategories({required bool isRefresh}) async {
    try {
      if (isRefresh) {
        isLoading.value = true;
        currentPage = 1;
        hasNextPage = false;
        categories.clear();
        totalCount.value = 0;
      }

      final params = _buildQueryParams(page: currentPage);
      debugPrint('fetchCategories paramsss === $params');
      final response = await BasicProvider('category')
          .getRequest(queryParams: params)
          .catchError(handleError);

      _parseResponse(response, isRefresh: isRefresh);
    } catch (e) {
      debugPrint('❌ fetchCategories error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Pagination ───────────────────────────────────────────────────────────
  Future<void> loadNextPage() async {
    try {
      isFetchingMore.value = true;
      currentPage++;
      final params = _buildQueryParams(page: currentPage);
      final response = await BasicProvider('category')
          .getRequest(queryParams: params)
          .catchError(handleError);
      _parseResponse(response, isRefresh: false);
    } catch (e) {
      debugPrint('❌ loadNextPage error: $e');
      currentPage--;
    } finally {
      isFetchingMore.value = false;
    }
  }

  // ─── Build Query Params ───────────────────────────────────────────────────
  Map<String, String> _buildQueryParams({required int page}) {
    final params = <String, String>{'page': page.toString()};

    final search = searchTextController.text.trim();
    if (search.isNotEmpty) params['search'] = search;

    if (showOnlyParents.value) {
      params['parentCategory'] = 'true';
    } else if (showOnlyChildren.value) {
      params['children'] = 'true';
    }

    if (selectedType.value != 'all') params['type'] = selectedType.value;

    if (selectedParentSlug.value.isNotEmpty) {
      params['childrenOfParent'] = selectedParentSlug.value;
      params.remove('parentCategory');
      params.remove('children');
    }

    return params;
  }

  // ─── Response Parser ──────────────────────────────────────────────────────
  void _parseResponse(dynamic response, {required bool isRefresh}) {
    if (response == null) return;

    List newItems = [];
    if (response is Map && response['data'] is List) {
      newItems = response['data'];
      hasNextPage = response['hasNextPage'] ?? false;
      totalCount.value = response['total'] ??
          (isRefresh ? newItems.length : totalCount.value + newItems.length);
    } else if (response is List) {
      newItems = response;
      hasNextPage = false;
      totalCount.value =
          isRefresh ? newItems.length : totalCount.value + newItems.length;
    }

    if (isRefresh) {
      categories.assignAll(newItems);
    } else {
      categories.addAll(newItems);
    }
  }

  // ─── Filter Methods ───────────────────────────────────────────────────────
  void onSearchChanged(String text) {
    searchTxt.value = text;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      fetchCategories(isRefresh: true);
    });
  }

  void toggleParentOnly(bool val) {
    showOnlyParents.value = val;
    if (val) {
      showOnlyChildren.value = false;
      selectedParentSlug.value = '';
    }
    fetchCategories(isRefresh: true);
  }

  void toggleChildrenOnly(bool val) {
    showOnlyChildren.value = val;
    if (val) showOnlyParents.value = false;
    fetchCategories(isRefresh: true);
  }

  void setType(String type) {
    selectedType.value = type;
    fetchCategories(isRefresh: true);
  }

  void setParentFilter(String slug) {
    selectedParentSlug.value = slug;
    showOnlyParents.value = false;
    showOnlyChildren.value = false;
    fetchCategories(isRefresh: true);
  }

  void clearAllFilters() {
    searchTextController.clear();
    searchTxt.value = '';
    showOnlyParents.value = false;
    showOnlyChildren.value = false;
    selectedType.value = 'all';
    selectedParentSlug.value = '';
    fetchCategories(isRefresh: true);
  }

  bool get hasActiveFilters =>
      searchTxt.value.trim().isNotEmpty ||
      showOnlyParents.value ||
      showOnlyChildren.value ||
      selectedType.value != 'all' ||
      selectedParentSlug.value.isNotEmpty;

  // ─── Navigation ───────────────────────────────────────────────────────────
  void navigateToCategory(dynamic category) {
    final children = category['children'];
    if (children is List && children.isNotEmpty) {
      Get.dialog(
        CategoryDialog(category: category),
        barrierDismissible: true,
      );
    } else {
      Get.toNamed(
        Routes.SHOPPRODUCTLISTVIEW,
        arguments: {
          'productId': category['_id'],
          'categorySlug': category['slug'],
          'name': category['name'],
          'source': 'category',
        },
      );
    }
  }
}
