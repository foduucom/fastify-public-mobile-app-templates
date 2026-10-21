import 'package:cached_network_image/cached_network_image.dart';
import '/components/app_image_placeholder.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/core/services/wishlistService.dart';
import '/core/services/cartServcie.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/app/modules/product/views/product_view.dart';
import '/app/modules/bottomar/controllers/bottombar_controller.dart';
import '/app/routes/app_pages.dart';
import '/constants/constants.dart';
import '/constants/dynamic_theme.dart';
import '/constants/helper_functions.dart';
import '/constants/product_helper.dart';
import '/components/product_quick_view_modal.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'studio_common_widgets.dart';
import 'package:new_fastify_template/components/parent_web_product_card.dart';

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
  final _hasMore = true.obs;
  int _countPerPage = 10;
  ScrollController? _scrollController;
  ScrollPosition? _parentScrollPosition;
  bool _useParentScroll = false;
  final _debugScrollInfo = "Pos: N/A".obs;

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

  @override
  void initState() {
    super.initState();
    trendingList = widget.externalProducts ?? <dynamic>[].obs;

    if (_isExternal) {
      _infiniteScroll = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _attachParentScrollListener();
      });
      return;
    }

    _infiniteScroll = widget.contentJson?['infinite_scroll'] == true;
    _countPerPage = widget.contentJson?['count'] ?? 10;

    // Handle products and pagination from contentJson
    final productData =
        widget.contentJson?['product'] ?? widget.contentJson?['products'];

    if (productData != null) {
      if (productData is Map) {
        trendingList.value = productData['data'] ?? [];
        _hasMore.value = productData['hasNextPage'] == true;
        _currentPage.value =
            int.tryParse(productData['next']?.toString() ?? '') ??
                ((int.tryParse(productData['current_page']?.toString() ?? '') ??
                        1) +
                    1);
      } else if (productData is List) {
        trendingList.value = productData;
        _hasMore.value = false;
      }
    }

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
    if (_parentScrollPosition == null || !_parentScrollPosition!.hasPixels) {
      return;
    }
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
    final heading = widget.contentJson?['section_title'] ??
        widget.contentJson?['heading'] ??
        'Trending';
    final subheading = widget.contentJson?['section_subtitle'] ??
        widget.contentJson?['subheading'] ??
        '';

    // ─── Layout Configuration ───
    // 'style': 'standard' (default), 'horizontal', or 'overlay'
    String style = widget.contentJson?['layout'] ?? 'standard';

    return Obx(() => Stack(
          children: [
            Column(
              children: [
                // ─── Section Header ───
                if (!_infiniteScroll && !widget.hideHeader)
                  StudioSectionHeader(
                    eyebrow: widget.contentJson?['eyebrow']?.toString(),
                    title: heading,
                    subtitle: subheading,
                    onSeeAll: () => Get.toNamed(Routes.CATEGORY),
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
            ),
            // ─── DEBUG OVERLAY ───
            if (_infiniteScroll && !_isExternal)
              Positioned(
                top: 0,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  int get _itemCount =>
      _infiniteScroll ? trendingList.length + 1 : trendingList.length;

  /// Extracts price display data from priceInfo map.
  ({
    String displayPrice,
    String originalPrice,
    bool hasDiscount,
    String discountRate
  }) _parsePriceData(Map<String, dynamic> priceInfo) {
    final displayPrice = priceInfo['productPrice']?.toString() ?? '0';
    final originalPrice = priceInfo['salePrice']?.toString() ?? '0';
    final hasDiscount = originalPrice != '0' &&
        originalPrice.isNotEmpty &&
        originalPrice != displayPrice;
    final discountRate = priceInfo['discountRate']?.toString() ?? '';
    return (
      displayPrice: displayPrice,
      originalPrice: originalPrice,
      hasDiscount: hasDiscount,
      discountRate: discountRate,
    );
  }

  /// Price row: bold current price + strikethrough original if discounted.
  Widget _buildPriceRichText(
      String displayPrice, String originalPrice, String discountRate) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return RichText(
      text: TextSpan(
        text: '₹$displayPrice',
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
        children: [
          if (discountRate.isNotEmpty) ...[
            const TextSpan(text: '  '),
            TextSpan(
              text: '₹$originalPrice',
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

  /// Wraps [child] with ScrollConfiguration that enables touch/mouse/trackpad.
  Widget _withScrollConfig(Widget child) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      child: child,
    );
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
        if (websiteDomain.contains('fashion-ecom')) {
          return _buildParentWebHorizontalList();
        }
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
        itemCount: _itemCount,
        itemBuilder: (context, index) {
          if (index >= trendingList.length) {
            return _buildLoadingIndicatorVertical();
          }
          final product = trendingList[index] as Map<String, dynamic>;
          final priceInfo = ProductHelper.calculatePriceInfo(product);
          if (!priceInfo['hasValidVariants']) {
            return const Text('No Valide Variants');
          }
          return _buildGridItem(product, priceInfo, style);
        },
      ),
    );
  }

  /// Build a single grid item — uses the card style from `layout`
  Widget _buildGridItem(Map<String, dynamic> product,
      Map<String, dynamic> priceInfo, String style) {
    if (style == 'parent_web' ||
        (style == 'standard' && websiteDomain.contains('fashion-ecom'))) {
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
    return Padding(
      padding: pageSurroundingPadding.copyWith(top: 8),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= trendingList.length) {
            return _buildLoadingIndicatorVertical();
          }
          final product = trendingList[index] as Map<String, dynamic>;
          final priceInfo = ProductHelper.calculatePriceInfo(product);
          if (!priceInfo['hasValidVariants']) return const SizedBox.shrink();
          // Use horizontal-style card (image left, info right) for vertical lists
          return _buildHorizontalItem(product, priceInfo);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STYLE 0 — PARENT WEB (Portrait 2-col fashion card mirroring parent website)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildParentWebHorizontalList() {
    final cardWidth = (MediaQuery.of(context).size.width * 0.46)
        .clamp(170.0, 195.0)
        .toDouble();
    const totalCardHeight = 315.0;

    return SizedBox(
      height: totalCardHeight,
      child: _withScrollConfig(
        ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          shrinkWrap: false,
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: _itemCount,
          itemBuilder: (context, index) {
            if (index >= trendingList.length) {
              return _buildLoadingIndicator();
            }
            final product = trendingList[index] as Map<String, dynamic>;
            final priceInfo = ProductHelper.calculatePriceInfo(product);
            if (!priceInfo['hasValidVariants']) {
              return const SizedBox.shrink();
            }
            return SizedBox(
              width: cardWidth,
              child: ParentWebProductCard(product: product, isList: false),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STYLE 1 — STANDARD (Vertical Card, Image on Top)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStandardStyleList() {
    final cardWidth = (MediaQuery.of(context).size.width * 0.38)
        .clamp(140.0, 160.0)
        .toDouble();
    const imageAspectRatio = 0.75;
    final imageHeight = cardWidth / imageAspectRatio;
    const textSectionHeight = 88.0;
    final totalCardHeight = imageHeight + textSectionHeight;

    return SizedBox(
      height: totalCardHeight,
      child: _withScrollConfig(
        ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          shrinkWrap: false,
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: _itemCount,
          itemBuilder: (context, index) {
            if (index >= trendingList.length) {
              return _buildLoadingIndicator();
            }
            final product = trendingList[index] as Map<String, dynamic>;
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

  Widget _buildSiteProductCard(Map<String, dynamic> product,
      Map<String, dynamic> priceInfo, double imageHeight) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasDiscount = priceInfo['discountRate'] != null &&
        priceInfo['discountRate'].toString().trim().isNotEmpty;
    final isVariable = priceInfo['productType'] == 'variable';
    final productId = ProductHelper.getProductId(product);
    final variantId = _resolveDefaultVariantId(product);
    final imageUrl = ProductHelper.getProductImage(product);

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
                  (imageUrl.isNotEmpty &&
                          imageUrl != HelperFunctions.getNoImage())
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
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
                  // Floating 3-action vertical button stack (top right)
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
                      ],
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
                color: DefaultThemeColors.alertWarninglight,
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
                color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Icon(
            icon,
            size: 15,
            color: iconColor ?? colorScheme.onSurface,
          ),
        ),
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

  Widget _buildVariablePrice(Map<String, dynamic> priceInfo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      '₹${_formatPrice(priceInfo['lowestPrice'])} - ₹${_formatPrice(priceInfo['highestPrice'])}',
      style: textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 11,
        color: colorScheme.primary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STYLE 2 — HORIZONTAL (Image Left, Info Right Card)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHorizontalStyleList() {
    return Padding(
      padding: pageSurroundingPadding,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _itemCount,
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
    print("imageUrl === $imageUrl");
    final productType = priceInfo['productType'];
    final (:displayPrice, :originalPrice, :hasDiscount, :discountRate) =
        _parsePriceData(priceInfo);

    return GestureDetector(
      onTap: () => _navigateToProduct(product),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.15),
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
                              const AppImagePlaceholder(
                            radius: 12,
                            width: 120,
                            height: 120,
                          ),
                        )
                      : const AppImagePlaceholder(
                          radius: 12,
                          width: 120,
                          height: 120,
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
                    const SizedBox(height: 6),
                    if (productType == 'variable')
                      Text(
                        '₹${priceInfo['lowestPrice']} - ₹${priceInfo['highestPrice']}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      )
                    else
                      _buildPriceRichText(
                          displayPrice, originalPrice, discountRate),
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
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: SizedBox(
        height: 260, // Increased to 320 to be extra safe against overflows
        child: _withScrollConfig(
          ListView.separated(
            controller: _scrollController,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            shrinkWrap: false,
            cacheExtent: 9999,
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: _itemCount,
            itemBuilder: (context, index) {
              if (index >= trendingList.length) {
                return _buildLoadingIndicator();
              }
              final product = trendingList[index] as Map<String, dynamic>;
              final priceInfo = ProductHelper.calculatePriceInfo(product);
              if (!priceInfo['hasValidVariants']) {
                return const SizedBox.shrink();
              }
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
    final (:displayPrice, :originalPrice, :hasDiscount, :discountRate) =
        _parsePriceData(priceInfo);

    return GestureDetector(
      onTap: () => _navigateToProduct(product),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.08),
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
                        colorScheme.surface.withValues(alpha: 0.7),
                        colorScheme.surface.withValues(alpha: 0.95),
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
                      const SizedBox(height: 4),
                      if (productType == 'variable')
                        Text(
                          '₹${priceInfo['lowestPrice']} - ₹${priceInfo['highestPrice']}',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        )
                      else
                        _buildPriceRichText(
                            displayPrice, originalPrice, discountRate),
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
          color: colorScheme.surface.withValues(alpha: 0.85),
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
        // Use first variant as default if none selected
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

  /// Variable product price display
  // Widget _buildVariablePrice(Map<String, dynamic> priceInfo) {
  //   final colorScheme = Theme.of(context).colorScheme;
  //   final textTheme = Theme.of(context).textTheme;

  //   return Text(
  //     '₹${priceInfo['lowestPrice']} - ₹${priceInfo['highestPrice']}',
  //     style: textTheme.bodyMedium?.copyWith(
  //       fontWeight: FontWeight.w600,
  //       color: colorScheme.primary,
  //     ),
  //   );
  // }

  /// Simple product price display with discount
  // Widget _buildSimplePrice(Map<String, dynamic> priceInfo) {
  //   final colorScheme = Theme.of(context).colorScheme;
  //   final textTheme = Theme.of(context).textTheme;

  //   return RichText(
  //     text: TextSpan(
  //       text: '₹${priceInfo['productPrice']}',
  //       style: textTheme.bodyMedium?.copyWith(
  //         fontWeight: FontWeight.w600,
  //         color: colorScheme.primary,
  //       ),
  //       children: [
  //         if (priceInfo['discountRate'] != null &&
  //             priceInfo['discountRate'].toString().isNotEmpty) ...[
  //           const TextSpan(text: '  '),
  //           TextSpan(
  //             text: '₹${priceInfo['discountPrice']}',
  //             style: textTheme.bodySmall?.copyWith(
  //               decoration: TextDecoration.lineThrough,
  //               color: colorScheme.onSurfaceVariant,
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }
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
        baseColor: colorScheme.surfaceContainerHighest,
        highlightColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
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
                    color: colorScheme.surfaceContainerHighest,
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
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10)),
                  height: 11,
                  width: 150,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10)),
                  height: 11,
                  width: 50,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
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

// ═══════════════════════════════════════════════════════════════════════════
// EXPORTABLE COMMON STUDIO PRODUCT CARD
// ═══════════════════════════════════════════════════════════════════════════
class StudioProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final double? imageHeight;
  final VoidCallback? onTap;

  const StudioProductCard({
    super.key,
    required this.product,
    this.imageHeight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final priceInfo = ProductHelper.calculatePriceInfo(product);
    final hasDiscount = priceInfo['discountRate'] != null &&
        priceInfo['discountRate'].toString().trim().isNotEmpty;
    final isVariable = priceInfo['productType'] == 'variable';
    final productId = ProductHelper.getProductId(product);
    final variantId = _resolveDefaultVariantId(product);
    final imageUrl = ProductHelper.getProductImage(product);

    final cardWidth = (MediaQuery.of(context).size.width * 0.38)
        .clamp(140.0, 160.0)
        .toDouble();
    const imageAspectRatio = 0.75;
    final calculatedHeight = imageHeight ?? (cardWidth / imageAspectRatio);

    return GestureDetector(
      onTap: onTap ??
          () {
            Get.to(
              () => ProductView(),
              preventDuplicates: false,
              arguments: {'productId': productId},
            );
          },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: calculatedHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  (imageUrl.isNotEmpty &&
                          imageUrl != HelperFunctions.getNoImage())
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
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
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _actionBtn(
                          context: context,
                          icon: Icons.shopping_bag_outlined,
                          tooltip: 'Add to Cart',
                          onTap: () async {
                            if (ProductHelper.isInStock(product) &&
                                variantId.isNotEmpty) {
                              try {
                                await CartService.to.manageCart(
                                  productId: productId,
                                  variantId: variantId,
                                  quantity: 1,
                                  product: product,
                                );
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
                              } catch (_) {
                                HelperFunctions().showSnackBarError(
                                    "Failed to update cart".tr);
                              }
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
                        _actionBtn(
                          context: context,
                          icon: Icons.remove_red_eye_outlined,
                          tooltip: 'Quick View',
                          onTap: () =>
                              ProductQuickViewModal.show(context, product),
                        ),
                        const SizedBox(height: 5),
                        Obx(() {
                          final isFav =
                              WishListService.to.isInWishlist(productId);
                          return _actionBtn(
                            context: context,
                            icon: isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            iconColor: isFav ? colorScheme.error : null,
                            tooltip: 'Wishlist',
                            onTap: () async {
                              String variantSlug =
                                  product['variant_slug'] ?? '';
                              String? vId;
                              if (product['type'] == 'variable') {
                                final vList = product['variants'];
                                if (vList is List && vList.isNotEmpty) {
                                  final v0 = vList[0];
                                  vId = (v0['_id'] ?? v0['id'])?.toString();
                                  variantSlug = v0['variant_slug'] ?? '';
                                }
                              }
                              await WishListService.to.toggleWishlist(
                                productId: productId,
                                variantSlug: variantSlug,
                                variantId: vId,
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => const Icon(
                Icons.star_rounded,
                size: 13,
                color: DefaultThemeColors.alertWarninglight,
              ),
            ),
          ),
          const SizedBox(height: 4),
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
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 3),
          if (isVariable)
            Center(
              child: Text(
                '₹${ProductHelper.formatPrice(priceInfo['lowestPrice']?.toString() ?? '0')} - ₹${ProductHelper.formatPrice(priceInfo['highestPrice']?.toString() ?? '0')}',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: colorScheme.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
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

  static Widget _actionBtn({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Icon(
            icon,
            size: 15,
            color: iconColor ?? colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  static String _resolveDefaultVariantId(Map<String, dynamic> product) {
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
}
