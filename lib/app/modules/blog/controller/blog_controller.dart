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

  // Pagination state for "All Articles" (from error.txt API: /api/blogs?page=1, page=2)
  final RxInt currentPage = 1.obs;
  final RxBool hasNextPage = true.obs;
  final RxBool isLoadingBlogs = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxInt totalArticles = 0.obs;

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
      "id": "slider",
      "type": "slider",
      "content_json": {
        "slider_id": "6afd5509092bb0fa151fc5d5",
        "full_screen": false,
        "height": 200,
        "slider": {
          "name": "blog-slider",
          "slug": "blog-slider",
          "content": [
            {
              "heading": "Blog",
              "sub_heading": "Stories Powered by Tech",
              "description":
                  "Discover the latest gadgets, smart home trends, and expert reviews designed to upgrade every corner of your digital life.",
              "filePath": "2026/11/17/appliance-lineup-5343cd2f.webp",
            }
          ]
        }
      },
      "visible": true
    },
    {
      "id": "search",
      "type": "search",
      "content_json": {
        "name": "Search",
        "placeholder": "Search articles, guides and reviews"
      },
      "visible": true
    },
    {
      "id": "text_block",
      "type": "text_block",
      "content_json": {
        "text": "Browse Categories",
        "size": 16,
        "weight": "bold",
        "alignment": "left",
        "color": "#000000"
      },
      "visible": true
    },
    {
      "id": "blog",
      "type": "blog",
      "content_json": {
        "blog_type": "blog_category",
        "no_of_blog": 70,
        "category_ids": [
          {
            "_id": "6af2a6985378860472ebf280",
            "name": "Gaming",
            "slug": "gaming-1"
          },
          {
            "_id": "6af2a6985378860472ebf27e",
            "name": "Audio Tech",
            "slug": "audio-tech"
          },
          {
            "_id": "6af2a6985378860472ebf27c",
            "name": "Smart Living",
            "slug": "smart-living"
          }
        ],
        "blogs": []
      },
      "visible": true
    }
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

  /// Paginated fetching for all blogs (matching backend error.txt specification: /api/blogs?page=1)
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

      Map? mapObj;
      List? rawList;

      if (response is Map) {
        mapObj = response;
        final inner = response['data'];
        if (inner is List) {
          rawList = inner;
        }
      } else if (response is List) {
        rawList = response;
      }

      if (rawList != null) {
        final fetched = rawList
            .map((item) => BlogModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        if (isRefresh) {
          allBlogs.assignAll(fetched);
        } else {
          final existingIds = allBlogs.map((b) => b.id).toSet();
          final newUnique =
              fetched.where((b) => !existingIds.contains(b.id)).toList();
          allBlogs.addAll(newUnique);
        }

        if (mapObj != null) {
          hasNextPage.value = mapObj['hasNextPage'] == true ||
              (mapObj['pagination'] is Map &&
                  mapObj['pagination']['has_next'] == true);
          final total = (mapObj['pagination'] is Map)
              ? (mapObj['pagination']['total'] as num?)?.toInt()
              : null;
          if (total != null) {
            totalArticles.value = total;
          } else {
            totalArticles.value = allBlogs.length;
          }
        }

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

      if (response == null) return;

      List? rawList;
      Map? mapObj;

      if (response is Map) {
        mapObj = response;
        final inner = response['data'];
        if (inner is List) rawList = inner;
      } else if (response is List) {
        rawList = response;
      }

      if (rawList != null && rawList.isNotEmpty) {
        final fetched = rawList
            .map((item) => BlogModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        final existingIds = allBlogs.map((b) => b.id).toSet();
        final newUnique =
            fetched.where((b) => !existingIds.contains(b.id)).toList();
        allBlogs.addAll(newUnique);

        currentPage.value = nextPage;
        if (mapObj != null) {
          hasNextPage.value = mapObj['hasNextPage'] == true ||
              (mapObj['pagination'] is Map &&
                  mapObj['pagination']['has_next'] == true);
          final total = (mapObj['pagination'] is Map)
              ? (mapObj['pagination']['total'] as num?)?.toInt()
              : null;
          if (total != null) totalArticles.value = total;
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

  void _syncFromSectionsData() {
    final feedData = sectionsData.value.feed;

    // 1. Synchronize Categories from CMS
    final catSet = <String>{'All'};
    for (final c in feedData.categories) {
      if (c.name.trim().isNotEmpty) {
        catSet.add(c.name.trim());
      }
    }
    // Also include any categories present on the blog items
    for (final b in feedData.blogs) {
      for (final cat in b.categories) {
        if (cat.trim().isNotEmpty) catSet.add(cat.trim());
      }
    }
    categories.assignAll(catSet.toList());

    // 2. Synchronize Blogs
    if (feedData.blogs.isNotEmpty) {
      allBlogs.assignAll(feedData.blogs);
    }

    _applyFilters();
  }

  void _extractCategoriesFromBlogs() {
    final catSet = <String>{'All'};
    for (final blog in allBlogs) {
      for (final cat in blog.categories) {
        if (cat.trim().isNotEmpty) {
          catSet.add(cat.trim());
        }
      }
    }
    categories.assignAll(catSet.toList());
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

  void onCategorySelected(String category) {
    selectedCategory.value = category;
    _applyFilters();
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
      result = result.where((b) {
        final matchesCat = b.categories.any(
            (c) => c.trim().toLowerCase() == category.toLowerCase());
        final matchesTag =
            b.tags.any((t) => t.trim().toLowerCase() == category.toLowerCase());
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
