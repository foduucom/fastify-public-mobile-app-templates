import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/components/commonWidgets/dynamic_horizontal_arrow_scroller.dart';
import '/components/app_image_placeholder.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/modules/category/views/category_dialog.dart';
import '/app/routes/app_pages.dart';
import '/components/shimmer_effects.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import '/constants/theme.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'home_common_widgets.dart';
import 'package:foduu_ecommerce/app/modules/shop/shop_navigation.dart';

class CategoryHome extends StatefulWidget {
  final dynamic categoryData;

  /// Overrides the default tap behavior (dialog / shop navigation) when set.
  final void Function(dynamic category)? onCategoryTap;
  CategoryHome({super.key, required this.categoryData, this.onCategoryTap});

  @override
  State<CategoryHome> createState() => _TopCategoryHomeState();
}

class _TopCategoryHomeState extends State<CategoryHome>
    with AutomaticKeepAliveClientMixin, BaseController {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    var contentJson = widget.categoryData ?? {};
    var categories = contentJson['categories'] ?? [];
    if (categories.isEmpty) return const SizedBox.shrink();

    // ─── Layout Configuration ───
    // 'view': 'list' (default) or 'grid'
    String viewMode = contentJson['view'] ?? 'list';
    // 'style': 'circular' (default) or 'rectangular'
    String style = contentJson['layout'] ?? 'circular';
    // 'orientation': 'horizontal' (default) or 'vertical'
    String orientation = contentJson['list_view_type'] ?? 'horizontal';
    // 'columns': 2 (default)
    int columns = int.tryParse(contentJson['columns'].toString()) ?? 2;
    String heading = (contentJson['heading'] ?? contentJson['title'] ?? '')
        .toString()
        .trim();
    if (heading == '_' || heading == '-' || heading == '--') heading = '';
    String subheading =
        (contentJson['subheading'] ?? contentJson['subtitle'] ?? '')
            .toString()
            .trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (heading.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: StudioSectionHeader(
              title: heading,
              subtitle: subheading,
              onSeeAll: () => openShop(),
            ),
          ),
          const SizedBox(height: 12),
        ],
        viewMode == 'grid'
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildGridView(categories, style, columns),
              )
            : _buildListView(categories, style, orientation),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildListView(List categories, String style, String orientation) {
    if (orientation == 'vertical') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildCategoryItem(
              categories[index], style,
              isVerticalList: true),
        ),
      );
    } else {
      final listHeight = 112.0;
      return SizedBox(
        height: listHeight,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: DynamicHorizontalArrowScroller(
            arrowSize: 32,
            iconSize: 19,
            scrollStep: 220,
            edgePadding: 4,
            itemCount: categories.length,
            builder: (context, scrollController) => ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) =>
                  _buildCategoryItem(categories[index], 'circular'),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildGridView(List categories, String style, int columns) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: style == 'circular'
            ? 0.8
            : style == 'overlay'
                ? _overlayGridAspectRatio
                : 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) =>
          _buildCategoryItem(categories[index], style, isGrid: true),
    );
  }

  Widget _buildCategoryItem(
    dynamic category,
    String style, {
    bool isVerticalList = false,
    bool isGrid = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (widget.onCategoryTap != null) {
          widget.onCategoryTap!(category);
          return;
        }
        {
          //------------
          List children = category['children'] ?? [];

          if (children.isNotEmpty) {
            // Instead of navigating to DETAILCATEGORY, show the dialog
            _showCategoryDialog(Get.context!, category);
          } else {
            // If no children, navigate directly to product list
            openShop(
              {
                'productId': category['_id'],
                'categorySlug': category['slug'],
                'name': category['name'],
                'source': 'category',
              },
            );
          }
          //------------
        }
      },
      child: style == 'rectangular'
          ? _buildRectangularItem(category, isVerticalList)
          : style == 'overlay'
              ? _buildOverlayItem(category, isGrid: isGrid)
              : _buildCircularItem(category, isGrid),
    );
  }

  // Editorial overlay card matching modern e-commerce standards:
  // Compact ~168px height, ~130px width to distinctively differentiate from product cards.
  static const double _overlayGridAspectRatio = 0.82;
  double get _overlayCardWidth => (Get.width * 0.33).clamp(124.0, 140.0);

  Widget _buildOverlayItem(dynamic category, {bool isGrid = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          (HelperFunctions().getImage(category['featured_image']).isNotEmpty &&
                  HelperFunctions().getImage(category['featured_image']) !=
                      HelperFunctions.getNoImage())
              ? CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl:
                      HelperFunctions().getImage(category['featured_image']),
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
                stops: [0.35, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 42,
            bottom: 10,
            child: Text(
              category['name'].toString(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
                height: 1.2,
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
    return isGrid ? card : SizedBox(width: _overlayCardWidth, child: card);
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('smart tv') || lower.contains('television') || lower.contains('smarttv')) {
      return Icons.tv_rounded;
    }
    if (lower.contains('tablet') || lower.contains('ipad')) {
      return Icons.tablet_android_rounded;
    }
    if (lower.contains('laptop')) {
      return Icons.laptop_mac_rounded;
    }
    if (lower.contains('desktop') || lower.contains('monitor') || lower.contains('display')) {
      return Icons.desktop_windows_rounded;
    }
    if (lower.contains('computer') || lower.contains('electronic')) {
      return Icons.memory_rounded;
    }
    if (lower.contains('phone') || lower.contains('smartphone') || lower.contains('mobile')) {
      return Icons.smartphone_rounded;
    }
    if (lower.contains('drone')) return Icons.flight_takeoff_rounded;
    if (lower.contains('smart home') || lower.contains('home')) {
      return Icons.home_outlined;
    }
    if (lower.contains('print')) return Icons.print_outlined;
    if (lower.contains('appliance')) return Icons.kitchen_outlined;
    if (lower.contains('camera')) return Icons.camera_alt_outlined;
    if (lower.contains('audio') ||
        lower.contains('headphone') ||
        lower.contains('sound')) return Icons.headphones_outlined;
    if (lower.contains('accessor')) return Icons.devices_other_outlined;
    if (lower.contains('watch') || lower.contains('smartwatch')) {
      return Icons.watch_outlined;
    }
    if (lower.contains('tv')) return Icons.tv_rounded;
    if (lower.contains('game') || lower.contains('gaming')) {
      return Icons.sports_esports_outlined;
    }
    if (lower.contains('speaker')) return Icons.speaker_outlined;
    return Icons.category_outlined;
  }

  Color _getCategoryTint(String name, ColorScheme colorScheme) {
    final lower = name.toLowerCase();
    if (lower.contains('smart tv') || lower.contains('tv')) {
      return const Color(0xFFE8F5E9); // soft green
    }
    if (lower.contains('tablet') || lower.contains('ipad')) {
      return const Color(0xFFE3F2FD); // soft blue
    }
    if (lower.contains('laptop') || lower.contains('desktop')) {
      return const Color(0xFFFFF3E0); // soft amber
    }
    if (lower.contains('computer') || lower.contains('electronic')) {
      return const Color(0xFFF3E5F5); // soft purple
    }
    if (lower.contains('phone') || lower.contains('mobile')) {
      return const Color(0xFFFFEBEE); // soft red
    }
    if (lower.contains('camera')) {
      return const Color(0xFFE0F2F1); // soft teal
    }
    if (lower.contains('audio') || lower.contains('headphone')) {
      return const Color(0xFFEDE7F6); // soft indigo
    }
    return colorScheme.primary.withOpacity(0.08);
  }

  Widget _buildCategoryFallback(String name, ColorScheme colorScheme) {
    final tint = _getCategoryTint(name, colorScheme);
    final iconColor = colorScheme.brightness == Brightness.dark
        ? colorScheme.primary
        : Color.lerp(tint, Colors.black87, 0.65) ?? colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tint,
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(name),
          size: 26,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _buildCircularItem(dynamic category, bool isGrid) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final catName = category['name']?.toString() ?? '';
    final tint = _getCategoryTint(catName, colorScheme);

    return Container(
      constraints: BoxConstraints(maxWidth: isGrid ? double.infinity : 82),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tint,
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildCategoryFallback(catName, colorScheme),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              catName,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    // Show the dialog using the updated CategoryDialog class
    Get.dialog(
      CategoryDialog(category: category),
      barrierDismissible: true, // Allow tapping outside to close
    );
  }

  Widget _buildRectangularItem(dynamic category, bool isVerticalList) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (isVerticalList) {
      // New UI style for the main Category Page
      return Center(
        child: Material(
          borderRadius: BorderRadius.circular(Get.height * 0.015),
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onCategoryTap != null
                ? widget.onCategoryTap!(category)
                : category['children'] != null &&
                        (category['children'] as List).isNotEmpty
                    ? _showCategoryDialog(context, category)
                    : openShop(
                        {
                          'productId': category['_id'],
                          'categorySlug': category['slug'],
                          'name': category['name'],
                          'source': 'category',
                        },
                      ),
            borderRadius: BorderRadius.circular(Get.height * 0.015),
            splashColor: colorScheme.primary.withOpacity(0.25),
            highlightColor: colorScheme.primary.withOpacity(0.1),
            child: Container(
              width: Get.width * 0.92,
              height: Get.height * 0.12,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(Get.height * 0.015),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.15),
                ),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    HelperFunctions().getImage(category['featured_image']),
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.35),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Get.width * 0.04),
                  child: Text(
                    category['name'].toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: Get.height * 0.025,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // Horizontal rectangular card
      return Container(
        width: 140,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: HelperFunctions().getImage(
                    category['featured_image'],
                  ),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (_, __, ___) =>
                      HelperFunctions().loadingIndicator(),
                  errorWidget: (_, __, ___) => const AppImagePlaceholder(
                    radius: 0,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                category['name'].toString(),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class CategoryHomeShimmer extends StatelessWidget {
  const CategoryHomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceVariant,
      highlightColor: colorScheme.surface,
      child: SizedBox(
        height: 110, // Reduced to match the new height
        child: ListView.separated(
          itemCount: 10,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  width: 70,
                  height: 70,
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  width: 40,
                  height: 10,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CategoryPageShimmer extends StatelessWidget {
  const CategoryPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          4,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: colorScheme.surfaceVariant,
                  highlightColor: colorScheme.surface,
                  child: Container(
                    width: 140,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const CategoryHomeShimmer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
