import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class CategoryDialog extends StatelessWidget {
  final Map<String, dynamic> category;
  final dynamic controller; // Your controller instance

  const CategoryDialog({
    Key? key,
    required this.category,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final height = Get.height;
    final children = category['children'] as List;

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(height * 0.015),
      ),
      child: Container(
        width: width * 0.92,
        constraints: BoxConstraints(
          maxHeight: height * 0.7,
        ),
        padding: EdgeInsets.all(width * 0.053),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and close button
            _buildHeader(context, height),
            SizedBox(height: height * 0.02),

            // Category image
            _buildCategoryImage(context, height),
            SizedBox(height: height * 0.02),

            // Subcategories list
            _buildSubcategoriesSection(context, height, children),
          ],
        ),
      ),
    );
  }

  // Header widget
  Widget _buildHeader(BuildContext context, double height) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            category['name'].toString(),
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: height * 0.02,
              fontWeight: FontWeight.w600,
              height: 1.75,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.close,
            size: height * 0.027,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // Category image widget
  Widget _buildCategoryImage(BuildContext context, double height) {
    return Container(
      width: double.infinity,
      height: height * 0.12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 0.015),
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            HelperFunctions().getImage(category['featured_image']),
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Subcategories section
  Widget _buildSubcategoriesSection(
      BuildContext context, double height, List children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subcategories',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: height * 0.018,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: height * 0.001),
        Flexible(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: children.length,
            shrinkWrap: true,
            separatorBuilder: (_, __) => SizedBox(height: height * 0.005),
            itemBuilder: (context, index) {
              final childCategory = children[index];
              return _buildSubcategoryItem(context, height, childCategory);
            },
          ),
        ),
      ],
    );
  }

  // Individual subcategory item
  Widget _buildSubcategoryItem(
      BuildContext context, double height, dynamic childCategory) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? DefaultThemeColors.lightDarker : DefaultThemeColors.darkmain;

    return InkWell(
      onTap: () {
        Get.back();
        Get.toNamed(
          Routes.SHOPPRODUCTLISTVIEW,
          arguments: {
            'productId': childCategory['_id'],
            'name': childCategory['name'],
            'source': 'category'
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: height * 0.005,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                childCategory['name'].toString(),
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: height * 0.016,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: height * 0.022,
              color: textColor,
            ),
          ],
        ),
      ),
    );
  }
}
