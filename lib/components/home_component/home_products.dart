import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart'
    show WishListService;
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

class TrendingProductSection extends StatefulWidget {
  final Map<String, dynamic>? contentJson;

  const TrendingProductSection({
    super.key,
    this.contentJson,
  });

  @override
  State<TrendingProductSection> createState() => _TrendingProductCardState();
}

class _TrendingProductCardState extends State<TrendingProductSection>
    with BaseController {
  final trendingList = <dynamic>[].obs;

  // ─── Pagination State ───
  bool _infiniteScroll = false;
  final _currentPage = 2.obs;
  final _isLoadingMore = false.obs;
  final _hasMore = true.obs;
  int _countPerPage = 10;
  ScrollController? _scrollController;
  ScrollPosition? _parentScrollPosition;
  bool _useParentScroll = false;

  @override
  void initState() {
    super.initState();
    _infiniteScroll = widget.contentJson?['infinite_scroll'] == true;
    _countPerPage = widget.contentJson?['count'] ?? 10;

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
    if (pos.pixels >= pos.maxScrollExtent - 100) {
      _fetchProductsFromApi();
    }
  }

  /// Fires for parent-scrolling layouts (grid / vertical / horizontal-style).
  void _onParentScroll() {
    if (_parentScrollPosition == null || !_parentScrollPosition!.hasPixels)
      return;
    final pos = _parentScrollPosition!;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _fetchProductsFromApi();
    }
  }

  Future<void> _fetchProductsFromApi() async {
    if (_isLoadingMore.value || !_hasMore.value) return;

    _isLoadingMore.value = true;

    try {
      final categoryType =
          widget.contentJson?['category_type'] ?? 'random_category';
      final categoryIds = widget.contentJson?['category_ids'];

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
    final showHeader =
        heading.trim().isNotEmpty && subheading.trim().isNotEmpty;
    final categoryType =
        widget.contentJson?['category_type'] ?? 'random_category';
    final categoryIds = widget.contentJson?['categories'];
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ─── Layout Configuration ───
    String style = widget.contentJson?['layout'] ?? 'standard';

    debugPrint(
        'DEBUG PRODUCTS SECTION: heading=$heading, layout=$style, infiniteScroll=$_infiniteScroll, contentJson=${widget.contentJson}');

    return Obx(() => Stack(
      children: [
        Column(
          children: [
            // ─── Section Header ───
            // if (!_infiniteScroll)
            //   StudioSectionHeader(
            //     title: heading,
            //     subtitle: subheading,
            //     onSeeAll: () => Get.toNamed(Routes.SEARCH),
            //   ),
            Padding(
                  padding: pageSurroundingPadding,
                  child: StudioSectionHeader(
                    title: heading,
                    subtitle: subheading,
                    onSeeAll: _infiniteScroll ||
                            (trendingList.length <= displayedProducts.length)
                        ? null
                        : () {
                            Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
                              'filterType': categoryType,
                              'filterValue': true,
                              'name': heading,
                              'source': 'dashboard'
                            });
                          },
                  ),
                ),
          
            const SizedBox(height: 4),
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
        )
      ],
    )  }

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
    // final itemCount =
    //     _infiniteScroll ? trendingList.length + 1 : trendingList.length;

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
    // final itemCount =
    //     _infiniteScroll ? trendingList.length + 1 : trendingList.length;

    final itemCount = _infiniteScroll
        ? displayedProducts.length + 1
        : displayedProducts.length;

    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: SizedBox(
        height: 250, // Increased height to accommodate content
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
              //if (index >= trendingList.length) {
              if (index >= displayedProducts.length) {
                return _buildLoadingIndicator();
              }
              final product = displayedProducts[index] as Map<String, dynamic>;
              final priceInfo = ProductHelper.calculatePriceInfo(product);
              if (!priceInfo['hasValidVariants'])
                return const SizedBox.shrink();
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 270, // Max height for each card
                  minWidth: 150,
                  maxWidth: 220,
                ),
                child: _buildStandardItem(product, priceInfo),
              );
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
    final storeName = product['brand']?['name'] ?? 'Store Name';

    // Calculate responsive width based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth > 600
        ? screenWidth * 0.25 // Tablet: 25% of screen width
        : screenWidth * 0.30; // Mobile: 30% of screen width
    final clampedWidth = itemWidth.clamp(150.0, 220.0);

    return GestureDetector(
      onTap: () => _navigateToProduct(product),
      child: SizedBox(
        width: clampedWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Alternative image widget that fills width while maintaining aspect ratio
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: SizedBox(
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  height:
                      180, // Fixed height, but maintains aspect ratio through fit
                  width: double.infinity,
                  progressIndicatorBuilder: (_, __, ___) =>
                      HelperFunctions().loadingIndicator(),
                  errorWidget: (_, __, ___) => Container(
                    height: 180,
                    color: colorScheme.surfaceVariant,
                    child: Icon(Icons.image_outlined,
                        color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
            // Content Section - Use Flexible to take remaining space but not overflow
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name
                    Flexible(
                      child: Text(
                        productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Store Name
                    Text(
                      storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Price
                    if (productType == 'variable')
                      _buildVariablePrice(priceInfo)
                    else
                      _buildSimplePrice(priceInfo),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STYLE 2 — HORIZONTAL (Image Left, Info Right Card)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHorizontalStyleList() {
    final itemCount =
        _infiniteScroll ? trendingList.length + 1 : trendingList.length;

    return Padding(
      padding: pageSurroundingPadding,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= trendingList.length) {
            return _buildLoadingIndicatorVertical();
          }
          final product = trendingList[index] as Map<String, dynamic>;
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
    // final itemCount =
    //     _infiniteScroll ? trendingList.length + 1 : trendingList.length;

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
    if (!_hasMore.value) return const SizedBox.shrink();
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
    if (!_hasMore.value) return const SizedBox.shrink();
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

  /// Variable product price display (compact version)
  Widget _buildVariablePrice(Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      '₹${priceInfo['lowestPrice']} - ₹${priceInfo['highestPrice']}',
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
              text: '₹${priceInfo['discountPrice']}',
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
                  height: 180,
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
