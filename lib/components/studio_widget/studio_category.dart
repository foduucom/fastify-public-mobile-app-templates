import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'studio_common_widgets.dart';

class CategoryHome extends StatefulWidget {
  final dynamic categoryData;
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
    var title = contentJson['heading'] ?? '';
    var subtitle = contentJson['subheading'] ?? '';
    print('🔥 ${title}');
    print("🔥 ${subtitle}");

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
        if (title.isNotEmpty)
          Padding(
            padding: pageSurroundingPadding,
            child: StudioSectionHeader(
              title: title,
              subtitle: subtitle,
              onSeeAll: () {
                Get.toNamed(Routes.CATEGORY);
              },
            ),
          ),
        Padding(
          padding: pageSurroundingPadding,
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
      return SizedBox(
        height: style == 'circular' ? 110 : 140, // Adjust height based on style
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
            separatorBuilder: (_, __) => const SizedBox(width: 4),
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
        childAspectRatio: style == 'circular' ? 0.7 : 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) =>
          _buildCategoryItem(categories[index], style, isGrid: true),
    );
  }

  Widget _buildCategoryItem(dynamic category, String style,
      {bool isVerticalList = false, bool isGrid = false}) {
    return CategoryGridItem(
      category: category,
      style: style,
      isVerticalList: isVerticalList,
      isGrid: isGrid,
      onTap: widget.onCategoryTap,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// Reusable category card, used both by [CategoryHome] (CMS sections) and by
/// any screen that needs the same card styling for a directly-fetched category
/// list (e.g. the category search/filter grid).
class CategoryGridItem extends StatelessWidget {
  final dynamic category;
  final String style;
  final bool isVerticalList;
  final bool isGrid;
  final void Function(dynamic category)? onTap;

  const CategoryGridItem({
    super.key,
    required this.category,
    this.style = 'circular',
    this.isVerticalList = false,
    this.isGrid = false,
    this.onTap,
  });

  bool get _hasImage => category['featured_image'] != null;

  Widget _categoryImage({
    required BuildContext context,
    required double? width,
    required double? height,
    required BoxFit fit,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    Widget placeholder() => Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          color: colorScheme.surfaceVariant,
          child: Icon(icon, color: colorScheme.onSurfaceVariant, size: 28),
        );

    if (!_hasImage) return placeholder();
    return CachedNetworkImage(
      imageUrl: HelperFunctions().getImage(category['featured_image']),
      width: width,
      height: height,
      fit: fit,
      errorWidget: (_, __, ___) => placeholder(),
      progressIndicatorBuilder: (_, __, ___) =>
          HelperFunctions().loadingIndicator(),
    );
  }

  void _defaultNavigate() {
    List children = category['children'] ?? [];

    if (children.isNotEmpty) {
      Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
        'source': 'category',
        'categoryId': category['_id'],
        'categorySlug': category['slug'],
        'name': category['name'],
        'children': children,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap != null ? onTap!(category) : _defaultNavigate(),
      child: style == 'rectangular'
          ? _buildRectangularItem(context, isVerticalList)
          : _buildCircularItem(context, isGrid, isVerticalList: isVerticalList),
    );
  }

  Widget _buildCircularItem(BuildContext context, bool isGrid,
      {bool isVerticalList = false}) {
    return Column(
      mainAxisSize: isGrid ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (isVerticalList)
          _buildCircularImage(context, 60, 60)
        else if (isGrid)
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: _buildCircularImage(context),
              ),
            ),
          )
        else
          _buildCircularImage(context, 70, 65),
        const SizedBox(height: 6),
        SizedBox(
          width: isGrid ? null : 80,
          child: Text(
            category['name'].toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: isGrid ? 11 : 12,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }

  Widget _buildCircularImage(BuildContext context,
      [double? width, double? height]) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: ClipOval(
        child: _categoryImage(
          context: context,
          width: width,
          height: height,
          fit: BoxFit.cover,
          icon: Icons.category_outlined,
        ),
      ),
    );
  }

  Widget _buildRectangularItem(BuildContext context, bool isVerticalList) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isVerticalList) {
      // Style used in the main Category Page
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                ),
                child: _categoryImage(
                  context: context,
                  width: 100,
                  height: null,
                  fit: BoxFit.cover,
                  icon: Icons.category,
                ),
              ),
            ),
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
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.chevron_right, size: 20),
            ),
          ],
        ),
      );
    } else {
      // Horizontal rectangular card
      return Container(
        width: 140,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: _categoryImage(
                  context: context,
                  width: double.infinity,
                  height: null,
                  fit: BoxFit.cover,
                  icon: Icons.category,
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
}

class CategoryHomeShimmer extends StatelessWidget {
  const CategoryHomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surfaceVariant,
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
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(50)),
                    width: 70,
                    height: 70,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
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
