import 'dart:async';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategorySearchFilterController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  final searchController = TextEditingController();
  static const String pageSlug = 'category';

  final categories = <dynamic>[].obs;
  final parentCategories = <dynamic>[].obs;

  final isLoading = false.obs;
  final isFetchingMore = false.obs;

  final searchText = ''.obs;
  final showOnlyParents = false.obs;
  final showOnlyChildren = false.obs;
  final selectedType = 'all'.obs; // 'all', 'product', 'home_category'
  final selectedParentSlug = ''.obs;

  final currentPage = 1.obs;
  final totalCount = 0.obs;
  final hasNextPage = false.obs;

  Timer? _debounce;

  static const int _pageSize = 10;

  @override
  Future<void> onInit() async {
    super.onInit();
    await fetchLayout(pageSlug);
    await _loadParentCategories();
    await fetchCategories(reset: true);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchText.value = value;
      fetchCategories(reset: true);
    });
  }

  void toggleShowOnlyParents(bool? value) {
    showOnlyParents.value = value ?? false;
    if (showOnlyParents.value) showOnlyChildren.value = false;
    selectedParentSlug.value = '';
    fetchCategories(reset: true);
  }

  void toggleShowOnlyChildren(bool? value) {
    showOnlyChildren.value = value ?? false;
    if (showOnlyChildren.value) showOnlyParents.value = false;
    fetchCategories(reset: true);
  }

  void onTypeChanged(String? value) {
    selectedType.value = value ?? 'all';
    fetchCategories(reset: true);
  }

  void onParentFilterChanged(String? slug) {
    selectedParentSlug.value = slug ?? '';
    if (selectedParentSlug.value.isNotEmpty) {
      showOnlyParents.value = false;
      showOnlyChildren.value = false;
    }
    fetchCategories(reset: true);
  }

  void clearAllFilters() {
    searchController.clear();
    searchText.value = '';
    showOnlyParents.value = false;
    showOnlyChildren.value = false;
    selectedType.value = 'all';
    selectedParentSlug.value = '';
    fetchCategories(reset: true);
  }

  bool get hasActiveFilters =>
      searchText.value.isNotEmpty ||
      showOnlyParents.value ||
      showOnlyChildren.value ||
      selectedType.value != 'all' ||
      selectedParentSlug.value.isNotEmpty;

  Future<void> _loadParentCategories() async {
    final response = await BasicProvider('category')
        .getRequest(queryParams: {'parentCategory': 'true'})
        .catchError(handleError);

    if (response == null) return;

    List docs = [];
    if (response is Map && response.containsKey('docs')) {
      docs = response['docs'];
    } else if (response is List) {
      docs = response;
    }
    parentCategories.assignAll(docs);
  }

  Future<void> fetchCategories({bool reset = false}) async {
    if (reset) {
      currentPage.value = 1;
      hasNextPage.value = false;
      categories.clear();
      isLoading.value = true;
    } else {
      if (!hasNextPage.value || isFetchingMore.value) return;
      isFetchingMore.value = true;
    }

    final params = _buildQueryParams();

    final response = await BasicProvider('category')
        .getRequest(queryParams: params)
        .catchError(handleError);

    isLoading.value = false;
    isFetchingMore.value = false;

    if (response == null) return;

    List docs = [];
    int total = 0;
    bool nextPage = false;

    if (response is Map) {
      docs = response['docs'] ?? response['data'] ?? [];
      total = response['totalDocs'] ?? response['total'] ?? docs.length;
      nextPage = response['hasNextPage'] ?? response['hasMore'] ?? false;
    } else if (response is List) {
      docs = response;
      total = docs.length;
    }

    if (reset) {
      categories.assignAll(docs);
    } else {
      categories.addAll(docs);
    }

    totalCount.value = total;
    hasNextPage.value = nextPage;
    if (nextPage) currentPage.value++;
  }

  Map<String, String> _buildQueryParams() {
    final params = <String, String>{
      'page': currentPage.value.toString(),
      'limit': _pageSize.toString(),
    };

    if (selectedParentSlug.value.isNotEmpty) {
      params['childrenOfParent'] = selectedParentSlug.value;
      return params;
    }

    if (searchText.value.isNotEmpty) params['search'] = searchText.value;
    if (showOnlyParents.value) params['parentCategory'] = 'true';
    if (showOnlyChildren.value) params['children'] = 'true';
    if (selectedType.value != 'all') params['type'] = selectedType.value;

    return params;
  }

  void onCategoryTap(dynamic category) {
    final List children = category['children'] ?? [];
    if (children.isNotEmpty) {
      Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
        'source': 'category',
        'categoryId': category['_id'],
        'categorySlug': category['slug'],
        'name': category['name'],
        'children': children,
      });
    } else {
      Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
        'productId': category['_id'],
        'categorySlug': category['slug'],
        'name': category['name'],
        'source': 'category',
      });
    }
  }
}
