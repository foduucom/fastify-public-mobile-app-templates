import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '/app/data/category_filter_service.dart';

/// The three category-tree types the Filter drawer needs. "product" backs
/// the "Category" section — confirm this mapping against a manual
/// `get-tree/product` call before relying on it in production.
const _kCategoryTreeTypes = ['product', 'material', 'style'];

/// Adds Category/Material/Style tree state to [ShopController], backed by
/// the `get-category-types`/`get-tree/{type}` APIs. Kept separate from
/// [ShopCategoryFilterMixin]/[ShopAttributeFilterMixin] to preserve the
/// existing single-responsibility split between shop mixins.
///
/// Ported from SOURCE (fastify-public-mobile-app-templates) as part of
/// PORT_AUDIT.md Phase 4.
mixin ShopCategoryTreeFilterMixin on GetxController {
  final _categoryFilterService = CategoryFilterService();

  final categoryTypes = <String>[].obs;
  final categoryTreeByType = <String, List<CategoryTreeNode>>{}.obs;
  final categoryTreeErrorByType = <String, bool>{}.obs;
  final isCategoryTreeLoading = false.obs;

  final _loadedTypes = <String>{};

  Future<void> ensureCategoryTreeLoaded() async {
    if (isCategoryTreeLoading.value) return;
    final pending =
        _kCategoryTreeTypes.where((t) => !_loadedTypes.contains(t)).toList();
    if (pending.isEmpty) return;

    isCategoryTreeLoading.value = true;
    try {
      if (categoryTypes.isEmpty) {
        categoryTypes.assignAll(await _categoryFilterService.getCategoryTypes());
      }

      // Sequential, not Future.wait: a single failed type must not blank
      // out the other sections.
      for (final type in pending) {
        try {
          final nodes = await _categoryFilterService.getTree(type);
          categoryTreeByType[type] = nodes;
          categoryTreeErrorByType[type] = false;
          _loadedTypes.add(type);
        } catch (e) {
          debugPrint('❌ ensureCategoryTreeLoaded($type) error: $e');
          categoryTreeErrorByType[type] = true;
        }
      }
    } finally {
      isCategoryTreeLoading.value = false;
    }
  }

  /// Retries only the types that previously failed.
  Future<void> retryCategoryTreeType(String type) async {
    _loadedTypes.remove(type);
    categoryTreeErrorByType[type] = false;
    await ensureCategoryTreeLoaded();
  }
}
