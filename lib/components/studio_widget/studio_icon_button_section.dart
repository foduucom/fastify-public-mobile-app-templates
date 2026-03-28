import 'package:flutter/material.dart';
import '/app/modules/bottomar/controllers/bottombar_controller.dart';
import '/app/routes/app_pages.dart';
import 'package:get/get.dart';

class IconButtonComponent extends StatelessWidget {
  final Map<String, dynamic> contentJson;

  const IconButtonComponent({Key? key, required this.contentJson})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var columnData = contentJson['columndata'] ?? {};
    if (columnData is! Map) return const SizedBox.shrink();

    List<Widget> buttons = [];
    columnData.forEach((key, value) {
      if (value is Map) {
        buttons.add(_buildButton(context, value));
      }
    });

    if (buttons.isEmpty) return const SizedBox.shrink();

    int requestedColumns =
        int.tryParse(contentJson['no_of_columns']?.toString() ?? '1') ?? 1;
    int crossAxisCount = buttons.length;
    if (crossAxisCount > requestedColumns) {
      crossAxisCount = requestedColumns;
    }
    if (crossAxisCount < 1) crossAxisCount = 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3.0, // Adjusted for button-like appearance
        children: buttons,
      ),
    );
  }

  Widget _buildButton(BuildContext context, Map value) {
    String text = value['link_text'] ?? '';
    return GestureDetector(
      onTap: () => _handleNavigation(value),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _handleNavigation(Map value) {
    String linkType = value['link_type'] ?? '';
    var link = value['link'] ?? {};
    String target = link['value']?.toString() ?? '';

    if (linkType == 'mobile_page') {
      if (target == 'products') {
        Get.toNamed(Routes.SHOPPRODUCTLISTVIEW);
      } else if (target == 'home') {
        _navigateToBottomBarTab(0);
      } else if (target == 'category') {
        _navigateToBottomBarTab(1);
      } else if (target == 'cart') {
        _navigateToBottomBarTab(2);
      } else if (target == 'wishlist') {
        _navigateToBottomBarTab(3);
      } else if (target == 'profile') {
        _navigateToBottomBarTab(4);
      } else {
        // Fallback for other custom pages using target as slug
        if (target.isNotEmpty) {
          Get.toNamed(Routes.CUSTOMPAGE, arguments: {'slug': target});
        }
      }
    } else if (linkType == 'category') {
      if (target.isNotEmpty) {
        Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
          'productId': target,
          'categorySlug': '', // Slug not provided in input JSON usually
          'name': link['label'] ?? 'Category',
          'source': 'category'
        });
      }
    } else if (linkType == 'product') {
      Get.toNamed(Routes.PRODUCTDETAILS, arguments: {'productId': target});
    }
  }

  void _navigateToBottomBarTab(int tabIndex) {
    // Ported logic from studio_socket_routing.dart
    final controller = Get.find<BottombarController>();
    controller.onTabChange(tabIndex);
    Get.until((route) => route.settings.name == Routes.BOTTOMBAR);
  }
}
