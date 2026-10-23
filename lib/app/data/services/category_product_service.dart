import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/data/models/category_products_page.dart';

class CategoryProductService {
  static const int pageSize = 20;

  final Map<String, CategoryProductsPage> _categoryCache = {};

  /// Returns null when the request failed or there is no connectivity, so the
  /// caller can show a retry state.
  Future<CategoryProductsPage?> fetchByParentCategory(
    String categoryId, {
    String? categorySlug,
    int page = 1,
    int count = pageSize,
  }) async {
    final cacheKey = '$categoryId:${categorySlug ?? ""}:$page:$count';
    if (_categoryCache.containsKey(cacheKey)) {
      return _categoryCache[cacheKey];
    }

    // 1. Try 'products?parentCategory=$categoryId' which populates variants & pricing
    try {
      final response = await BasicProvider('products').getRequest(queryParams: {
        'parentCategory': categoryId,
        'page': page.toString(),
        'count': count.toString(),
      });
      if (response != null) {
        final pageData = CategoryProductsPage.fromResponse(response);
        if (pageData.items.isNotEmpty) {
          _categoryCache[cacheKey] = pageData;
          return pageData;
        }
      }
    } catch (_) {}

    // 2. Try by slug if available (e.g. 'enclosures')
    if (categorySlug != null && categorySlug.isNotEmpty) {
      try {
        final response = await BasicProvider('products').getRequest(queryParams: {
          'category': categorySlug,
          'page': page.toString(),
          'count': count.toString(),
        });
        if (response != null) {
          final pageData = CategoryProductsPage.fromResponse(response);
          if (pageData.items.isNotEmpty) {
            _categoryCache[cacheKey] = pageData;
            return pageData;
          }
        }
      } catch (_) {}
    }

    // 3. Fallback to 'products/by-parent-category/$categoryId'
    try {
      final fallback = await BasicProvider('products/by-parent-category/$categoryId')
          .getRequest(queryParams: {
        'page': page.toString(),
        'count': count.toString(),
      });
      if (fallback != null) {
        final pageData = CategoryProductsPage.fromResponse(fallback);
        if (pageData.items.isNotEmpty) {
          _categoryCache[cacheKey] = pageData;
          return pageData;
        }
      }
    } catch (_) {}

    return null;
  }

  /// Plain `products` listing (best sellers, latest, …).
  Future<CategoryProductsPage?> fetchProducts({
    String? sortBy,
    String sortOrder = 'desc',
    int count = 12,
    int page = 1,
  }) async {
    final response = await BasicProvider('products').getRequest(queryParams: {
      'page': page.toString(),
      'count': count.toString(),
      if (sortBy != null) 'sort_by': sortBy,
      if (sortBy != null) 'sort_order': sortOrder,
    });
    if (response == null) return null;
    return CategoryProductsPage.fromResponse(response);
  }
}
