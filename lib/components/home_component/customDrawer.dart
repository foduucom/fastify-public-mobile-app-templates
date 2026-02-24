import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:foduu_ecommerce/components/drawerList.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
// import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:font_awesome_flutter/name_icon_mapping.dart';

class CustomDrawer extends GetView<HomepageController> {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isDrawerNavigationLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.drawernavigationItems.isEmpty) {
        return _emptyState();
      }

      return Column(
        children: [
          PopupMenuButton<ThemeMode>(
            onSelected: (mode) {
              final themeController = Get.find<ThemeController>();
              themeController.setThemeMode(mode);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: ThemeMode.system, child: Text('System Default')),
              const PopupMenuItem(
                  value: ThemeMode.light, child: Text('Light Mode')),
              const PopupMenuItem(
                  value: ThemeMode.dark, child: Text('Dark Mode')),
            ],
            icon: const Icon(Icons.color_lens),
          ),
          SizedBox(
            height: 200,
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(vertical: 8).copyWith(top: 50),
              children:
                  controller.drawernavigationItems.map(_buildItem).toList(),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildItem(dynamic item) {
    final text = item['text'] ?? '';
    final type = item['type'] ?? '';
    final slug = item['slug'] ?? '';
    final iconName = item['icon'] ?? '';
    final children = item['children'] ?? [];

    // final icon = FaIcon(
    //   faIconNameMapping[iconName],
    //   size: 18,
    // );

    if (children.isNotEmpty) {
      return ExpansionTile(
        leading: Icon(Icons.arrow_forward_ios),
        title: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: const EdgeInsets.only(left: 16),
        children: children.map<Widget>((child) {
          return DrawerChildTile(
            title: child['text'],
            onTap: () {
              Get.back();
              _handleNavigation(child['type'], child['slug']);
            },
          );
        }).toList(),
      );
    }

    return DrawerTile(
      icon: Icon(Icons.arrow_forward_ios),
      title: text,
      onTap: () {
        Get.back();
        _handleNavigation(type, slug);
      },
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
            ),
            SizedBox(height: 12),
            Text(
              'No navigation items',
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(String type, String slug) {
    if (type == 'category') {
      Get.toNamed('/category/$slug');
    } else if (type == 'page') {
      Get.toNamed('/page/$slug');
    }
  }
}
