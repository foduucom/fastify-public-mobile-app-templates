import 'package:get/get.dart';
import 'package:zouhi/app/data/models/category_products_page.dart';
import 'package:zouhi/app/data/services/category_product_service.dart';

class CategoryTab {
  final String id;
  final String name;
  const CategoryTab(this.id, this.name);
}

/// Paging state of one tab. Kept per tab so switching tabs never refetches.
class TabProducts {
  final items = <CategoryProduct>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasError = false.obs;
  final hasNext = false.obs;
  final total = 0.obs;
  bool loadedOnce = false;
  int page = 0;
  int generation = 0; // bumped on refresh so stale responses are dropped
}

class CategoryProductsController extends GetxController {
  CategoryProductsController({CategoryProductService? service})
      : _service = service ?? CategoryProductService();

  final CategoryProductService _service;

  final title = 'Products'.obs;
  final tabs = <CategoryTab>[];
  final _states = <String, TabProducts>{};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      final id = (args['categoryId'] ?? args['productId'] ?? args['id'] ?? '')
          .toString();
      final name = (args['name'] ?? 'Products').toString();
      title.value = name;
      final children = _tabsFrom(args['children']);
      // The category's own products come first; children (when the backend
      // provides them) become further tabs. With no children there is just the
      // one category and the view hides the tab bar.
      if (id.isNotEmpty) tabs.add(CategoryTab(id, name));
      tabs.addAll(children.where((t) => t.id != id));
    }
  }

  static List<CategoryTab> _tabsFrom(dynamic children) {
    if (children is! List) return const [];
    final out = <CategoryTab>[];
    for (final c in children) {
      if (c is! Map) continue; // bare ids carry no label, nothing to show
      final id = (c['_id'] ?? c['id'] ?? '').toString();
      final name = (c['name'] ?? '').toString();
      if (id.isNotEmpty && name.isNotEmpty) out.add(CategoryTab(id, name));
    }
    return out;
  }

  TabProducts stateFor(String categoryId) =>
      _states.putIfAbsent(categoryId, () => TabProducts());

  /// First-visit load; a no-op once a tab has been loaded.
  Future<void> ensureLoaded(String categoryId) async {
    final s = stateFor(categoryId);
    if (s.loadedOnce || s.isLoading.value) return;
    await _loadPage(categoryId, 1);
  }

  Future<void> refreshTab(String categoryId) async {
    final s = stateFor(categoryId);
    s.generation++;
    s.isLoadingMore.value = false;
    await _loadPage(categoryId, 1);
  }

  Future<void> loadMore(String categoryId) async {
    final s = stateFor(categoryId);
    if (!s.hasNext.value || s.isLoading.value || s.isLoadingMore.value) return;
    await _loadPage(categoryId, s.page + 1);
  }

  Future<void> _loadPage(String categoryId, int page) async {
    final s = stateFor(categoryId);
    final generation = s.generation;
    final first = page == 1;
    if (first) {
      s.isLoading.value = true;
    } else {
      s.isLoadingMore.value = true;
    }
    s.hasError.value = false;

    CategoryProductsPage? result;
    try {
      result = await _service.fetchByParentCategory(categoryId, page: page);
    } catch (_) {
      result = null;
    }

    if (generation != s.generation) return; // a refresh superseded this call

    if (result == null) {
      if (first || s.items.isEmpty) s.hasError.value = true;
    } else {
      if (first) {
        s.items.assignAll(result.items);
      } else {
        final known = s.items.map((e) => e.id).toSet();
        s.items.addAll(result.items.where((e) => !known.contains(e.id)));
      }
      s.page = result.pageInfo.currentPage;
      s.hasNext.value = result.pageInfo.hasNext;
      s.total.value = result.pageInfo.total;
      s.loadedOnce = true;
    }
    s.isLoading.value = false;
    s.isLoadingMore.value = false;
  }
}
