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

  // ─── Pagination State (for future use, but not affecting current design) ───
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
      } else if (productData is List) {
        trendingList.value = productData;
        _hasMore.value = false;
      }
    }

    if (_infiniteScroll) {
      _determineScrollMode();
      if (!_useParentScroll) {
        _scrollController = ScrollController();
        _scrollController!.addListener(_onScroll);
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

    final selfScrolling = (view == 'list') &&
        (listViewType != 'vertical') &&
        (style == 'standard' || style == 'overlay');

    _useParentScroll = !selfScrolling;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_infiniteScroll && _useParentScroll) {
      _parentScrollPosition?.removeListener(_onParentScroll);
      try {
        final scrollable = Scrollable.of(context);
        _parentScrollPosition = scrollable.position;
        _parentScrollPosition?.addListener(_onParentScroll);
      } catch (e) {
        print('⚠️ Could not attach parent scroll listener: $e');
      }
    }
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _parentScrollPosition?.removeListener(_onParentScroll);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController == null) return;
    if (_scrollController!.position.pixels >=
        _scrollController!.position.maxScrollExtent - 100) {
      _fetchProductsFromApi();
    }
  }

  void _onParentScroll() {
    if (_parentScrollPosition == null || !_parentScrollPosition!.hasPixels)
      return;
    if (_parentScrollPosition!.pixels >=
        _parentScrollPosition!.maxScrollExtent - 200) {
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

      List newProducts = [];
      if (response is Map) {
        _hasMore.value = response['hasNextPage'] ?? false;
        if (response['next'] != null) {
          _currentPage.value = int.parse(response['next'].toString());
        } else if (response['current_page'] != null) {
          _currentPage.value =
              int.parse(response['current_page'].toString()) + 1;
        }

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
    final heading = widget.contentJson?['heading'] ?? 'Trending';
    final subheading = widget.contentJson?['subheading'] ?? '';
    final categoryType =
        widget.contentJson?['category_type'] ?? 'random_category';
    final categoryIds = widget.contentJson?['categories'];
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ─── Layout Configuration ───
    String style = widget.contentJson?['layout'] ?? 'standard';

    return Obx(() => Column(
          children: [
            // ─── Section Header ───
            Padding(
              padding: pageSurroundingPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(heading, style: textTheme.titleLarge),
                        subheading.isEmpty
                            ? Container()
                            : Text(subheading,
                                style: textTheme.titleSmall!.copyWith(
                                    color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
                        'productId': categoryIds,
                        'name': heading,
                        'productype': categoryType,
                        'source': 'dashboard'
                      });
                    },
                    child: Text(
                      'See all',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
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
        ));
  }

  /// Route to the correct style builder - PRESERVING ORIGINAL DESIGN
  Widget _buildProductLayout(String style) {
    final view = widget.contentJson?['view'] ?? 'list';
    final listViewType = widget.contentJson?['list_view_type'] ?? 'horizontal';

    if (view == 'grid') {
      return _buildGridView(style);
    }

    if (listViewType == 'vertical') {
      return _buildVerticalListView(style);
    }

    // Original horizontal layouts with EXACT original designs
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
  // GRID VIEW - New layout option (doesn't affect original design)
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
    final itemCount =
        _infiniteScroll ? trendingList.length + 1 : trendingList.length;

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
          if (index >= trendingList.length) {
            return _buildLoadingIndicatorVertical();
          }
          final product = trendingList[index] as Map<String, dynamic>;
          final priceInfo = ProductHelper.calculatePriceInfo(product);
          if (!priceInfo['hasValidVariants']) return const SizedBox.shrink();
          return _buildGridItem(product, priceInfo, style);
        },
      ),
    );
  }

  Widget _buildGridItem(Map<String, dynamic> product,
      Map<String, dynamic> priceInfo, String style) {
    if (style == 'overlay') {
      return _buildOverlayItem(product, priceInfo);
    }

    if (style == 'horizontal') {
      return _buildHorizontalItem(product, priceInfo);
    }
    return _buildStandardItem(product, priceInfo);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VERTICAL LIST VIEW - New layout option (doesn't affect original design)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildVerticalListView(String style) {
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

  // ═══════════════════════════════════════════════════════════════════════════
  // STYLE 1 — STANDARD (ORIGINAL DESIGN - EXACTLY AS BEFORE)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStandardStyleList() {
    final itemCount =
        _infiniteScroll ? trendingList.length + 1 : trendingList.length;

    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: SizedBox(
        height: 250, // Reduced from 300 to 260 for better compactness
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
              if (index >= trendingList.length) {
                return _buildLoadingIndicator();
              }
              final product = trendingList[index];
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
    final storeName = product['storeName'] ?? 'Store Name';

    return InkWell(
      onTap: () => _navigateToProduct(product),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 150, // Slightly reduced from 160 for better fit
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 150, // Reduced from 180 to 150
                    width: 150,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (_, __, ___) =>
                        HelperFunctions().loadingIndicator(),
                    errorWidget: (_, __, ___) => Container(
                      height: 150,
                      width: 150,
                      color: colorScheme.surfaceVariant,
                      child: Icon(Icons.image_outlined,
                          color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
                // Wishlist Button
                Positioned(
                  left: 6,
                  top: 6,
                  child: _buildWishlistButton(product),
                ),
                // Discount Badge
                if (priceInfo['discountRate'] != null &&
                    priceInfo['discountRate'].toString().isNotEmpty)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        priceInfo['discountRate'],
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onError,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content Section - Compact padding
            Padding(
              padding: const EdgeInsets.all(8.0), // Reduced from 10 to 8
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Name
                  Text(
                    productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13, // Slightly smaller font
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2), // Reduced from 4 to 2
                  // Store Name
                  Text(
                    storeName,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4), // Reduced from 8 to 4
                  // Price at bottom left
                  if (productType == 'variable')
                    _buildVariablePrice(priceInfo)
                  else
                    _buildSimplePrice(priceInfo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STYLE 2 — HORIZONTAL (ORIGINAL DESIGN - EXACTLY AS BEFORE)
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

    return InkWell(
      onTap: () => _navigateToProduct(product),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.15),
            width: 1,
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
                    // Add to cart hint (Horizontal style unique feature)
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
            // Wishlist on the right (Horizontal style unique feature)
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
  // STYLE 3 — OVERLAY (ORIGINAL DESIGN - EXACTLY AS BEFORE)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildOverlayStyleList() {
    final itemCount =
        _infiniteScroll ? trendingList.length + 1 : trendingList.length;

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
              if (index >= trendingList.length) {
                return _buildLoadingIndicator();
              }
              final product = trendingList[index] as Map<String, dynamic>;
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

    return InkWell(
      onTap: () => _navigateToProduct(product),
      borderRadius: BorderRadius.circular(14),
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
              // Full background image (Overlay style unique feature)
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
              // Gradient overlay at bottom (Overlay style unique feature)
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
              // Discount badge at top-right (Overlay style unique feature - uses primary color)
              if (priceInfo['discountRate'] != null &&
                  priceInfo['discountRate'].toString().isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme
                          .primary, // Overlay style uses primary color
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
    final variantSlug = product['variant_slug'] ?? '';
    final variantId = product['variant_id']?.toString() ??
        ((product['variant_ids'] != null &&
                product['variant_ids'] is List &&
                product['variant_ids'].isNotEmpty)
            ? product['variant_ids'][0]['_id']?.toString()
            : (product['variants'] != null &&
                    product['variants'] is List &&
                    product['variants'].isNotEmpty)
                ? product['variants'][0]['_id']?.toString()
                : null);

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
        fontSize: 12, // Reduced from 13
        color: colorScheme.primary,
      ),
    );
  }

  /// Simple product price display with discount (compact version)
  Widget _buildSimplePrice(Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return RichText(
      text: TextSpan(
        text: '₹${priceInfo['productPrice']}',
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 12, // Reduced from 13
          color: colorScheme.primary,
        ),
        children: [
          if (priceInfo['discountRate'] != null &&
              priceInfo['discountRate'].toString().isNotEmpty) ...[
            const TextSpan(text: '  '),
            TextSpan(
              text: '₹${priceInfo['discountPrice']}',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 10, // Reduced from 11
                decoration: TextDecoration.lineThrough,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: priceInfo['discountRate'],
              style: textTheme.bodySmall?.copyWith(
                fontSize: 10, // Reduced from 11
                color: colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Wishlist button with background circle (compact for Standard & Overlay)
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
