import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/components/drawerList.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
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
            _buildDrawerHeader(context, isLoggedIn, userData),
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
                  if (controller.drawernavigationItems.isEmpty &&
                      isLoggedIn) ...[
                    DrawerTile(
                      icon: Icon(Icons.home_outlined,
                          color: Get.theme.colorScheme.onSurface),
                      title: 'Home',
                      subtitle: 'Go to home screen',
                      onTap: () => _navigateToBottomBarPage(0),
                    ),
                    DrawerTile(
                      icon: Icon(Icons.shopping_bag_outlined,
                          color: Get.theme.colorScheme.onSurface),
                      title: 'All Products',
                      subtitle: 'Browse all items',
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.SHOPPRODUCTLISTVIEW);
                      },
                    ),
                    DrawerTile(
                      icon: Icon(Icons.category_outlined,
                          color: Get.theme.colorScheme.onSurface),
                      title: 'Shop By categories',
                      subtitle: 'Explore sections',
                      onTap: () => _navigateToBottomBarPage(1),
                    ),
                    DrawerTile(
                      icon: Icon(Icons.filter_alt_outlined,
                          color: Get.theme.colorScheme.onSurface),
                      title: 'Filter',
                      subtitle: 'Refine your search',
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.CATEGORY_SEARCH_FILTER);
                      },
                    ),
                    DrawerTile(
                      icon: Icon(Icons.shopping_basket_outlined,
                          color: Get.theme.colorScheme.onSurface),
                      title: 'Orders',
                      subtitle: 'Track your purchases',
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.ORDERS);
                      },
                    ),
                    DrawerTile(
                      icon: Icon(Icons.help_outline,
                          color: Get.theme.colorScheme.onSurface),
                      title: 'Help and support',
                      subtitle: 'Get assistance',
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.CONTACTUS);
                      },
                    ),
                    DrawerTile(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      title: 'Logout',
                      subtitle: 'Exit your account',
                      onTap: () async {
                        Get.back();
                        await Get.find<BottombarController>().logout();
                      },
                    ),
                  ] else ...[
                    ...controller.drawernavigationItems
                        .map(_buildItem)
                        .toList(),
                  ],
                ],
              ),
            ),
            _buildThemeSwitcher(),
          ],
        );
      }),
    );
  }

  Widget _buildDrawerHeader(
      BuildContext context, bool isLoggedIn, dynamic userData) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Get.theme.primaryColor,
            Get.theme.primaryColor.withOpacity(0.85),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image with borders and shadows
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Get.theme.primaryColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Get.theme.colorScheme.surface.withOpacity(0.1),
                  blurRadius: 8,
                  
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: isLoggedIn && userData?['featured_image'] != null
                  ? CachedNetworkImage(
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      imageUrl: HelperFunctions()
                          .getImage(userData['featured_image']),
                      placeholder: (context, url) => const SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => CircleAvatar(
                        radius: 36,
                        backgroundColor: Get.theme.primaryColor,
                        child: Icon(
                          Icons.person,
                          size: 44,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 36,
                      backgroundColor: Get.theme.primaryColor,
                      child: Icon(
                        Icons.person,
                        size: 44,
                        color: Colors.grey.shade400,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // User Name
          Text(
            isLoggedIn ? (userData?['name'] ?? 'User') : 'Welcome Guest',
            style: TextStyle(
              color: Get.theme.colorScheme.onPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          // User Email
          Text(
            isLoggedIn ? (userData?['email'] ?? '') : 'Login to your account',
            style: TextStyle(
              color: Get.theme.colorScheme.onPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
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

  void _navigateToBottomBarPage(int index) {
    Get.back();
    try {
      final bottomController = Get.find<BottombarController>();
      bottomController.onTabChange(index);
    } catch (e) {
      Get.offAllNamed(Routes.BOTTOMBAR, arguments: {'index': index});
    }
  }
}
