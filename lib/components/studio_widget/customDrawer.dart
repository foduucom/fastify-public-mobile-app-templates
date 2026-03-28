import 'package:flutter/material.dart';
import '/app/routes/app_pages.dart';
import '/app/modules/auth/auth_details.dart';
import '/app/modules/homepage/controllers/homepage_controller.dart';
import '/components/drawerList.dart';
import '/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class CustomDrawer extends GetView<HomepageController> {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Obx(() {
        if (controller.isDrawerNavigationLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final bool isLoggedIn = AuthDetails.isUserLogin();
        final userData = AuthDetails.getUserDetails();

        return Column(
          children: [
            _buildDrawerHeader(isLoggedIn, userData),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (!isLoggedIn)
                    DrawerTile(
                      icon: const Icon(Icons.login, color: Colors.blue),
                      title: 'Login',
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.LOGIN);
                      },
                    ),
                  if (controller.drawernavigationItems.isEmpty && isLoggedIn)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No navigation items available'),
                    ),
                  ...controller.drawernavigationItems.map(_buildItem).toList(),
                ],
              ),
            ),
            _buildThemeSwitcher(),
          ],
        );
      }),
    );
  }

  Widget _buildDrawerHeader(bool isLoggedIn, dynamic userData) {
    return UserAccountsDrawerHeader(
      accountName: Text(
        isLoggedIn ? (userData?['name'] ?? 'User') : 'Welcome Guest',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(
        isLoggedIn ? (userData?['email'] ?? '') : 'Login to your account',
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(
          Icons.person,
          size: 40,
          color: Colors.grey.shade400,
        ),
      ),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor,
      ),
    );
  }

  Widget _buildThemeSwitcher() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Theme Mode',
              style: TextStyle(fontWeight: FontWeight.w500)),
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
        ],
      ),
    );
  }

  Widget _buildItem(dynamic item) {
    final text = item['text'] ?? '';
    final type = item['type'] ?? '';
    final slug = item['slug'] ?? '';
    final children = item['children'] ?? [];

    if (children.isNotEmpty) {
      return ExpansionTile(
        leading: const Icon(Icons.arrow_forward),
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
      icon: const Icon(Icons.arrow_forward),
      title: text,
      onTap: () {
        Get.back();
        _handleNavigation(type, slug);
      },
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
