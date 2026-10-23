import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/constants/api_sanitizer.dart';

/// One searchable category, flattened out of the tree.
class CategoryEntry {
  final String id;
  final String name;
  final String slug;
  final dynamic featuredImage;
  final String? parentId;
  final String? parentName;

  /// e.g. `Fibre Cable › Fiber Patch Cables` (ancestors only, no self).
  final String breadcrumb;
  final int depth;
  final String type;

  const CategoryEntry({
    required this.id,
    required this.name,
    required this.slug,
    required this.featuredImage,
    required this.parentId,
    required this.parentName,
    required this.breadcrumb,
    required this.depth,
    required this.type,
  });

  /// Same shape the search UI already consumes (raw category maps).
  Map<String, dynamic> toMap() => {
        '_id': id,
        'id': id,
        'name': name,
        'slug': slug,
        'featured_image': featuredImage,
        'parentCategory': parentId,
        'parent_name': parentName,
        'breadcrumb': breadcrumb,
        'depth': depth,
        'type': type,
      };

  factory CategoryEntry.fromMap(Map m) => CategoryEntry(
        id: (m['_id'] ?? m['id'] ?? '').toString(),
        name: (m['name'] ?? '').toString(),
        slug: (m['slug'] ?? '').toString(),
        featuredImage: m['featured_image'],
        parentId: m['parentCategory']?.toString(),
        parentName: m['parent_name']?.toString(),
        breadcrumb: (m['breadcrumb'] ?? '').toString(),
        depth: int.tryParse('${m['depth'] ?? 0}') ?? 0,
        type: (m['type'] ?? '').toString(),
      );
}

typedef CategoryFetcher = Future<dynamic> Function(String path);

/// Complete, flattened category index.
///
/// `category/get-tree/{type}` only expands two levels; deeper categories come
/// back as bare ID strings in `children`. Those IDs are hydrated through
/// `category/children/{id}` (returns the single category) so search sees the
/// same categories as the website.
class CategoryIndexService {
  static const types = ['product', 'material'];
  static const _cacheKey = 'category_index_v2';
  static const _cacheTsKey = 'category_index_v2_ts';
  static const Duration ttl = Duration(hours: 24);

  static const int maxDepth = 5;
  static const int maxHydrated = 300;
  static const int concurrency = 6;
  static const Duration retryCooldown = Duration(minutes: 2);

  final CategoryFetcher _fetch;
  final dynamic Function(String key) _read;
  final void Function(String key, dynamic value) _write;

  CategoryIndexService({
    CategoryFetcher? fetcher,
    dynamic Function(String key)? read,
    void Function(String key, dynamic value)? write,
  })  : _fetch = fetcher ?? _defaultFetch,
        _read = read ?? ((k) => GetStorage().read(k)),
        _write = write ?? ((k, v) => GetStorage().write(k, v));

  static Future<dynamic> _defaultFetch(String path) =>
      BasicProvider(path, showSnackBar: false).getRequest();

  List<CategoryEntry> _entries = const [];
  Future<List<CategoryEntry>>? _inFlight;
  bool _complete = false;
  DateTime? _lastAttempt;

  List<CategoryEntry> get entries => _entries;

  /// Invalidate in-memory and disk cache.
  void clearCache() {
    _entries = const [];
    _complete = false;
    _write(_cacheKey, null);
    _write(_cacheTsKey, null);
  }

  /// Returns the index, building it if needed. Concurrent callers share one
  /// build. Cached data is returned instantly while a stale cache refreshes.
  Future<List<CategoryEntry>> ensureLoaded({bool forceRefresh = false}) {
    if (forceRefresh) {
      return _refresh();
    }

    if (_entries.isNotEmpty) {
      // Complete, refresh already running, or a partial index that was tried
      // recently: serve what we have instead of hitting the network per query.
      final recentlyTried = _lastAttempt != null &&
          DateTime.now().difference(_lastAttempt!) < retryCooldown;
      if (_complete || _inFlight != null || recentlyTried) {
        return Future.value(_entries);
      }
    }

    if (_entries.isEmpty) {
      final cached = _readCache();
      if (cached != null) {
        _entries = cached.entries;
        if (!cached.stale) {
          _complete = true;
          return Future.value(_entries);
        }
        // Stale: serve now, refresh in the background.
        _refresh();
        return Future.value(_entries);
      }
    }
    return _refresh();
  }

  Future<List<CategoryEntry>> _refresh() {
    return _inFlight ??= _build().whenComplete(() => _inFlight = null);
  }

  /// Returns the category tree fully hydrated with all child levels.
  /// Solves the shallow-tree API limitation where 3rd-level children are
  /// only raw IDs (e.g. Fiber Patch Cables subcategories).
  Future<List<Map<String, dynamic>>> getHydratedCategoryTree(
      {String type = 'product', bool forceRefresh = false}) async {
    final all = await ensureLoaded(forceRefresh: forceRefresh);
    if (all.isEmpty) return const [];

    final relevant = all
        .where((e) => type.isEmpty || e.type == type || e.type.isEmpty)
        .toList();

    final Map<String, List<CategoryEntry>> childrenMap = {};
    for (final e in relevant) {
      if (e.parentId != null && e.parentId!.isNotEmpty) {
        childrenMap.putIfAbsent(e.parentId!, () => []).add(e);
      }
    }

    final Set<String> allIds = relevant.map((e) => e.id).toSet();
    final roots = relevant
        .where((e) =>
            e.depth == 0 ||
            e.parentId == null ||
            e.parentId!.isEmpty ||
            !allIds.contains(e.parentId))
        .toList();

    Map<String, dynamic> buildNode(CategoryEntry entry) {
      final childrenEntries = childrenMap[entry.id] ?? const [];
      return {
        '_id': entry.id,
        'id': entry.id,
        'name': entry.name,
        'slug': entry.slug,
        'featured_image': entry.featuredImage,
        'parentCategory': entry.parentId,
        'parent_name': entry.parentName,
        'breadcrumb': entry.breadcrumb,
        'depth': entry.depth,
        'type': entry.type,
        'children': childrenEntries.map(buildNode).toList(),
      };
    }

    return roots.map(buildNode).toList();
  }

  Future<List<CategoryEntry>> _build() async {
    _lastAttempt = DateTime.now();
    try {
      final built = await buildIndex();
      if (built.entries.isNotEmpty) {
        _entries = built.entries;
        _complete = built.complete;
        // Only persist a full index so a half-failed run is retried.
        if (built.complete) _writeCache(built.entries);
      }
    } catch (e) {
      debugPrint('category index build error: $e');
    }
    return _entries;
  }

  /// Builds the index from the network. Exposed for tests.
  @visibleForTesting
  Future<({List<CategoryEntry> entries, bool complete})> buildIndex() async {
    final out = <CategoryEntry>[];
    final seen = <String>{};
    var complete = true;

    // IDs we still need to resolve, with the parent context they came from.
    final pending = <_Pending>[];

    void add(Map n, {String? parentId, String? parentName, String crumb = '', required int depth}) {
      final id = (n['_id'] ?? n['id'] ?? '').toString();
      final name = (n['name'] ?? '').toString();
      if (id.isEmpty || !seen.add(id)) return;
      if (name.isNotEmpty) {
        out.add(CategoryEntry(
          id: id,
          name: name,
          slug: (n['slug'] ?? '').toString(),
          featuredImage: n['featured_image'],
          parentId: parentId,
          parentName: parentName,
          breadcrumb: crumb,
          depth: depth,
          type: (n['type'] ?? '').toString(),
        ));
      }
      final childCrumb = crumb.isEmpty ? name : '$crumb › $name';
      final children = n['children'];
      if (children is! List) return;
      for (final c in children) {
        if (c is Map) {
          add(Map.from(c),
              parentId: id, parentName: name, crumb: childCrumb, depth: depth + 1);
        } else if (c is String && c.isNotEmpty) {
          pending.add(_Pending(c, id, name, childCrumb, depth + 1));
        }
      }
    }

    // 1. Trees (each type independently; one failing must not drop the other).
    final trees = await Future.wait(types.map((t) async {
      try {
        return await _fetch('category/get-tree/$t');
      } catch (e) {
        debugPrint('category tree $t error: $e');
        return null;
      }
    }));
    var anyTree = false;
    for (final r in trees) {
      final roots = _extractList(r);
      if (roots.isEmpty) continue;
      anyTree = true;
      for (final n in stripHeavyList(roots)) {
        if (n is Map) add(Map.from(n), depth: 0);
      }
    }
    if (!anyTree) {
      // Offline / failed: fall back to the tree the home screen cached.
      final home = _read('home_category_tree');
      if (home is List) {
        for (final n in home) {
          if (n is Map) add(Map.from(n), depth: 0);
        }
      }
      return (entries: out, complete: false);
    }

    // 2. Hydrate bare-ID children (BFS, bounded).
    var hydrated = 0;
    while (pending.isNotEmpty) {
      final batch = <_Pending>[];
      while (pending.isNotEmpty && batch.length < concurrency) {
        final p = pending.removeAt(0);
        if (seen.contains(p.id)) continue;
        if (p.depth > maxDepth || hydrated >= maxHydrated) {
          complete = false;
          continue;
        }
        batch.add(p);
      }
      if (batch.isEmpty) break;
      hydrated += batch.length;

      final results = await Future.wait(batch.map((p) async {
        try {
          return await _fetch('category/children/${p.id}');
        } catch (e) {
          debugPrint('category ${p.id} error: $e');
          return null;
        }
      }));

      for (var i = 0; i < batch.length; i++) {
        final p = batch[i];
        final node = _extractNode(results[i]);
        if (node == null) {
          complete = false;
          continue;
        }
        final clean = stripHeavyFields(node) as Map;
        add(Map.from(clean),
            parentId: p.parentId,
            parentName: p.parentName,
            crumb: p.crumb,
            depth: p.depth);
      }
    }

    return (entries: out, complete: complete);
  }

  // ---- parsing ---------------------------------------------------------------

  List _extractList(dynamic r) {
    if (r is List) return r;
    if (r is Map) {
      final d = r['data'];
      if (d is List) return d;
      if (d is Map && d['data'] is List) return d['data'] as List;
    }
    return const [];
  }

  /// `category/children/{id}` answers `{status, data: {…category…}}`.
  Map? _extractNode(dynamic r) {
    if (r is! Map) return null;
    final d = r['data'];
    if (d is Map && (d['_id'] != null || d['id'] != null)) return d;
    if (r['_id'] != null || r['id'] != null) return r;
    return null;
  }

  // ---- cache -----------------------------------------------------------------

  ({List<CategoryEntry> entries, bool stale})? _readCache() {
    try {
      final raw = _read(_cacheKey);
      if (raw is! List || raw.isEmpty) return null;
      final ts = int.tryParse('${_read(_cacheTsKey) ?? ''}') ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      return (
        entries: raw
            .whereType<Map>()
            .map(CategoryEntry.fromMap)
            .where((e) => e.id.isNotEmpty && e.name.isNotEmpty)
            .toList(),
        stale: age > ttl.inMilliseconds,
      );
    } catch (e) {
      return null;
    }
  }

  void _writeCache(List<CategoryEntry> entries) {
    try {
      _write(_cacheKey, entries.map((e) => e.toMap()).toList());
      _write(_cacheTsKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('category index cache write error: $e');
    }
  }
}

class _Pending {
  final String id;
  final String parentId;
  final String parentName;
  final String crumb;
  final int depth;
  _Pending(this.id, this.parentId, this.parentName, this.crumb, this.depth);
}
