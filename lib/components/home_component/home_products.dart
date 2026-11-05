import 'package:cached_network_image/cached_network_image.dart';
import '/components/app_image_placeholder.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:foddu/core/services/wishlistService.dart' show WishListService;
import 'package:foddu/core/services/cartServcie.dart' show CartService;
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
import 'package:foddu/constants/dynamic_theme.dart';
import 'package:foddu/core/foduuStudio/foduu_studio_layout_mixin.dart';
import 'package:foddu/components/product_quick_view_modal.dart';
import 'package:foddu/components/parent_web_product_card.dart';
import 'package:foddu/app/modules/shop/shop_navigation.dart';
import 'package:foddu/app/modules/bottomar/controllers/bottombar_controller.dart';

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
  int _countPerPage = 10;
  ScrollController? _scrollController;
  ScrollPosition? _parentScrollPosition;
  bool _useParentScroll = false;

  // ─── Category tabs (built in-app from the page's categories section) ───
  List<Map<String, dynamic>> _tabs = [];
  final _selectedTab = 0.obs;
  final _selectedFeaturedProduct = 0.obs;
  final PageController _featuredPageController =
      PageController(viewportFraction: 0.94);
  bool get _tabsEnabled => _tabs.isNotEmpty;
  final _childCategoriesCache = <String, List<dynamic>>{}.obs;

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
    final layout = json?['layout'] ?? 'standard';
    final showTabs =
        json?['show_tabs'] ?? (layout == 'horizontal' || layout == 'standard');
    final cats = json?['tab_categories'];
    if (showTabs != true || _infiniteScroll || cats is! List) return;
    _tabs = [
      for (final c in cats)
        if (c is Map &&
            (c['_id'] != null || c['id'] != null) &&
            c['name'] != null)
          Map<String, dynamic>.from(c)
    ];
  }

  /// Products of the selected tab (all loaded products when tabs are off).
  List get _tabProducts {
    if (!_tabsEnabled) return trendingList;
    final tab = _tabs[_selectedTab.value];
    final id = (tab['_id'] ?? tab['id'] ?? '').toString();

    final childIds = <String>{};
    if (tab['children'] is List) {
      for (final ch in tab['children']) {
        if (ch is Map && (ch['_id'] != null || ch['id'] != null)) {
          childIds.add((ch['_id'] ?? ch['id']).toString());
        }
      }
    }

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
    final rawCount = widget.contentJson?['count'];
    _countPerPage = (rawCount is int && rawCount > 0)
        ? rawCount
        : int.tryParse(rawCount?.toString() ?? '') ?? 10;
    if (_countPerPage <= 0) _countPerPage = 10;
    _initTabs();

    // Handle products and pagination from contentJson
    final productData =
        widget.contentJson?['product'] ?? widget.contentJson?['products'];

    if (productData != null) {
      if (productData is Map) {
        trendingList.value = productData['data'] ?? [];
        _hasMore.value = productData['hasNextPage'] ?? false;
        _currentPage.value = productData['next'] ??
            ((productData['current_page'] ?? 1) + 1).toInt();
      } else {
        trendingList.value = productData;
        _hasMore.value = false;
      }
    } else {
      _currentPage.value = 1;
    }

    if (trendingList.isEmpty && !_isExternal) {
      _isInitialLoading.value = true;
    }

    if (_infiniteScroll) {
      _determineScrollMode();
      if (!_useParentScroll) {
        _scrollController = ScrollController();
        _scrollController!.addListener(_onScroll);
      } else {
        // Wait for parent scrollable to be fully built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _attachParentScrollListener();
        });
      }
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
    _featuredPageController.dispose();
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _parentScrollPosition?.removeListener(_onParentScroll);
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

  Future<void> _fetchProductsFromApi() async {
    if (_isLoadingMore.value || !_hasMore.value) return;

    _isLoadingMore.value = true;

    try {
      final heroCategoryIds = _configuredHeroCategories()
          .expand(_categoryRecordIds)
          .toSet()
          .toList(growable: false);
      final categoryType = heroCategoryIds.isNotEmpty
          ? 'specific_category'
          : widget.contentJson?['category_type'] ?? 'random_category';
      final configuredCategoryIds = widget.contentJson?['category_ids'];
      final categoryIds =
          heroCategoryIds.isNotEmpty ? heroCategoryIds : configuredCategoryIds;

      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'page': _currentPage.toString(),
        'count': _countPerPage.toString(),
      };

      if (categoryType == 'parent_category' ||
          categoryType == 'random_category') {
        queryParams['random'] = 'true';
      } else if (categoryType == 'specific_category' &&
          categoryIds != null &&
          categoryIds is List &&
          categoryIds.isNotEmpty) {
        queryParams['specific'] = categoryIds.map((e) => e.toString()).toList();
      }

      final response = await BasicProvider('products')
          .getRequest(queryParams: queryParams)
          .catchError(handleError);

      if (response == null) {
        _isLoadingMore.value = false;
        _hasMore.value = false;
        return;
      }

      // Handle response and update pagination state
      List newProducts = [];
      if (response is Map) {
        _hasMore.value = response['hasNextPage'] ?? false;
        if (response['next'] != null) {
          _currentPage.value = int.parse(response['next'].toString());
        } else if (response['current_page'] != null) {
          _currentPage.value =
              int.parse(response['current_page'].toString()) + 1;
        }

        // Extract products - check common keys
        if (response['data'] != null && response['data'] is List) {
          newProducts = response['data'];
        } else if (response['product'] != null && response['product'] is List) {
          newProducts = response['product'];
        } else if (response['products'] != null &&
            response['products'] is List) {
          newProducts = response['products'];
        }
      } else if (response is List) {
        newProducts = response;
        _hasMore.value = false;
      }

      if (newProducts.isNotEmpty) {
        trendingList.addAll(newProducts);
      }

      _isLoadingMore.value = false;

      // Final fallback if hasNextPage was missing
      if (response is Map && response['hasNextPage'] == null) {
        if (newProducts.length < _countPerPage) {
          _hasMore.value = false;
        }
      }
    } catch (e) {
      print("🔥 Error fetching products: $e");
      _isLoadingMore.value = false;
      _hasMore.value = false;
    } finally {
      _isInitialLoading.value = false;
    }
  }

  void _loadProducts() {
    if (widget.contentJson != null) {
      final productData =
          widget.contentJson?['product'] ?? widget.contentJson?['products'];
      if (productData != null) {
        if (productData is List) {
          trendingList.assignAll(productData);
        } else if (productData is Map && productData['data'] != null) {
          trendingList.assignAll(List.from(productData['data']));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

    debugPrint('Products section: heading="$heading", layout=$style, '
        'infiniteScroll=$_infiniteScroll, count=${trendingList.length}');

    return Obx(() => Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Section Header ───
                if (!widget.hideHeader &&
                    style != 'parent_web' &&
                    (heading.isNotEmpty || subheading.isNotEmpty)) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: StudioSectionHeader(
                      title: heading.isNotEmpty ? heading : subheading,
                      subtitle: heading.isNotEmpty && subheading.isNotEmpty
                          ? subheading
                          : null,
                      onSeeAll: () {
                        openShop({
                          'filterType': categoryType,
                          'filterValue': true,
                          'name': heading.isNotEmpty ? heading : 'Products',
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
                (_isInitialLoading.value && trendingList.isEmpty)
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
                const SizedBox(height: 18),
              ],
            )
          ],
        ));
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
            onTap: () => _selectedTab.value = i,
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
    const textSectionHeight = 98.0;
    final totalCardHeight = imageHeight + textSectionHeight;

    return SizedBox(
      height: totalCardHeight,
      child: ListView.separated(
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
                  // Floating Wishlist Heart (top right)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Obx(() {
                      final isFav = WishListService.to.isInWishlist(productId);
                      return _actionCircleBtn(
                        icon: isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        iconColor: isFav ? colorScheme.error : null,
                        tooltip: 'Wishlist',
                        onTap: () => _handleWishlistTap(product),
                      );
                    }),
                  ),
                  // Floating Quick Add to Bag (bottom right)
                  if (ProductHelper.isInStock(product) && variantId.isNotEmpty)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: _actionCircleBtn(
                        icon: Icons.shopping_bag_outlined,
                        tooltip: 'Add to Cart',
                        onTap: () async {
                          await _handleAddToCart(
                              product, productId, variantId, 1);
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
                                if (Get.isRegistered<BottombarController>()) {
                                  Get.find<BottombarController>()
                                      .currentPageIndex
                                      .value = cartTabIndex;
                                  Get.find<BottombarController>()
                                      .pageController
                                      .jumpToPage(cartTabIndex);
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
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          // 5-star rating centered
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => const Icon(
                Icons.star_rounded,
                size: 13,
                color: Color(0xFFFFB800),
              ),
            ),
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
                        color: colorScheme.onSurface,
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
        int.tryParse(widget.contentJson?['columns']?.toString() ?? '2') ?? 2;

    // Determine safe aspect ratio:
    // Vertical portrait cards (parent_web, standard, overlay) require childAspectRatio <= 0.85.
    // If the CMS passes a squat ratio (like 2.4), clamp to proper vertical ratios:
    // 2 columns -> ~0.58 (matching boutique portrait card standards)
    // 3+ columns -> ~0.52
    // 1 column -> ~0.65
    double resolvedAspectRatio;
    if (style == 'horizontal') {
      resolvedAspectRatio = double.tryParse(
              widget.contentJson?['aspect_ratio']?.toString() ?? '2.4') ??
          2.4;
    } else {
      final configuredRatio = double.tryParse(
          widget.contentJson?['aspect_ratio']?.toString() ?? '');
      if (configuredRatio != null &&
          configuredRatio > 0 &&
          configuredRatio <= 0.85) {
        resolvedAspectRatio = configuredRatio;
      } else {
        resolvedAspectRatio =
            columns >= 3 ? 0.52 : (columns == 1 ? 0.65 : 0.58);
      }
    }

    final spacing =
        double.tryParse(widget.contentJson?['spacing']?.toString() ?? '12') ??
            12;

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
          childAspectRatio: resolvedAspectRatio,
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

  /// Build a single grid item — uses the card style from `layout`
  Widget _buildGridItem(Map<String, dynamic> product,
      Map<String, dynamic> priceInfo, String style) {
    if (style == 'parent_web') {
      return ParentWebProductCard(product: product, isList: false);
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
            return ParentWebProductCard(product: product, isList: true);
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
    final loadedProducts = displayedProducts
        .whereType<Map>()
        .map((product) => Map<String, dynamic>.from(product))
        .where(
          (product) =>
              ProductHelper.calculatePriceInfo(product)['hasValidVariants'] ==
              true,
        )
        .toList();
    if (loadedProducts.isEmpty) return const SizedBox.shrink();

    final bool isHeroCarousel =
        widget.contentJson?['category_type'] == 'parent_category' &&
            (widget.contentJson?['hero_categories'] != null ||
                (widget.contentJson?['count'] ?? 0) == 0);

    // If not the top hero section, render as clean boutique portrait cards
    if (!isHeroCarousel) {
      const double cardWidth = 155.0;
      const double cardHeight = 265.0;
      return SizedBox(
        height: cardHeight,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: loadedProducts.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return SizedBox(
              width: cardWidth,
              child: ParentWebProductCard(
                product: loadedProducts[index],
                isList: false,
              ),
            );
          },
        ),
      );
    }

    final categoryRecords = _configuredHeroCategories();
    final slides = <({Map<String, dynamic> product, String categoryName})>[];

    // Preserve the configured category order, while giving every matching
    // product its own hero slide instead of promoting only the first product.
    for (final category in categoryRecords) {
      final ids = _categoryRecordIds(category);
      if (ids.isEmpty) continue;
      for (final product in loadedProducts) {
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

    // Without configured hero categories, honor the section's explicit
    // category scope when product category metadata is available.
    if (categoryRecords.isEmpty) {
      final configuredIds = _configuredProductCategoryIds();
      final hasProductCategoryData = loadedProducts.any(
        (product) => _productCategoryIds(product).isNotEmpty,
      );
      final categoryProducts = configuredIds.isEmpty
          ? loadedProducts
          : loadedProducts
              .where((product) => _productCategoryIds(product)
                  .intersection(configuredIds)
                  .isNotEmpty)
              .toList();
      final products = configuredIds.isNotEmpty &&
              hasProductCategoryData &&
              categoryProducts.isEmpty
          ? <Map<String, dynamic>>[]
          : categoryProducts.isEmpty
              ? loadedProducts
              : categoryProducts;
      for (final product in products) {
        slides.add((
          product: product,
          categoryName: _featuredCategoryName(product),
        ));
      }
    }
    if (slides.isEmpty) return const SizedBox.shrink();

    final selected =
        _selectedFeaturedProduct.value.clamp(0, slides.length - 1).toInt();
    final hasLoadMoreSlide = _infiniteScroll && _hasMoreValue;
    final itemCount = slides.length + (hasLoadMoreSlide ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _featuredHeroHeight(context),
          child: PageView.builder(
            controller: _featuredPageController,
            itemCount: itemCount,
            onPageChanged: (index) {
              if (index < slides.length) {
                _selectedFeaturedProduct.value = index;
                if (hasLoadMoreSlide && index >= slides.length - 2) {
                  _triggerLoadMore();
                }
              } else {
                _triggerLoadMore();
              }
            },
            itemBuilder: (context, index) {
              if (index >= slides.length) {
                return Center(child: _buildLoadingIndicator());
              }
              final slide = slides[index];
              return Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: _buildParentWebFeaturedProduct(
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
            child: Row(
              children: [
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
              ],
            ),
          ),
        ],
      ],
    );
  }

  double _featuredHeroHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 620 ? 430 : (width * 1.12).clamp(390.0, 500.0).toDouble();
  }

  List<Map<String, dynamic>> _configuredHeroCategories() {
    final raw = widget.contentJson?['hero_categories'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((category) => Map<String, dynamic>.from(category))
        .toList(growable: false);
  }

  String _categoryRecordName(Map<String, dynamic> category) =>
      (category['name'] ?? category['title'] ?? '').toString().trim();

  Set<String> _categoryRecordIds(Map<String, dynamic> category) {
    final ids = <String>{};
    final id = category['_id'] ?? category['id'];
    if (id != null && id.toString().isNotEmpty) ids.add(id.toString());
    final children = category['children'];
    if (children is List) {
      for (final child in children) {
        if (child is! Map) continue;
        final childId = child['_id'] ?? child['id'];
        if (childId != null && childId.toString().isNotEmpty) {
          ids.add(childId.toString());
        }
      }
    }
    return ids;
  }

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
        .map((value) {
          if (value is Map)
            return (value['_id'] ?? value['id'] ?? '').toString();
          return value.toString();
        })
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  String _featuredCategoryName(Map<String, dynamic> product) {
    if (product['category_name'] != null &&
        product['category_name'].toString().trim().isNotEmpty) {
      return product['category_name'].toString().trim();
    }
    final raw = product['categories'] ?? product['category'];
    final categories = raw is List
        ? raw
        : raw == null
            ? const []
            : [raw];
    final configuredIds = _configuredProductCategoryIds();
    dynamic category;
    for (final item in categories) {
      if (item is Map &&
          configuredIds.contains(
            (item['_id'] ?? item['id'] ?? '').toString(),
          )) {
        category = item;
        break;
      }
    }
    if (configuredIds.isEmpty && categories.isNotEmpty) {
      category = categories.first;
    }
    if (category is Map) {
      final name = (category['name'] ?? category['title'])?.toString();
      if (name != null && name.trim().isNotEmpty) return name.trim();
    }
    if (category != null) {
      final id = category.toString();
      final mapped = FoduuStudioLayoutMixin.categoryNameMap[id];
      if (mapped != null && mapped.trim().isNotEmpty) return mapped.trim();
    }
    for (final item in categories) {
      final id = (item is Map ? (item['_id'] ?? item['id']) : item)?.toString();
      if (id != null) {
        final mapped = FoduuStudioLayoutMixin.categoryNameMap[id];
        if (mapped != null && mapped.trim().isNotEmpty) return mapped.trim();
      }
    }
    return '';
  }

  Set<String> _productCategoryIds(Map<String, dynamic> product) {
    final raw = product['categories'] ?? product['category'];
    final categories = raw is List
        ? raw
        : raw == null
            ? const []
            : [raw];
    return categories
        .map((category) {
          if (category is Map) {
            return (category['_id'] ?? category['id'] ?? '').toString();
          }
          return category.toString();
        })
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Widget _buildParentWebFeaturedProduct(
    Map<String, dynamic> product, {
    String? categoryNameOverride,
  }) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final priceInfo = ProductHelper.calculatePriceInfo(product);
    final imageUrl = ProductHelper.getProductImage(product);
    final name = ProductHelper.getProductName(product);
    final categoryName = categoryNameOverride ?? _featuredCategoryName(product);
    final productId = ProductHelper.getProductId(product);
    final variantId = _resolveDefaultVariantId(product);
    final hasDiscount =
        priceInfo['discountRate']?.toString().trim().isNotEmpty ?? false;
    final mediaHeight = (MediaQuery.of(context).size.width * 1.12)
        .clamp(390.0, 500.0)
        .toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 620;
        final detailColor = wide ? colors.onSurface : Colors.white;
        late final Widget details;
        final image = ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: wide ? 380 : mediaHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
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
                if (!wide)
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.42, 1],
                        colors: [Colors.transparent, Color(0xD9000000)],
                      ),
                    ),
                  ),
                if (hasDiscount)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.error,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        priceInfo['discountRate'].toString().trim(),
                        style: text.labelSmall?.copyWith(
                          color: colors.onError,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (!wide)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Builder(builder: (_) => details),
                  ),
              ],
            ),
          ),
        );

        details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (categoryName.isNotEmpty) ...[
              Text(
                categoryName.toUpperCase(),
                style: text.labelMedium?.copyWith(
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w700,
                  color: wide ? colors.primary : Colors.white70,
                ),
              ),
              const SizedBox(height: 10),
            ],
            Text(
              name,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: (wide ? text.displaySmall : text.headlineMedium)?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.0,
                letterSpacing: -0.8,
                color: detailColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              children: [
                Text(
                  ProductHelper.formatPrice(priceInfo['productPrice']),
                  style: text.titleLarge?.copyWith(
                    color: detailColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (hasDiscount)
                  Text(
                    ProductHelper.formatPrice(priceInfo['salePrice']),
                    style: text.bodyMedium?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: wide ? colors.onSurfaceVariant : Colors.white70,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    if (!ProductHelper.isInStock(product) ||
                        variantId.isEmpty) {
                      Get.snackbar(
                        'Out of Stock',
                        'This product is currently out of stock',
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                      );
                      return;
                    }
                    await _handleAddToCart(product, productId, variantId, 1);
                    Get.snackbar(
                      'Added to Cart',
                      '$name added to your cart',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: colors.primary,
                      colorText: colors.onPrimary,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Add to Cart'),
                  style: wide
                      ? null
                      : FilledButton.styleFrom(
                          backgroundColor: colors.surface,
                          foregroundColor: colors.onSurface,
                          minimumSize: const Size(148, 48),
                        ),
                ),
                TextButton(
                  onPressed: () => _navigateToProduct(product),
                  style: TextButton.styleFrom(
                    foregroundColor: wide ? colors.primary : Colors.white,
                    minimumSize: const Size(112, 48),
                  ),
                  child: const Text('View Detail'),
                ),
              ],
            ),
          ],
        );

        return Container(
          padding: EdgeInsets.all(wide ? 24 : 0),
          decoration: BoxDecoration(
            color: wide ? colors.surfaceContainerLow : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: wide
              ? Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: details,
                      ),
                    ),
                    Expanded(flex: 6, child: image),
                  ],
                )
              : image,
        );
      },
    );
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
    const textSectionHeight = 98.0;
    final totalCardHeight = imageHeight + textSectionHeight;

    return SizedBox(
      height: totalCardHeight,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: ListView.separated(
          controller: _scrollController,
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
    );
  }

  Widget _buildStandardItem(
      Map<String, dynamic> product, Map<String, dynamic> priceInfo) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : (MediaQuery.of(context).size.width * 0.38)
                .clamp(140.0, 160.0)
                .toDouble();
        const imageAspectRatio = 0.75;
        final calculatedImageHeight = cardWidth / imageAspectRatio;
        // Keep image height within cell bounds leaving room for stars, title, and price
        final imageHeight = constraints.maxHeight.isFinite && constraints.maxHeight > 120
            ? (constraints.maxHeight - 90).clamp(60.0, calculatedImageHeight)
            : calculatedImageHeight;

        return SizedBox(
          width: cardWidth,
          child: _buildSiteProductCard(product, priceInfo, imageHeight),
        );
      },
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 120,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: ListView.separated(
            controller: _scrollController,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
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
                width: 280,
                child: _buildHorizontalItem(product, priceInfo),
              );
            },
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
    final brand = product['brand'];
    final brandName = brand is Map ? brand['name'] : brand;
    final rawStore = (product['storeName'] ?? brandName ?? '').toString().trim();
    final bool showStore =
        rawStore.isNotEmpty && rawStore.toLowerCase() != 'store name';

    return GestureDetector(
      onTap: () => _navigateToProduct(product),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
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
                          width: 100,
                          height: 120,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder: (_, __, ___) =>
                              HelperFunctions().loadingIndicator(),
                          errorWidget: (_, __, ___) =>
                              const AppImagePlaceholder(radius: 0),
                        )
                      : const AppImagePlaceholder(
                          radius: 0, width: 100, height: 120),
                ),
                // Discount Badge
                if (priceInfo['discountRate'] != null &&
                    priceInfo['discountRate'].toString().isNotEmpty)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
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
                          fontWeight: FontWeight.w700,
                          fontSize: 9.5,
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
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showStore) ...[
                          Text(
                            rawStore.toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 9.5,
                              letterSpacing: 0.8,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          productName,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    // Rating Stars
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (index) => const Icon(
                          Icons.star_rounded,
                          size: 11,
                          color: Color(0xFFFFB800),
                        ),
                      ),
                    ),
                    // Price
                    if (productType == 'variable')
                      _buildVariablePrice(priceInfo)
                    else
                      _buildSimplePrice(priceInfo),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 276,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: ListView.separated(
            controller: _scrollController,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            shrinkWrap: false,
            cacheExtent: 9999,
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index >= displayedProducts.length) {
                return _buildLoadingIndicator();
              }
              final product = displayedProducts[index] as Map<String, dynamic>;
              final priceInfo = ProductHelper.calculatePriceInfo(product);
              if (!priceInfo['hasValidVariants'])
                return const SizedBox.shrink();
              return _buildOverlayItem(product, priceInfo);
            },
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
    final brand = product['brand'];
    final brandName = brand is Map ? brand['name'] : brand;
    final rawStore = (product['storeName'] ?? brandName ?? '').toString().trim();
    final bool showStore =
        rawStore.isNotEmpty && rawStore.toLowerCase() != 'store name';

    return GestureDetector(
      onTap: () => _navigateToProduct(product),
      child: Container(
        width: 164,
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
              // Keep product photography unobstructed and put information on
              // a predictable surface beneath it.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 78,
                child: Container(
                  color: colorScheme.surface.withOpacity(0.97),
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        productName,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (showStore) ...[
                        const SizedBox(height: 2),
                        Text(
                          rawStore,
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
              // Keep the cart action within the photo area, clear of the
              // caption and price.
              if (ProductHelper.isInStock(product))
                Positioned(
                  right: 8,
                  bottom: 86,
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
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      priceInfo['discountRate'],
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
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

    for (final v in variants) {
      if (v is! Map) continue;
      final price = HelperFunctions.parseAmount(v['sale_price']) > 0
          ? HelperFunctions.parseAmount(v['sale_price'])
          : HelperFunctions.parseAmount(v['price']);

      if (price < bestOverallPrice) {
        bestOverallPrice = price;
        bestOverall = v;
      }

      final stockStatus = (v['stock_status'] ?? '').toString();
      final inStock = stockStatus.isEmpty || stockStatus == 'in_stock';
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
    if (variantId.isEmpty) return const SizedBox.shrink();

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
              color: const Color(0xFF111111),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(7.0),
            child: const Icon(Icons.add, size: 16, color: Colors.white),
          ),
        );
      }

      // When in cart: sleek boutique checkmark in onyx circle
      return GestureDetector(
        onTap: () {
          Get.snackbar(
            'In Your Bag',
            '${ProductHelper.getProductName(product)} is in your shopping bag',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF111111),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF111111),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(7.0),
          child: const Icon(Icons.check_rounded,
              size: 16, color: Color(0xFFD4AF37)),
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

  Future<void> _handleAddToCart(Map<String, dynamic> product, String productId,
      String variantId, int delta) async {
    try {
      await CartService.to.manageCart(
        productId: productId,
        variantId: variantId,
        quantity: delta,
        product: product,
      );
    } catch (e) {
      HelperFunctions().showSnackBarError("Failed to update cart".tr);
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
    final low = _formatPrice(priceInfo['lowestPrice']);
    final high = _formatPrice(priceInfo['highestPrice']);
    final priceText = (low == high || high.isEmpty || high == '0')
        ? '₹$low'
        : '₹$low - ₹$high';

    return Text(
      priceText,
      style: textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: colorScheme.onSurface,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Simple product price display with discount (compact version)
  Widget _buildSimplePrice(Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final productPrice = _formatPrice(priceInfo['productPrice']);
    final discountPrice =
        _formatPrice(priceInfo['discountPrice'] ?? priceInfo['salePrice']);
    final discountRate = (priceInfo['discountRate'] ?? '').toString().trim();

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        text: '₹$productPrice',
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: colorScheme.onSurface,
        ),
        children: [
          if (discountRate.isNotEmpty &&
              discountPrice.isNotEmpty &&
              discountPrice != productPrice &&
              discountPrice != '0') ...[
            const TextSpan(text: '  '),
            TextSpan(
              text: '₹$discountPrice',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 10,
                decoration: TextDecoration.lineThrough,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: discountRate,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE53935),
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
