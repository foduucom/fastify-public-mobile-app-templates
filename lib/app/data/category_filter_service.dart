import 'package:foddu/app/data/basic_provider.dart';

/// A node from the `category/get-tree/{type}` API.
class CategoryTreeNode {
  final String id;
  final String name;
  final String slug;
  final bool isFeatured;
  final List<CategoryTreeNode> children;
  final String breadcrumb;

  CategoryTreeNode({
    required this.id,
    required this.name,
    required this.slug,
    required this.isFeatured,
    required this.children,
    this.breadcrumb = '',
  });

  factory CategoryTreeNode.fromJson(
    Map<String, dynamic> json, {
    String parentBreadcrumb = '',
  }) {
    final name = json['name']?.toString() ?? '';
    final breadcrumb =
        parentBreadcrumb.isEmpty ? name : '$parentBreadcrumb › $name';
    final rawChildren = json['children'];
    return CategoryTreeNode(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: name,
      slug: json['slug']?.toString() ?? '',
      isFeatured: json['is_featured'] == true ||
          const {'true', '1', 'yes'}
              .contains(json['is_featured']?.toString().toLowerCase()),
      breadcrumb: breadcrumb,
      children: rawChildren is List
          ? rawChildren
              .whereType<Map>()
              .map((c) => CategoryTreeNode.fromJson(
                    Map<String, dynamic>.from(c),
                    parentBreadcrumb: breadcrumb,
                  ))
              .toList()
          : const [],
    );
  }

  Iterable<CategoryTreeNode> get flattened sync* {
    yield this;
    for (final child in children) {
      yield* child.flattened;
    }
  }
}

/// Fetches the category-type tree (Category/Material/Style) used to drive
/// the Filter drawer, via the two new backend endpoints:
/// `category/get-category-types` and `category/get-tree/{type}`.
class CategoryFilterService {
  static const _maxHydratedChildren = 300;
  static const _maxTreeDepth = 5;
  static const _hydrationBatchSize = 6;

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

    final hydratedRaw = await _hydrateChildren(raw);
    return hydratedRaw
        .whereType<Map>()
        .map((e) => CategoryTreeNode.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<dynamic>> _hydrateChildren(List rawRoots) async {
    final roots = <Map<String, dynamic>>[];
    final seen = <String>{};
    final pending = <_PendingCategoryChild>[];

    void collectChildren(Map<String, dynamic> parent, int depth) {
      final rawChildren = parent['children'];
      if (rawChildren is! List) {
        parent['children'] = <Map<String, dynamic>>[];
        return;
      }
      final children = <Map<String, dynamic>>[];
      for (final child in rawChildren) {
        if (child is Map) {
          final childMap = Map<String, dynamic>.from(child);
          final childId =
              (childMap['_id'] ?? childMap['id'] ?? '').toString().trim();
          if (childId.isNotEmpty && !seen.add(childId)) continue;
          children.add(childMap);
          collectChildren(childMap, depth + 1);
        } else if (child is String && child.trim().isNotEmpty) {
          final childId = child.trim();
          if (!seen.contains(childId) && depth <= _maxTreeDepth) {
            seen.add(childId);
            pending.add(_PendingCategoryChild(childId, parent, depth + 1));
          }
        }
      }
      parent['children'] = children;
    }

    for (final root in rawRoots) {
      if (root is! Map) continue;
      final node = Map<String, dynamic>.from(root);
      final id = (node['_id'] ?? node['id'] ?? '').toString().trim();
      if (id.isNotEmpty && !seen.add(id)) continue;
      roots.add(node);
      collectChildren(node, 0);
    }

    var hydrated = 0;
    while (pending.isNotEmpty && hydrated < _maxHydratedChildren) {
      final batch = <_PendingCategoryChild>[];
      while (pending.isNotEmpty && batch.length < _hydrationBatchSize) {
        final next = pending.removeAt(0);
        if (next.depth > _maxTreeDepth ||
            hydrated + batch.length >= _maxHydratedChildren) {
          continue;
        }
        batch.add(next);
      }
      if (batch.isEmpty) break;
      hydrated += batch.length;

      final resolved = await Future.wait(batch.map(_fetchChild));
      for (var index = 0; index < batch.length; index++) {
        final node = resolved[index];
        if (node == null) continue;
        final childId = (node['_id'] ?? node['id'] ?? '').toString().trim();
        if (childId.isNotEmpty && childId != batch[index].id) {
          // Some APIs return a canonical ID different from the requested alias.
          if (!seen.add(childId)) continue;
        }
        (batch[index].parent['children'] as List).add(node);
        collectChildren(node, batch[index].depth);
      }
    }
    return roots;
  }

  Future<Map<String, dynamic>?> _fetchChild(
      _PendingCategoryChild pending) async {
    try {
      final response = await BasicProvider(
              'category/children/${Uri.encodeComponent(pending.id)}')
          .getRequest();
      dynamic node = response;
      for (var depth = 0; depth < 3 && node is Map; depth++) {
        if (node['_id'] != null || node['id'] != null) break;
        node = node['data'];
      }
      if (node is! Map) return null;
      final normalized = Map<String, dynamic>.from(node);
      normalized.putIfAbsent('_id', () => pending.id);
      return normalized;
    } catch (_) {
      return null;
    }
  }
}

class _PendingCategoryChild {
  const _PendingCategoryChild(this.id, this.parent, this.depth);

  final String id;
  final Map<String, dynamic> parent;
  final int depth;
}
