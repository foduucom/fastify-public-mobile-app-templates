import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/app/routes/app_pages.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class CategoryHome extends StatefulWidget {
  final dynamic categoryData;
  CategoryHome({super.key, required this.categoryData});

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

    return Padding(
      padding: pageSurroundingPadding,
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
        height: style == 'circular' ? 90 : 140, // Adjust height based on style
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
        {
          //------------

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

          //------------
        }
        ;
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
      // Style used in the main Category Page
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
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
                  errorWidget: (_, __, ___) => const Icon(Icons.category),
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
