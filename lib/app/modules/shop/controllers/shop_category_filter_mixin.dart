import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:get/get.dart';

/// Adds category drill-down/browsing state to [ShopController]: the full
/// category tree, the currently-visible level (for the Sub Category strip),
/// a breadcrumb stack for navigating back up, and per-category product counts.
mixin ShopCategoryFilterMixin on GetxController {
  final allCategories = <dynamic>[].obs;
  final filterCurrentCategories = <dynamic>[].obs;
  final filterCategoryStack = <Map<String, dynamic>>[].obs;
  final categorySearchController = TextEditingController();
  final categorySearchQuery = ''.obs;
  final categoryCountCache = <String, int>{}.obs;
  final isCountLoading = <String, bool>{}.obs;
  final isCategoriesDropdownExpanded = false.obs;

  bool get isSelectedCategoryParent {
    if (filterCategoryStack.isEmpty) return false;
    final current = filterCategoryStack.last['cat'] as Map;
    final children = current['children'];
    return children is List && children.isNotEmpty;
  }

  /// Seeds the drill-down state from a top-level category doc (used both by
  /// direct navigation args and by [fetchCategoryBySlug] for deep links).
  void seedCategoryContext(dynamic category) {
    filterCategoryStack.clear();
    filterCurrentCategories.assignAll(category['children'] ?? []);
  }

  void drillIntoCategory(dynamic category) {
    final List children = category['children'] ?? [];
    filterCategoryStack.add({'cat': category});
    filterCurrentCategories.assignAll(children);
  }

  void goUpFilterCategory() {
    if (filterCategoryStack.isEmpty) return;
    filterCategoryStack.removeLast();
    if (filterCategoryStack.isEmpty) {
      // Back to the root category passed in via navigation arguments.
      filterCurrentCategories.assignAll(
        (Get.arguments is Map ? Get.arguments['children'] : null) ?? [],
      );
    } else {
      final parent = filterCategoryStack.last['cat'] as Map;
      filterCurrentCategories.assignAll(parent['children'] ?? []);
    }
  }

  List<Map<String, dynamic>> getSearchedCategories(String query) {
    final lower = query.toLowerCase();
    return allCategories
        .where((c) =>
            (c['name']?.toString().toLowerCase() ?? '').contains(lower))
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Resolves a category doc (including `children`) by slug for entry points
  /// that only carry a slug (e.g. deep links) rather than a pre-loaded doc.
  Future<dynamic> fetchCategoryBySlug(String slug) async {
    dynamic response;
    try {
      response = await BasicProvider('category')
          .getRequest(queryParams: {'slug': slug});
    } catch (e) {
      debugPrint('❌ fetchCategoryBySlug error: $e');
      return null;
    }

    if (response == null) return null;
    List docs = [];
    if (response is Map) {
      docs = response['docs'] ?? response['data'] ?? [];
    } else if (response is List) {
      docs = response;
    }
    return docs.isNotEmpty ? docs.first : null;
  }
}
