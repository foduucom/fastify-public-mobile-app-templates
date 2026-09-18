import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/app/routes/app_pages.dart';
import '/app/modules/auth/auth_details.dart';
import '/app/modules/homepage/controllers/homepage_controller.dart';
import '/app/modules/bottomar/controllers/bottombar_controller.dart';
import '/app/modules/shop/controllers/shop_controller.dart';
import '/components/drawerList.dart';
import '/constants/dynamic_theme.dart';
import '/constants/helper_functions.dart';
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
      'icon': Icons.history,
      'label': 'Recently Viewed',
      'badge': 'RECENT',
      'filterType': 'recentlpy_viewed',
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
                      icon: Icon(Icons.login,
                          color: Theme.of(context).colorScheme.secondary),
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
                          color: Theme.of(context).colorScheme.onSurface),
                      title: 'Home',
                      onTap: () => _navigateToBottomBarPage(0),
                    ),
                    const SizedBox(height: 4),
                    _buildFeaturedCollections(context),
                    _buildSectionHeader(context, 'SHOP & EXPLORE'),
                    DrawerTile(
                      icon: Icon(Icons.shopping_bag_outlined,
                          color: Theme.of(context).colorScheme.onSurface),
                      title: 'All Products',
                      onTap: () => _navigateToBottomBarPage(3, arguments: {
                        'source': 'all_products',
                        'name': 'All Products',
                      }),
                    ),
                    DrawerTile(
                      icon: Icon(Icons.category_outlined,
                          color: Theme.of(context).colorScheme.onSurface),
                      title: 'Shop By categories',
                      onTap: () => _navigateToBottomBarPage(1),
                    ),
                    DrawerTile(
                      icon: Icon(Icons.filter_alt_outlined,
                          color: Theme.of(context).colorScheme.onSurface),
                      title: 'Filter',
                      onTap: () => _navigateToBottomBarPage(1),
                    ),
                    _buildSectionHeader(context, 'MY ACCOUNT'),
                    DrawerTile(
                      icon: Icon(Icons.shopping_basket_outlined,
                          color: Theme.of(context).colorScheme.onSurface),
                      title: 'Orders',
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.ORDERS);
                      },
                    ),
                    DrawerTile(
                      icon: Icon(Icons.favorite_border,
                          color: Theme.of(context).colorScheme.onSurface),
                      title: 'My Wishlist',
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.WISHLIST);
                      },
                    ),
                    _buildSectionHeader(context, 'SUPPORT & HELP'),
                    DrawerTile(
                      icon: Icon(Icons.help_outline,
                          color: Theme.of(context).colorScheme.onSurface),
                      title: 'Help and support',
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.CONTACTUS);
                      },
                    ),
                    const SizedBox(height: 8),
                  ] else ...[
                    if (controller.drawernavigationItems.isEmpty &&
                        isLoggedIn)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No navigation items available'),
                      ),
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
              _navigateToBottomBarPage(4);
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
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 32,
                        backgroundColor: Get.theme.primaryColor,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildSectionHeader(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildFeaturedCollections(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 104,
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
              _navigateToBottomBarPage(3, arguments: {
                'source': 'dashboard',
                'filterType': item['filterType'],
                'name': item['label'],
              });
            },
            child: Container(
              width: 92,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: colorScheme.outline.withOpacity(0.15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item['icon'] as IconData,
                      color: colorScheme.primary, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    item['label'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
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
                  label:
                      const Text('Logout', style: TextStyle(color: Colors.red)),
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
    if (item == null || item is! Map) return const SizedBox.shrink();
    final text = item['text']?.toString() ?? '';
    final type = item['type']?.toString() ?? '';
    final slug = item['slug']?.toString() ?? '';
    final rawChildren = item['children'];
    final List children = rawChildren is List ? rawChildren : [];

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
        children: children.whereType<Map>().map<Widget>((child) {
          return DrawerChildTile(
            title: child['text']?.toString() ?? '',
            onTap: () {
              Get.back();
              _handleNavigation(child['type']?.toString() ?? '',
                  child['slug']?.toString() ?? '');
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
    final cleanSlug = slug.toLowerCase().replaceAll('/', '').trim();
    final cleanType = type.toLowerCase().trim();

    if (cleanSlug == 'category' ||
        cleanSlug == 'categories' ||
        cleanSlug == 'category_search_filter_view' ||
        (cleanType == 'category' &&
            (cleanSlug.isEmpty || cleanSlug == 'category'))) {
      _navigateToBottomBarPage(1);
    } else if (cleanSlug == 'shop' ||
        cleanSlug == 'shopproductlistview' ||
        cleanSlug == 'shop_view' ||
        cleanSlug == 'all-products' ||
        cleanSlug == 'products' ||
        (cleanType == 'shop' && (cleanSlug.isEmpty || cleanSlug == 'shop'))) {
      _navigateToBottomBarPage(3);
    } else if (cleanSlug == 'profile' ||
        cleanSlug == 'profile_view' ||
        cleanSlug == 'account' ||
        cleanSlug == 'user' ||
        (cleanType == 'profile' &&
            (cleanSlug.isEmpty || cleanSlug == 'profile'))) {
      _navigateToBottomBarPage(4);
    } else if (cleanSlug == 'home' || cleanType == 'home') {
      _navigateToBottomBarPage(0);
    } else if (cleanSlug == 'cart' || cleanType == 'cart') {
      _navigateToBottomBarPage(2);
    } else if (type == 'category') {
      Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
        'categorySlug': slug,
        'source': 'drawer',
      });
    } else if (type == 'page') {
      Get.toNamed(Routes.CUSTOMPAGE, arguments: {'slug': slug, 'label': ''});
    } else if (slug.isNotEmpty) {
      if (slug.startsWith('/')) {
        Get.toNamed(slug);
      } else {
        Get.toNamed('/$slug');
      }
    }
  }

  void _navigateToBottomBarPage(int index, {dynamic arguments}) {
    Get.back();
    final shopArgs = arguments ?? {
      'source': 'all_products',
      'name': 'All Products',
    };
    try {
      if (Get.isRegistered<BottombarController>()) {
        final bottomController = Get.find<BottombarController>();
        bottomController.onTabChange(index);

        if (index == 3) {
          if (Get.isRegistered<ShopController>()) {
            Get.find<ShopController>().applyArguments(shopArgs);
          } else {
            final shopCtrl = Get.put(ShopController());
            shopCtrl.applyArguments(shopArgs);
          }
        }

        Get.until((route) =>
            route.settings.name == Routes.BOTTOMBAR || route.isFirst);
      } else {
        Get.offAllNamed(Routes.BOTTOMBAR,
            arguments: {'index': index, 'shopArguments': shopArgs});
      }
    } catch (e) {
      Get.offAllNamed(Routes.BOTTOMBAR,
          arguments: {'index': index, 'shopArguments': shopArgs});
    }
  }
}
