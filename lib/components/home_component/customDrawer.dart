import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/modules/category/controllers/category_controller.dart';
import 'package:foduu_ecommerce/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/drawerList.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:foduu_ecommerce/app/modules/shop/shop_navigation.dart';
import 'package:shimmer/shimmer.dart';

// ---------------------------------------------------------------------------
// CustomDrawer — Skip-Mode Aware  (vIsioninfra reference pattern)
// ---------------------------------------------------------------------------
// • Always shown for both guests (skip mode) and logged-in users.
// • 3-level PageView drill-down: Main Menu → Categories → Subcategories.
// • Section-labelled menu: SHOP & EXPLORE / MY ACCOUNT / SUPPORT & HELP.
// • Light minimalist header with guest fallback avatar & soft sign-in copy.
// • Footer: support pill + theme switcher + context-aware auth button.
// ---------------------------------------------------------------------------

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  // ── Page navigation ──────────────────────────────────────────────────────
  final PageController _pageController = PageController();
  int _currentLevel = 0; // 0 = main, 1 = categories, 2 = subcategories

  // ── Category drill-down state ────────────────────────────────────────────
  Map<String, dynamic>? _selectedParent;

  // ── CMS drawer items (from HomepageController) ───────────────────────────
  HomepageController get _hc => Get.find<HomepageController>();

  // ──────────────────────────────────────────────────────────────────────────

  void _goToLevel(int level, {Map<String, dynamic>? parent}) {
    setState(() {
      _currentLevel = level;
      if (parent != null) _selectedParent = parent;
    });
    _pageController.animateToPage(
      level,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    if (_currentLevel > 0) _goToLevel(_currentLevel - 1);
  }

  void _navigateToBottomBarPage(int index) {
    Get.back();
    try {
      final bc = Get.find<BottombarController>();
      bc.onTabChange(index);
    } catch (_) {
      Get.offAllNamed(Routes.BOTTOMBAR, arguments: {'index': index});
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Obx(() {
        if (_hc.isDrawerNavigationLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildMainMenuPage(context),
            _buildCategoryPage(context),
            _buildSubCategoryPage(context),
          ],
        );
      }),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PAGE 0 — MAIN MENU
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildMainMenuPage(BuildContext context) {
    final bool isLoggedIn = AuthDetails.isUserLogin();
    final authdetails = AuthDetails.getUserDetails() ?? {};

    return Column(
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        _buildHeader(context, isLoggedIn, authdetails),

        // ── Scrollable body ─────────────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              // SHOP & EXPLORE
              _buildSectionHeader(context, 'SHOP & EXPLORE'),
              DrawerTile(
                icon: const Icon(Icons.home_outlined),
                title: 'Home',
                subtitle: 'Offers, top deals & new arrivals',
                onTap: () => _navigateToBottomBarPage(0),
              ),
              DrawerTile(
                icon: const Icon(Icons.shopping_bag_outlined),
                title: 'All Products',
                subtitle: 'Browse the complete catalog',
                onTap: () {
                  Get.back();
                  openShop();
                },
              ),
              // Browse by Category — drills into level 1
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: SizedBox(
                  height: double.infinity,
                  child: SvgPicture.asset(
                    'assets/icon/cateorey.svg',
                    width: 22,
                    colorFilter: ColorFilter.mode(
                      context.primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                title: const Text(
                  'Browse by Category',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Explore product categories',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.onSurfaceVariantColor,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: context.onSurfaceVariantColor,
                ),
                onTap: () => _goToLevel(1),
              ),
              DrawerTile(
                icon: const Icon(Icons.search_rounded),
                title: 'Search & Filter',
                subtitle: 'Find products by keyword or filter',
                onTap: () {
                  Get.back();
                  Get.toNamed(Routes.SEARCH);
                },
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

              const SizedBox(height: 8),
              Divider(height: 1, color: context.outlineColor.withOpacity(0.4)),
              const SizedBox(height: 8),

              // MY ACCOUNT — only when logged in
              if (isLoggedIn) ...[
                _buildSectionHeader(context, 'MY ACCOUNT'),
                DrawerTile(
                  icon: const Icon(Icons.shopping_basket_outlined),
                  title: 'My Orders',
                  subtitle: 'Ongoing & recent order history',
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.ORDERS);
                  },
                ),
                DrawerTile(
                  icon: const Icon(Icons.favorite_border_rounded),
                  title: 'Your Wishlist',
                  subtitle: 'Saved & favourite products',
                  onTap: () => _navigateToBottomBarPage(2),
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
                DrawerTile(
                  icon: const Icon(Icons.person_outline_rounded),
                  title: 'Your Account',
                  subtitle: 'Profile, addresses & settings',
                  onTap: () => _navigateToBottomBarPage(profileTabIndex),
                ),
                const SizedBox(height: 8),
                Divider(
                    height: 1,
                    color: context.outlineColor.withOpacity(0.4)),
                const SizedBox(height: 8),
              ],

              // SUPPORT & HELP
              _buildSectionHeader(context, 'SUPPORT & HELP'),
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

              // CMS dynamic items (if any)
              if (_hc.drawernavigationItems.isNotEmpty) ...[
                const SizedBox(height: 8),
                Divider(
                    height: 1,
                    color: context.outlineColor.withOpacity(0.4)),
                const SizedBox(height: 8),
                ..._hc.drawernavigationItems
                    .map(_buildCmsDynamicItem)
                    .toList(),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),

        // ── Footer ──────────────────────────────────────────────────────────
        _buildFooter(context, isLoggedIn),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PAGE 1 — PARENT CATEGORIES
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildCategoryPage(BuildContext context) {
    // Pull categories from CategoryController if registered,
    // otherwise show skeleton until it becomes available.
    final bool catAvailable =
        Get.isRegistered<CategoryController>();
    final CategoryController? catController =
        catAvailable ? Get.find<CategoryController>() : null;

    return Column(
      children: [
        // Back header
        _buildSubPageHeader(context, 'Browse by Category'),

        Expanded(
          child: catController == null
              ? _buildCategorySkeleton(context)
              : Obx(() {
                  final categories = catController.categoryList;
                  return categories.isEmpty
                      ? _buildCategorySkeleton(context)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: categories.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: context.outlineColor.withOpacity(0.3),
                            indent: 16,
                            endIndent: 16,
                          ),
                          itemBuilder: (_, i) {
                            final cat = categories[i] as Map<String, dynamic>? ?? {};
                            final name = cat['name']?.toString() ??
                                cat['text']?.toString() ??
                                '';
                            final hasChildren =
                                (cat['children'] as List?)?.isNotEmpty ?? false;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 6),
                              title: Text(
                                name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 14),
                              ),
                              trailing: hasChildren
                                  ? Icon(Icons.arrow_forward_ios_rounded,
                                      size: 13,
                                      color: context.onSurfaceVariantColor)
                                  : null,
                              onTap: () {
                                if (hasChildren) {
                                  _goToLevel(2, parent: cat);
                                } else {
                                  Get.back();
                                  Get.toNamed(Routes.CATEGORY_SEARCH,
                                      arguments: cat);
                                }
                              },
                            );
                          },
                        );
                }),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PAGE 2 — SUBCATEGORIES
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildSubCategoryPage(BuildContext context) {
    final children =
        (_selectedParent?['children'] as List?)?.cast<Map<String, dynamic>>() ??
            [];
    final parentName = _selectedParent?['name']?.toString() ??
        _selectedParent?['text']?.toString() ??
        'Subcategories';

    return Column(
      children: [
        _buildSubPageHeader(context, parentName),
        Expanded(
          child: children.isEmpty
              ? Center(
                  child: Text(
                    'No subcategories found.',
                    style:
                        TextStyle(color: context.onSurfaceVariantColor),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: children.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: context.outlineColor.withOpacity(0.3),
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (_, i) {
                    final sub = children[i];
                    final name = sub['name']?.toString() ??
                        sub['text']?.toString() ?? '';
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      title: Text(name,
                          style: const TextStyle(fontSize: 14)),
                      trailing: Icon(Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: context.onSurfaceVariantColor),
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.CATEGORY_SEARCH,
                            arguments: sub);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HEADER — minimalist light, always shown for guest & logged-in
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, bool isLoggedIn,
      Map<String, dynamic> authdetails) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        left: 16,
        right: 12,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          bottom: BorderSide(
              color: context.outlineColor.withOpacity(0.4), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Avatar — network image for logged-in, placeholder for guest
          GestureDetector(
            onTap: () {
              Get.back();
              if (isLoggedIn) {
                _navigateToBottomBarPage(profileTabIndex);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: context.primaryColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: context.primaryColor.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: isLoggedIn &&
                        (authdetails['featured_image'] ?? '').toString().isNotEmpty
                    ? CachedNetworkImage(
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
                        memCacheWidth:
                            (46 * MediaQuery.of(context).devicePixelRatio)
                                .round(),
                        memCacheHeight:
                            (46 * MediaQuery.of(context).devicePixelRatio)
                                .round(),
                        imageUrl: HelperFunctions()
                            .getImage(authdetails['featured_image']),
                        placeholder: (_, __) => _guestAvatar(),
                        errorWidget: (_, __, ___) => _guestAvatar(),
                      )
                    : _guestAvatar(),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Name + subtitle
          Expanded(
            child: GestureDetector(
              onTap: () {
                Get.back();
                if (isLoggedIn) {
                  _navigateToBottomBarPage(profileTabIndex);
                } else {
                  isOtpLogin
                      ? Get.toNamed(Routes.MOBILELOGIN)
                      : Get.toNamed(Routes.LOGIN);
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          isLoggedIn
                              ? (authdetails['name']?.toString() ?? 'User')
                              : 'Welcome Guest',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.onSurfaceColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: context.primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isLoggedIn
                        ? (authdetails['email']?.toString() ??
                            'View Account')
                        : 'Sign in to access your account',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.onSurfaceVariantColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Close button
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.close_rounded,
              color: context.onSurfaceVariantColor,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FOOTER — support pill + theme + auth
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildFooter(BuildContext context, bool isLoggedIn) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          top: BorderSide(
              color: context.outlineColor.withOpacity(0.4), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Support pill
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: context.primaryColor.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.headset_mic_outlined,
                      size: 16, color: context.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      supportEmail,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.onSurfaceColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Theme switcher row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Theme Mode',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.onSurfaceVariantColor,
                  ),
                ),
                PopupMenuButton<ThemeMode>(
                  onSelected: (mode) {
                    final tc = Get.find<ThemeController>();
                    tc.setThemeMode(mode);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: ThemeMode.system,
                        child: Text('System Default')),
                    PopupMenuItem(
                        value: ThemeMode.light, child: Text('Light Mode')),
                    PopupMenuItem(
                        value: ThemeMode.dark, child: Text('Dark Mode')),
                  ],
                  icon: Icon(Icons.color_lens_outlined,
                      color: context.primaryColor),
                  tooltip: 'Change theme',
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Auth button — full width
            SizedBox(
              width: double.infinity,
              child: isLoggedIn
                  ? ElevatedButton.icon(
                      onPressed: () async {
                        Get.back();
                        await Get.find<BottombarController>().logout();
                      },
                      icon: const Icon(Icons.logout_rounded,
                          size: 18, color: Colors.white),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        isOtpLogin
                            ? Get.toNamed(Routes.MOBILELOGIN)
                            : Get.toNamed(Routes.LOGIN);
                      },
                      icon: const Icon(Icons.login_rounded,
                          size: 18, color: Colors.white),
                      label: const Text(
                        'Sign In / Register',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SUB-PAGE HEADER (back arrow + title for category drill-downs)
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildSubPageHeader(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 4,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          bottom: BorderSide(
              color: context.outlineColor.withOpacity(0.4), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            tooltip: 'Back',
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.close_rounded,
                size: 20, color: context.onSurfaceVariantColor),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SECTION HEADER LABEL
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: context.onSurfaceVariantColor,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SKELETON LOADING STATE
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildCategorySkeleton(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.outlineColor.withOpacity(0.3),
      highlightColor: context.outlineColor.withOpacity(0.1),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 8,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: context.outlineColor,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (_, __) => ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Container(
            height: 14,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          trailing: Container(
            height: 14,
            width: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // CMS DYNAMIC ITEM BUILDER (drawernavigationItems from API)
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildCmsDynamicItem(dynamic item) {
    final text = item['text']?.toString() ?? '';
    final type = item['type']?.toString() ?? '';
    final slug = item['slug']?.toString() ?? '';
    final children = item['children'] as List? ?? [];

    if (children.isNotEmpty) {
      return ExpansionTile(
        leading: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        title: Text(
          text,
          style:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.only(left: 16),
        children: children.map<Widget>((child) {
          return DrawerChildTile(
            title: child['text']?.toString() ?? '',
            onTap: () {
              Get.back();
              _handleCmsNavigation(child['type']?.toString() ?? '',
                  child['slug']?.toString() ?? '');
            },
          );
        }).toList(),
      );
    }

    return DrawerTile(
      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      title: text,
      onTap: () {
        Get.back();
        _handleCmsNavigation(type, slug);
      },
    );
  }

  void _handleCmsNavigation(String type, String slug) {
    if (type == 'category') {
      Get.toNamed(Routes.CATEGORY_SEARCH, arguments: {'slug': slug});
    } else if (type == 'page') {
      Get.toNamed(Routes.ABOUTUS, arguments: {'slug': slug});
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  Widget _guestAvatar() => Image.asset(
        'assets/images/profile_image.png',
        width: 46,
        height: 46,
        fit: BoxFit.cover,
      );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

