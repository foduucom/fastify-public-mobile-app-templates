import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/data/models/blog_sections.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_mixin.dart';
import 'package:foduu_ecommerce/models/blog_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BlogController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  final RxList<BlogModel> allBlogs = <BlogModel>[].obs;
  final RxList<BlogModel> filteredBlogs = <BlogModel>[].obs;

  // View mode switcher: true = Grid View, false = List View (matching website tabs)
  final RxBool isGridView = true.obs;

  // Pagination state for "All Articles" (from /api/blogs?page=1, page=2)
  final RxInt currentPage = 1.obs;
  final RxBool hasNextPage = true.obs;
  final RxBool isLoadingBlogs = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxInt totalArticles = 0.obs;
  bool _hasLoadedPaginatedFeed = false;
  bool _isAutoLoadingRemainingPages = false;

  // Search & Category Filtering
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxList<String> categories = <String>['All'].obs;

  // Server-driven sections state
  final rawSections = <dynamic>[].obs;
  final sectionsData = BlogBroadcastSectionsData.canonical().obs;

  static const _cacheKey = 'cms_page_blog_sections';

  static final List<Map<String, dynamic>> defaultCanonicalBlogSections = [
    {
      "id": "rich_text",
      "type": "rich_text",
      "content_json": {
        "html_content": "News & Insights",
      },
      "visible": true,
    },
    {
      "id": "blog",
      "type": "blog",
      "content_json": {
        "title": "Our Latest Blog Posts",
        "subtitle":
            "Explore in-depth articles, buying guides, and technical breakdowns.",
        "blog_type": "blog_category",
        "no_of_blog": 100,
        "category_ids": [
          {
            "_id": "6af827652a0fe203761799d1",
            "name": "Wearables & Tech",
            "slug": "wearables-tech",
          },
          {
            "_id": "6af827652a0fe203761799d0",
            "name": "Cameras & Video",
            "slug": "cameras-video",
          },
          {
            "_id": "6af827652a0fe203761799ce",
            "name": "Audio & Sound",
            "slug": "audio-sound",
          },
        ],
        "blogs": [],
      },
      "visible": true,
    },
  ];

  late final ScrollController scrollController;
  late final TextEditingController searchController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    searchController = TextEditingController();

    _attachScrollListener();
    _loadCached();
    fetchBlogLayout();
    fetchAllArticles(isRefresh: true);
  }

  void _attachScrollListener() {
    scrollController.addListener(() {
      if (scrollController.hasClients &&
          scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 150.0 &&
          !isLoadingBlogs.value &&
          !isMoreLoading.value &&
          hasNextPage.value) {
        fetchMoreArticles();
      }
    });
  }

  void _loadCached() {
    try {
      final cachedSections = GetStorage().read(_cacheKey);
      if (cachedSections is List && cachedSections.isNotEmpty) {
        rawSections.assignAll(cachedSections);
        sectionsData.value =
            BlogBroadcastSectionsData.fromSections(cachedSections);
        _syncFromSectionsData();
        buildLayout(cachedSections);
        return;
      }
    } catch (_) {}

    // Pre-seed layout with canonical default sections if no cache exists
    buildLayout(defaultCanonicalBlogSections);
  }

  /// Intercepts both initial fetch and live WebSocket broadcasts from FoduuStudioLayoutMixin
  @override
  void buildLayout(List sections) {
    super.buildLayout(sections);
    if (sections.isNotEmpty) {
      rawSections.assignAll(sections);
      sectionsData.value = BlogBroadcastSectionsData.fromSections(sections);
      _syncFromSectionsData();
      try {
        GetStorage().write(_cacheKey, sections);
      } catch (_) {}
    }
  }

  /// 3-Tier resilient fetching for Blog layout (mobile-app/blog)
  Future<void> fetchBlogLayout({bool silent = false}) async {
    try {
      await fetchLayout('blog', silent: silent);
    } catch (e) {
      debugPrint('BlogLayout fetch error: $e');
    }
  }

  /// Paginated fetching for all blogs (/api/blogs?page=1)
  Future<void> fetchAllArticles({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasNextPage.value = true;
        isLoadingBlogs.value = true;
      }

      final response = await BasicProvider('blogs')
          .getRequest(queryParams: {'page': '1'})
          .catchError(handleError);

      if (response == null) return;

      final parsed = _parseBlogsResponse(response);
      final rawList = parsed.items;

      if (rawList != null) {
        _hasLoadedPaginatedFeed = true;
        final fetched = _decodeBlogs(rawList);

        if (isRefresh) {
          allBlogs.assignAll(fetched);
        } else {
          _appendUniqueBlogs(fetched);
        }

        hasNextPage.value = parsed.hasNext;
        totalArticles.value = parsed.total ?? allBlogs.length;

        _extractCategoriesFromBlogs();
        _applyFilters();
      }
    } catch (e) {
      debugPrint('fetchAllArticles error: $e');
    } finally {
      isLoadingBlogs.value = false;
    }
  }

  /// Next page fetching for continuous infinite scrolling (e.g. /api/blogs?page=2)
  Future<void> fetchMoreArticles() async {
    if (isMoreLoading.value || !hasNextPage.value) return;

    try {
      isMoreLoading.value = true;
      final nextPage = currentPage.value + 1;

      final response = await BasicProvider('blogs')
          .getRequest(queryParams: {'page': nextPage.toString()})
          .catchError(handleError);

      if (response == null) {
        hasNextPage.value = false;
        return;
      }

      final parsed = _parseBlogsResponse(response);
      final rawList = parsed.items;

      if (rawList != null && rawList.isNotEmpty) {
        _hasLoadedPaginatedFeed = true;
        final fetched = _decodeBlogs(rawList);
        _appendUniqueBlogs(fetched);

        currentPage.value = nextPage;
        hasNextPage.value = parsed.hasNext;
        if (parsed.total != null) {
          totalArticles.value = parsed.total!;
        }

        _extractCategoriesFromBlogs();
        _applyFilters();
      } else {
        hasNextPage.value = false;
      }
    } catch (e) {
      debugPrint('fetchMoreArticles error: $e');
    } finally {
      isMoreLoading.value = false;
    }
  }

  /// Loads remaining paginated pages in the background so category/search
  /// filters operate over the complete article set.
  Future<void> _loadRemainingPagesInBackground() async {
    if (_isAutoLoadingRemainingPages || !hasNextPage.value) return;
    _isAutoLoadingRemainingPages = true;
    try {
      while (hasNextPage.value) {
        final prevPage = currentPage.value;
        await fetchMoreArticles();
        if (currentPage.value == prevPage) break;
      }
    } finally {
      _isAutoLoadingRemainingPages = false;
    }
  }

  ({List? items, bool hasNext, int? total}) _parseBlogsResponse(dynamic response) {
    List? rawList;
    Map? mapObj;

    if (response is Map) {
      mapObj = response;
      final inner = response['data'];
      if (inner is List) {
        rawList = inner;
      } else if (inner is Map) {
        mapObj = inner;
        final nested = inner['data'] ?? inner['blogs'] ?? inner['docs'];
        if (nested is List) rawList = nested;
      }
    } else if (response is List) {
      rawList = response;
    }

    bool hasNext = false;
    int? total;
    if (mapObj != null) {
      final pagination =
          mapObj['pagination'] is Map ? mapObj['pagination'] as Map : null;
      final currentP = (pagination?['current_page'] as num?)?.toInt();
      final lastP = (pagination?['last_page'] as num?)?.toInt();
      hasNext = mapObj['hasNextPage'] == true ||
          pagination?['has_next'] == true ||
          (currentP != null && lastP != null && currentP < lastP);
      total = (pagination?['total'] as num?)?.toInt() ??
          (mapObj['total'] as num?)?.toInt();
    }

    return (items: rawList, hasNext: hasNext, total: total);
  }

  List<BlogModel> _decodeBlogs(List rawList) {
    final result = <BlogModel>[];
    for (final item in rawList) {
      if (item is Map) {
        try {
          result.add(BlogModel.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {}
      }
    }
    return result;
  }

  void _appendUniqueBlogs(List<BlogModel> fetched) {
    final existingKeys =
        allBlogs.map((b) => b.id.isNotEmpty ? b.id : b.slug).toSet();
    final newUnique = fetched
        .where((b) => !existingKeys.contains(b.id.isNotEmpty ? b.id : b.slug))
        .toList();
    allBlogs.addAll(newUnique);
  }

  void _syncFromSectionsData() {
    final feedData = sectionsData.value.feed;

    // 1. Synchronize Categories from CMS
    final catSet = <String>{'All'};
    for (final c in feedData.categories) {
      final norm = normalizeBlogCategory(c.name);
      if (norm.isNotEmpty) {
        catSet.add(norm);
      }
    }
    // Also include any categories present on the blog items
    for (final b in feedData.blogs) {
      for (final cat in b.categories) {
        final norm = normalizeBlogCategory(cat);
        if (norm.isNotEmpty) catSet.add(norm);
      }
    }
    categories.assignAll(catSet.toList());

    // 2. Synchronize Blogs only as an initial/offline fallback before the
    // paginated /api/blogs feed has loaded (prevents overwriting 23 articles
    // with the 15-item CMS section subset).
    if (!_hasLoadedPaginatedFeed &&
        allBlogs.isEmpty &&
        feedData.blogs.isNotEmpty) {
      allBlogs.assignAll(feedData.blogs);
    }

    _applyFilters();
  }

  void _extractCategoriesFromBlogs() {
    final catSet = <String>{'All'};
    for (final c in sectionsData.value.feed.categories) {
      final norm = normalizeBlogCategory(c.name);
      if (norm.isNotEmpty) catSet.add(norm);
    }
    for (final blog in allBlogs) {
      for (final cat in blog.categories) {
        final norm = normalizeBlogCategory(cat);
        if (norm.isNotEmpty) {
          catSet.add(norm);
        }
      }
    }
    categories.assignAll(catSet.toList());
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilters();
    if (query.trim().isNotEmpty && hasNextPage.value) {
      _loadRemainingPagesInBackground();
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applyFilters();
  }

  void onCategorySelected(String category) {
    selectedCategory.value = category;
    _applyFilters();
    if (category != 'All' && category.isNotEmpty && hasNextPage.value) {
      _loadRemainingPagesInBackground();
    }
  }

  void selectCategory(String category) {
    onCategorySelected(category);
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  Future<void> onRefresh() async {
    currentPage.value = 1;
    hasNextPage.value = true;
    await Future.wait([
      fetchBlogLayout(silent: false),
      fetchAllArticles(isRefresh: true),
    ]);
  }

  void _applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    final category = selectedCategory.value;

    List<BlogModel> result = allBlogs.toList();

    // 1. Filter by category
    if (category != 'All' && category.isNotEmpty) {
      final target = normalizeBlogCategory(category).toLowerCase();
      result = result.where((b) {
        final matchesCat = b.categories.any(
            (c) => normalizeBlogCategory(c).toLowerCase() == target);
        final matchesTag =
            b.tags.any((t) => normalizeBlogCategory(t).toLowerCase() == target);
        return matchesCat || matchesTag;
      }).toList();
    }

    // 2. Filter by search query
    if (query.isNotEmpty) {
      result = result.where((b) {
        final titleMatch = b.title.toLowerCase().contains(query);
        final excerptMatch = b.cleanExcerpt.toLowerCase().contains(query);
        final authorMatch = b.authorName.toLowerCase().contains(query);
        final catMatch = b.categories
            .any((c) => c.toLowerCase().contains(query));
        return titleMatch || excerptMatch || authorMatch || catMatch;
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
