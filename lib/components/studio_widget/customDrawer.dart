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

  static const _featuredCollections = [
    {
      'icon': Icons.local_fire_department_outlined,
      'label': 'Trending',
      'badge': 'TRENDING',
      'filterType': 'trending_products',
    },
    {
      'icon': Icons.star_outline,
      'label': 'Featured',
      'badge': 'FEATURED',
      'filterType': 'featured_products',
    },
    {
      'icon': Icons.thumb_up_outlined,
      'label': 'Recommended',
      'badge': 'PICK',
      'filterType': 'recommended_products',
    },
    {
      'icon': Icons.history,
      'label': 'Recently Viewed',
      'badge': 'RECENT',
      'filterType': 'recently_viewed',
    },
  ];

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
                    const SizedBox(height: 4),
                    _buildFeaturedCollections(context),
                    _buildSectionHeader('SHOP & EXPLORE'),
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
                        Get.toNamed(Routes.CATEGORY);
                      },
                    ),
                    _buildSectionHeader('MY ACCOUNT'),
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
                      icon: Icon(Icons.favorite_border,
                          color: Get.theme.colorScheme.onSurface),
                      title: 'My Wishlist',
                      subtitle: 'Items you saved',
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.WISHLIST);
                      },
                    ),
                    _buildSectionHeader('SUPPORT & HELP'),
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
                    const SizedBox(height: 8),
                  ] else ...[
                    ...controller.drawernavigationItems
                        .map(_buildItem)
                        .toList(),
                  ],
                ],
              ),
            ),
            _buildThemeSwitcher(),
            _buildAuthButton(isLoggedIn),
          ],
        );
      }),
    );
  }

  Widget _buildDrawerHeader(
      BuildContext context, bool isLoggedIn, dynamic userData) {
    return InkWell(
      onTap: isLoggedIn
          ? () {
              Get.back();
              Get.toNamed(Routes.PROFILE);
            }
          : null,
      child: Container(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        imageUrl: HelperFunctions()
                            .getImage(userData['featured_image']),
                        placeholder: (context, url) => const SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => CircleAvatar(
                          radius: 32,
                          backgroundColor: Get.theme.primaryColor,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 32,
                        backgroundColor: Get.theme.primaryColor,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLoggedIn
                        ? (userData?['name'] ?? 'User')
                        : 'Welcome Guest',
                    style: TextStyle(
                      color: Get.theme.colorScheme.onPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLoggedIn
                        ? (userData?['email'] ?? '')
                        : 'Login to your account',
                    style: TextStyle(
                      color: Get.theme.colorScheme.onPrimary.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isLoggedIn)
              Icon(Icons.chevron_right,
                  color: Get.theme.colorScheme.onPrimary.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Get.theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildFeaturedCollections(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _featuredCollections.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = _featuredCollections[index];
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
                'source': 'dashboard',
                'filterType': item['filterType'],
                'name': item['label'],
              });
            },
            child: Container(
              width: 92,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'] as IconData,
                      color: colorScheme.primary, size: 24),
                  const SizedBox(height: 6),
                  Text(
                    item['label'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['badge'] as String,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildAuthButton(bool isLoggedIn) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: isLoggedIn
              ? OutlinedButton.icon(
                  onPressed: () async {
                    Get.back();
                    await Get.find<BottombarController>().logout();
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Logout',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                )
              : ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed(Routes.LOGIN);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Sign In / Register'),
                ),
        ),
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
