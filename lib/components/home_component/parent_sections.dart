import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/data/models/category_products_page.dart';
import 'package:zouhi/app/data/models/home_cms.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:zouhi/app/modules/shop/views/productdetail_view.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/category_product_card.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/home_config.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:zouhi/components/home_component/contact_pricing_product_card.dart';
import 'package:zouhi/components/product_image_placeholder.dart';
import 'package:zouhi/components/security_cameras_coming_soon_sheet.dart';

/// Home sections mirroring vision.vbought.com/home, driven by `pages/home`.

const _poppins = 'Poppins';

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontFamily: _poppins,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.themeTextColor)),
          ),
        ],
      ),
    );
  }
}

/// Card height used wherever product cards sit in a horizontal rail.
double _cardHeight(BuildContext context, double cardWidth) {
  final scale = MediaQuery.textScalerOf(context).scale(1);
  return (cardWidth / 0.67) + (scale > 1.0 ? (scale - 1.0) * 16 : 0);
}

Widget _networkImage(String? url,
    {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  if (url == null) {
    return Container(width: width, height: height, color: Colors.black12);
  }
  return CachedNetworkImage(
    imageUrl: url,
    width: width,
    height: height,
    fit: fit,
    memCacheWidth: 900,
    errorWidget: (_, __, ___) =>
        Container(width: width, height: height, color: Colors.black12),
  );
}

// ── Feature strip ──────────────────────────────────────────────────────────

class FeatureStrip extends StatelessWidget {
  final HomeComponent? component;
  const FeatureStrip({super.key, this.component});

  static const _defaults = [
    ('w-icon-truck', 'Free Shipping & Returns', 'For all orders over \$99'),
    ('w-icon-bag', 'Secure Payment', 'We ensure secure payment'),
    ('w-icon-money', 'Money Back Guarantee', 'Any back within 30 days'),
    ('w-icon-chat', 'Customer Support', 'Call or email us 24/7'),
  ];

  static IconData _icon(String key) {
    if (key.contains('truck')) return Icons.local_shipping_outlined;
    if (key.contains('bag')) return Icons.lock_outline;
    if (key.contains('money')) return Icons.payments_outlined;
    if (key.contains('chat')) return Icons.support_agent_outlined;
    return Icons.check_circle_outline;
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      for (var i = 0; i < 4; i++)
        (
          component?.str('feature_${i + 1}_icon', _defaults[i].$1) ??
              _defaults[i].$1,
          component?.str('feature_${i + 1}_title', _defaults[i].$2) ??
              _defaults[i].$2,
          component?.str('feature_${i + 1}_text', _defaults[i].$3) ??
              _defaults[i].$3,
        )
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: context.themeWhiteColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: context.themeBorderColor.withValues(alpha: 0.3)),
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisExtent: 74),
          itemBuilder: (_, i) => Row(
            children: [
              const SizedBox(width: 4),
              Icon(_icon(items[i].$1),
                  size: 30, color: context.themePrimaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(items[i].$2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: _poppins,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.themeTextColor)),
                    const SizedBox(height: 2),
                    Text(items[i].$3,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: _poppins,
                            fontSize: 10.5,
                            color: context.themeSecondrytext)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Special offers (countdown + category tabs) ─────────────────────────────

class _Countdown extends StatefulWidget {
  final DateTime endsAt;
  const _Countdown({required this.endsAt});

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  Timer? _timer;
  late Duration _left;

  @override
  void initState() {
    super.initState();
    _left = _remaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      final next = _remaining();
      setState(() => _left = next);
      if (next == Duration.zero) t.cancel();
    });
  }

  Duration _remaining() {
    final d = widget.endsAt.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final h = _left.inHours % 24,
        m = _left.inMinutes % 60,
        s = _left.inSeconds % 60;
    return Text(
      '${_left.inDays}days,${_two(h)}:${_two(m)}:${_two(s)}',
      style: TextStyle(
          fontFamily: _poppins,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: context.themeTextColor),
    );
  }
}

class SpecialOffersSection extends StatefulWidget {
  final HomeComponent? component;
  final int itemsPerTab;
  const SpecialOffersSection({super.key, this.component, this.itemsPerTab = 6});

  @override
  State<SpecialOffersSection> createState() => _SpecialOffersSectionState();
}

class _SpecialOffersSectionState extends State<SpecialOffersSection> {
  final controller = Get.find<HomepageController>();
  int _tab = 0;

  /// `+10d` / `+12h` / `+30m`, relative to when the home page was opened (the
  /// web page uses the same relative jQuery countdown).
  DateTime _endsAt() {
    final raw = widget.component?.str('countdown_until', '+10d') ?? '+10d';
    final m = RegExp(r'^\+?(\d+)\s*([dhm])').firstMatch(raw);
    final n = int.tryParse(m?.group(1) ?? '') ?? 10;
    final unit = m?.group(2) ?? 'd';
    final d = unit == 'h'
        ? Duration(hours: n)
        : unit == 'm'
            ? Duration(minutes: n)
            : Duration(days: n);
    return controller.startedAt.add(d);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.component;
    const tabs = HomeConfig.specialOfferTabs;
    final discount = c?.str('discount_percent', '50% OFF') ?? '50% OFF';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
            c?.str('section_heading', 'Special Offers!') ?? 'Special Offers!'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.themegreyColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(TextSpan(
                        text: 'Up to ',
                        style: TextStyle(
                            fontFamily: _poppins,
                            fontSize: 14,
                            color: context.themeTextColor),
                        children: [
                          TextSpan(
                              text: discount,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: context.themePrimaryColor)),
                        ],
                      )),
                      const SizedBox(height: 4),
                      Text(
                          c?.str('countdown_label',
                                  'Hurry Up! Offer End In:') ??
                              'Hurry Up! Offer End In:',
                          style: TextStyle(
                              fontFamily: _poppins,
                              fontSize: 11.5,
                              color: context.themeSecondrytext)),
                    ],
                  ),
                ),
                _Countdown(endsAt: _endsAt()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => ProductRail(
            products: controller.specialOffers.toList(),
            loading: controller.specialOffersLoading.value)),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 2,
                          color: i == _tab
                              ? context.themePrimaryColor
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Text(tabs[i].name.toUpperCase(),
                        style: TextStyle(
                            fontFamily: _poppins,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: i == _tab
                                ? context.themePrimaryColor
                                : context.themeTextColor)),
                  ),
                ),
            ],
          ),
        ),
        Divider(
            height: 1, color: context.themeBorderColor.withValues(alpha: 0.3)),
        if (tabs.isNotEmpty)
          _tabGrid(context, tabs[_tab.clamp(0, tabs.length - 1)]),
      ],
    );
  }

  Widget _tabGrid(BuildContext context, ({String id, String name}) tab) {
    return Obx(() {
      final items = controller.specialItems[tab.id];
      final loading = controller.specialLoading[tab.id] ?? true;
      if (items == null) {
        return SizedBox(
          height: 140,
          child: Center(
            child: loading
                ? const CircularProgressIndicator(strokeWidth: 2.5)
                : Text('No products found.',
                    style: TextStyle(
                        fontFamily: _poppins,
                        color: context.themeSecondrytext)),
          ),
        );
      }
      if (items.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No products found.')),
        );
      }
      final shown = items.take(widget.itemsPerTab).toList();
      final isContactPricingTab = tab.id == '6a991c0cee3010dd62b873e4' ||
          tab.id == '6a991188e9868dc79a02e27c' ||
          tab.name.toLowerCase().contains('fibre cable') ||
          tab.name.toLowerCase().contains('connectors');

      return Column(
        children: [
          if (shown.length == 1 && !isContactPricingTab)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: _SpecialOfferHeroCard(
                product: shown.first,
                tabName: tab.name,
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: shown.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isContactPricingTab ? 0.62 : 0.72,
              ),
              itemBuilder: (_, i) {
                if (isContactPricingTab) {
                  return ContactPricingProductCard(
                    product: shown[i],
                    onContactPricing: () => Get.toNamed(
                      Routes.CATEGORYPRODUCTS,
                      arguments: {
                        'categoryId': tab.id,
                        'name': tab.name,
                      },
                    ),
                    onCardTap: () => Get.to(
                      () => ProductdetailView(),
                      preventDuplicates: false,
                      arguments: {'productId': shown[i].id},
                    ),
                  );
                }
                return CategoryProductCard(product: shown[i], index: i);
              },
            ),
          TextButton(
            onPressed: () => Get.toNamed(Routes.CATEGORYPRODUCTS,
                arguments: {'categoryId': tab.id, 'name': tab.name}),
            child: Text('View all ${tab.name}',
                style: TextStyle(
                    fontFamily: _poppins,
                    fontWeight: FontWeight.w600,
                    color: context.themePrimaryColor)),
          ),
        ],
      );
    });
  }
}

class _SpecialOfferHeroCard extends StatelessWidget {
  final CategoryProduct product;
  final String tabName;

  const _SpecialOfferHeroCard({
    required this.product,
    required this.tabName,
  });

  int _discountPercent(double original, double effective) {
    if (original <= 0) return 0;
    return (((original - effective) / original) * 100).round();
  }

  void _toggleWishlist(BuildContext context) async {
    if (!HelperFunctions.checkAndPromptLogin(
        message: "Please login to add products to your wishlist.")) {
      return;
    }
    if (!Get.isRegistered<WishlistController>()) {
      Get.put(WishlistController(), permanent: true);
    }
    final wishlist = Get.find<WishlistController>();
    final pid = product.id;
    if (wishlist.wishlistProductIds.contains(pid)) {
      wishlist.wishlistProductIds.remove(pid);
      wishlist.update();
      await wishlist.removeProductFromWishlist(productid: pid);
    } else {
      wishlist.wishlistProductIds.add(pid);
      wishlist.update();
      await wishlist.addProductToWishlist(productid: pid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.image == null
        ? null
        : HelperFunctions().getImage(product.image);
    final hasRealImage = imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl != HelperFunctions.getNoImage();

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Get.to(
        () => ProductdetailView(),
        preventDuplicates: false,
        arguments: {'productId': product.id},
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.themeWhiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: context.themeBorderColor.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left thumbnail with badge + wishlist
            Stack(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: hasRealImage
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,
                            memCacheWidth: 400,
                            errorWidget: (_, __, ___) =>
                                const ProductImagePlaceholder(
                              radius: 8,
                              padding: EdgeInsets.all(12),
                            ),
                          )
                        : const ProductImagePlaceholder(
                            radius: 8,
                            padding: EdgeInsets.all(12),
                          ),
                  ),
                ),
                if (product.hasDiscount)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${_discountPercent(product.price, product.effectivePrice)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          fontFamily: _poppins,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () => _toggleWishlist(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: context.themeWhiteColor.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Obx(() {
                          final inWishlist =
                              Get.isRegistered<WishlistController>() &&
                                  Get.find<WishlistController>()
                                      .wishlistProductIds
                                      .contains(product.id);
                          return Icon(
                            inWishlist
                                ? Icons.favorite
                                : Icons.favorite_border_rounded,
                            size: 18,
                            color: inWishlist
                                ? const Color(0xFFE53935)
                                : context.themeTextColor.withValues(alpha: 0.6),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // Right info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: context.themePrimaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'SPECIAL OFFER',
                      style: TextStyle(
                        fontFamily: _poppins,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: context.themePrimaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: _poppins,
                      fontSize: 14,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                      color: context.themeTextColor,
                    ),
                  ),
                  if (product.hasRating) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 13, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          '${product.averageRating!.toStringAsFixed(1)} (${product.ratingCount})',
                          style: TextStyle(
                            fontFamily: _poppins,
                            fontSize: 11,
                            color: context.themeSecondrytext,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        product.effectivePrice.toFormattedPrice(),
                        style: TextStyle(
                          fontFamily: _poppins,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.themeTextColor,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          product.price.toFormattedPrice(),
                          style: TextStyle(
                            fontFamily: _poppins,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: context.themeSecondrytext,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: context.themePrimaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            size: 14, color: context.colors.onPrimary),
                        const SizedBox(width: 5),
                        Text(
                          'Claim Offer',
                          style: TextStyle(
                            fontFamily: _poppins,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.colors.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Banners ────────────────────────────────────────────────────────────────

class _BannerCard extends StatelessWidget {
  final String? image;
  final String subtitle;
  final String title;
  final String? detail;
  final String buttonText;
  final double height;
  final VoidCallback? onTap;

  const _BannerCard({
    required this.image,
    required this.subtitle,
    required this.title,
    required this.buttonText,
    this.detail,
    this.height = 170,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _networkImage(image),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.65),
                        Colors.black.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subtitle.isNotEmpty)
                        Text(subtitle.toUpperCase(),
                            style: const TextStyle(
                                fontFamily: _poppins,
                                fontSize: 11,
                                letterSpacing: 1,
                                color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text(title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontFamily: _poppins,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      if (detail != null && detail!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(detail!,
                            style: const TextStyle(
                                fontFamily: _poppins,
                                fontSize: 12.5,
                                color: Colors.white)),
                      ],
                      const SizedBox(height: 10),
                      Builder(builder: (context) {
                        final isComingSoon =
                            buttonText.toLowerCase().contains('coming soon');
                        return GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isComingSoon
                                  ? const Color(0xFF0F172A)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: isComingSoon
                                  ? Border.all(
                                      color: Colors.amber.shade400, width: 1)
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isComingSoon) ...[
                                  Icon(Icons.access_time_rounded,
                                      size: 13, color: Colors.amber.shade400),
                                  const SizedBox(width: 5),
                                ],
                                Text(
                                  buttonText,
                                  style: TextStyle(
                                    fontFamily: _poppins,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isComingSoon
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryBanners extends StatelessWidget {
  final HomeComponent? component;
  const CategoryBanners({super.key, this.component});

  @override
  Widget build(BuildContext context) {
    final c = component;
    if (c == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Column(
        children: [
          for (final i in [1, 2])
            if (c.str('banner_${i}_title').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BannerCard(
                  image: c.image('banner_${i}_image'),
                  subtitle: c.str('banner_${i}_subtitle'),
                  title: c.str('banner_${i}_title'),
                  detail: c.str('banner_${i}_price_text'),
                  buttonText: c.str('banner_${i}_button_text', 'Shop Now'),
                  onTap: () {
                    final btn =
                        c.str('banner_${i}_button_text').toLowerCase();
                    final title = c.str('banner_${i}_title').toLowerCase();
                    if (btn.contains('coming soon') ||
                        title.contains('camera')) {
                      showSecurityCamerasComingSoonSheet(context);
                      return;
                    }
                    BottombarController.switchTab(1, arguments: {
                      'name': 'All Products',
                    });
                  },
                ),
              ),
        ],
      ),
    );
  }
}

class PromoStrip extends StatelessWidget {
  final HomeComponent? component;
  const PromoStrip({super.key, this.component});

  @override
  Widget build(BuildContext context) {
    final c = component;
    if (c == null) return const SizedBox.shrink();
    final coupon = c.str('coupon_code');
    final detail =
        '${c.str('coupon_prefix', 'Use code')} $coupon ${c.str('coupon_suffix')}'
            .trim();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: _BannerCard(
        image: c.image('banner_image'),
        subtitle: '',
        title: c.str('title'),
        detail: detail,
        buttonText: c.str('button_text', 'Shop Now'),
        height: 150,
        onTap: () {
          if (coupon.isNotEmpty) {
            Clipboard.setData(ClipboardData(text: coupon));
            Get.snackbar(
              'Coupon Copied',
              'Coupon code "$coupon" copied to clipboard! Use it at checkout.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: context.themePrimaryColor,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
              margin: const EdgeInsets.all(12),
            );
          }
          BottombarController.switchTab(1, arguments: {
            'name': 'All Products',
          });
        },
      ),
    );
  }
}

// ── Product rails ──────────────────────────────────────────────────────────

class ProductRail extends StatelessWidget {
  final List<CategoryProduct> products;
  final bool loading;
  const ProductRail({super.key, required this.products, required this.loading});

  @override
  Widget build(BuildContext context) {
    const cardWidth = 165.0;
    final height = _cardHeight(context, cardWidth);
    if (products.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: loading
              ? const CircularProgressIndicator(strokeWidth: 2.5)
              : Text('No products found.',
                  style: TextStyle(
                      fontFamily: _poppins, color: context.themeSecondrytext)),
        ),
      );
    }
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SizedBox(
            width: cardWidth,
            child: CategoryProductCard(product: products[i], index: i)),
      ),
    );
  }
}

class BestSellerSection extends StatelessWidget {
  final HomeComponent? component;
  const BestSellerSection({super.key, this.component});

  @override
  Widget build(BuildContext context) {
    final c = component;
    final controller = Get.find<HomepageController>();
    final banner = c?.image('banner_image');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(c?.str('section_heading', 'Best Seller Products') ??
            'Best Seller Products'),
        if (c != null && c.str('banner_title').isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _BannerCard(
              image: banner,
              subtitle: c.str('banner_subtitle'),
              title: c.str('banner_title'),
              buttonText: c.str('banner_button_text', 'Shop Now'),
              height: 150,
              onTap: () {
                BottombarController.switchTab(1, arguments: {
                  'name': 'All Products',
                });
              },
            ),
          ),
        Obx(() => ProductRail(
            products: controller.bestSellers.toList(),
            loading: controller.isBestLoading.value)),
      ],
    );
  }
}

class LatestProductsSection extends StatelessWidget {
  final HomeComponent? component;
  const LatestProductsSection({super.key, this.component});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomepageController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(component?.str('section_heading', 'Latest Products') ??
            'Latest Products'),
        Obx(() => ProductRail(
            products: controller.latestProducts.toList(),
            loading: controller.isLatestLoading.value)),
      ],
    );
  }
}

// ── PicOS software platform ────────────────────────────────────────────────

class PicosSection extends StatelessWidget {
  final HomeComponent? component;
  const PicosSection({super.key, this.component});

  @override
  Widget build(BuildContext context) {
    final c = component;
    final fallbackBanner = HomeConfig.resolveUrl(
        '/assets/images/demos/demo15/products/fs-switches.png');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(c?.str('section_title', 'PicOS Software Platform') ??
            'PicOS Software Platform'),
        for (var i = 0; i < HomeConfig.picosCards.length; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              decoration: BoxDecoration(
                color: context.themeWhiteColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: context.themeBorderColor.withValues(alpha: 0.3)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 625 / 300,
                    child: _networkImage(
                        c?.image('card_${i + 1}_image') ?? fallbackBanner,
                        fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _networkImage(
                              c?.image('card_${i + 1}_badge_image'),
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  c?.str('card_${i + 1}_title',
                                          HomeConfig.picosCards[i].title) ??
                                      HomeConfig.picosCards[i].title,
                                  style: TextStyle(
                                      fontFamily: _poppins,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: context.themeTextColor)),
                              const SizedBox(height: 4),
                              Text(
                                  c?.str('card_${i + 1}_text',
                                          HomeConfig.picosCards[i].text) ??
                                      HomeConfig.picosCards[i].text,
                                  style: TextStyle(
                                      fontFamily: _poppins,
                                      fontSize: 12,
                                      height: 1.4,
                                      color: context.themeSecondrytext)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Spacer block ───────────────────────────────────────────────────────────

class SpacerBlock extends StatelessWidget {
  final HomeComponent? component;
  const SpacerBlock({super.key, this.component});

  @override
  Widget build(BuildContext context) {
    final raw = component?.str('height', '24px') ?? '24px';
    final numVal =
        double.tryParse(raw.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 24.0;
    return SizedBox(height: numVal.clamp(6.0, 60.0));
  }
}

// ── Our Clients (Brands) section ───────────────────────────────────────────

class OurClientsSection extends StatelessWidget {
  final HomeComponent? component;
  const OurClientsSection({super.key, this.component});

  @override
  Widget build(BuildContext context) {
    final heading =
        component?.str('brands_heading', 'Our Clients') ?? 'Our Clients';
    final limit = component?.integer('brands_limit', 8) ?? 8;
    final controller = Get.find<HomepageController>();

    return Obx(() {
      final list = controller.brandsList.take(limit).toList();
      if (list.isEmpty && !controller.isBrandsLoading.value) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(heading),
          SizedBox(
            height: 64,
            child: controller.isBrandsLoading.value && list.isEmpty
                ? const Center(child: CupertinoActivityIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final brand = list[index];
                      if (brand is! Map) return const SizedBox.shrink();
                      final name = brand['name']?.toString() ?? '';
                      final logo = brand['logo'] ??
                          brand['image'] ??
                          brand['featured_image'];
                      final logoUrl = logo != null
                          ? HelperFunctions()
                              .getImage(logo, moduleName: "brands")
                          : null;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            BottombarController.switchTab(1, arguments: {
                              'source': 'brand',
                              'brandId':
                                  brand['_id'] ?? brand['id'] ?? brand['slug'],
                              'name': name,
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 110,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: context.themeWhiteColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.themeBorderColor
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: logoUrl != null && logoUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: logoUrl,
                                    fit: BoxFit.contain,
                                    errorWidget: (_, __, ___) => Text(
                                      name,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: _poppins,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: context.themeTextColor,
                                      ),
                                    ),
                                  )
                                : Text(
                                    name,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: _poppins,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: context.themeTextColor,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
        ],
      );
    });
  }
}

