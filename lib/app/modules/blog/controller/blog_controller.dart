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
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt maxPage = 1.obs;

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
    currentPage.value = 1;
    await fetchBlogs(isRefresh: true);
  }

  Future<void> fetchBlogs({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isLoading.value = true;
        hasError.value = false;
        errorMessage.value = '';
      }

      final response = await BasicProvider(
              'blogs?count=10&page=${isRefresh ? 1 : currentPage.value}')
          .getRequest()
          .catchError(handleError);

      if (response == null) {
        if (isRefresh && allBlogs.isEmpty) {
          hasError.value = true;
          errorMessage.value = 'Failed to load blogs. Please try again.';
        }
        return;
      }

      // BasicProvider._processResponse() already unwraps the outer "data", so
      // `response` is normally { data: [...], last_page: ... }. Also accept the
      // full envelope { status, data: { data: [...] } } and a bare list.
      Map? dataObj;
      if (response is Map) {
        final inner = response['data'];
        if (inner is List) {
          dataObj = response;
        } else if (inner is Map) {
          dataObj = inner;
        }
      } else if (response is List) {
        dataObj = {'data': response};
      }

      if (dataObj != null) {
        final rawList = dataObj['data'];

        if (rawList is List) {
          final List<BlogModel> fetchedList = rawList
              .map((item) =>
                  BlogModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();

          if (isRefresh) {
            allBlogs.assignAll(fetchedList);
          } else {
            allBlogs.addAll(fetchedList);
          }
        }

        maxPage.value = (dataObj['last_page'] as num?)?.toInt() ?? 1;
        _extractCategories();
        _applyFilters();
      } else {
        if (isRefresh && allBlogs.isEmpty) {
          hasError.value = true;
          errorMessage.value = 'No blogs found.';
        }
      }
    } catch (e) {
      debugPrint('Blog fetch error: $e');
      if (isRefresh && allBlogs.isEmpty) {
        hasError.value = true;
        errorMessage.value = 'Something went wrong. Tap to retry.';
      }
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<void> fetchMoreBlogs() async {
    if (currentPage.value >= maxPage.value || isMoreLoading.value) return;

    isMoreLoading.value = true;
    currentPage.value++;
    await fetchBlogs(isRefresh: false);
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
          .where((b) => b.categories.any(
              (c) => c.trim().toLowerCase() == category.toLowerCase()))
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
