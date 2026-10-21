import 'package:cached_network_image/cached_network_image.dart';
import '/components/app_image_placeholder.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/app/routes/app_pages.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'studio_common_widgets.dart';

// ── Private value object for type-based styling ───────────────────────────────
class _CategoryTypeStyle {
  final Color accentColor;
  final IconData fallbackIcon;
  const _CategoryTypeStyle(
      {required this.accentColor, required this.fallbackIcon});
}

class CategoryHome extends StatefulWidget {
  final dynamic categoryData;
  final void Function(dynamic category)? onCategoryTap;
  const CategoryHome({super.key, required this.categoryData, this.onCategoryTap});

  @override
  State<CategoryHome> createState() => _TopCategoryHomeState();
}

class _TopCategoryHomeState extends State<CategoryHome>
    with AutomaticKeepAliveClientMixin, BaseController {
  // ── Helpers used only by vertical rectangular list ───────────────────────────

  bool _isHot(dynamic category) => category['is_featured'] == true;

  bool _isRecent(dynamic category) {
    final createdAt = category['created_at'];
    if (createdAt == null) return false;
    try {
      final date = DateTime.parse(createdAt.toString());
      return DateTime.now().difference(date).inDays <= 7;
    } catch (_) {
      return false;
    }
  }

  _CategoryTypeStyle _getCategoryStyle(dynamic category, ColorScheme cs) {
    switch ((category['type'] ?? '').toString().toLowerCase()) {
      case 'product':
        return _CategoryTypeStyle(
            accentColor: cs.primary, fallbackIcon: Icons.local_dining);
      case 'product options':
        return _CategoryTypeStyle(
            accentColor: cs.secondary, fallbackIcon: Icons.tune);
      case 'even':
        return _CategoryTypeStyle(
            accentColor: Colors.amber.shade600,
            fallbackIcon: Icons.star_outline);
      default:
        return _CategoryTypeStyle(
            accentColor: cs.onSurfaceVariant,
            fallbackIcon: Icons.category_outlined);
    }
  }

  Widget _badge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBadgeRow(dynamic category, ColorScheme cs) {
    final hot = _isHot(category);
    final recent = _isRecent(category);
    if (!hot && !recent) return const SizedBox.shrink();
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        if (hot) _badge('🔥 Hot', cs.error, cs.onError),
        if (recent) _badge('New', Colors.green.shade600, Colors.white),
      ],
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StudioSectionHeader(
          title: contentJson['heading'] ?? contentJson['heading'] ?? '',
          subtitle:
              contentJson['subheading'] ?? contentJson['subheading'] ?? '',
          onSeeAll: () => Get.toNamed(Routes.CATEGORY),
        ),
        Padding(
          padding: pageSurroundingPadding.copyWith(bottom: 0),
          child: viewMode == 'grid'
              ? _buildGridView(categories, style, columns)
              : _buildListView(categories, style, orientation),
        ),
      ],
    );
  }

  Widget _buildListView(List categories, String style, String orientation) {
    if (orientation == 'vertical') {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _buildCategoryItem(categories[index], style, isVerticalList: true),
      );
    } else {
      final bool hasAnyImage = categories.any((c) {
        final img = HelperFunctions().getImage(c['featured_image']);
        return img.isNotEmpty && img != HelperFunctions.getNoImage();
      });

      // When images are missing (fashion SDUI response), render luxury pill chips
      final double listHeight = !hasAnyImage
          ? 52.0
          : (style == 'rectangular'
              ? 140.0
              : (style == 'overlay' ? 100.0 : 110.0));

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
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (!hasAnyImage) {
                return GestureDetector(
                  onTap: () => _onCategoryTap(categories[index]),
                  child: _buildLuxuryPillItem(categories[index]),
                );
              }
              return _buildCategoryItem(categories[index], style);
            },
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
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: style == 'rectangular'
            ? 1.1
            : (style == 'overlay' ? 1.4 : 0.7),
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) =>
          _buildCategoryItem(categories[index], style, isGrid: true),
    );
  }

  void _onCategoryTap(dynamic category) {
    if (widget.onCategoryTap != null) {
      widget.onCategoryTap!(category);
      return;
    }
    List children = category['children'] ?? [];
    if (children.isNotEmpty) {
      Get.toNamed(Routes.DETAILCATEGORY, arguments: {
        'name': category['name'],
        'id': category['_id'],
        'children': children,
        'bannerData': {
          'name': category['name'],
          'image': category['featured_image'],
        }
      });
    } else {
      Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
        'productId': category['_id'],
        'categorySlug': category['slug'],
        'name': category['name'],
        'source': 'category'
      });
    }
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('women') ||
        lower.contains('female') ||
        lower.contains('lady') ||
        lower.contains('girl')) {
      return Icons.woman_rounded;
    }
    if (lower.contains('men') ||
        lower.contains('male') ||
        lower.contains('boy')) {
      return Icons.man_rounded;
    }
    if (lower.contains('kid') ||
        lower.contains('child') ||
        lower.contains('baby')) {
      return Icons.child_care_rounded;
    }
    if (lower.contains('shoe') || lower.contains('footwear')) {
      return Icons.skateboarding_rounded;
    }
    if (lower.contains('bag') || lower.contains('purse')) {
      return Icons.shopping_bag_outlined;
    }
    if (lower.contains('watch') ||
        lower.contains('jewel') ||
        lower.contains('accessor')) {
      return Icons.watch_outlined;
    }
    return Icons.checkroom_rounded;
  }

  Widget _buildLuxuryPillItem(dynamic category) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = category['name']?.toString() ?? '';
    final icon = _getCategoryIcon(name);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : colorScheme.outlineVariant.withValues(alpha: 0.7),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? const Color(0xFF242424)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            ),
            child: Icon(
              icon,
              size: 15,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(dynamic category, String style,
      {bool isVerticalList = false, bool isGrid = false}) {
    return GestureDetector(
      onTap: () => _onCategoryTap(category),
      child: style == 'rectangular'
          ? _buildRectangularItem(category, isVerticalList)
          : (style == 'overlay'
              ? _buildOverlayItem(category, isVerticalList, isGrid)
              : _buildCircularItem(category, isGrid)),
    );
  }

  Widget _buildOverlayItem(dynamic category, bool isVerticalList, bool isGrid) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final imgUrl = HelperFunctions().getImage(category['featured_image']);
    final bool hasImage =
        imgUrl.isNotEmpty && imgUrl != HelperFunctions.getNoImage();
    final name = category['name']?.toString() ?? '';
    final icon = _getCategoryIcon(name);

    final cardWidth =
        isGrid ? double.infinity : (isVerticalList ? double.infinity : 130.0);
    final cardHeight = isVerticalList ? 80.0 : 100.0;

    if (!hasImage) {
      // Luxury minimal card without generic placeholder
      return Container(
        width: cardWidth,
        height: cardHeight,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: colorScheme.surface,
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              ),
              child: Icon(icon, size: 20, color: colorScheme.onSurface),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Explore',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceContainerHighest,
        border:
            Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: imgUrl,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => _buildOverlayPlaceholder(colorScheme),
            progressIndicatorBuilder: (_, __, ___) =>
                HelperFunctions().loadingIndicator(),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
          // Text & Shop Action
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Shop Now →',
                  style: TextStyle(
                    color: colorScheme.primary.computeLuminance() > 0.5
                        ? const Color(0xFFFFF176)
                        : colorScheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayPlaceholder(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.15),
            cs.surfaceContainerHighest,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.checkroom_outlined,
          color: cs.onSurfaceVariant.withValues(alpha: 0.4),
          size: 28,
        ),
      ),
    );
  }

  Widget _buildCircularItem(dynamic category, bool isGrid) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final name = category['name']?.toString() ?? '';
    final icon = _getCategoryIcon(name);
    final imgUrl = HelperFunctions().getImage(category['featured_image']);
    final bool hasImage =
        imgUrl.isNotEmpty && imgUrl != HelperFunctions.getNoImage();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          padding: hasImage ? const EdgeInsets.all(6) : const EdgeInsets.all(12),
          child: hasImage
              ? CachedNetworkImage(
                  imageUrl: imgUrl,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) =>
                      Icon(icon, size: 22, color: colorScheme.onSurface),
                  progressIndicatorBuilder: (_, __, ___) =>
                      HelperFunctions().loadingIndicator(),
                )
              : Icon(icon, size: 22, color: colorScheme.onSurface),
        ),
        const SizedBox(height: 4),
        Flexible(
          child: Text(
            name,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRectangularItem(dynamic category, bool isVerticalList) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isVerticalList) {
      // ── Enhanced vertical list style ──────────────────────────────────────
      final typeStyle = _getCategoryStyle(category, colorScheme);

      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: typeStyle.accentColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Image panel with type-tinted background
            Container(
              width: 100,
              decoration: BoxDecoration(
                color: typeStyle.accentColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                ),
                child: (HelperFunctions()
                            .getImage(category['featured_image'])
                            .isNotEmpty &&
                        HelperFunctions().getImage(category['featured_image']) !=
                            HelperFunctions.getNoImage())
                    ? CachedNetworkImage(
                        imageUrl: HelperFunctions()
                            .getImage(category['featured_image']),
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const AppImagePlaceholder(radius: 10),
                      )
                    : const AppImagePlaceholder(radius: 10),
              ),
            ),
            // Text + badges
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category['name'].toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (category['children'] != null &&
                        (category['children'] as List).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${(category['children'] as List).length} subcategories',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    _buildBadgeRow(category, colorScheme),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.chevron_right,
                  size: 20, color: typeStyle.accentColor),
            ),
          ],
        ),
      );
    } else {
      // Horizontal rectangular card — unchanged
      return Container(
        width: 140,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: (HelperFunctions()
                            .getImage(category['featured_image'])
                            .isNotEmpty &&
                        HelperFunctions().getImage(category['featured_image']) !=
                            HelperFunctions.getNoImage())
                    ? CachedNetworkImage(
                        imageUrl: HelperFunctions()
                            .getImage(category['featured_image']),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const AppImagePlaceholder(radius: 12),
                      )
                    : const AppImagePlaceholder(radius: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                category['name'].toString(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        highlightColor: Theme.of(context).colorScheme.surface,
        child: SizedBox(
          height: 100,
          child: ListView.separated(
            itemCount: 10,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(50)),
                    width: 70,
                    height: 70,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(50)),
                    width: 40,
                    height: 10,
                  ),
                ],
              );
            },
          ),
        ));
  }
}
