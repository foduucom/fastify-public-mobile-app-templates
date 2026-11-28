import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/models/blog_model.dart';
import 'package:get/get.dart';

class BlogController extends GetxController with BaseController {
  final RxList<BlogModel> allBlogs = <BlogModel>[].obs;
  final RxList<BlogModel> filteredBlogs = <BlogModel>[].obs;

  // View mode switcher: true = Grid View, false = List View (matching website tabs)
  final RxBool isGridView = true.obs;

  // Loading and error states
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool hasMoreError = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt maxPage = 1.obs;
  int _requestGeneration = 0;

  // Filter & Search
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxList<String> categories = <String>['All'].obs;

  late final ScrollController scrollController;
  late final TextEditingController searchController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    searchController = TextEditingController();
    _initScrollListener();
    fetchBlogs(isRefresh: true);
  }

  void _initScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 80.0) {
        if (!isLoading.value &&
            !isMoreLoading.value &&
            currentPage.value < maxPage.value) {
          fetchMoreBlogs();
        }
      }
    });
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  Future<void> onRefresh() async {
    await fetchBlogs(isRefresh: true);
  }

  Future<void> fetchBlogs({bool isRefresh = false}) async {
    final previousPage = currentPage.value;
    final previousMaxPage = maxPage.value;
    if (isRefresh) {
      _requestGeneration++;
      currentPage.value = 1;
      isLoading.value = true;
      isMoreLoading.value = false;
      hasMoreError.value = false;
      hasError.value = false;
      errorMessage.value = '';
    } else {
      if (isMoreLoading.value || currentPage.value >= maxPage.value) return;
      isMoreLoading.value = true;
      hasMoreError.value = false;
    }
    final generation = _requestGeneration;
    final requestedPage = isRefresh ? 1 : currentPage.value + 1;

    try {
      final response = await BasicProvider('blogs?count=10&page=$requestedPage')
          .getRequest()
          .catchError(handleError);

      if (generation != _requestGeneration) return;
      if (response == null) {
        if (isRefresh) {
          currentPage.value = previousPage;
          maxPage.value = previousMaxPage;
        }
        if (isRefresh && allBlogs.isEmpty) {
          hasError.value = true;
          errorMessage.value = 'Failed to load blogs. Please try again.';
        } else if (!isRefresh) {
          hasMoreError.value = true;
        }
        return;
      }

      final page = _normalizeBlogPage(response);
      if (page == null) {
        if (isRefresh) {
          currentPage.value = previousPage;
          maxPage.value = previousMaxPage;
        }
        if (isRefresh && allBlogs.isEmpty) {
          errorMessage.value = 'Could not read the articles response.';
          hasError.value = true;
        } else if (!isRefresh) {
          hasMoreError.value = true;
        }
        return;
      }

      final fetchedList = page['items'] as List<BlogModel>;
      if (isRefresh) {
        allBlogs.assignAll(fetchedList);
      } else {
        final existingIds = allBlogs.map((blog) => blog.id).toSet();
        allBlogs.addAll(fetchedList.where(
            (blog) => blog.id.isEmpty || !existingIds.contains(blog.id)));
      }
      currentPage.value = requestedPage;
      maxPage.value = page['lastPage'] as int;
      _extractCategories();
      _applyFilters();
    } catch (e) {
      if (generation != _requestGeneration) return;
      if (isRefresh) {
        currentPage.value = previousPage;
        maxPage.value = previousMaxPage;
      }
      debugPrint('Blog fetch error: $e');
      if (isRefresh && allBlogs.isEmpty) {
        hasError.value = true;
        errorMessage.value = 'Something went wrong. Tap to retry.';
      } else if (!isRefresh) {
        hasMoreError.value = true;
      }
    } finally {
      if (generation == _requestGeneration) {
        isLoading.value = false;
        isMoreLoading.value = false;
      }
    }
  }

  Future<void> fetchMoreBlogs() async {
    if (currentPage.value >= maxPage.value ||
        isMoreLoading.value ||
        isLoading.value) {
      return;
    }
    await fetchBlogs(isRefresh: false);
  }

  Future<void> retryMoreBlogs() => fetchBlogs(isRefresh: false);

  Map<String, dynamic>? _normalizeBlogPage(dynamic response) {
    if (response is List) {
      return {
        'items': _toBlogModels(response),
        'lastPage': 1,
      };
    }
    if (response is! Map) return null;

    dynamic current = response;
    // Keep pagination fields from outer envelopes while walking to the actual
    // article array (for example {meta, data: {data: [...]} }).
    Map<String, dynamic> meta = Map<String, dynamic>.from(response);
    for (var depth = 0; depth < 5; depth++) {
      if (current is List) {
        return {
          'items': _toBlogModels(current),
          'lastPage': _lastPage(meta),
        };
      }
      if (current is! Map) return null;
      meta = {...meta, ...Map<String, dynamic>.from(current)};
      final pagination = current['pagination'];
      if (pagination is Map) {
        meta = {...meta, ...Map<String, dynamic>.from(pagination)};
      }

      for (final key in ['data', 'blogs', 'posts', 'items', 'results']) {
        if (current[key] is List) {
          return {
            'items': _toBlogModels(current[key] as List),
            'lastPage': _lastPage(meta),
          };
        }
      }

      dynamic nested;
      for (final key in ['data', 'blogs', 'posts', 'items', 'results']) {
        if (current[key] is Map) {
          nested = current[key];
          break;
        }
      }
      if (nested == null) return null;
      current = nested;
    }
    return null;
  }

  List<BlogModel> _toBlogModels(List rawItems) => rawItems
      .whereType<Map>()
      .map((item) => BlogModel.fromJson(Map<String, dynamic>.from(item)))
      .toList();

  int _lastPage(Map data) {
    final value = data['last_page'] ?? data['total_pages'] ?? data['lastPage'];
    return int.tryParse(value?.toString() ?? '') ?? 1;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applyFilters();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void _extractCategories() {
    final Set<String> catSet = {'All'};
    for (final blog in allBlogs) {
      for (final cat in blog.categories) {
        if (cat.trim().isNotEmpty) {
          catSet.add(cat.trim());
        }
      }
    }
    categories.assignAll(catSet.toList());
  }

  void _applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    final category = selectedCategory.value;

    List<BlogModel> result = allBlogs.toList();

    if (category != 'All') {
      result = result
          .where((b) => b.categories
              .any((c) => c.trim().toLowerCase() == category.toLowerCase()))
          .toList();
    }

    if (query.isNotEmpty) {
      result = result.where((b) {
        final titleMatch = b.title.toLowerCase().contains(query);
        final excerptMatch = b.cleanExcerpt.toLowerCase().contains(query);
        final authorMatch = b.authorName.toLowerCase().contains(query);
        return titleMatch || excerptMatch || authorMatch;
      }).toList();
    }

    filteredBlogs.assignAll(result);
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
