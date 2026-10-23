import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/data/category_index_service.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/modules/category/controllers/category_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:zouhi/components/drawerList.dart';
import 'package:zouhi/components/security_cameras_coming_soon_sheet.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final PageController _pageController = PageController();
  final CategoryIndexService _categoryIndexService = CategoryIndexService();
  int _currentLevel = 0;
  List<Map<String, dynamic>> _categoryStack = [];
  final RxList<Map<String, dynamic>> _hydratedCategories =
      <Map<String, dynamic>>[].obs;
  final Map<String, Map<String, dynamic>> _categoryMapById = {};
  final RxBool _isTreeLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadHydratedCategories();
  }

  Future<void> _loadHydratedCategories() async {
    final cached = _categoryIndexService.entries;
    if (cached.isNotEmpty) {
      _populateFromEntries(cached);
    }

    if (_hydratedCategories.isEmpty) {
      _isTreeLoading.value = true;
    }

    try {
      // 1. Instantly display cached tree if available
      final tree = await _categoryIndexService.getHydratedCategoryTree();
      if (tree.isNotEmpty) {
        _indexTreeNodes(tree);
        _hydratedCategories.assignAll(tree);
        _isTreeLoading.value = false;
      }
    } catch (e) {
      debugPrint("CustomDrawer _loadHydratedCategories cache error: $e");
    }

    // 2. Sync fresh tree in background to reflect newly added subcategories
    try {
      final freshTree = await _categoryIndexService.getHydratedCategoryTree(
          forceRefresh: true);
      if (freshTree.isNotEmpty && mounted) {
        _indexTreeNodes(freshTree);
        _hydratedCategories.assignAll(freshTree);
      }
    } catch (e) {
      debugPrint("CustomDrawer _loadHydratedCategories refresh error: $e");
    } finally {
      if (mounted) _isTreeLoading.value = false;
    }
  }

  void _populateFromEntries(List<CategoryEntry> entries) {
    for (final e in entries) {
      _categoryMapById[e.id] = e.toMap();
    }
  }

  void _indexTreeNodes(List<Map<String, dynamic>> nodes) {
    for (final node in nodes) {
      final id = node['_id']?.toString() ?? node['id']?.toString() ?? '';
      if (id.isNotEmpty) {
        _categoryMapById[id] = node;
      }
      final children = node['children'];
      if (children is List && children.isNotEmpty) {
        _indexTreeNodes(children.whereType<Map<String, dynamic>>().toList());
      }
    }
  }

  Map<String, dynamic>? _resolveCategory(dynamic raw) {
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final id = map['_id']?.toString() ?? map['id']?.toString() ?? '';
      if (id.isNotEmpty && _categoryMapById.containsKey(id)) {
        final indexed = _categoryMapById[id]!;
        final indexedChildren = indexed['children'];
        final currentChildren = map['children'];
        if ((currentChildren == null ||
                (currentChildren is List && currentChildren.isEmpty) ||
                (currentChildren is List &&
                    currentChildren.any((c) => c is String))) &&
            indexedChildren is List &&
            indexedChildren.isNotEmpty &&
            indexedChildren.any((c) => c is Map)) {
          map['children'] = indexedChildren;
        }
      }
      return map;
    }
    if (raw is String && _categoryMapById.containsKey(raw)) {
      return _categoryMapById[raw];
    }
    return null;
  }

  List<Map<String, dynamic>> _resolveChildren(dynamic rawList) {
    if (rawList is! List) return [];
    final List<Map<String, dynamic>> list = [];
    for (final item in rawList) {
      final resolved = _resolveCategory(item);
      if (resolved != null && (resolved['name'] ?? '').toString().isNotEmpty) {
        list.add(resolved);
      }
    }
    return list;
  }

  void _navigateToShop(Map<String, dynamic> args) {
    Get.back();
    final slug = (args['categorySlug'] ?? '').toString().toLowerCase();
    final name = (args['name'] ?? '').toString().toLowerCase();
    if (slug == 'cable-assemblies' || name.contains('cable assembl')) {
      Get.toNamed(Routes.CABLE_ASSEMBLIES);
      return;
    }
    if (slug == 'mtp-solution' ||
        slug.contains('mtp') ||
        name.contains('mtp')) {
      Get.toNamed(Routes.MTP_SOLUTION);
      return;
    }
    BottombarController.switchTab(1, arguments: args);
  }

  void _goToLevel(int level) {
    setState(() {
      _currentLevel = level;
    });
    _pageController.animateToPage(
      level,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentLevel == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentLevel == 2) {
          if (_categoryStack.length > 1) {
            setState(() {
              _categoryStack.removeLast();
            });
          } else {
            setState(() {
              _categoryStack.clear();
            });
            _goToLevel(1);
          }
        } else if (_currentLevel == 1) {
          _goToLevel(0);
        }
      },
      child: Drawer(
        backgroundColor: context.themeWhiteColor,
        child: SafeArea(
          top: false,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMainMenuPage(context),
              _buildParentCategoriesPage(context),
              _buildSubCategoriesPage(context),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PAGE 0: MAIN MENU PAGE
  // ---------------------------------------------------------------------------
  Widget _buildMainMenuPage(BuildContext context) {
    final authdetails = AuthDetails.getUserDetails() ?? {};
    final bool isLoggedIn = AuthDetails.isUserLogin();

    return Column(
      children: [
        // 1. Clean Minimalist Light Header Section
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            bottom: 16,
            left: 16,
            right: 12,
          ),
          decoration: BoxDecoration(
            color: context.themeWhiteColor,
            border: Border(
              bottom: BorderSide(color: context.themeBorderColor, width: 1),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                  BottombarController.switchTab(4);
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: context.themePrimaryColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: context.themePrimaryColor.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: isLoggedIn
                        ? CachedNetworkImage(
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            memCacheWidth:
                                (48 * MediaQuery.of(context).devicePixelRatio)
                                    .round(),
                            memCacheHeight:
                                (48 * MediaQuery.of(context).devicePixelRatio)
                                    .round(),
                            imageUrl: HelperFunctions()
                                .getImage(authdetails['featured_image']),
                            placeholder: (context, url) => Image.asset(
                              'assets/images/person.png',
                              width: 48,
                              height: 48,
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/images/person.png',
                              width: 48,
                              height: 48,
                            ),
                          )
                        : Image.asset(
                            'assets/images/person.png',
                            width: 48,
                            height: 48,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                    Get.find<BottombarController>().currentPageIndex.value = 4;
                    Get.find<BottombarController>()
                        .pageController
                        .jumpToPage(4);
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
                                  ? '${authdetails['name'] ?? 'User'}'
                                  : 'Welcome Guest',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.themeTextColor,
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: context.themePrimaryColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isLoggedIn
                            ? (authdetails['email'] ?? 'View Account')
                            : 'Sign in to access your account',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.themeSecondrytext,
                          fontFamily: 'Poppins',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.close_rounded,
                  color: context.themeSecondrytext,
                  size: 22,
                ),
              ),
            ],
          ),
        ),

        // 2. Scrollable Body Content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              // Featured Categories / Collections (Quick Access Chips)
              _buildSectionHeader(
                context,
                'FEATURED COLLECTIONS',
                onViewAll: () {
                  _navigateToShop({
                    'productId': '',
                    'name': 'All Products',
                    'productType': '',
                    'source': 'dashboard',
                  });
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 94,
                child: Builder(
                  builder: (context) {
                    final homeCtrl = Get.isRegistered<HomepageController>()
                        ? Get.find<HomepageController>()
                        : null;
                    final categories = homeCtrl?.productCategoryList ?? [];

                    if (categories.isNotEmpty) {
                      final displayList = categories.take(5).toList();
                      const colors = [
                        (
                          Color(0xFFE8F5E9),
                          Color(0xFF2E7D32),
                          'POPULAR',
                          Icons.cable_rounded
                        ),
                        (
                          Color(0xFFFFF3E0),
                          Color(0xFFE65100),
                          'TRENDING',
                          Icons.settings_input_component_rounded
                        ),
                        (
                          Color(0xFFEDE7F6),
                          Color(0xFF512DA8),
                          'HOT',
                          Icons.device_hub_rounded
                        ),
                        (
                          Color(0xFFFFEBEE),
                          Color(0xFFC62828),
                          'TOP',
                          Icons.electrical_services_rounded
                        ),
                        (
                          Color(0xFFE3F2FD),
                          Color(0xFF1565C0),
                          'NEW',
                          Icons.precision_manufacturing_outlined
                        ),
                      ];

                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: displayList.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          if (i == displayList.length) {
                            return _buildCollectionCard(
                              iconData: Icons.grid_view_rounded,
                              title: 'View All',
                              badge: 'ALL',
                              color: const Color(0xFFF5F5F5),
                              iconColor: context.themePrimaryColor,
                              onTap: () {
                                _navigateToShop({
                                  'productId': '',
                                  'name': 'All Products',
                                  'productType': '',
                                  'source': 'dashboard',
                                });
                              },
                            );
                          }
                          final cat = displayList[i];
                          final catName = cat['name']?.toString() ?? 'Category';
                          final catId = cat['_id']?.toString() ??
                              cat['id']?.toString() ??
                              '';
                          final catSlug = cat['slug']?.toString() ?? catId;
                          final palette = colors[i % colors.length];

                          return _buildCollectionCard(
                            iconData: palette.$4,
                            title: catName,
                            badge: palette.$3,
                            color: palette.$1,
                            iconColor: palette.$2,
                            onTap: () {
                              _navigateToShop({
                                'productId': catId,
                                'categorySlug': catSlug,
                                'name': catName,
                                'source': 'featured_collections',
                              });
                            },
                          );
                        },
                      );
                    }

                    // Fallback to real Vision catalog collections
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildCollectionCard(
                          iconData: Icons.cable_rounded,
                          title: 'Fiber Cables',
                          badge: 'POPULAR',
                          color: const Color(0xFFE8F5E9),
                          iconColor: const Color(0xFF2E7D32),
                          onTap: () {
                            _navigateToShop({
                              'name': 'Fiber Cables',
                              'categorySlug': 'fibre-cable',
                              'source': 'featured_collections',
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildCollectionCard(
                          iconData: Icons.memory_rounded,
                          title: 'Passive Devices',
                          badge: 'TRENDING',
                          color: const Color(0xFFFFF3E0),
                          iconColor: const Color(0xFFE65100),
                          onTap: () {
                            _navigateToShop({
                              'name': 'Passive Devices',
                              'categorySlug': 'passive-devices',
                              'source': 'featured_collections',
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildCollectionCard(
                          iconData: Icons.device_hub_rounded,
                          title: 'Connectors & Adapters',
                          badge: 'HOT',
                          color: const Color(0xFFEDE7F6),
                          iconColor: const Color(0xFF512DA8),
                          onTap: () {
                            _navigateToShop({
                              'name': 'Connectors & Adapters',
                              'categorySlug': 'fibre-optic-connectors-and-adap',
                              'source': 'featured_collections',
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildCollectionCard(
                          iconData: Icons.cleaning_services_rounded,
                          title: 'Cleaning',
                          badge: 'TOP',
                          color: const Color(0xFFFFEBEE),
                          iconColor: const Color(0xFFC62828),
                          onTap: () {
                            _navigateToShop({
                              'name': 'Cleaning',
                              'categorySlug': 'cleaning',
                              'source': 'featured_collections',
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildCollectionCard(
                          iconData: Icons.grid_view_rounded,
                          title: 'View All',
                          badge: 'ALL',
                          color: const Color(0xFFF5F5F5),
                          iconColor: context.themePrimaryColor,
                          onTap: () {
                            _navigateToShop({
                              'productId': '',
                              'name': 'All Products',
                              'productType': '',
                              'source': 'dashboard',
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              Divider(height: 1, color: context.themeBorderColor),
              const SizedBox(height: 12),

              // Shop & Explore Section
              _buildSectionHeader(context, 'SHOP & EXPLORE'),
              drawerList(
                icon: 'assets/icon/homicon.svg',
                title: 'Home',
                subtitle: 'Offers, Top Deals, Top Brands',
                pressevent: () {
                  Get.back();
                  BottombarController.switchTab(0);
                },
              ),
              drawerList(
                icon: 'assets/icon/drawerAllProduct.svg',
                title: 'All Products',
                subtitle: 'Browse complete catalog',
                pressevent: () {
                  _navigateToShop({
                    'productId': '',
                    'name': 'All Products',
                    'productType': '',
                    'source': 'dashboard',
                  });
                },
              ),

              // Creative Multi-Level Browse by Category Tile
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                minLeadingWidth: 0,
                leading: SizedBox(
                  height: double.infinity,
                  child: SvgPicture.asset(
                    'assets/icon/cateorey.svg',
                    width: 20,
                  ),
                ),
                title: const Text(
                  'Browse by Category',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  'Explore product categories',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: context.themeSecondrytext,
                ),
                onTap: () => _goToLevel(1),
              ),

              drawerList(
                icon: 'assets/icon/drawerFilter.svg',
                title: 'Filter by search',
                subtitle: 'Search products, keywords & filters',
                pressevent: () {
                  Get.back();
                  Get.toNamed(Routes.SEARCH);
                },
              ),

              const SizedBox(height: 12),
              Divider(height: 1, color: context.themeBorderColor),
              const SizedBox(height: 12),

              // Solutions & Services Section
              _buildSectionHeader(context, 'SOLUTIONS & SERVICES'),
              // drawerList(
              //   iconData: Icons.cable_rounded,
              //   title: 'Cable Assemblies',
              //   subtitle: 'Custom pre-terminated cable configurator',
              //   pressevent: () {
              //     Get.back();
              //     Get.toNamed(Routes.CABLE_ASSEMBLIES);
              //   },
              // ),
              drawerList(
                iconData: Icons.hub_outlined,
                title: 'Solutions',
                subtitle: 'Infrastructure by industry & challenge',
                pressevent: () {
                  Get.back();
                  Get.toNamed(Routes.SOLUTIONS);
                },
              ),
              drawerList(
                iconData: Icons.videocam_outlined,
                title: 'Cameras',
                badgeText: 'Coming Soon',
                subtitle: 'Enterprise surveillance & CCTV',
                pressevent: () {
                  Get.back();
                  showSecurityCamerasComingSoonSheet(context);
                },
              ),
              // drawerList(
              //   iconData: Icons.miscellaneous_services_rounded,
              //   title: 'Services',
              //   subtitle: 'Technical support, deployment & warranty',
              //   pressevent: () {
              //     Get.back();
              //     Get.toNamed(Routes.SERVICES);
              //   },
              // ),
              drawerList(
                iconData: Icons.info_outline_rounded,
                title: 'About Us',
                subtitle: 'Learn more about Vision Infrastructure',
                pressevent: () {
                  Get.back();
                  Get.toNamed(Routes.ABOUTUS);
                },
              ),
              drawerList(
                iconData: Icons.contact_mail_outlined,
                title: 'Contact Us',
                subtitle: 'Reach our team, send a message',
                pressevent: () {
                  Get.back();
                  Get.toNamed(Routes.CONTACT);
                },
              ),

              const SizedBox(height: 12),
              Divider(height: 1, color: context.themeBorderColor),
              const SizedBox(height: 12),

              // My Account Section (Only visible for logged-in users)
              if (isLoggedIn) ...[
                _buildSectionHeader(context, 'MY ACCOUNT'),
                drawerList(
                  icon: 'assets/icon/drawricon2.svg',
                  title: 'My Orders',
                  subtitle: 'Ongoing & recent order history',
                  pressevent: () {
                    Get.back();
                    Get.toNamed(Routes.ORDERS);
                  },
                ),
                drawerList(
                  icon: 'assets/icon/drawricon3.svg',
                  title: 'Your Wishlist',
                  subtitle: 'Saved & favorite products',
                  pressevent: () {
                    Get.back();
                    BottombarController.switchTab(3);
                  },
                ),
                drawerList(
                  icon: 'assets/icon/drawricon7.svg',
                  title: 'Your Account',
                  subtitle: 'Profile, addresses & settings',
                  pressevent: () {
                    Get.back();
                    BottombarController.switchTab(4);
                  },
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: context.themeBorderColor),
                const SizedBox(height: 12),
              ],

              // Support & Help Section
              _buildSectionHeader(context, 'SUPPORT & HELP'),
              drawerList(
                iconData: Icons.support_agent_rounded,
                title: 'Help & Customer Care',
                subtitle: 'Customer support & FAQs',
                pressevent: () {
                  Get.back();
                  Get.toNamed(Routes.HELPANDSUPPORT);
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),

        // 3. Clean Footer Section (Support Info & Auth Action)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.themeWhiteColor,
            border: Border(
              top: BorderSide(color: context.themeBorderColor, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: context.themePrimaryColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: context.themePrimaryColor.withOpacity(0.12)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.themePrimaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.headset_mic_outlined,
                        size: 16,
                        color: context.themePrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        supportEmail,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: context.themeTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: isLoggedIn
                        ? context.themeRedColor
                        : context.themePrimaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    if (isLoggedIn) {
                      Get.find<BottombarController>().confirmAndLogout(context);
                    } else {
                      isOtpLogin
                          ? Get.toNamed(Routes.MOBILELOGIN)
                          : Get.toNamed(Routes.LOGIN);
                    }
                  },
                  icon: Icon(
                    isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    isLoggedIn ? 'Logout' : 'Sign In / Register',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      letterSpacing: 0.3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PAGE 1: PARENT CATEGORIES PAGE
  // ---------------------------------------------------------------------------
  Widget _buildParentCategoriesPage(BuildContext context) {
    final homepageController = Get.isRegistered<HomepageController>()
        ? Get.find<HomepageController>()
        : Get.put(HomepageController());
    final categoryController = Get.isRegistered<CategoryController>()
        ? Get.find<CategoryController>()
        : Get.put(CategoryController());

    return Column(
      children: [
        // Top Breadcrumb Header
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            bottom: 16,
            left: 8,
            right: 12,
          ),
          decoration: BoxDecoration(
            color: context.themeWhiteColor,
            border: Border(
              bottom: BorderSide(color: context.themeBorderColor, width: 1),
            ),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => _goToLevel(0),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios_new_rounded,
                          size: 14, color: context.themePrimaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Menu',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: context.themePrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '|',
                style: TextStyle(color: context.themeSecondrytext),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Browse Categories',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: context.themeTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.close_rounded,
                  color: context.themeSecondrytext,
                  size: 22,
                ),
              ),
            ],
          ),
        ),

        // Categories List
        Expanded(
          child: Obx(() {
            final loading = _isTreeLoading.value;
            final List categories = _hydratedCategories.isNotEmpty
                ? _hydratedCategories.toList()
                : (homepageController.categoryTreeList.isNotEmpty
                    ? homepageController.categoryTreeList.toList()
                    : categoryController.categoryList.toList());

            if (loading && categories.isEmpty) {
              return _buildCategorySkeleton(context);
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: categories.length + 1,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: context.themeBorderColor,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                if (index == categories.length) {
                  // Explore All Grid shortcut
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Icon(Icons.grid_view_rounded,
                        color: context.themePrimaryColor, size: 20),
                    title: Text(
                      'Explore Our Shop',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.themePrimaryColor,
                      ),
                    ),
                    onTap: () {
                      Get.back();
                      Get.find<BottombarController>().currentPageIndex.value =
                          1;
                      Get.find<BottombarController>()
                          .pageController
                          .jumpToPage(1);
                    },
                  );
                }

                final rawCat = categories[index];
                final cat = _resolveCategory(rawCat) ??
                    (rawCat is Map ? Map<String, dynamic>.from(rawCat) : null);
                if (cat == null) return const SizedBox.shrink();

                String catName = cat['name']?.toString() ?? 'Category';
                List rawChildren = (cat['children'] is List)
                    ? cat['children']
                    : (cat['subcategories'] is List
                        ? cat['subcategories']
                        : []);
                List<Map<String, dynamic>> children =
                    _resolveChildren(rawChildren);

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  title: Text(
                    catName,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.themeTextColor,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (children.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.themegreyColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${children.length}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: context.themeSecondrytext,
                            ),
                          ),
                        ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: context.themeSecondrytext,
                      ),
                    ],
                  ),
                  onTap: () {
                    final slug = (cat['slug'] ?? '').toString().toLowerCase();
                    if (slug == 'cable-assemblies' ||
                        catName.toLowerCase().contains('cable assembl')) {
                      Get.back();
                      Get.toNamed(Routes.CABLE_ASSEMBLIES);
                      return;
                    }
                    if (slug == 'mtp-solution' ||
                        slug.contains('mtp') ||
                        catName.toLowerCase().contains('mtp')) {
                      Get.back();
                      Get.toNamed(Routes.MTP_SOLUTION);
                      return;
                    }
                    if (children.isNotEmpty) {
                      setState(() {
                        _categoryStack = [Map<String, dynamic>.from(cat)];
                      });
                      _goToLevel(2);
                    } else {
                      _navigateToShop({
                        'productId': cat['_id'],
                        'categorySlug': cat['slug'] ?? cat['_id'],
                        'name': catName,
                        'source': 'category'
                      });
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

  // ---------------------------------------------------------------------------
  // PAGE 2: SUBCATEGORIES PAGE (RECURSIVE STACK)
  // ---------------------------------------------------------------------------
  Widget _buildSubCategoriesPage(BuildContext context) {
    if (_categoryStack.isEmpty) return const SizedBox.shrink();

    final activeCat = _categoryStack.last;
    String parentName = activeCat['name']?.toString() ?? 'Category';
    List rawChildren = (activeCat['children'] is List)
        ? activeCat['children']
        : (activeCat['subcategories'] is List
            ? activeCat['subcategories']
            : []);
    List<Map<String, dynamic>> children = _resolveChildren(rawChildren);

    String backLabel = _categoryStack.length > 1
        ? (_categoryStack[_categoryStack.length - 2]['name']?.toString() ??
            'Back')
        : 'Categories';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0.15, 0.0),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
      child: Column(
        key: ValueKey(activeCat['_id'] ??
            activeCat['slug'] ??
            activeCat['name'] ??
            _categoryStack.length),
        children: [
          // Top Breadcrumb Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 16,
              left: 8,
              right: 12,
            ),
            decoration: BoxDecoration(
              color: context.themeWhiteColor,
              border: Border(
                bottom: BorderSide(color: context.themeBorderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    if (_categoryStack.length > 1) {
                      setState(() {
                        _categoryStack.removeLast();
                      });
                    } else {
                      setState(() {
                        _categoryStack.clear();
                      });
                      _goToLevel(1);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios_new_rounded,
                            size: 14, color: context.themePrimaryColor),
                        const SizedBox(width: 4),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: Text(
                            backLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: context.themePrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '|',
                  style: TextStyle(color: context.themeSecondrytext),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    parentName,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: context.themeTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: context.themeSecondrytext,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),

          // Shop All Parent Category Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: InkWell(
              onTap: () {
                _navigateToShop({
                  'productId': activeCat['_id'],
                  'categorySlug': activeCat['slug'] ?? activeCat['_id'],
                  'name': parentName,
                  'source': 'category'
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: context.themePrimaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.themePrimaryColor.withOpacity(0.22),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Shop All $parentName Products",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: context.themePrimaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: context.themePrimaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Divider(height: 1, color: context.themeBorderColor),

          // Subcategories List
          Expanded(
            child: children.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No further subcategories found.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: context.themeSecondrytext,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: children.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: context.themeBorderColor,
                      indent: 20,
                      endIndent: 20,
                    ),
                    itemBuilder: (context, index) {
                      final child = children[index];
                      final childName =
                          child['name']?.toString() ?? 'Subcategory';
                      List rawSubChildren = (child['children'] is List)
                          ? child['children']
                          : (child['subcategories'] is List
                              ? child['subcategories']
                              : []);
                      List<Map<String, dynamic>> subChildren =
                          _resolveChildren(rawSubChildren);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 4),
                        title: Text(
                          childName,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.themeTextColor,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (subChildren.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: context.themegreyColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${subChildren.length}',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: context.themeSecondrytext,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: context.themeSecondrytext,
                            ),
                          ],
                        ),
                        onTap: () {
                          if (subChildren.isNotEmpty) {
                            setState(() {
                              _categoryStack
                                  .add(Map<String, dynamic>.from(child));
                            });
                          } else {
                            _navigateToShop({
                              'productId': child['_id'],
                              'categorySlug': child['slug'] ?? child['_id'],
                              'name': childName,
                              'source': 'category'
                            });
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySkeleton(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 8,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: context.themeBorderColor,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (_, __) {
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Container(
            height: 16,
            width: 140,
            decoration: BoxDecoration(
              color: context.themegreyColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          trailing: Container(
            height: 16,
            width: 24,
            decoration: BoxDecoration(
              color: context.themegreyColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }

  // Helper widget for section headers
  Widget _buildSectionHeader(BuildContext context, String title,
      {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: context.themeSecondrytext,
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: context.themePrimaryColor,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 15,
                    color: context.themePrimaryColor,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Helper widget for collection cards/chips
  Widget _buildCollectionCard({
    required IconData iconData,
    required String title,
    required String badge,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 125,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(iconData, color: iconColor, size: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: iconColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
