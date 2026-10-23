import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/models/category_products_page.dart';
import 'package:zouhi/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:zouhi/app/modules/shop/views/productdetail_view.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/product_image_placeholder.dart';
import 'package:zouhi/components/shimmer_effects.dart';
import 'package:zouhi/components/support_call_sheet.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

/// Flagship Hero Section: "Top Categories Of The Month"
///
/// Features:
/// 1. Centered Header matching vision.foduu.store/home.
/// 2. Interactive Circular Category Rail with uniform Vision logo fallback.
/// 3. Blue Active Ring Indicator on selected category.
/// 4. Horizontal Scroll Indicator Dots.
/// 5. Strictly First 4 Products in a 2x2 grid per senior standards.
/// 6. Premium Image 2 Card Architecture:
///    - Top-Left: `QUOTE` badge or discount tag.
///    - Top-Right: Wishlist heart icon.
///    - Centered Image Container.
///    - Left-Aligned Bold Title & 2-line Description.
///    - `📄 Price on Request` secondary pill tag.
///    - Full-Width Navy Button: `✉ Contact for Pricing >`.
/// 7. "View All Products" button when category contains more items.
class CategoryHome extends StatefulWidget {
  final dynamic productCategoryList;
  final dynamic isLoading;
  final String? title;
  final String? subtitle;
  final int? itemLimit;

  const CategoryHome({
    super.key,
    this.productCategoryList,
    this.isLoading,
    this.title,
    this.subtitle,
    this.itemLimit,
  });

  @override
  State<CategoryHome> createState() => _TopCategoryHomeState();
}

class _TopCategoryHomeState extends State<CategoryHome>
    with AutomaticKeepAliveClientMixin, BaseController {
  final homeController = Get.find<HomepageController>();
  late final ScrollController _scrollController = ScrollController();
  int _activeDotPage = 0;

  static const String _defaultCategoryLogo =
      'https://vision.foduu.store/assets/images/shop/vison.jpg';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndSelectInitialCategory();
    });

    if (homeController.categoryTreeList.isEmpty) {
      homeController.getCategoryTreeData().then((_) {
        if (mounted) {
          _checkAndSelectInitialCategory();
        }
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;
    final progress = _scrollController.offset / maxScroll;
    final newPage = progress > 0.4 ? 1 : 0;
    if (newPage != _activeDotPage && mounted) {
      setState(() {
        _activeDotPage = newPage;
      });
    }
  }

  void _checkAndSelectInitialCategory() {
    final list = _topCategories;
    if (list.isEmpty) return;

    final currIndex =
        homeController.selectedTopCategoryIndex.value.clamp(0, list.length - 1);
    final cat = list[currIndex];
    final id = (cat['_id'] ?? cat['id'] ?? '').toString();
    final slug = (cat['slug'] ?? '').toString();
    final key = id.isNotEmpty ? id : slug;

    if (!homeController.topCategoryProducts.containsKey(key)) {
      homeController.selectTopCategory(currIndex, cat);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  static const List<String> _preferredOrderSlugs = [
    'cable-assemblies',
    'mtp-solution',
    'cleaning',
    'connectors',
    'copper',
    'enclosures',
    'fibre-cable',
    'passive-devices',
    'patch-lead',
  ];

  static const Map<String, dynamic> _cableAssembliesCategory = {
    '_id': 'cable-assemblies',
    'id': 'cable-assemblies',
    'name': 'Cable Assemblies',
    'slug': 'cable-assemblies',
    'featured_image_url': _defaultCategoryLogo,
  };

  static const Map<String, dynamic> _mtpSolutionCategory = {
    '_id': 'mtp-solution',
    'id': 'mtp-solution',
    'name': 'MTP Solution',
    'slug': 'mtp-solution',
    'featured_image_url': _defaultCategoryLogo,
  };

  int _orderWeight(dynamic cat) {
    if (cat is! Map) return 999;
    final slug = (cat['slug'] ?? '').toString().toLowerCase();
    final name = (cat['name'] ?? '').toString().toLowerCase();

    for (var i = 0; i < _preferredOrderSlugs.length; i++) {
      final key = _preferredOrderSlugs[i];
      if (slug.contains(key) || name.contains(key)) return i;
    }
    return 999;
  }

  List get _topCategories {
    final list = homeController.categoryTreeList.whereType<Map>().toList();

    final hasCableAssemblies = list.any((c) {
      final slug = (c['slug'] ?? '').toString().toLowerCase();
      final name = (c['name'] ?? '').toString().toLowerCase();
      return slug.contains('cable-assembl') || name.contains('cable assembl');
    });

    final hasMtp = list.any((c) {
      final slug = (c['slug'] ?? '').toString().toLowerCase();
      final name = (c['name'] ?? '').toString().toLowerCase();
      return slug.contains('mtp') || name.contains('mtp');
    });

    final combined = <dynamic>[];
    if (!hasCableAssemblies) combined.add(_cableAssembliesCategory);
    if (!hasMtp) combined.add(_mtpSolutionCategory);
    combined.addAll(list);

    combined.sort((a, b) => _orderWeight(a).compareTo(_orderWeight(b)));
    return combined.take(widget.itemLimit ?? 10).toList();
  }

  String _getCategoryImage(dynamic category) {
    if (category is! Map) return _defaultCategoryLogo;

    var featuredImage = category['featured_image'] ??
        category['featured_image_url'] ??
        category['featured_image_icon'];

    if (featuredImage != null && featuredImage.toString().trim().isNotEmpty) {
      final str = featuredImage.toString().trim();
      if (str.startsWith('http://') || str.startsWith('https://')) {
        return str;
      }
      final img = HelperFunctions().getImage(
        featuredImage,
        moduleName: "categories",
      );
      if (img.isNotEmpty && img != HelperFunctions.getNoImage()) {
        return img;
      }
    }
    return _defaultCategoryLogo;
  }

  String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _toggleWishlist(
      BuildContext context, CategoryProduct product) async {
    if (!Get.isRegistered<WishlistController>()) {
      Get.put(WishlistController(), permanent: true);
    }
    final wishlist = Get.find<WishlistController>();
    if (!HelperFunctions.checkAndPromptLogin(
        message: "Please login to add products to your wishlist.")) {
      return;
    }
    final productId = product.id;
    if (wishlist.wishlistProductIds.contains(productId)) {
      wishlist.wishlistProductIds.remove(productId);
      wishlist.update();
      await wishlist.removeProductFromWishlist(productid: productId);
    } else {
      wishlist.wishlistProductIds.add(productId);
      wishlist.update();
      await wishlist.addProductToWishlist(productid: productId);
    }
  }

  void _navigateToCategoryProducts(
    dynamic category, [
    BuildContext? context,
    CategoryProduct? product,
  ]) {
    if (category == null) {
      if (context != null && product != null) {
        _showContactPricingSheet(context, product);
      }
      return;
    }
    final slug = (category['slug'] ?? '').toString().toLowerCase();
    final name = (category['name'] ?? '').toString();

    if (slug == 'cable-assemblies' ||
        name.toLowerCase().contains('cable assembl')) {
      Get.toNamed(Routes.CABLE_ASSEMBLIES);
      return;
    }

    if (slug == 'mtp-solution' ||
        slug.contains('mtp') ||
        name.toLowerCase().contains('mtp')) {
      Get.toNamed(Routes.MTP_SOLUTION);
      return;
    }

    final categoryId = (category['_id'] ?? category['id'] ?? '').toString();

    Get.toNamed(
      Routes.CATEGORYPRODUCTS,
      arguments: {
        'categoryId': categoryId,
        'name': name.isNotEmpty ? name : 'Products',
        'children': category['children'],
      },
    );
  }

  void _showContactPricingSheet(BuildContext context, CategoryProduct product) {
    final imageUrl = product.image == null
        ? null
        : HelperFunctions().getImage(product.image);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: context.themeWhiteColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,
                            errorWidget: (_, __, ___) =>
                                const ProductImagePlaceholder(radius: 6),
                          )
                        : const ProductImagePlaceholder(radius: 6),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: context.themeTextColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF4F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Custom B2B Pricing',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B3B64),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: context.themeSecondrytext),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 14),
              Text(
                'Inquire for Bulk & Custom Pricing',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.themeTextColor,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFEEF4F9),
                  child: Icon(Icons.phone_in_talk_rounded,
                      color: context.themePrimaryColor, size: 20),
                ),
                title: const Text('Call Toll-Free Support',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                subtitle: Text(supportContact,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: context.themeSecondrytext)),
                onTap: () {
                  Get.back();
                  handleSupportCall(context);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE0F2FE),
                  child: Icon(Icons.email_outlined,
                      color: Color(0xFF0284C7), size: 20),
                ),
                title: const Text('Email Quote Request',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                subtitle: Text(supportEmail,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: context.themeSecondrytext)),
                onTap: () async {
                  Get.back();
                  final subject = Uri.encodeComponent(
                      'Quote Inquiry: ${product.name} [${product.id}]');
                  final body = Uri.encodeComponent(
                      'Hello Vision Infrastructure,\n\nPlease provide pricing for ${product.name}.\nQuantity: \nCompany: ');
                  final mailUrl =
                      'mailto:$supportEmail?subject=$subject&body=$body';
                  if (await canLaunchUrlString(mailUrl)) {
                    await launchUrlString(mailUrl);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      final categories = _topCategories;
      final isTreeLoading = homeController.isCategoryTreeLoading.value;

      if (!isTreeLoading && categories.isEmpty) {
        return const SizedBox.shrink();
      }

      final selectedIndex = homeController.selectedTopCategoryIndex.value
          .clamp(0, categories.isEmpty ? 0 : categories.length - 1);
      final activeCategory =
          categories.isNotEmpty ? categories[selectedIndex] : null;

      final activeId =
          (activeCategory?['_id'] ?? activeCategory?['id'] ?? '').toString();
      final activeSlug = (activeCategory?['slug'] ?? '').toString();
      final activeCategoryName =
          (activeCategory?['name'] ?? 'Category').toString();
      final activeKey = activeId.isNotEmpty ? activeId : activeSlug;

      final allProducts = homeController.topCategoryProducts[activeKey] ?? [];
      // Senior Requirement: Strictly show only first 4 products
      final products = allProducts.take(4).toList();
      final isProductsLoading =
          homeController.isTopCategoryProductsLoading.value;

      return Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Centered Section Heading matching website
            Center(
              child: Text(
                widget.title ?? "Top Categories Of The Month",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.themetitleColor,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 2. Horizontal Circular Category Rail with Uniform Fallback
            SizedBox(
              height: 120,
              child: isTreeLoading
                  ? const CategoryHomeShimmer()
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = index == selectedIndex;
                        final name = (cat['name'] ?? 'Category').toString();
                        final imgUrl = _getCategoryImage(cat);

                        return GestureDetector(
                          onTap: () {
                            final slug =
                                (cat['slug'] ?? '').toString().toLowerCase();
                            final catName =
                                (cat['name'] ?? '').toString().toLowerCase();
                            if (slug == 'mtp-solution' ||
                                slug.contains('mtp') ||
                                catName.contains('mtp')) {
                              Get.toNamed(Routes.MTP_SOLUTION);
                              return;
                            }
                            if (slug == 'cable-assemblies' ||
                                catName.contains('cable assembl')) {
                              Get.toNamed(Routes.CABLE_ASSEMBLIES);
                              return;
                            }
                            if (homeController.selectedTopCategoryIndex.value !=
                                index) {
                              homeController.selectTopCategory(index, cat);
                            }
                          },
                          child: SizedBox(
                            width: 78,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Circular Avatar with Active Ring
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  width: 68,
                                  height: 68,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? context.themePrimaryColor
                                          : Colors.transparent,
                                      width: isSelected ? 2.5 : 0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: context.themePrimaryColor
                                                  .withValues(alpha: 0.18),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFF1F5F9),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFFE2E8F0),
                                        width: 1,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: imgUrl,
                                        fit: BoxFit.contain,
                                        memCacheWidth: 150,
                                        memCacheHeight: 150,
                                        errorWidget: (_, __, ___) => Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Image.asset(
                                            'assets/images/VIC-Logo-Final-500.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        placeholder: (_, __) => Center(
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: HelperFunctions()
                                                .loadingIndicator(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Category Name Label
                                Text(
                                  name,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? context.themePrimaryColor
                                        : context.themeTextColor,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // 3. Carousel Progress Dots (- o)
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _activeDotPage == 0 ? 16 : 6,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _activeDotPage == 0
                        ? context.themePrimaryColor
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 5),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _activeDotPage == 1 ? 16 : 6,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _activeDotPage == 1
                        ? context.themePrimaryColor
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 4. Live In-Place Product Grid (Strictly First 4 Products - 2x2 Grid)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Builder(
                builder: (_) {
                  if (isProductsLoading) {
                    return _buildProductsShimmer();
                  }

                  if (products.isEmpty) {
                    return _buildEmptyState(context, activeCategory);
                  }

                  return Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 260,
                        ),
                        itemBuilder: (context, idx) {
                          return _buildImage2ProductCard(
                              context, products[idx], activeCategory);
                        },
                      ),

                      // "View All Products" button if there are additional products
                      if (allProducts.length > 4) ...[
                        const SizedBox(height: 14),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: context.themePrimaryColor
                                  .withValues(alpha: 0.4),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                          ),
                          onPressed: () {
                            final slug =
                                (activeCategory?['slug'] ?? '').toString();
                            final id = (activeCategory?['_id'] ??
                                    activeCategory?['id'] ??
                                    '')
                                .toString();
                            Get.toNamed(Routes.CATEGORYPRODUCTS, arguments: {
                              'categoryId': id.isNotEmpty ? id : slug,
                              'categorySlug': slug,
                              'name': activeCategoryName,
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'View All $activeCategoryName Products',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: context.themePrimaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: context.themePrimaryColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Card Widget matching the Image 2 Layout Requested by User
  // ---------------------------------------------------------------------------
  Widget _buildImage2ProductCard(
    BuildContext context,
    CategoryProduct product,
    dynamic activeCategory,
  ) {
    final imageUrl = product.image == null
        ? null
        : HelperFunctions().getImage(product.image);
    final hasRealImage = imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl != HelperFunctions.getNoImage();

    final cleanDesc = _cleanText(product.description);
    final displayDesc = cleanDesc.isEmpty
        ? 'High quality infrastructure component.'
        : cleanDesc;
    final discountPercent = product.discountPercent;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Get.to(
              () => ProductdetailView(),
              preventDuplicates: false,
              arguments: {'productId': product.id},
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Media Area with QUOTE Badge (Left) and Wishlist Heart (Right)
                Stack(
                  children: [
                    Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBFBFB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: hasRealImage
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.contain,
                              memCacheWidth: 350,
                              errorWidget: (_, __, ___) =>
                                  const ProductImagePlaceholder(radius: 6),
                            )
                          : const ProductImagePlaceholder(radius: 6),
                    ),

                    // Top-Left Badge: QUOTE or Discount
                    Positioned(
                      top: 4,
                      left: 4,
                      child: discountPercent > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$discountPercent% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF4F9),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFF20558A)
                                      .withValues(alpha: 0.2),
                                  width: 0.8,
                                ),
                              ),
                              child: const Text(
                                'QUOTE',
                                style: TextStyle(
                                  color: Color(0xFF20558A),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                    ),

                    // Top-Right Wishlist Heart Button
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GetBuilder<WishlistController>(
                        init: Get.isRegistered<WishlistController>()
                            ? Get.find<WishlistController>()
                            : Get.put(WishlistController(), permanent: true),
                        builder: (wishController) {
                          final isFav = wishController.wishlistProductIds
                              .contains(product.id);
                          return InkWell(
                            onTap: () => _toggleWishlist(context, product),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(5.5),
                              child: isFav
                                  ? SvgPicture.asset(
                                      'assets/icon/like.svg',
                                      width: 13,
                                      height: 13,
                                    )
                                  : SvgPicture.asset(
                                      'assets/icon/unlike.svg',
                                      width: 13,
                                      height: 13,
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Left-Aligned Product Name
                Text(
                  product.name,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: context.themeTextColor,
                  ),
                ),
                const SizedBox(height: 3),

                // Left-Aligned 2-Line Description with ellipsis
                Text(
                  displayDesc,
                  maxLines: 2,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10.5,
                    color: context.themeSecondrytext,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),

                // "Price on Request" Sub-Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 11,
                        color: Color(0xFF475569),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Price on Request',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Full-Width Pill Action Button: ✉ Contact for Pricing >
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16324F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      _navigateToCategoryProducts(
                          activeCategory, context, product);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email_outlined,
                            size: 13, color: Colors.white),
                        SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Contact for Pricing',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 3),
                        Icon(Icons.chevron_right_rounded,
                            size: 15, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, dynamic category) {
    final catName = category != null ? category['name'] ?? '' : '';
    final slug = (category?['slug'] ?? '').toString().toLowerCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 44,
              color: context.themeSecondrytext.withValues(alpha: 0.5)),
          const SizedBox(height: 10),
          Text(
            'Explore $catName',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.themeTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Custom hardware and engineered configurations available upon inquiry.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              color: context.themeSecondrytext,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.themePrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            ),
            onPressed: () {
              if (slug.contains('cable-assembl')) {
                Get.toNamed(Routes.CABLE_ASSEMBLIES);
              } else if (slug.contains('mtp')) {
                Get.toNamed(Routes.MTP_SOLUTION);
              } else {
                _navigateToCategoryProducts(category);
              }
            },
            child: Text(
              slug.contains('cable-assembl')
                  ? 'Open Cable Configurator'
                  : slug.contains('mtp')
                      ? 'Open MTP Solution Page'
                      : 'View Category Products',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsShimmer() {
    return AppShimmer(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 295,
        ),
        itemBuilder: (_, __) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class CategoryHomeShimmer extends StatelessWidget {
  const CategoryHomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        itemCount: 8,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, __) {
          return Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                width: 52,
                height: 10,
              ),
            ],
          );
        },
      ),
    );
  }
}
