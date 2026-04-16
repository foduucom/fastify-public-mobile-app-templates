import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/app/routes/app_pages.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

// ── Private value object for type-based styling ───────────────────────────────
class _CategoryTypeStyle {
  final Color accentColor;
  final IconData fallbackIcon;
  const _CategoryTypeStyle(
      {required this.accentColor, required this.fallbackIcon});
}

class CategoryHome extends StatefulWidget {
  final dynamic categoryData;
  CategoryHome({super.key, required this.categoryData});

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

    return Padding(
      padding: pageSurroundingPadding.copyWith(bottom: 0),
      child: viewMode == 'grid'
          ? _buildGridView(categories, style, columns)
          : _buildListView(categories, style, orientation),
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
      return SizedBox(
        height: style == 'rectangular' ? 140 : 82, // Adjust height based on style
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
            separatorBuilder: (_, __) => const SizedBox(width: 13),
            itemBuilder: (context, index) =>
                _buildCategoryItem(categories[index], style),
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
        childAspectRatio: style == 'circular' ? 0.8 : 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) =>
          _buildCategoryItem(categories[index], style, isGrid: true),
    );
  }

  Widget _buildCategoryItem(dynamic category, String style,
      {bool isVerticalList = false, bool isGrid = false}) {
    return GestureDetector(
      onTap: () {
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
      },
      child: style == 'rectangular'
          ? _buildRectangularItem(category, isVerticalList)
          : _buildCircularItem(category, isGrid),
    );
  }

  Widget _buildCircularItem(dynamic category, bool isGrid) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.4),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: CachedNetworkImage(
            imageUrl: HelperFunctions().getImage(category['featured_image']),
            fit: BoxFit.contain,
            errorWidget: (_, __, ___) =>
                const Icon(Icons.category_outlined, size: 24),
            progressIndicatorBuilder: (_, __, ___) =>
                HelperFunctions().loadingIndicator(),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          category['name'].toString(),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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
                child: CachedNetworkImage(
                  imageUrl:
                      HelperFunctions().getImage(category['featured_image']),
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Center(
                    child: Icon(
                      typeStyle.fallbackIcon,
                      size: 32,
                      color: typeStyle.accentColor,
                    ),
                  ),
                ),
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
                child: CachedNetworkImage(
                  imageUrl:
                      HelperFunctions().getImage(category['featured_image']),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Icon(Icons.category),
                ),
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
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(50)),
                    width: 70,
                    height: 70,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
