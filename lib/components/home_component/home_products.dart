import 'package:cached_network_image/cached_network_image.dart';
import '/components/app_image_placeholder.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart'
    show WishListService;
import 'package:foduu_ecommerce/core/services/cartServcie.dart'
    show CartService;
import 'package:foduu_ecommerce/services/product_pagination.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/app/routes/app_pages.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import '/constants/product_helper.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'home_common_widgets.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/components/product_quick_view_modal.dart';
import 'package:foduu_ecommerce/components/parent_web_product_card.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_mixin.dart';
import 'package:foduu_ecommerce/app/modules/shop/shop_navigation.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/components/commonWidgets/dynamic_horizontal_arrow_scroller.dart';

class TrendingProductSection extends StatefulWidget {
  final Map<String, dynamic>? contentJson;

  /// When provided, the section renders this externally-owned list instead of
  /// fetching its own data — used by pages (Shop) that run their own filtered,
  /// paginated product fetch and just want the shared grid/card rendering.
  final RxList<dynamic>? externalProducts;

  /// Whether the external caller has more pages to load (external mode only).
  final bool externalHasMore;

  /// Whether the external caller is fetching another page (external mode only).
  final bool externalIsLoadingMore;

  /// Called when scrolling nears the end in external mode; the caller fetches
  /// and appends to [externalProducts].
  final VoidCallback? onLoadMore;

  /// Hides the heading/subheading/"see all" row (external mode).
  final bool hideHeader;

  const TrendingProductSection({
    super.key,
    this.contentJson,
    this.externalProducts,
    this.externalHasMore = false,
    this.externalIsLoadingMore = false,
    this.onLoadMore,
    this.hideHeader = false,
  });

  @override
  State<TrendingProductSection> createState() => _TrendingProductCardState();
}

class _TrendingProductCardState extends State<TrendingProductSection>
    with BaseController {
  late final RxList<dynamic> trendingList;
  bool get _isExternal => widget.externalProducts != null;

  // ─── Pagination State ───
  bool _infiniteScroll = false;
  final _currentPage = 2.obs;
  final _isLoadingMore = false.obs;
  final _isInitialLoading = false.obs;
  final _hasMore = true.obs;
  bool _pageLoadFailed = false;
  int _countPerPage = 10;
  ScrollController? _scrollController;
  ScrollPosition? _parentScrollPosition;
  bool _useParentScroll = false;

  // ─── Category tabs (built in-app from the page's categories section) ───
  List<Map<String, dynamic>> _tabs = [];
  final _selectedTab = 0.obs;
  final _selectedFeaturedProduct = 0.obs;
  final PageController _featuredPageController =
      PageController(viewportFraction: 0.88);
  bool get _tabsEnabled => _tabs.isNotEmpty;
  final _childCategoriesCache = <String, List<dynamic>>{}.obs;
  final _tabProductsCache = <String, List<dynamic>>{}.obs;
  final _isTabLoading = false.obs;
  static const int _tabProductLimit = 8;

  bool get _hasMoreValue =>
      _isExternal ? widget.externalHasMore : _hasMore.value;
  bool get _isLoadingMoreValue =>
      _isExternal ? widget.externalIsLoadingMore : _isLoadingMore.value;

  void _triggerLoadMore() {
    if (_isExternal) {
      if (!_hasMoreValue || _isLoadingMoreValue) return;
      widget.onLoadMore?.call();
    } else {
      _fetchProductsFromApi();
    }
  }

  void _initTabs() {
    final json = widget.contentJson;
    final categoryType = (json?['category_type'] ?? '').toString();
    final showTabs =
        json?['show_tabs'] ?? (categoryType == 'specific_category');
    final rawCats = json?['category_ids'] is List &&
            (json?['category_ids'] as List).isNotEmpty
        ? json!['category_ids']
        : json?['tab_categories'];
    final cats = rawCats;
    if (showTabs != true || _infiniteScroll || cats is! List) return;
    _tabs = [
      for (final c in cats)
        if (c is Map &&
            (c['_id'] != null || c['id'] != null) &&
            c['name'] != null)
          Map<String, dynamic>.from(c)
    ];
    if (_tabs.isNotEmpty) _infiniteScroll = false;
  }

  Future<void> _selectTab(int index) async {
    _selectedTab.value = index;
    if (index < 0 || index >= _tabs.length) return;
    final categoryId =
        (_tabs[index]['_id'] ?? _tabs[index]['id'] ?? '').toString();
    if (categoryId.isEmpty || _tabProductsCache.containsKey(categoryId)) return;
    _isTabLoading.value = true;
    try {
      final response = await BasicProvider('products').getRequest(queryParams: {
        'page': '1',
        'count': '$_tabProductLimit',
        'specific': [categoryId],
      });
      List products = [];
      if (response is List) {
        products = response;
      } else if (response is Map) {
        final values =
            response['data'] ?? response['product'] ?? response['products'];
        if (values is List) products = values;
      }
      _tabProductsCache[categoryId] = products;
    } catch (error) {
      debugPrint('Unable to load CMS product tab $categoryId: $error');
    } finally {
      _isTabLoading.value = false;
    }
  }

  Set<String> _categoryTreeIds(Map category) {
    final ids = <String>{};
    void visit(dynamic node) {
      if (node is! Map) return;
      final id = (node['_id'] ?? node['id'] ?? '').toString();
      if (id.isNotEmpty) ids.add(id);
      final children = node['children'];
      if (children is List) {
        for (final child in children) {
          visit(child);
        }
      }
    }

    visit(category);
    return ids;
  }

  /// Products of the selected tab (all loaded products when tabs are off).
  List get _tabProducts {
    if (!_tabsEnabled) return trendingList;
    final tab = _tabs[_selectedTab.value];
    final id = (tab['_id'] ?? tab['id'] ?? '').toString();
    final cached = _tabProductsCache[id];
    if (cached != null) return cached;

    final childIds = _categoryTreeIds(tab)..remove(id);

    return trendingList.where((p) {
      final cats = (p is Map ? p['categories'] : null);
      if (cats is! List) return false;
      return cats.any((c) {
        final catId = (c is Map ? (c['_id'] ?? c['id']) : c).toString();
        return catId == id || childIds.contains(catId);
      });
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    trendingList = widget.externalProducts ?? <dynamic>[].obs;

    if (_isExternal) {
      // Full external list with a load-more row; pagination is driven by the
      // caller, so listen to the enclosing scrollable.
      _infiniteScroll = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _attachParentScrollListener();
      });
      return;
    }

    _infiniteScroll = widget.contentJson?['infinite_scroll'] == true;
    _countPerPage = _parsePageSize(widget.contentJson?['count']);
    _initTabs();
    if (_tabsEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _selectTab(0);
      });
    }

    // Handle products and pagination from contentJson
    final productData =
        widget.contentJson?['product'] ?? widget.contentJson?['products'];

    if (productData != null) {
      if (productData is Map) {
        final initialProducts = _productListFrom(productData) ?? <dynamic>[];
        trendingList.assignAll(initialProducts);
        _hasMore.value = ProductPagination.hasMore(
          productData,
          itemCount: initialProducts.length,
          pageSize: _countPerPage,
        );
        _currentPage.value = ProductPagination.nextPage(
          productData,
          defaultPage: initialProducts.isEmpty ? 1 : 2,
        );
      } else {
        trendingList.assignAll(productData is List ? productData : <dynamic>[]);
        _hasMore.value = false;
      }
    } else {
      _currentPage.value = 1;
    }

    if (trendingList.isEmpty && !_isExternal) {
      _isInitialLoading.value = true;
    }

    if (_infiniteScroll) {
      _configurePaginationScroll();
      if (trendingList.isEmpty && _hasMore.value) {
        _fetchProductsFromApi();
      }
    } else {
      _loadProducts();
      if (trendingList.isEmpty && !_isExternal) {
        _currentPage.value = 1;
        _fetchProductsFromApi();
      }
    }
  }

  int _parsePageSize(dynamic value) {
    final parsed = value is int ? value : int.tryParse(value?.toString() ?? '');
    return parsed != null && parsed > 0 ? parsed : 10;
  }

  void _configurePaginationScroll() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;
    _parentScrollPosition?.removeListener(_onParentScroll);
    _parentScrollPosition = null;
    if (!_infiniteScroll || _isExternal) return;

    _determineScrollMode();
    if (!_useParentScroll) {
      _scrollController = ScrollController()..addListener(_onScroll);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attachParentScrollListener();
      _loadMoreIfViewportNotFull();
    });
  }

  List<dynamic>? _productListFrom(dynamic raw) {
    dynamic value = raw;
    for (var depth = 0; depth < 3 && value is Map; depth++) {
      final candidate = value['data'] ??
          value['products'] ??
          value['product'] ??
          value['docs'];
      if (candidate is List) return candidate;
      value = candidate;
    }
    return value is List ? value : null;
  }

  @override
  void didUpdateWidget(covariant TrendingProductSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isExternal || identical(widget.contentJson, oldWidget.contentJson)) {
      return;
    }

    _infiniteScroll = widget.contentJson?['infinite_scroll'] == true;
    _countPerPage = _parsePageSize(widget.contentJson?['count']);
    _tabs = [];
    _initTabs();
    _tabProductsCache.clear();
    _childCategoriesCache.clear();
    _selectedTab.value = 0;
    _selectedFeaturedProduct.value = 0;
    _pageLoadFailed = false;

    final productData =
        widget.contentJson?['product'] ?? widget.contentJson?['products'];
    if (productData is Map) {
      final products = _productListFrom(productData) ?? <dynamic>[];
      trendingList.assignAll(products);
      _hasMore.value = ProductPagination.hasMore(
        productData,
        itemCount: products.length,
        pageSize: _countPerPage,
      );
      _currentPage.value = ProductPagination.nextPage(
        productData,
        defaultPage: products.isEmpty ? 1 : 2,
      );
      _isInitialLoading.value = false;
    } else if (productData is List) {
      trendingList.assignAll(productData);
      _hasMore.value = false;
      _currentPage.value = 1;
      _isInitialLoading.value = false;
    } else {
      trendingList.clear();
      _hasMore.value = true;
      _currentPage.value = 1;
      _isInitialLoading.value = true;
    }

    _configurePaginationScroll();
    if (_tabsEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _selectTab(0);
      });
    } else if (trendingList.isEmpty) {
      _fetchProductsFromApi();
    }
  }

  /// Determine whether this layout scrolls itself or relies on the parent.
  void _determineScrollMode() {
    final view = widget.contentJson?['view'] ?? 'list';
    final listViewType = widget.contentJson?['list_view_type'] ?? 'horizontal';
    final style = widget.contentJson?['layout'] ?? 'standard';

    // Self-scrolling: horizontal direction + (standard or overlay) style
    final selfScrolling = (view == 'list') &&
        (listViewType != 'vertical') &&
        (style == 'standard' ||
            style == 'overlay' ||
            style == 'horizontal' ||
            style == 'parent_web');

    _useParentScroll = !selfScrolling;
  }

  void _attachParentScrollListener() {
    if (!mounted) return;
    try {
      final scrollable = Scrollable.maybeOf(context);
      if (scrollable != null) {
        _parentScrollPosition = scrollable.position;
        _parentScrollPosition?.addListener(_onParentScroll);
      }
    } catch (e) {
      print('⚠️ Could not attach parent scroll listener: $e');
    }
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _parentScrollPosition?.removeListener(_onParentScroll);
    _featuredPageController.dispose();
    super.dispose();
  }

  /// Fires for self-scrolling horizontal lists (standard / overlay).
  void _onScroll() {
    if (_scrollController == null || !_scrollController!.hasClients) return;
    final pos = _scrollController!.position;
    if (pos.maxScrollExtent > 150 &&
        pos.pixels > 50 &&
        pos.pixels >= pos.maxScrollExtent - 150) {
      _triggerLoadMore();
    }
  }

  /// Fires for parent-scrolling layouts (grid / vertical / horizontal-style).
  void _onParentScroll() {
    if (_parentScrollPosition == null || !_parentScrollPosition!.hasPixels)
      return;
    final pos = _parentScrollPosition!;
    if (pos.maxScrollExtent > 300 &&
        pos.pixels > 100 &&
        pos.pixels >= pos.maxScrollExtent - 250) {
      _triggerLoadMore();
    }
  }

  void _loadMoreIfViewportNotFull() {
    if (!mounted || _isExternal || !_infiniteScroll) return;
    if (!_hasMoreValue || _isLoadingMoreValue || _pageLoadFailed) return;
    final position = _parentScrollPosition;
    if (position == null || !position.hasPixels) return;
    if (position.maxScrollExtent <= 300) _fetchProductsFromApi();
  }

  Future<void> _fetchProductsFromApi() async {
    if (_isLoadingMore.value || !_hasMore.value || _pageLoadFailed) return;

    final requestedPage = _currentPage.value;
    _isLoadingMore.value = true;
    _pageLoadFailed = false;

    try {
      final heroCategoryIds = _configuredHeroCategories()
          .expand(_categoryRecordIds)
          .toSet()
          .toList(growable: false);
      final categoryType = heroCategoryIds.isNotEmpty
          ? 'specific_category'
          : widget.contentJson?['category_type'] ?? 'random_category';
      final categoryIds = heroCategoryIds.isNotEmpty
          ? heroCategoryIds
          : _configuredProductCategoryIds().toList(growable: false);

      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'page': requestedPage.toString(),
        'count': _countPerPage.toString(),
      };

      if (categoryType == 'parent_category' ||
          categoryType == 'random_category') {
        queryParams['random'] = 'true';
      } else if (categoryType == 'specific_category' &&
          categoryIds.isNotEmpty) {
        queryParams['specific'] = categoryIds
            .map((id) => id.toString())
            .where((id) => id.isNotEmpty)
            .toList();
      }

      final response = await BasicProvider('products')
          .getRequest(queryParams: queryParams)
          .catchError(handleError);

      if (response == null) {
        _pageLoadFailed = true;
        return;
      }

      // Handle response and update pagination state
      List newProducts = [];
      if (response is Map) {
        newProducts = _productListFrom(response) ?? [];
        _hasMore.value = ProductPagination.hasMore(
          response,
          itemCount: newProducts.length,
          pageSize: _countPerPage,
        );
        _currentPage.value = ProductPagination.nextPage(
          response,
          defaultPage: requestedPage + 1,
        );
      } else if (response is List) {
        newProducts = response;
        _hasMore.value = false;
        _currentPage.value = requestedPage + 1;
      } else {
        throw StateError('The products response has an unsupported shape.');
      }

      if (newProducts.isNotEmpty) {
        trendingList
            .addAll(ProductPagination.uniquePage(trendingList, newProducts));
      }
      _pageLoadFailed = false;
    } catch (e) {
      print("🔥 Error fetching products: $e");
      _pageLoadFailed = true;
    } finally {
      _isLoadingMore.value = false;
      _isInitialLoading.value = false;
      if (_useParentScroll && _hasMore.value && !_pageLoadFailed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadMoreIfViewportNotFull();
        });
      }
    }
  }

  void _loadProducts() {
    if (widget.contentJson != null) {
      final productData =
          widget.contentJson?['product'] ?? widget.contentJson?['products'];
      if (productData != null) {
        trendingList.assignAll(_productListFrom(productData) ??
            (productData is List ? productData : <dynamic>[]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final heading =
        (widget.contentJson?['heading'] ?? widget.contentJson?['title'] ?? '')
            .toString();
    final subheading = (widget.contentJson?['subheading'] ??
            widget.contentJson?['subtitle'] ??
            '')
        .toString();
    final categoryType =
        widget.contentJson?['category_type'] ?? 'random_category';

    // ─── Layout Configuration ───
    String style = widget.contentJson?['layout'] ?? 'standard';
    var displayHeading = heading.trim();
    var displaySubheading = subheading.trim();
    if (displayHeading == '_' || displayHeading.toLowerCase() == 'null') {
      displayHeading = '';
    }
    if (displaySubheading == '_' ||
        displaySubheading.toLowerCase() == 'null' ||
        displaySubheading.toLowerCase().contains('all products -')) {
      displaySubheading = '';
    }
    if (displayHeading.isEmpty && style != 'parent_web') {
      if (displaySubheading.isNotEmpty) {
        displayHeading = displaySubheading;
        displaySubheading = '';
      } else {
        displayHeading = switch (categoryType.toString()) {
          'discounted_products' => 'Special Offers',
          'most_popular' || 'popular' => 'Most Popular Products',
          'featured' => 'Featured Collection',
          _ => 'Trending Products',
        };
      }
    }

    debugPrint(
        'Products section: layout=$style, infiniteScroll=$_infiniteScroll, count=${trendingList.length}');

    return Obx(() => Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Section Header ───
                if (!widget.hideHeader &&
                    style != 'parent_web' &&
                    displayHeading.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: StudioSectionHeader(
                      title: displayHeading,
                      subtitle: displaySubheading.isNotEmpty
                          ? displaySubheading
                          : null,
                      onSeeAll: _tabsEnabled
                          ? null
                          : () {
                              openShop({
                                'filterType': categoryType,
                                'filterValue': true,
                                'name': displayHeading,
                                'source': 'dashboard'
                              });
                            },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_tabsEnabled) _buildTabBar(),
                if (_tabsEnabled) const SizedBox(height: 12),
                // ─── Product Cards ───
                ((_isInitialLoading.value && trendingList.isEmpty) ||
                        (_tabsEnabled &&
                            _isTabLoading.value &&
                            displayedProducts.isEmpty))
                    ? const SizedBox(
                        height: 260,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: TrendingProductsShimmer(),
                        ),
                      )
                    : trendingList.isEmpty
                        ? const SizedBox.shrink()
                        : (_tabsEnabled
                            ? _buildTabbedList()
                            : _buildProductLayout(style)),
                if (_tabsEnabled && displayedProducts.isNotEmpty)
                  _buildExploreTabButton(_tabs[_selectedTab.value]),
                if (_infiniteScroll &&
                    !_hasMoreValue &&
                    displayedProducts.isNotEmpty)
                  _buildEndOfCatalogFooter(colorScheme, textTheme),
                const SizedBox(height: 26),
              ],
            )
          ],
        ));
  }

  Widget _buildEndOfCatalogFooter(
      ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: colorScheme.outline.withValues(alpha: 0.25)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text(
                  "You've viewed all ${displayedProducts.length} items",
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Divider(color: colorScheme.outline.withValues(alpha: 0.25)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORY TABS (mirrors the website's "Favorite Style Product")
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTabBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final selected = _selectedTab.value == i;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _selectTab(i),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selected ? colorScheme.primary : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Text(
                _tabs[i]['name']?.toString() ?? '',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExploreTabButton(Map<String, dynamic> activeTab) {
    final colors = Theme.of(context).colorScheme;
    final name = (activeTab['name'] ?? 'Products').toString();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SizedBox(
        width: double.infinity,
        height: 42,
        child: OutlinedButton.icon(
          onPressed: () => openShop({
            'source': 'category',
            'categorySlug': activeTab['slug'],
            'category': activeTab['_id'] ?? activeTab['id'],
            'name': name,
          }),
          icon: const Icon(Icons.arrow_forward_rounded, size: 17),
          label: Text('Explore All $name'),
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.primary,
            side: BorderSide(color: colors.outline.withValues(alpha: 0.28)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    );
  }

  /// Selected tab's products as tall website-style cards in a sideways row.
  Widget _buildTabbedList() {
    final products = displayedProducts;
    final currentTab =
        _tabs.length > _selectedTab.value ? _tabs[_selectedTab.value] : null;

    if (products.isEmpty) {
      return _buildEmptyTabFallback(currentTab);
    }
    final cardWidth = (MediaQuery.of(context).size.width * 0.38)
        .clamp(140.0, 160.0)
        .toDouble();
    const imageAspectRatio = 0.75;
    final imageHeight = cardWidth / imageAspectRatio;
    const textSectionHeight = 88.0;
    final totalCardHeight = imageHeight + textSectionHeight;

    return SizedBox(
      height: totalCardHeight,
      child: DynamicHorizontalArrowScroller(
        itemCount: products.length,
        scrollStep: (cardWidth + 12) * 2,
        builder: (context, scrollController) => ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final product = products[index] as Map<String, dynamic>;
            final priceInfo = ProductHelper.calculatePriceInfo(product);
            if (!priceInfo['hasValidVariants']) return const SizedBox.shrink();
            return SizedBox(
              width: cardWidth,
              child: _buildSiteProductCard(product, priceInfo, imageHeight),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSiteProductCard(Map<String, dynamic> product,
      Map<String, dynamic> priceInfo, double imageHeight) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasDiscount = priceInfo['discountRate'] != null &&
        priceInfo['discountRate'].toString().trim().isNotEmpty;
    final isVariable = priceInfo['productType'] == 'variable';
    final productId = ProductHelper.getProductId(product);
    final variantId = _resolveDefaultVariantId(product);
    final rating = double.tryParse(
            (product['average_rating'] ?? product['rating'] ?? 0).toString()) ??
        0;
    final ratingCount = int.tryParse(
            (product['rating_count'] ?? product['review_count'] ?? 0)
                .toString()) ??
        0;

    return GestureDetector(
      onTap: () => _navigateToProduct(product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  (ProductHelper.getProductImage(product).isNotEmpty &&
                          ProductHelper.getProductImage(product) !=
                              HelperFunctions.getNoImage())
                      ? CachedNetworkImage(
                          imageUrl: ProductHelper.getProductImage(product),
                          fit: BoxFit.cover,
                          progressIndicatorBuilder: (_, __, ___) =>
                              HelperFunctions().loadingIndicator(),
                          errorWidget: (_, __, ___) =>
                              const AppImagePlaceholder(radius: 10),
                        )
                      : const AppImagePlaceholder(radius: 10),
                  if (hasDiscount)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Sale',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onError,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  // Floating 4-action vertical button stack (top right)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Add to cart
                        _actionCircleBtn(
                          icon: Icons.shopping_bag_outlined,
                          tooltip: 'Add to Cart',
                          onTap: () async {
                            if (ProductHelper.isInStock(product) &&
                                variantId.isNotEmpty) {
                              final added = await _handleAddToCart(
                                  product, productId, variantId, 1);
                              if (!added) return;
                              Get.snackbar(
                                'Added to Cart',
                                '${ProductHelper.getProductName(product)} added to your cart',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: colorScheme.primary,
                                colorText: colorScheme.onPrimary,
                                duration: const Duration(seconds: 3),
                                margin: const EdgeInsets.all(16),
                                mainButton: TextButton(
                                  onPressed: () {
                                    if (Get.isRegistered<
                                        BottombarController>()) {
                                      Get.find<BottombarController>()
                                          .currentPageIndex
                                          .value = 4;
                                      Get.find<BottombarController>()
                                          .pageController
                                          .jumpToPage(4);
                                    }
                                  },
                                  child: Text(
                                    'VIEW CART',
                                    style: TextStyle(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              Get.snackbar(
                                'Out of Stock',
                                'This product is out of stock',
                                snackPosition: SnackPosition.BOTTOM,
                                margin: const EdgeInsets.all(16),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 5),
                        // 2. Quick view
                        _actionCircleBtn(
                          icon: Icons.remove_red_eye_outlined,
                          tooltip: 'Quick View',
                          onTap: () =>
                              ProductQuickViewModal.show(context, product),
                        ),
                        const SizedBox(height: 5),
                        // 3. Wishlist
                        Obx(() {
                          final isFav =
                              WishListService.to.isInWishlist(productId);
                          return _actionCircleBtn(
                            icon: isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            iconColor: isFav ? colorScheme.error : null,
                            tooltip: 'Wishlist',
                            onTap: () => _handleWishlistTap(product),
                          );
                        }),
                        //const SizedBox(height: 5),
                        // 4. Compare
                        // _actionCircleBtn(
                        //   icon: Icons.swap_horiz_rounded,
                        //   tooltip: 'Compare',
                        //   onTap: () {
                        //     Get.snackbar(
                        //       'Compare',
                        //       '${ProductHelper.getProductName(product)} added to comparison',
                        //       snackPosition: SnackPosition.BOTTOM,
                        //       backgroundColor: colorScheme.secondary,
                        //       colorText: colorScheme.onSecondary,
                        //       duration: const Duration(seconds: 2),
                        //       margin: const EdgeInsets.all(16),
                        //     );
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Render actual review data instead of assuming a perfect rating.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) {
                final full = rating >= index + 1;
                final half = !full && rating >= index + 0.5;
                return Icon(
                  half
                      ? Icons.star_half_rounded
                      : full
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                  size: 13,
                  color: full || half
                      ? const Color(0xFFFFB800)
                      : colorScheme.outline.withValues(alpha: 0.45),
                );
              },
            ),
          ),
          if (rating > 0 || ratingCount > 0)
            Text(
              rating > 0 ? rating.toStringAsFixed(1) : '($ratingCount)',
              style: textTheme.labelSmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          const SizedBox(height: 4),
          // Title centered
          SizedBox(
            height: 32,
            child: Text(
              ProductHelper.getProductName(product),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.25,
                color: context.onSurfaceColor,
              ),
            ),
          ),
          const SizedBox(height: 3),
          // Price centered
          if (isVariable)
            Center(child: _buildVariablePrice(priceInfo))
          else
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ProductHelper.formatPrice(
                          priceInfo['productPrice']?.toString() ?? '0'),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      maxLines: 1,
                    ),
                    if (hasDiscount && priceInfo['salePrice'] != null) ...[
                      const SizedBox(width: 5),
                      Text(
                        ProductHelper.formatPrice(
                            priceInfo['salePrice'].toString()),
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionCircleBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Icon(
            icon,
            size: 15,
            color: iconColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTabFallback(Map<String, dynamic>? tab) {
    if (tab == null) {
      return _buildBrandEmptyState('Products');
    }

    final categoryName = tab['name']?.toString() ?? 'Category';
    final parentId = (tab['_id'] ?? tab['id'] ?? '').toString();

    // 1. Check if local children already exist in the category payload
    final localChildren = tab['children'];
    if (localChildren is List && localChildren.isNotEmpty) {
      return _buildSubcategoriesShelf(localChildren, categoryName);
    }

    // 2. Check in-memory cache
    if (_childCategoriesCache.containsKey(parentId)) {
      final cached = _childCategoriesCache[parentId]!;
      if (cached.isNotEmpty) {
        return _buildSubcategoriesShelf(cached, categoryName);
      }
      return _buildBrandEmptyState(categoryName);
    }

    // 3. Asynchronously fetch child categories for this parent category
    return FutureBuilder<List<dynamic>>(
      future: _fetchChildCategories(parentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 140,
            child: Center(child: HelperFunctions().loadingIndicator()),
          );
        }
        final children = snapshot.data ?? [];
        if (children.isNotEmpty) {
          return _buildSubcategoriesShelf(children, categoryName);
        }
        return _buildBrandEmptyState(categoryName);
      },
    );
  }

  Future<List<dynamic>> _fetchChildCategories(String parentId) async {
    if (parentId.isEmpty) return [];
    if (_childCategoriesCache.containsKey(parentId)) {
      return _childCategoriesCache[parentId]!;
    }
    try {
      final response = await BasicProvider('category').getRequest(
        queryParams: {'childrenOfParent': parentId},
      ).catchError((_) => null);

      List fetched = [];
      if (response is Map<String, dynamic> && response.containsKey('docs')) {
        fetched = response['docs'] is List ? response['docs'] : [];
      } else if (response is Map<String, dynamic> &&
          response.containsKey('data')) {
        fetched = response['data'] is List ? response['data'] : [];
      } else if (response is List) {
        fetched = response;
      }
      _childCategoriesCache[parentId] = fetched;
      return fetched;
    } catch (_) {
      _childCategoriesCache[parentId] = [];
      return [];
    }
  }

  Widget _buildSubcategoriesShelf(List children, String categoryName) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 16, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Explore $categoryName Styles',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: children.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final child = children[index] as Map<String, dynamic>;
                final name = child['name']?.toString() ?? '';
                final image =
                    HelperFunctions().getImage(child['featured_image']);
                final slug = child['slug']?.toString() ?? '';
                final id = (child['_id'] ?? child['id'] ?? '').toString();

                return GestureDetector(
                  onTap: () {
                    openShop(
                      {
                        'productId': id,
                        'categorySlug': slug,
                        'name': name,
                        'source': 'category',
                      },
                    );
                  },
                  child: Container(
                    width: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          (image.isNotEmpty &&
                                  image != HelperFunctions.getNoImage())
                              ? CachedNetworkImage(
                                  imageUrl: image,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) =>
                                      const AppImagePlaceholder(radius: 10),
                                  progressIndicatorBuilder: (_, __, ___) =>
                                      HelperFunctions().loadingIndicator(),
                                )
                              : const AppImagePlaceholder(radius: 10),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Color(0xCC000000)],
                                stops: [0.3, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            right: 36,
                            bottom: 10,
                            child: Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandEmptyState(String categoryName) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.storefront_outlined,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'New $categoryName Styles Coming Soon',
            textAlign: TextAlign.center,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'We are curating an exclusive collection. Check back soon or explore our full catalog.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {
              openShop({
                'name': 'All Products',
                'source': 'dashboard',
              });
            },
            icon: const Icon(Icons.arrow_forward, size: 14),
            label: const Text('Explore All Products'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side:
                  BorderSide(color: colorScheme.primary.withValues(alpha: 0.6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getDisplayLimit() {
    if (_tabsEnabled) return 1 << 30;
    final count = int.tryParse(widget.contentJson?['count']?.toString() ?? '');
    if (count != null && count > 0) return count;
    return 10;
  }

  List get displayedProducts {
    if (_infiniteScroll) {
      return trendingList;
    }
    final limit = _getDisplayLimit();
    return _tabProducts.take(limit).toList();
  }

  /// Route to the correct layout based on `view`, `list_view_type`, and card `style`
  Widget _buildProductLayout(String style) {
    final view = widget.contentJson?['view'] ?? 'list';
    final listViewType = widget.contentJson?['list_view_type'] ?? 'horizontal';

    if (view == 'grid') {
      return _buildGridView(style);
    }

    // list view
    if (listViewType == 'vertical') {
      return _buildVerticalListView(style);
    }

    // default: horizontal scrolling list (original behavior)
    switch (style) {
      case 'parent_web':
        return _buildParentWebHorizontalList();
      case 'horizontal':
        return _buildHorizontalStyleList();
      case 'overlay':
        return _buildOverlayStyleList();
      case 'standard':
      default:
        return _buildStandardStyleList();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GRID VIEW
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildGridView(String style) {
    final columns =
        int.tryParse(widget.contentJson?['columns']?.toString() ?? '1') ?? 1;
    final aspectRatio = double.tryParse(
            widget.contentJson?['aspect_ratio']?.toString() ?? '2.4') ??
        2.4;
    final spacing =
        double.tryParse(widget.contentJson?['spacing']?.toString() ?? '21') ??
            21;
    // final itemCount =
    //     _infiniteScroll ? trendingList.length + 1 : trendingList.length;

    final itemCount = _infiniteScroll
        ? displayedProducts.length + 1
        : displayedProducts.length;

    return Padding(
      padding: pageSurroundingPadding,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: aspectRatio,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          //if (index >= trendingList.length) {
          if (index >= displayedProducts.length) {
            return _buildLoadingIndicatorVertical();
          }
          final product = displayedProducts[index] as Map<String, dynamic>;
          final priceInfo = ProductHelper.calculatePriceInfo(product);
          if (!priceInfo['hasValidVariants']) return const SizedBox.shrink();
          return _buildGridItem(product, priceInfo, style);
        },
      ),
    );
  }

  List<Map<String, dynamic>> _configuredHeroCategories() {
    final raw = widget.contentJson?['hero_categories'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((category) => Map<String, dynamic>.from(category))
        .toList(growable: false);
  }

  Set<String> _categoryRecordIds(Map<String, dynamic> category) {
    final ids = <String>{};
    final id = category['_id'] ?? category['id'];
    if (id != null && id.toString().isNotEmpty) ids.add(id.toString());
    final children = category['children'];
    if (children is List) {
      for (final child in children) {
        if (child is Map) ids.addAll(_categoryTreeIds(child));
      }
    }
    return ids;
  }

  String _categoryRecordName(Map<String, dynamic> category) =>
      (category['name'] ?? category['title'] ?? '').toString().trim();

  Set<String> _configuredProductCategoryIds() {
    final raw = widget.contentJson?['category_ids'] ??
        widget.contentJson?['category_id'] ??
        widget.contentJson?['category'];
    final values = raw is List
        ? raw
        : raw == null
            ? const []
            : [raw];
    return values
        .map((value) => value is Map
            ? (value['_id'] ?? value['id'] ?? '').toString()
            : value.toString())
        .where((id) =>
            id.isNotEmpty &&
            !const {'product', 'products', 'all'}.contains(id.toLowerCase()))
        .toSet();
  }

  Set<String> _productCategoryIds(Map<String, dynamic> product) {
    final raw = product['categories'] ?? product['category'];
    final categories = raw is List
        ? raw
        : raw == null
            ? const []
            : [raw];
    return categories
        .map((category) => category is Map
            ? (category['_id'] ?? category['id'] ?? '').toString()
            : category.toString())
        .where((id) =>
            id.isNotEmpty &&
            !const {'product', 'products', 'all'}.contains(id.toLowerCase()))
        .toSet();
  }

  String _featuredCategoryName(Map<String, dynamic> product) {
    final directName = product['category_name']?.toString().trim();
    if (directName != null && directName.isNotEmpty) return directName;

    final raw = product['categories'] ?? product['category'];
    final categories = raw is List
        ? raw
        : raw == null
            ? const []
            : [raw];
    final configuredIds = _configuredProductCategoryIds();
    for (final category in categories) {
      final id = category is Map
          ? (category['_id'] ?? category['id'])?.toString()
          : category?.toString();
      if (category is Map &&
          (configuredIds.isEmpty || configuredIds.contains(id))) {
        final name = (category['name'] ?? category['title'])?.toString().trim();
        if (name != null && name.isNotEmpty) return name;
      }
      final mappedName =
          id == null ? null : FoduuStudioLayoutMixin.categoryNameMap[id];
      if ((configuredIds.isEmpty || configuredIds.contains(id)) &&
          mappedName != null &&
          mappedName.trim().isNotEmpty) {
        return mappedName.trim();
      }
    }
    return '';
  }

  /// Build a single grid item — uses the card style from `layout`
  Widget _buildGridItem(Map<String, dynamic> product,
      Map<String, dynamic> priceInfo, String style) {
    if (style == 'parent_web') {
      return ParentWebProductCard(
        product: product,
        isList: false,
        categoryLabel: _featuredCategoryName(product),
      );
    }

    if (style == 'overlay') {
      return _buildOverlayItem(product, priceInfo);
    }

    if (style == 'horizontal') {
      return _buildHorizontalItem(product, priceInfo);
    }
    // default: standard card style for grid
    return _buildStandardItem(product, priceInfo);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VERTICAL LIST VIEW
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildVerticalListView(String style) {
    final itemCount = _infiniteScroll
        ? displayedProducts.length + 1
        : displayedProducts.length;

    final isParentWeb = style == 'parent_web';
    final listPadding = isParentWeb
        ? const EdgeInsets.symmetric(vertical: 4)
        : pageSurroundingPadding;

    return Padding(
      padding: listPadding,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: isParentWeb ? 0 : 10),
        itemBuilder: (context, index) {
          if (index >= displayedProducts.length) {
            return _buildLoadingIndicatorVertical();
          }
          final product = displayedProducts[index] as Map<String, dynamic>;
          final priceInfo = ProductHelper.calculatePriceInfo(product);
          if (!priceInfo['hasValidVariants']) return const SizedBox.shrink();

          if (style == 'parent_web') {
            return ParentWebProductCard(
              product: product,
              isList: true,
              categoryLabel: _featuredCategoryName(product),
            );
          }

          if (style == 'overlay') {
            return _buildOverlayItem(product, priceInfo);
          }

          // Use horizontal-style card (image left, info right) for vertical lists
          return _buildHorizontalItem(product, priceInfo);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STYLE 0 — PARENT WEB (Clean portrait cards with 4 action buttons)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildParentWebHorizontalList() {
    final heroMode =
        widget.contentJson?['category_type'] == 'parent_category' ||
            widget.contentJson?['hero_categories'] is List;
    final heroProducts = displayedProducts
        .whereType<Map>()
        .map((product) => Map<String, dynamic>.from(product))
        .where((product) =>
            ProductHelper.calculatePriceInfo(product)['hasValidVariants'] ==
            true)
        .toList(growable: false);
    if (heroMode && heroProducts.isNotEmpty) {
      final categoryRecords = _configuredHeroCategories();
      final slides = <({Map<String, dynamic> product, String categoryName})>[];
      for (final category in categoryRecords) {
        final ids = _categoryRecordIds(category);
        if (ids.isEmpty) continue;
        for (final product in heroProducts) {
          final productId = ProductHelper.getProductId(product);
          final alreadyAdded = productId.isNotEmpty &&
              slides.any((slide) =>
                  ProductHelper.getProductId(slide.product) == productId);
          if (_productCategoryIds(product).intersection(ids).isNotEmpty &&
              !alreadyAdded) {
            slides.add((
              product: product,
              categoryName: _categoryRecordName(category),
            ));
          }
        }
      }

      if (categoryRecords.isEmpty) {
        final configuredIds = _configuredProductCategoryIds();
        final categoryProducts = configuredIds.isEmpty
            ? heroProducts
            : heroProducts
                .where((product) => _productCategoryIds(product)
                    .intersection(configuredIds)
                    .isNotEmpty)
                .toList();
        final selectedProducts =
            categoryProducts.isNotEmpty ? categoryProducts : heroProducts;
        for (final product in selectedProducts) {
          slides.add((
            product: product,
            categoryName: _featuredCategoryName(product),
          ));
        }
      }
      if (slides.isEmpty) return const SizedBox.shrink();
      final selected =
          _selectedFeaturedProduct.value.clamp(0, slides.length - 1).toInt();
      final itemCount =
          slides.length + (_infiniteScroll && _hasMoreValue ? 1 : 0);
      final heroHeight = _featuredHeroHeight(context);
      return Column(
        children: [
          SizedBox(
            height: heroHeight,
            child: PageView.builder(
              controller: _featuredPageController,
              itemCount: itemCount,
              onPageChanged: (index) {
                if (index >= slides.length) {
                  _triggerLoadMore();
                  return;
                }
                _selectedFeaturedProduct.value = index;
                if (_infiniteScroll && index >= slides.length - 2) {
                  _triggerLoadMore();
                }
              },
              itemBuilder: (context, index) {
                if (index >= slides.length) {
                  return Center(child: _buildLoadingIndicator());
                }
                final slide = slides[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildFeaturedHeroCard(
                    slide.product,
                    categoryNameOverride: slide.categoryName,
                  ),
                );
              },
            ),
          ),
          if (slides.length > 1) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Expanded(
                  child: Semantics(
                    label: 'Product ${selected + 1} of ${slides.length}',
                    child: LinearProgressIndicator(
                      value: (selected + 1) / slides.length,
                      minHeight: 3,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${selected + 1} / ${slides.length}'),
              ]),
            ),
          ],
        ],
      );
    }

    final itemCount = _infiniteScroll
        ? displayedProducts.length + 1
        : displayedProducts.length;

    final cardWidth = (MediaQuery.of(context).size.width * 0.40)
        .clamp(145.0, 175.0)
        .toDouble();
    const totalCardHeight = 270.0;

    return SizedBox(
      height: totalCardHeight,
      child: DynamicHorizontalArrowScroller(
        controller: _scrollController,
        itemCount: itemCount,
        scrollStep: (cardWidth + 12) * 2,
        builder: (context, scrollController) => ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            shrinkWrap: false,
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index >= displayedProducts.length) {
                return _buildLoadingIndicator();
              }
              final product = displayedProducts[index] as Map<String, dynamic>;
              final priceInfo = ProductHelper.calculatePriceInfo(product);
              if (!priceInfo['hasValidVariants']) {
                return const SizedBox.shrink();
              }
              return SizedBox(
                width: cardWidth,
                child: ParentWebProductCard(
                  product: product,
                  isList: false,
                  categoryLabel: _featuredCategoryName(product),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  double _featuredHeroHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 620 ? 430 : (width * 1.12).clamp(390.0, 500.0).toDouble();
  }

  Widget _buildFeaturedHeroCard(Map<String, dynamic> product,
      {String? categoryNameOverride}) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final priceInfo = ProductHelper.calculatePriceInfo(product);
    final imageUrl = ProductHelper.getProductImage(product);
    final productName = ProductHelper.getProductName(product);
    final categoryName = categoryNameOverride ?? _featuredCategoryName(product);
    final variantId = _resolveDefaultVariantId(product);
    final productId = ProductHelper.getProductId(product);
    final hasDiscount = '${priceInfo['discountRate'] ?? ''}'.trim().isNotEmpty;

    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 620;
      final height = _featuredHeroHeight(context);
      final image = ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(fit: StackFit.expand, children: [
          imageUrl.isNotEmpty && imageUrl != HelperFunctions.getNoImage()
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (_, __, ___) =>
                      HelperFunctions().loadingIndicator(),
                  errorWidget: (_, __, ___) =>
                      const AppImagePlaceholder(radius: 20),
                )
              : const AppImagePlaceholder(radius: 20),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.38, 1],
                colors: [Colors.transparent, Color(0xE6000000)],
              ),
            ),
          ),
          if (hasDiscount)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.error,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${priceInfo['discountRate']}',
                    style: text.labelSmall?.copyWith(
                        color: colors.onError, fontWeight: FontWeight.bold)),
              ),
            ),
          if (!wide)
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (categoryName.isNotEmpty) ...[
                    Text(categoryName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelMedium?.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                  ],
                  Text(productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.05)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Text(ProductHelper.formatPrice(priceInfo['productPrice']),
                        style: text.titleMedium?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    if (hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(ProductHelper.formatPrice(priceInfo['salePrice']),
                          style: text.bodySmall?.copyWith(
                              color: Colors.white70,
                              decoration: TextDecoration.lineThrough)),
                    ],
                  ]),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    FilledButton.icon(
                      onPressed: () async {
                        if (!ProductHelper.isInStock(product) ||
                            variantId.isEmpty) {
                          Get.snackbar('Out of Stock',
                              'This product is currently out of stock',
                              snackPosition: SnackPosition.BOTTOM);
                          return;
                        }
                        final added = await _handleAddToCart(
                            product, productId, variantId, 1);
                        if (added) {
                          Get.snackbar(
                            'Added to Cart',
                            '$productName added to your cart',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: colors.primary,
                            colorText: colors.onPrimary,
                            margin: const EdgeInsets.all(16),
                          );
                        }
                      },
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Add to Cart'),
                      style: FilledButton.styleFrom(
                          backgroundColor: colors.surface,
                          foregroundColor: colors.onSurface),
                    ),
                    OutlinedButton(
                      onPressed: () => _navigateToProduct(product),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white70)),
                      child: const Text('View Detail'),
                    ),
                  ]),
                ],
              ),
            ),
        ]),
      );
      if (!wide) return image;
      return Container(
        height: height,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (categoryName.isNotEmpty)
                    Text(categoryName.toUpperCase(),
                        style: text.labelMedium?.copyWith(
                            color: colors.primary,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(productName,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: text.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Text(ProductHelper.formatPrice(priceInfo['productPrice']),
                      style: text.titleLarge),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () async {
                      if (!ProductHelper.isInStock(product) ||
                          variantId.isEmpty) {
                        Get.snackbar('Out of Stock',
                            'This product is currently out of stock',
                            snackPosition: SnackPosition.BOTTOM);
                        return;
                      }
                      final added = await _handleAddToCart(
                          product, productId, variantId, 1);
                      if (added) {
                        Get.snackbar(
                          'Added to Cart',
                          '$productName added to your cart',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: colors.primary,
                          colorText: colors.onPrimary,
                          margin: const EdgeInsets.all(16),
                        );
                      }
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Add to Cart'),
                  ),
                  TextButton(
                      onPressed: () => _navigateToProduct(product),
                      child: const Text('View Detail')),
                ],
              ),
            ),
          ),
          Expanded(flex: 5, child: image),
        ]),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STYLE 1 — STANDARD (Vertical Card, Image on Top)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStandardStyleList() {
    final itemCount = _infiniteScroll
        ? displayedProducts.length + 1
        : displayedProducts.length;

    final cardWidth = (MediaQuery.of(context).size.width * 0.38)
        .clamp(140.0, 160.0)
        .toDouble();
    const imageAspectRatio = 0.75;
    final imageHeight = cardWidth / imageAspectRatio;
    const textSectionHeight = 88.0;
    final totalCardHeight = imageHeight + textSectionHeight;

    return SizedBox(
      height: totalCardHeight,
      child: DynamicHorizontalArrowScroller(
        controller: _scrollController,
        itemCount: itemCount,
        scrollStep: (cardWidth + 12) * 2,
        builder: (context, scrollController) => ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            shrinkWrap: false,
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index >= displayedProducts.length) {
                return _buildLoadingIndicator();
              }
              final product = displayedProducts[index] as Map<String, dynamic>;
              final priceInfo = ProductHelper.calculatePriceInfo(product);
              if (!priceInfo['hasValidVariants']) {
                return const SizedBox.shrink();
              }
              return SizedBox(
                width: cardWidth,
                child: _buildSiteProductCard(product, priceInfo, imageHeight),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStandardItem(
      Map<String, dynamic> product, Map<String, dynamic> priceInfo) {
    final cardWidth = (MediaQuery.of(context).size.width * 0.38)
        .clamp(140.0, 160.0)
        .toDouble();
    const imageAspectRatio = 0.75;
    final imageHeight = cardWidth / imageAspectRatio;

    return SizedBox(
      width: cardWidth,
      child: _buildSiteProductCard(product, priceInfo, imageHeight),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STYLE 2 — HORIZONTAL (Image Left, Info Right Card)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHorizontalStyleList() {
    final itemCount = _infiniteScroll
        ? displayedProducts.length + 1
        : displayedProducts.length;

    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: SizedBox(
        height: 120,
        child: DynamicHorizontalArrowScroller(
          controller: _scrollController,
          itemCount: itemCount,
          scrollStep: 310.0,
          builder: (context, scrollController) => ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            child: ListView.separated(
              controller: scrollController,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index >= displayedProducts.length) {
                  return _buildLoadingIndicator();
                }
                final product =
                    displayedProducts[index] as Map<String, dynamic>;
                final priceInfo = ProductHelper.calculatePriceInfo(product);
                if (!priceInfo['hasValidVariants']) {
                  return const SizedBox.shrink();
                }
                return SizedBox(
                  width: 300,
                  child: _buildHorizontalItem(product, priceInfo),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalItem(
      Map<String, dynamic> product, Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final productName = ProductHelper.getProductName(product);
    final imageUrl = ProductHelper.getProductImage(product);
    final productType = priceInfo['productType'];
    final storeName = product['storeName'] ?? 'Store Name';

    return GestureDetector(
      onTap: () => _navigateToProduct(product),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                  child: (imageUrl.isNotEmpty &&
                          imageUrl != HelperFunctions.getNoImage())
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder: (_, __, ___) =>
                              HelperFunctions().loadingIndicator(),
                          errorWidget: (_, __, ___) =>
                              const AppImagePlaceholder(radius: 0),
                        )
                      : const AppImagePlaceholder(
                          radius: 0, width: 120, height: 120),
                ),
                // Discount Badge
                if (priceInfo['discountRate'] != null &&
                    priceInfo['discountRate'].toString().isNotEmpty)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        priceInfo['discountRate'],
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onError,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Product Info
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      productName,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      storeName,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (productType == 'variable')
                      _buildVariablePrice(priceInfo)
                    else
                      _buildSimplePrice(priceInfo),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'View Product',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Wishlist + Add to Cart on the right
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildWishlistIcon(product),
                  if (ProductHelper.isInStock(product))
                    _buildCartControl(product),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STYLE 3 — OVERLAY (Full Image Card with Overlay Text)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildOverlayStyleList() {
    // final itemCount =
    //     _infiniteScroll ? trendingList.length + 1 : trendingList.length;

    final itemCount = _infiniteScroll
        ? displayedProducts.length + 1
        : displayedProducts.length;

    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: SizedBox(
        height: 260,
        child: DynamicHorizontalArrowScroller(
          controller: _scrollController,
          itemCount: itemCount,
          scrollStep: 280.0,
          builder: (context, scrollController) => ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            child: ListView.separated(
              controller: scrollController,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              shrinkWrap: false,
              cacheExtent: 9999,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index >= displayedProducts.length) {
                  return _buildLoadingIndicator();
                }
                final product =
                    displayedProducts[index] as Map<String, dynamic>;
                final priceInfo = ProductHelper.calculatePriceInfo(product);
                if (!priceInfo['hasValidVariants'])
                  return const SizedBox.shrink();
                return _buildOverlayItem(product, priceInfo);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayItem(
      Map<String, dynamic> product, Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final productName = ProductHelper.getProductName(product);
    final imageUrl = ProductHelper.getProductImage(product);
    final productType = priceInfo['productType'];
    final storeName = product['storeName'] ?? 'Store Name';

    return GestureDetector(
      onTap: () => _navigateToProduct(product),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full background image
              (imageUrl.isNotEmpty && imageUrl != HelperFunctions.getNoImage())
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (_, __, ___) =>
                          HelperFunctions().loadingIndicator(),
                      errorWidget: (_, __, ___) =>
                          const AppImagePlaceholder(radius: 14),
                    )
                  : const AppImagePlaceholder(radius: 14),
              // Gradient overlay at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        colorScheme.surface.withOpacity(0.7),
                        colorScheme.surface.withOpacity(0.95),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        productName,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        storeName,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (productType == 'variable')
                        _buildVariablePrice(priceInfo)
                      else
                        _buildSimplePrice(priceInfo),
                    ],
                  ),
                ),
              ),
              // Wishlist at top-left
              Positioned(
                left: 8,
                top: 8,
                child: _buildWishlistButton(product),
              ),
              // Add to Cart control at bottom-right, above the text panel
              if (ProductHelper.isInStock(product))
                Positioned(
                  right: 8,
                  bottom: 70,
                  child: _buildCartControl(product),
                ),
              // Discount badge at top-right
              if (priceInfo['discountRate'] != null &&
                  priceInfo['discountRate'].toString().isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      priceInfo['discountRate'],
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOADING INDICATORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Horizontal loading indicator (for standard & overlay horizontal lists)
  Widget _buildLoadingIndicator() {
    if (!_hasMoreValue) return const SizedBox.shrink();
    if (!_isExternal && _pageLoadFailed) {
      return SizedBox(
        width: 100,
        child: Center(
          child: TextButton(
            onPressed: _retryFetchProducts,
            child: Text('Retry'.tr),
          ),
        ),
      );
    }
    return const SizedBox(
      width: 60,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }

  /// Vertical loading indicator (for horizontal-style vertical list)
  Widget _buildLoadingIndicatorVertical() {
    if (!_hasMoreValue) return const SizedBox.shrink();
    if (!_isExternal && _pageLoadFailed) {
      return Center(
        child: TextButton(
          onPressed: _retryFetchProducts,
          child: Text('Retry'.tr),
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }

  void _retryFetchProducts() {
    if (_isExternal || _isLoadingMore.value) return;
    _pageLoadFailed = false;
    _fetchProductsFromApi();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Navigate to product detail page
  void _navigateToProduct(Map<String, dynamic> product) {
    final productId = ProductHelper.getProductId(product);
    Get.toNamed(
      Routes.PRODUCTDETAILS,
      arguments: {'productId': productId},
    );
  }

  /// Wishlist button with background circle (for Standard & Overlay styles)
  Widget _buildWishlistButton(Map<String, dynamic> product) {
    final colorScheme = Theme.of(context).colorScheme;
    final productId = ProductHelper.getProductId(product);

    return GestureDetector(
      onTap: () => _handleWishlistTap(product),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: colorScheme.surface.withOpacity(0.85),
        ),
        padding: const EdgeInsets.all(6.0),
        child: Obx(() {
          final isInWishlist = WishListService.to.isInWishlist(productId);
          return SvgPicture.asset(
            isInWishlist ? 'assets/icon/like.svg' : 'assets/icon/unlike.svg',
            width: 16,
            height: 16,
          );
        }),
      ),
    );
  }

  /// Wishlist icon without background (for Horizontal style)
  Widget _buildWishlistIcon(Map<String, dynamic> product) {
    final productId = ProductHelper.getProductId(product);

    return GestureDetector(
      onTap: () => _handleWishlistTap(product),
      child: Obx(() {
        final isInWishlist = WishListService.to.isInWishlist(productId);
        return SvgPicture.asset(
          isInWishlist ? 'assets/icon/like.svg' : 'assets/icon/unlike.svg',
          width: 20,
          height: 20,
        );
      }),
    );
  }

  /// Resolve the variant to add to cart for a product with no on-card
  /// variant picker — the cheapest in-stock variant, falling back to the
  /// cheapest variant overall if none are in stock.
  String _resolveDefaultVariantId(Map<String, dynamic> product) {
    final variants = product['variants'];
    if (variants is! List || variants.isEmpty) return '';

    Map? bestInStock;
    double bestInStockPrice = double.infinity;
    Map? bestOverall;
    double bestOverallPrice = double.infinity;

    for (var index = 0; index < variants.length; index++) {
      final v = variants[index];
      if (v is! Map) continue;
      final price = HelperFunctions.parseAmount(v['sale_price']) > 0
          ? HelperFunctions.parseAmount(v['sale_price'])
          : HelperFunctions.parseAmount(v['price']);

      if (price < bestOverallPrice) {
        bestOverallPrice = price;
        bestOverall = v;
      }

      final inStock = ProductHelper.isInStock(product, variantIndex: index);
      if (inStock && price < bestInStockPrice) {
        bestInStockPrice = price;
        bestInStock = v;
      }
    }

    final chosen = bestInStock ?? bestOverall;
    return (chosen?['_id'] ?? chosen?['id'] ?? '').toString();
  }

  /// Card-level add-to-cart control — shows a "+" when the product isn't in
  /// the cart, and a quantity stepper once it is. Reacts to CartService's
  /// cartItems for both guest (local) and logged-in (server) carts.
  Widget _buildCartControl(Map<String, dynamic> product) {
    final colorScheme = Theme.of(context).colorScheme;
    final productId = ProductHelper.getProductId(product);
    final variantId = _resolveDefaultVariantId(product);
    final variants = product['variants'];
    final requiresVariant = product['type'] == 'variable' ||
        (variants is List && variants.isNotEmpty);
    if (requiresVariant && variantId.isEmpty) return const SizedBox.shrink();

    return Obx(() {
      final cartItem = CartService.to.cartItems.firstWhereOrNull((item) {
        final p = item['product_id'];
        final pid = (p is Map ? (p['_id'] ?? p['id']) : p)?.toString();
        return pid == productId && item['variant_id'] == variantId;
      });

      if (cartItem == null) {
        return GestureDetector(
          onTap: () => _handleAddToCart(product, productId, variantId, 1),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary,
            ),
            padding: const EdgeInsets.all(6.0),
            child: Icon(Icons.add, size: 16, color: colorScheme.onPrimary),
          ),
        );
      }

      final qty = cartItem['quantity'] ?? 1;
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.primary),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _cartStepperButton(Icons.remove, colorScheme,
                () => _handleAddToCart(product, productId, variantId, -1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child:
                  Text('$qty', style: Theme.of(context).textTheme.labelMedium),
            ),
            _cartStepperButton(Icons.add, colorScheme,
                () => _handleAddToCart(product, productId, variantId, 1)),
          ],
        ),
      );
    });
  }

  Widget _cartStepperButton(
      IconData icon, ColorScheme colorScheme, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 14, color: colorScheme.primary),
      ),
    );
  }

  Future<bool> _handleAddToCart(Map<String, dynamic> product, String productId,
      String variantId, int delta) async {
    if (delta > 0 && !ProductHelper.isInStock(product)) {
      HelperFunctions().showSnackBarError('This product is out of stock.');
      return false;
    }
    if (delta > 0 &&
        (product['type'] == 'variable' || product['variants'] is List) &&
        variantId.isEmpty) {
      HelperFunctions().showSnackBarError('Select a product option first.');
      return false;
    }
    try {
      await CartService.to.manageCart(
        productId: productId,
        variantId: variantId,
        quantity: delta,
        product: product,
      );
      return true;
    } catch (e) {
      HelperFunctions().showSnackBarError("Failed to update cart".tr);
      return false;
    }
  }

  /// Handle wishlist tap
  void _handleWishlistTap(Map<String, dynamic> product) async {
    final productId = ProductHelper.getProductId(product);
    String variantSlug = product['variant_slug'] ?? '';
    String? variantId;

    if (product['type'] == 'variable') {
      final variants = product['variants'];
      if (variants is List && variants.isNotEmpty) {
        final variant = variants[0];
        variantId = (variant['_id'] ?? variant['id'])?.toString();
        variantSlug = variant['variant_slug'] ?? '';
      }
    }

    await WishListService.to.toggleWishlist(
      productId: productId,
      variantSlug: variantSlug,
      variantId: variantId,
    );
  }

  String _formatPrice(dynamic val) {
    if (val == null) return '';
    final s = val.toString().trim();
    if (s.isEmpty) return '';
    final numVal = num.tryParse(s);
    if (numVal != null) {
      if (numVal == numVal.roundToDouble()) {
        return numVal.toInt().toString();
      }
      return numVal.toStringAsFixed(2);
    }
    return s;
  }

  /// Variable product price display (compact version)
  Widget _buildVariablePrice(Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      '₹${_formatPrice(priceInfo['lowestPrice'])} - ₹${_formatPrice(priceInfo['highestPrice'])}',
      style: textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 11, // Reduced from 12
        color: colorScheme.primary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Simple product price display with discount (compact version)
  Widget _buildSimplePrice(Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        text: '₹${priceInfo['productPrice']}',
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 11, // Reduced from 12
          color: colorScheme.primary,
        ),
        children: [
          if (priceInfo['discountRate'] != null &&
              priceInfo['discountRate'].toString().isNotEmpty) ...[
            const TextSpan(text: '  '),
            TextSpan(
              text: '₹${priceInfo['discountPrice'] ?? priceInfo['salePrice']}',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 9, // Reduced from 10
                decoration: TextDecoration.lineThrough,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: priceInfo['discountRate'],
              style: textTheme.bodySmall?.copyWith(
                fontSize: 9, // Reduced from 10
                color: colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHIMMER PLACEHOLDER
// ═══════════════════════════════════════════════════════════════════════════
class TrendingProductsShimmer extends StatelessWidget {
  const TrendingProductsShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      enabled: true,
      direction: ShimmerDirection.ltr,
      loop: 0,
      period: const Duration(seconds: 1),
      baseColor: colorScheme.surfaceVariant,
      highlightColor: colorScheme.onSurfaceVariant.withOpacity(0.3),
      child: ListView.separated(
        itemCount: 10,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 10);
        },
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.outline,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  height: 160,
                  width: 160,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 14,
                        width: 140,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 12,
                        width: 100,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 13,
                        width: 80,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
