import 'package:flutter/material.dart';
import 'package:foddu/app/modules/auth/auth_details.dart';
import 'package:foddu/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foddu/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:foddu/app/routes/app_pages.dart';
import 'package:foddu/components/drawerList.dart';
import 'package:foddu/constants/dynamic_theme.dart';
import 'package:foddu/constants/constants.dart';
import 'package:foddu/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:foddu/app/modules/shop/shop_navigation.dart';
import 'package:foddu/components/commonWidgets/user_avatar.dart';

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
                  if (controller.drawernavigationItems.isEmpty) ...[
                    DrawerTile(
                      icon: const Icon(Icons.home_outlined),
                      title: 'Home',
                      subtitle: 'Go to home screen',
                      onTap: () => _navigateToBottomBarPage(0),
                    ),
                    DrawerTile(
                      icon: const Icon(Icons.shopping_bag_outlined),
                      title: 'All Products',
                      subtitle: 'Browse all items',
                      onTap: () {
                        Get.back();
                        openShop();
                      },
                    ),
                    DrawerTile(
                      icon: const Icon(Icons.category_outlined),
                      title: 'Shop By categories',
                      subtitle: 'Explore sections',
                      onTap: () => _navigateToBottomBarPage(shopTabIndex),
                    ),
                    DrawerTile(
                      icon: const Icon(Icons.article_outlined),
                      title: 'Blogs',
                      subtitle: 'Articles & insights',
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.BLOG);
                      },
                    ),
                    if (isLoggedIn) ...[
                      DrawerTile(
                        icon: const Icon(Icons.shopping_basket_outlined),
                        title: 'Orders',
                        subtitle: 'Track your purchases',
                        onTap: () {
                          Get.back();
                          Get.toNamed(Routes.ORDERS);
                        },
                      ),
                      DrawerTile(
                        icon: const Icon(Icons.confirmation_num_outlined),
                        title: 'Support Tickets',
                        subtitle: 'View & raise tickets',
                        onTap: () {
                          Get.back();
                          Get.toNamed(Routes.SUPPORT_TICKET);
                        },
                      ),
                      DrawerTile(
                        icon: const Icon(Icons.rate_review_outlined),
                        title: 'My Reviews',
                        subtitle: 'Your product reviews',
                        onTap: () {
                          Get.back();
                          Get.toNamed(Routes.MY_REVIEWS);
                        },
                      ),
                    ],
                    DrawerTile(
                      icon: const Icon(Icons.headset_mic_outlined),
                      title: 'Help & Customer Care',
                      subtitle: 'FAQs, contact & support',
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.HELPANDSUPPORT);
                      },
                    ),
                    DrawerTile(
                      icon: const Icon(Icons.info_outline),
                      title: 'About Us',
                      subtitle: 'Learn about our store',
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.ABOUTUS);
                      },
                    ),
                    DrawerTile(
                      icon: const Icon(Icons.mail_outline),
                      title: 'Contact Us',
                      subtitle: 'Get in touch with us',
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.CONTACTUS);
                      },
                    ),
                  ] else ...[
                    ...controller.drawernavigationItems
                        .map(_buildItem)
                        .toList(),
                    if (isLoggedIn) ...[
                      DrawerTile(
                        icon: const Icon(Icons.shopping_basket_outlined),
                        title: 'Orders',
                        subtitle: 'Track your purchases',
                        onTap: () {
                          Get.back();
                          Get.toNamed(Routes.ORDERS);
                        },
                      ),
                      DrawerTile(
                        icon: const Icon(Icons.confirmation_num_outlined),
                        title: 'Support Tickets',
                        subtitle: 'View & raise tickets',
                        onTap: () {
                          Get.back();
                          Get.toNamed(Routes.SUPPORT_TICKET);
                        },
                      ),
                    ],
                    DrawerTile(
                      icon: const Icon(Icons.headset_mic_outlined),
                      title: 'Help & Customer Care',
                      subtitle: 'FAQs, contact & support',
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.HELPANDSUPPORT);
                      },
                    ),
                    DrawerTile(
                      icon: const Icon(Icons.info_outline),
                      title: 'About Us',
                      subtitle: 'Learn about our store',
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.ABOUTUS);
                      },
                    ),
                  ],
                ],
              ),
            ),
            _buildSupportInfoPill(),
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
      onTap: () {
        Get.back();
        if (isLoggedIn) {
          _navigateToBottomBarPage(1); // Profile tab
        } else {
          isOtpLogin
              ? Get.toNamed(Routes.MOBILELOGIN)
              : Get.toNamed(Routes.LOGIN);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20,
          bottom: 20,
          left: 18,
          right: 18,
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
            UserAvatar(
              imageUrl: (isLoggedIn &&
                      userData != null &&
                      userData['featured_image'] != null)
                  ? HelperFunctions().getImage(userData['featured_image'])
                  : null,
              name: isLoggedIn && userData != null ? userData['name']?.toString() : null,
              radius: 28,
              borderWidth: 2,
              borderColor: Colors.white.withOpacity(0.4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLoggedIn && userData != null
                        ? (userData['name']?.toString() ?? 'User')
                        : 'Welcome Guest',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isLoggedIn && userData != null
                        ? (userData['email']?.toString() ?? '')
                        : 'Sign in to access your account',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.88),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportInfoPill() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Get.theme.primaryColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.headset_mic_outlined,
            size: 16,
            color: Get.theme.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              supportEmail,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Get.theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
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
                  label: const Text('Logout', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    isOtpLogin
                        ? Get.toNamed(Routes.MOBILELOGIN)
                        : Get.toNamed(Routes.LOGIN);
                  },
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: const Text(
                    'Sign In / Register',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildThemeSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
      Get.toNamed('/category/');
    } else if (type == 'page') {
      Get.toNamed('/page/');
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
