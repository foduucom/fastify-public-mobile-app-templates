import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/product/views/product_view.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'studio_common_widgets.dart';

class TrendingProductSection extends StatefulWidget {
  final Map<String, dynamic>? contentJson;

  /// When provided, the section renders this externally-owned list instead
  /// of fetching its own data from [contentJson] — used by pages (Shop,
  /// Search) that already run their own filtered/paginated product fetch
  /// and just want the shared grid/card rendering.
  final RxList<dynamic>? externalProducts;

  /// Whether the external caller has more pages to load. Ignored unless
  /// [externalProducts] is set.
  final bool externalHasMore;

  /// Whether the external caller is currently fetching another page.
  /// Ignored unless [externalProducts] is set.
  final bool externalIsLoadingMore;

  /// Called when the scroll position nears the end, in external mode —
  /// the caller is responsible for fetching and appending to
  /// [externalProducts].
  final VoidCallback? onLoadMore;

  /// Hides the section heading/subheading/"see all" row — used in external
  /// mode where the surrounding page already has its own header/filters.
  final bool hideHeader;

  /// Called instead of the default product-detail navigation when a card is
  /// tapped — lets callers (e.g. Search) hook side effects like saving a
  /// recent search before navigating.
  final void Function(Map<String, dynamic> product)? onProductTap;

  const TrendingProductSection({
    super.key,
    this.contentJson,
    this.externalProducts,
    this.externalHasMore = false,
    this.externalIsLoadingMore = false,
    this.onLoadMore,
    this.hideHeader = false,
    this.onProductTap,
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
  final _hasMore = true.obs;
  int _countPerPage = 10;
  ScrollController? _scrollController;
  ScrollPosition? _parentScrollPosition;
  bool _useParentScroll = false;
  final _debugScrollInfo = "Pos: N/A".obs;

  bool get _hasMoreValue => _isExternal ? widget.externalHasMore : _hasMore.value;
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

  @override
  void initState() {
    super.initState();
    trendingList = widget.externalProducts ?? <dynamic>[].obs;

    if (_isExternal) {
      // Show the full external list (no display-limit truncation) with a
      // load-more row, same as infinite-scroll mode — but pagination/data
      // itself is entirely driven by the external caller. The grid is
      // embedded in the caller's own scrollable, so listen to that.
      _infiniteScroll = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _attachParentScrollListener();
      });
      return;
    }

    _infiniteScroll = widget.contentJson?['infinite_scroll'] == true;
    _countPerPage = widget.contentJson?['count'] ?? 10;

    // Pagination state is already handled by _loadProducts() or _fetchProductsFromApi()
    // No need to set trendingList.value here as it's redundant with _loadProducts()

    if (_infiniteScroll) {
      _determineScrollMode();
      print('Initialized scroll — useParentScroll=$_useParentScroll');
      if (!_useParentScroll) {
        _scrollController = ScrollController();
        _scrollController!.addListener(_onScroll);
      } else {
        // Wait for parent scrollable to be fully built and laid out before attaching
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _attachParentScrollListener();
        });
      }
      // If we don't have products yet, or if we need more
      if (trendingList.isEmpty && _hasMore.value) {
        _fetchProductsFromApi();
      }
    } else {
      _loadProducts();
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
        (style == 'standard' || style == 'overlay');

    _useParentScroll = !selfScrolling;
  }

  void _attachParentScrollListener() {
    if (!mounted) return;
    try {
      final scrollable = Scrollable.maybeOf(context);
      if (scrollable != null) {
        _parentScrollPosition = scrollable.position;
        _parentScrollPosition?.addListener(_onParentScroll);
        print(
            '✅ Attached parent scroll listener to: ${scrollable.axisDirection} scrollable');
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
    super.dispose();
  }

  /// Fires for self-scrolling horizontal lists (standard / overlay).
  void _onScroll() {
    if (_scrollController == null || !_scrollController!.hasClients) return;
    final pos = _scrollController!.position;
    _debugScrollInfo.value =
        "Pos: ${pos.pixels.toInt()} / ${pos.maxScrollExtent.toInt()}";
    if (pos.pixels >= pos.maxScrollExtent - 100) {
      _triggerLoadMore();
    }
  }

  /// Fires for parent-scrolling layouts (grid / vertical / horizontal-style).
  void _onParentScroll() {
    if (_parentScrollPosition == null || !_parentScrollPosition!.hasPixels)
      return;
    final pos = _parentScrollPosition!;
    _debugScrollInfo.value =
        "Pos: ${pos.pixels.toInt()} / ${pos.maxScrollExtent.toInt()}";

    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _triggerLoadMore();
    }
  }

  Future<void> _fetchProductsFromApi() async {
    if (_isLoadingMore.value || !_hasMore.value) {
      print(
          "⏳ Skipping fetch: isLoadingMore=${_isLoadingMore.value}, hasMore=${_hasMore.value}");
      return;
    }

    print("🚀 Starting product fetch...");
    _isLoadingMore.value = true;

    try {
      final categoryType =
          widget.contentJson?['category_type'] ?? 'random_category';
      final categoryIds = widget.contentJson?['category_ids'];

      print("📂 Category Type: $categoryType");
      print("🆔 Category IDs: $categoryIds");
      print("📄 Current Page: ${_currentPage.value}");
      print("🔢 Count Per Page: $_countPerPage");

      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'page': _currentPage.toString(),
        'count': _countPerPage.toString(),
      };

      if (categoryType == 'parent_category' ||
          categoryType == 'random_category') {
        queryParams['random'] = 'true';
        print("🎲 Fetching random products");
      } else if (categoryType == 'specific_category' &&
          categoryIds != null &&
          categoryIds is List &&
          categoryIds.isNotEmpty) {
        queryParams['specific'] = categoryIds.map((e) => e.toString()).toList();
        print(
            "🎯 Fetching specific category products: ${queryParams['specific']}");
      }

      print("🌐 Sending API request with params: $queryParams");

      final response = await BasicProvider('products')
          .getRequest(queryParams: queryParams)
          .catchError(handleError);

      if (response == null) {
        print("❌ API returned null response");
        _isLoadingMore.value = false;
        _hasMore.value = false;
        return;
      }

      print("✅ API Response received");

      // Handle response and update pagination state
      List newProducts = [];
      if (response is Map) {
        print("📦 Response is a Map");

        // Update pagination from response
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
        print("📦 Response is a List (deprecated structure)");
        newProducts = response;
        _hasMore.value = false;
      }

      print("🛍️ Products fetched: ${newProducts.length}");

      if (newProducts.isNotEmpty) {
        trendingList.addAll(newProducts);
      }

      print("➡️ Next page will be: ${_currentPage.value}");
      _isLoadingMore.value = false;

      // Final fallback if hasNextPage was missing
      if (response is Map && response['hasNextPage'] == null) {
        if (newProducts.length < _countPerPage) {
          _hasMore.value = false;
          print("🛑 No more products (fallback check)");
        }
      }
    } catch (e) {
      print("🔥 Error fetching products: $e");
      _isLoadingMore.value = false;
      _hasMore.value = false;
    }

    print("🏁 Fetch completed\n");
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
    final heading = widget.contentJson?['heading'] ?? 'Trending';
    final subheading = widget.contentJson?['subheading'] ?? '';
    final categoryType =
        widget.contentJson?['category_type'] ?? 'random_category';
    final categoryIds = widget.contentJson?['categories'];
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ─── Layout Configuration ───
    // 'style': 'standard' (default), 'horizontal', or 'overlay'
    String style = widget.contentJson?['layout'] ?? 'standard';

    debugPrint('DEBUG PRODUCTS SECTION: heading=$heading, layout=$style, infiniteScroll=$_infiniteScroll, contentJson=${widget.contentJson}');

    return Obx(() => Stack(
          children: [
            Column(
              children: [
                // ─── Section Header ───
                if (!widget.hideHeader) ...[
                  Padding(
                    padding: pageSurroundingPadding,
                    child: StudioSectionHeader(
                      title: heading,
                      subtitle: subheading,
                      onSeeAll: _infiniteScroll ||
                              (trendingList.length <= displayedProducts.length)
                          ? null
                          : () {
                              Get.toNamed(Routes.SHOPPRODUCTLISTVIEW,
                                  arguments: {
                                    'filterType': categoryType,
                                    'filterValue': true,
                                    'name': heading,
                                    'source': 'dashboard'
                                  });
                            },
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                // ─── Product Cards ───
                trendingList.isEmpty
                    ? const SizedBox(
                        height: 300,
                        child: Padding(
                          padding: EdgeInsets.only(left: 6.0),
                          child: TrendingProductsShimmer(),
                        ),
                      )
                    : _buildProductLayout(style),
                const SizedBox(height: 10),
              ],
            ),
            // ─── DEBUG OVERLAY ───
            if (_infiniteScroll)
              Positioned(
                top: 0,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _debugText("Items: ${trendingList.length}"),
                      _debugText("Page: ${_currentPage.value}"),
                      _debugText("Loading: ${_isLoadingMore.value}"),
                      _debugText("Has More: ${_hasMore.value}"),
                      _debugText("Parent Scroll: $_useParentScroll"),
                      _debugText(_debugScrollInfo.value),
                    ],
                  ),
                ),
              ),
          ],
        ));
  }

  Widget _debugText(String text) {
    return Text(
      text,
      style: const TextStyle(
          color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
    );
  }

  int _getDisplayLimit() {
    final style = widget.contentJson?['layout'] ?? 'standard';
    final listViewType = widget.contentJson?['list_view_type'] ?? 'horizontal';
    if (style == 'horizontal' || listViewType == 'vertical') {
      return 2;
    } else if (style == 'standard') {
      return 3;
    }
    return widget.contentJson?['count'] ?? 4;
  }

  List get displayedProducts {
    if (_infiniteScroll) {
      return trendingList;
    }
    final limit = _getDisplayLimit();
    return trendingList.take(limit).toList();
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
    double defaultAspectRatio = 2.4;
    if (style == 'standard') {
      defaultAspectRatio = 0.6;
    } else if (style == 'overlay') {
      defaultAspectRatio = 0.7;
    }
    double aspectRatio = double.tryParse(
            widget.contentJson?['aspect_ratio']?.toString() ?? '') ??
        defaultAspectRatio;

    if (style == 'standard' || style == 'overlay') {
      final screenWidth = MediaQuery.of(context).size.width;
      final paddingX = pageSurroundingPadding.horizontal;
      final spacingVal =
          double.tryParse(widget.contentJson?['spacing']?.toString() ?? '21') ??
              21;
      final cellWidth =
          (screenWidth - paddingX - (columns - 1) * spacingVal) / columns;
      final minHeight = style == 'standard' ? 245.0 : 255.0;
      final maxAspectRatio = cellWidth / minHeight;
      if (aspectRatio > maxAspectRatio) {
        aspectRatio = maxAspectRatio;
      }
    }

    final spacing =
        double.tryParse(widget.contentJson?['spacing']?.toString() ?? '21') ??
            21;
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
          if (index >= displayedProducts.length) {
            return _buildLoadingIndicatorVertical();
          }
          final product = displayedProducts[index] as Map<String, dynamic>;
          final priceInfo = ProductHelper.calculatePriceInfo(product);
          if (!priceInfo['hasValidVariants'])
            return const Text('No Valide Variants');
          return _buildGridItem(product, priceInfo, style);
        },
      ),
    );
  }

  /// Build a single grid item — uses the card style from `layout`
  Widget _buildGridItem(Map<String, dynamic> product,
      Map<String, dynamic> priceInfo, String style) {
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

    return Padding(
      padding: pageSurroundingPadding,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= displayedProducts.length) {
            return _buildLoadingIndicatorVertical();
          }
          final product = displayedProducts[index] as Map<String, dynamic>;
          final priceInfo = ProductHelper.calculatePriceInfo(product);
          if (!priceInfo['hasValidVariants']) return const SizedBox.shrink();
          // Use horizontal-style card (image left, info right) for vertical lists
          return _buildHorizontalItem(product, priceInfo);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STYLE 1 — STANDARD (Vertical Card, Image on Top)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStandardStyleList() {
    final itemCount = _infiniteScroll
        ? displayedProducts.length + 1
        : displayedProducts.length;

    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: SizedBox(
        height: 270,
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
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            shrinkWrap: false,
            cacheExtent: 9999,
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index >= displayedProducts.length) {
                return _buildLoadingIndicator();
              }
              final product = displayedProducts[index];
              final priceInfo = ProductHelper.calculatePriceInfo(product);
              if (!priceInfo['hasValidVariants'])
                return const SizedBox.shrink();
              return _buildStandardItem(product, priceInfo);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStandardItem(
      Map<String, dynamic> product, Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final productName = ProductHelper.getProductName(product);
    final imageUrl = ProductHelper.getProductImage(product);
    final productType = priceInfo['productType'];
    final inStock = ProductHelper.isInStock(product);
    print('For Product $productName and inStock $inStock');
    return GestureDetector(
      onTap: inStock ? () => _navigateToProduct(product) : null,
      child: Opacity(
        opacity: inStock ? 1.0 : 0.5,
        child: SizedBox(
          width: 160,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 0.9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        progressIndicatorBuilder: (_, __, ___) =>
                            HelperFunctions().loadingIndicator(),
                        errorWidget: (_, __, ___) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.image_outlined,
                              color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                  // Wishlist Button
                  _buildWishlistButton(product),
                  // Discount Badge
                  if (inStock &&
                      priceInfo['discountRate'] != null &&
                      priceInfo['discountRate'].toString().isNotEmpty)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(4),
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
                  // Out of Stock Badge
                  if (!inStock)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Out of Stock',
                          textAlign: TextAlign.center,
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Product Name
              Text(
                productName,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              ProductHelper.buildRatingWidget(product, textTheme, colorScheme),
              const SizedBox(height: 4),
              // Price
              if (productType == 'variable')
                _buildVariablePrice(priceInfo)
              else
                _buildSimplePrice(priceInfo),
            ],
          ),
        ),
      ),
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
      padding: pageSurroundingPadding,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= displayedProducts.length) {
            return _buildLoadingIndicatorVertical();
          }
          final product = displayedProducts[index] as Map<String, dynamic>;
          final priceInfo = ProductHelper.calculatePriceInfo(product);
          if (!priceInfo['hasValidVariants']) return const SizedBox.shrink();
          return _buildHorizontalItem(product, priceInfo);
        },
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

    // print('product image url $imageUrl');

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
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (_, __, ___) =>
                        HelperFunctions().loadingIndicator(),
                    errorWidget: (_, __, ___) => Container(
                      width: 120,
                      height: 120,
                      color: colorScheme.surfaceVariant,
                      child: Icon(Icons.image_outlined,
                          color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
                // Discount Badge
                if (priceInfo['discountRate'] != null &&
                    priceInfo['discountRate'].toString().isNotEmpty)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
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
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      productName,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    ProductHelper.buildRatingWidget(product, textTheme, colorScheme),
                    const SizedBox(height: 6),
                    if (productType == 'variable')
                      _buildVariablePrice(priceInfo)
                    else
                      _buildSimplePrice(priceInfo),
                    const Spacer(),
                    // Add to cart hint
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
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Wishlist on the right
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 8.0),
              child: Align(
                alignment: Alignment.topRight,
                child: _buildWishlistIcon(product),
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
    final itemCount = _infiniteScroll
        ? displayedProducts.length + 1
        : displayedProducts.length;

    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: SizedBox(
        height: 260,
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
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (_, __, ___) =>
                    HelperFunctions().loadingIndicator(),
                errorWidget: (_, __, ___) => Container(
                  color: colorScheme.surfaceVariant,
                  child: Icon(Icons.image_outlined,
                      color: colorScheme.onSurfaceVariant, size: 40),
                ),
              ),
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
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        productName,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      ProductHelper.buildRatingWidget(product, textTheme, colorScheme),
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
                left: 6,
                top: 6,
                child: _buildWishlistButton(product),
              ),
              // Discount badge at top-right
              if (priceInfo['discountRate'] != null &&
                  priceInfo['discountRate'].toString().isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
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
    if (widget.onProductTap != null) {
      widget.onProductTap!(product);
      return;
    }
    final productId = ProductHelper.getProductId(product);
    Get.to(
      () => ProductView(),
      preventDuplicates: false,
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

  /// Handle wishlist tap
  void _handleWishlistTap(Map<String, dynamic> product) async {
    final productId = ProductHelper.getProductId(product);
    String variantSlug = '';
    String? variantId;

    // Try to get variant slug from the variants array first (works for both simple and variable products)
    final variants = product['variants'];
    if (variants is List && variants.isNotEmpty) {
      final variant = variants[0];
      variantId = (variant['_id'] ?? variant['id'])?.toString();
      variantSlug = variant['slug'] ?? variant['variant_slug'] ?? '';
    }

    // Fallback to product-level slug if variants didn't provide one
    if (variantSlug.isEmpty) {
      variantSlug = product['variant_slug'] ?? product['slug'] ?? '';
    }

    await WishListService.to.toggleWishlist(
      productId: productId,
      variantSlug: variantSlug,
      variantId: variantId,
      productData: product,
    );
  }

  /// Variable product price display
  Widget _buildVariablePrice(Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      '₹${priceInfo['lowestPrice']} - ₹${priceInfo['highestPrice']}',
      style: textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
      ),
    );
  }

  /// Simple product price display with discount
  Widget _buildSimplePrice(Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return RichText(
      text: TextSpan(
        text: '₹${priceInfo['productPrice']}',
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
        children: [
          if (priceInfo['discountRate'] != null &&
              priceInfo['discountRate'].toString().isNotEmpty) ...[
            const TextSpan(text: '  '),
            TextSpan(
              text: '₹${priceInfo['salePrice']}',
              style: textTheme.bodySmall?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: colorScheme.onSurfaceVariant,
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
            return const SizedBox(
              width: 10,
            );
          },
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 180,
                  width: 160,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10)),
                  height: 11,
                  width: 150,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10)),
                  height: 11,
                  width: 50,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10)),
                  height: 11,
                  width: 100,
                ),
              ],
            );
          },
        ));
  }
}
