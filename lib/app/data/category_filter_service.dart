import 'package:foduu_ecommerce/app/data/basic_provider.dart';

/// A node from the `category/get-tree/{type}` API. [children] is parsed but
/// intentionally unused today (the Filter drawer renders flat top-level
/// checkboxes only) — kept for a possible future nested-drawer variant.
class CategoryTreeNode {
  final String id;
  final String name;
  final String slug;
  final bool isFeatured;
  final List<CategoryTreeNode> children;

  CategoryTreeNode({
    required this.id,
    required this.name,
    required this.slug,
    required this.isFeatured,
    required this.children,
  });

  factory CategoryTreeNode.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    return CategoryTreeNode(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      isFeatured: json['is_featured'] == true,
      children: rawChildren is List
          ? rawChildren
              .whereType<Map>()
              .map((c) => CategoryTreeNode.fromJson(
                  Map<String, dynamic>.from(c)))
              .toList()
          : const [],
    );
  }
}

/// Fetches the category-type tree (Category/Material/Style) used to drive
/// the Filter drawer, via the two new backend endpoints:
/// `category/get-category-types` and `category/get-tree/{type}`.
class CategoryFilterService {
  Future<List<String>> getCategoryTypes() async {
    final response =
        await BasicProvider('category/get-category-types').getRequest();
    if (response is List) return response.map((e) => e.toString()).toList();
    if (response is Map && response['data'] is List) {
      return (response['data'] as List).map((e) => e.toString()).toList();
    }
    return const [];
  }

  Future<List<CategoryTreeNode>> getTree(String type) async {
    final response =
        await BasicProvider('category/get-tree/$type').getRequest();
    List raw = const [];
    if (response is List) {
      raw = response;
    } else if (response is Map) {
      if (response['data'] is List) {
        raw = response['data'];
      } else if (response['data'] is Map && response['data']['data'] is List) {
        raw = response['data']['data'];
      } else if (response['docs'] is List) {
        raw = response['docs'];
      }
    }

    return raw
        .whereType<Map>()
        .map((e) =>
            CategoryTreeNode.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
