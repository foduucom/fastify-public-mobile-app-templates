import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/shimmer_effects.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
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

    var data = widget.categoryData;
    var contentJson = data ?? {};
    var categories = contentJson['categories'] ?? [];
    String viewType = contentJson['view'] ?? 'list';

    // Check for list view type (horizontal/vertical)
    String listViewType = contentJson['list_view_type'] ?? 'horizontal';

    // Check for grid view rows/columns
    int columns = int.tryParse(contentJson['columns'].toString()) ?? 2;

    if (categories.isEmpty) return const Text('No categories found');

    return Padding(
        padding: pageSurroundingPadding,
        child: viewType == 'grid'
            ? _buildGridView(categories, columns)
            : _buildListView(categories, listViewType));
  }

  Widget _buildListView(List categories, String type) {
    if (type == 'vertical') {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) =>
            _buildCategoryItem(categories, index, isVertical: true),
      );
    } else {
      return SizedBox(
        height: 100,
        child: ListView.separated(
          shrinkWrap: false,
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 13),
          itemBuilder: (context, index) =>
              _buildCategoryItem(categories, index),
        ),
      );
    }
  }

  Widget _buildGridView(List categories, int columns) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8, // Adjust as needed
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryItem(categories, index, isGrid: true);
      },
    );
  }

  Widget _buildCategoryItem(List categories, int index,
      {bool isVertical = false, bool isGrid = false}) {
    var category = categories[index];
    return GestureDetector(
      onTap: () {
        List children = category['children'] ?? [];

        // ✅ Extract safe values ONCE at the beginning
        String categoryId = category['_id']?.toString() ?? '';
        String categoryName = category['name']?.toString() ?? 'Category';
        String imageUrl =
            HelperFunctions().getImage(category['featured_image']) ?? '';

        print(
            "name : ${categoryName}, id : ${categoryId}, children : ${children}, Image Url : ${imageUrl}");

        if (children.isNotEmpty) {
          // For categories with subcategories
          Get.toNamed(
            Routes.DETAILCATEGORY,
            arguments: {
              'name': categoryName,
              'id': categoryId,
              'children': children,
              'bannerData': {
                'name': categoryName,
                'image': imageUrl,
              }
            },
          );
        } else {
          // ✅ FIXED: Use the safe values we already extracted
          Get.toNamed(
            Routes.SHOPPRODUCTLISTVIEW,
            arguments: {
              'productId': categoryId, // ✅ Use safe value
              'name': categoryName, // ✅ Use safe value
              'source': 'category'
            },
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Stack(
              children: [
                Container(
                  width: isVertical ? 60 : 70,
                  height: isVertical ? 60 : 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                ),
                Positioned.fill(
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: HelperFunctions()
                        .getImage(category['featured_image'], isLog: true),
                    errorWidget: ((context, url, error) {
                      return const Icon(Icons.error);
                    }),
                    progressIndicatorBuilder: ((context, url, progress) {
                      return HelperFunctions().loadingIndicator();
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: isGrid ? null : 80, // Limit width in list view to wrap text
            child: Text(
              category['name'].toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
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
