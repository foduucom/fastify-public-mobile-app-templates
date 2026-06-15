import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
    String heading =
        (contentJson['heading'] ?? contentJson['title'] ?? '').toString();
    String subheading =
        (contentJson['subheading'] ?? contentJson['subtitle'] ?? '').toString();

    return Column(
      children: [
        if (heading.isNotEmpty)
          Padding(
            padding: pageSurroundingPadding,
            child: StudioSectionHeader(
              title: heading,
              subtitle: subheading,
              onSeeAll: () => Get.toNamed(Routes.CATEGORY_SEARCH),
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
        height: style == 'circular' ? 140 : 140, // Reduced height slightly
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
        mainAxisSpacing: 6, //12 FROM
        crossAxisSpacing: 6, //12 FROM
        childAspectRatio: style == 'circular' ? 0.8 : 1.1,
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
        {
          //------------
          List children = category['children'] ?? [];

          if (children.isNotEmpty) {
            // Instead of navigating to DETAILCATEGORY, show the dialog
            _showCategoryDialog(Get.context!, category);
          } else {
            // If no children, navigate directly to product list
            Get.toNamed(
              Routes.SHOPPRODUCTLISTVIEW,
              arguments: {
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
          : _buildCircularItem(category, isGrid),
    );
  }

  Widget _buildCircularItem(dynamic category, bool isGrid) {
    return Container(
      constraints: BoxConstraints(maxWidth: isGrid ? double.infinity : 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 70,
              height: 70,
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: HelperFunctions().getImage(
                  category['featured_image'],
                ),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.category_outlined),
                progressIndicatorBuilder: (_, __, ___) =>
                    HelperFunctions().loadingIndicator(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              category['name'].toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 4,
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
    final children = category['children'] as List;

    // Show the dialog using the updated CategoryDialog class
    Get.dialog(
      CategoryDialog(category: category),
      barrierDismissible: true, // Allow tapping outside to close
    );
  }

  Widget _buildRectangularItem(dynamic category, bool isVerticalList) {
    final colorScheme = Theme.of(context).colorScheme;
    print("Category: ${category.toString()}");
    if (isVerticalList) {
      // New UI style for the main Category Page
      return Center(
        child: Material(
          borderRadius: BorderRadius.circular(Get.height * 0.015),
          color: Colors.transparent,
          child: InkWell(
            onTap: () => category['children'] != null &&
                    (category['children'] as List).isNotEmpty
                ? _showCategoryDialog(context, category)
                : Get.toNamed(
                    Routes.SHOPPRODUCTLISTVIEW,
                    arguments: {
                      'productId': category['_id'],
                      'categorySlug': category['slug'],
                      'name': category['name'],
                      'source': 'category',
                    },
                  ),
            borderRadius: BorderRadius.circular(Get.height * 0.015),
            splashColor: Theme.of(context).primaryColor.withOpacity(0.3),
            highlightColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Container(
              width: Get.width * 0.92,
              height: Get.height * 0.12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Get.height * 0.015),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    HelperFunctions().getImage(category['featured_image']),
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
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
                child: CachedNetworkImage(
                  imageUrl: HelperFunctions().getImage(
                    category['featured_image'],
                  ),
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
                style: const TextStyle(
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
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.surface,
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
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  width: 70,
                  height: 70,
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
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
                  baseColor: Theme.of(context).colorScheme.surfaceVariant,
                  highlightColor: Theme.of(context).colorScheme.surface,
                  child: Container(
                    width: 140,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
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
