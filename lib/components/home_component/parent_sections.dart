import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/data/models/category_products_page.dart';
import 'package:zouhi/app/data/models/home_cms.dart';
import 'package:zouhi/app/data/models/home_sections.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:zouhi/components/category_product_card.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/home_config.dart';
import 'package:zouhi/constants/theme_ext.dart';
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
  final HomeTrustBadgesData? data;
  const FeatureStrip({super.key, this.component, this.data});

  static const _defaults = [
    ('w-icon-truck', 'Free Shipping & Returns', 'For all orders over \$500'),
    ('w-icon-bag', 'Secure Payment', 'We ensure secure payment'),
    ('w-icon-money', 'Quality Assured', 'Products selected for quality'),
    ('w-icon-chat', 'Call Us', 'Call or email us'),
  ];

  static IconData _icon(String key, int index) {
    final k = key.toLowerCase();
    if (k.contains('truck') || k.contains('shipping') || index == 0) {
      return Icons.local_shipping_outlined;
    }
    if (k.contains('bag') ||
        k.contains('payment') ||
        k.contains('lock') ||
        index == 1) {
      return Icons.lock_outline;
    }
    if (k.contains('money') ||
        k.contains('quality') ||
        k.contains('assured') ||
        index == 2) {
      return Icons.verified_outlined;
    }
    if (k.contains('chat') ||
        k.contains('call') ||
        k.contains('support') ||
        k.contains('email') ||
        index == 3) {
      return Icons.support_agent_outlined;
    }
    return Icons.check_circle_outline;
  }

  @override
  Widget build(BuildContext context) {
    final List<(String, String, String, String?)> items;
    if (data != null && data!.badges.isNotEmpty) {
      items = data!.badges
          .map((b) => (b.iconKey, b.title, b.description, b.imageUrl))
          .toList();
    } else {
      items = [
        for (var i = 0; i < 4; i++)
          (
            component?.str('feature_${i + 1}_icon', _defaults[i].$1) ??
                _defaults[i].$1,
            component?.str('feature_${i + 1}_title', _defaults[i].$2) ??
                _defaults[i].$2,
            component?.str('feature_${i + 1}_text', _defaults[i].$3) ??
                _defaults[i].$3,
            null,
          )
      ];
    }
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
          itemBuilder: (_, i) {
            final iconKey = items[i].$1;
            final title = items[i].$2;
            final subtitle = items[i].$3;
            final imgUrl = items[i].$4;

            return Row(
              children: [
                const SizedBox(width: 4),
                if (imgUrl != null && imgUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: imgUrl,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => Icon(
                      _icon(iconKey, i),
                      size: 28,
                      color: context.themePrimaryColor,
                    ),
                  )
                else
                  Icon(
                    _icon(iconKey, i),
                    size: 28,
                    color: context.themePrimaryColor,
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: _poppins,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.themeTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: _poppins,
                          fontSize: 10.5,
                          color: context.themeSecondrytext,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Special offers (countdown + product rail) ──────────────────────────────

class _CountdownBoxes extends StatefulWidget {
  final DateTime endsAt;
  const _CountdownBoxes({required this.endsAt});

  @override
  State<_CountdownBoxes> createState() => _CountdownBoxesState();
}

class _CountdownBoxesState extends State<_CountdownBoxes> {
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
    final days = _left.inDays;
    final h = _left.inHours % 24;
    final m = _left.inMinutes % 60;
    final s = _left.inSeconds % 60;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBox(context, _two(days), 'Days'),
        _buildColon(context),
        _buildBox(context, _two(h), 'Hrs'),
        _buildColon(context),
        _buildBox(context, _two(m), 'Mins'),
        _buildColon(context),
        _buildBox(context, _two(s), 'Secs'),
      ],
    );
  }

  Widget _buildColon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: SizedBox(
        height: 32,
        child: Center(
          child: Text(
            ':',
            style: TextStyle(
              fontFamily: _poppins,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.themeTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBox(BuildContext context, String value, String unit) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.themegreyColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: context.themeBorderColor.withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: _poppins,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.themeTextColor,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          unit,
          style: TextStyle(
            fontFamily: _poppins,
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
            color: context.themeSecondrytext,
          ),
        ),
      ],
    );
  }
}

class SpecialOffersSection extends StatelessWidget {
  final HomeComponent? component;
  final HomeSpecialOffersData? data;
  const SpecialOffersSection({super.key, this.component, this.data});

  DateTime _endsAt() {
    final raw = component?.str('countdown_until', '+10d') ?? '+10d';
    final m = RegExp(r'^\+?(\d+)\s*([dhm])').firstMatch(raw);
    final n = int.tryParse(m?.group(1) ?? '') ?? 10;
    final unit = m?.group(2) ?? 'd';
    final d = unit == 'h'
        ? Duration(hours: n)
        : unit == 'm'
            ? Duration(minutes: n)
            : Duration(days: n);
    final start = Get.isRegistered<HomepageController>()
        ? Get.find<HomepageController>().startedAt
        : DateTime.now();
    return start.add(d);
  }

  @override
  Widget build(BuildContext context) {
    final c = component;
    final controller = Get.isRegistered<HomepageController>()
        ? Get.find<HomepageController>()
        : null;

    final rawHeading = data?.heading.isNotEmpty == true
        ? data!.heading
        : (c?.str('section_heading', 'Special Offers!') ?? 'Special Offers!');

    // Extract title (e.g. "Special Offers!") and discount (e.g. "Up to 50% OFF")
    String title = 'Special Offers!';
    String discount =
        data?.discount.isNotEmpty == true ? data!.discount : '50% OFF';
    String prefix = 'Up to ';

    if (rawHeading.contains('!')) {
      final parts = rawHeading.split('!');
      title = '${parts[0].trim()}!';
      if (parts.length > 1 && parts[1].trim().isNotEmpty) {
        final rest = parts[1].trim();
        if (rest.toLowerCase().startsWith('up to ')) {
          prefix = rest.substring(0, 6);
          discount = rest.substring(6).trim();
        } else {
          prefix = '';
          discount = rest;
        }
      }
    } else if (rawHeading.isNotEmpty) {
      title = rawHeading;
    }

    final countdownLabel = data?.countdownLabel.isNotEmpty == true
        ? data!.countdownLabel
        : (c?.str('countdown_label', 'Hurry Up! Offer End In:') ??
            'Hurry Up! Offer End In:');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side: Heading, Discount, Countdown label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: _poppins,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: context.themeTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        text: prefix,
                        style: TextStyle(
                          fontFamily: _poppins,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.themeTextColor,
                        ),
                        children: [
                          TextSpan(
                            text: discount,
                            style: TextStyle(
                              fontFamily: _poppins,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: context.themePrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (countdownLabel.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        countdownLabel,
                        style: TextStyle(
                          fontFamily: _poppins,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: context.themeSecondrytext,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Right side: Compact countdown timer boxes
              _CountdownBoxes(endsAt: _endsAt()),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (data != null && data!.products.isNotEmpty)
          ProductRail(
            products: data!.products,
            loading: false,
          )
        else if (controller != null)
          Obx(() {
            final items = (data != null && data!.products.isNotEmpty)
                ? data!.products
                : controller.specialOffers.toList();
            return ProductRail(
              products: items,
              loading: items.isEmpty && controller.specialOffersLoading.value,
            );
          })
        else
          const ProductRail(products: [], loading: false),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Banners ────────────────────────────────────────────────────────────────

typedef _BannerCard = VisionBannerCard;

class VisionBannerCard extends StatelessWidget {
  final String? image;
  final String subtitle;
  final String title;
  final String? detail;
  final String buttonText;
  final double height;
  final VoidCallback? onTap;

  const VisionBannerCard({
    super.key,
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

class CategoryBanners extends StatefulWidget {
  final HomeComponent? component;
  final HomeBannersData? data;
  const CategoryBanners({super.key, this.component, this.data});

  @override
  State<CategoryBanners> createState() => _CategoryBannersState();
}

class _CategoryBannersState extends State<CategoryBanners> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % 2;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    if (data == null) {
      final c = widget.component;
      if (c == null || c.str('banner_1_title').isEmpty) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
        child: VisionBannerCard(
          image: c.image('banner_1_image'),
          subtitle: c.str('banner_1_subtitle'),
          title: c.str('banner_1_title'),
          detail: null,
          buttonText: 'Coming Soon',
          onTap: () {
            showSecurityCamerasComingSoonSheet(context);
          },
        ),
      );
    }

    final b1 = data.enterpriseNetworking;
    final b2 = data.fiberCable;
    final items = [b1, b2];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 175,
            child: PageView.builder(
              controller: _pageController,
              itemCount: items.length,
              onPageChanged: (idx) {
                if (mounted) setState(() => _currentPage = idx);
              },
              itemBuilder: (context, idx) {
                final item = items[idx];
                final isComingSoon =
                    item.buttonText.toLowerCase().contains('coming soon');
                return VisionBannerCard(
                  image: item.imageUrl,
                  subtitle: item.subtitle,
                  title: item.title,
                  detail: item.detail,
                  buttonText: item.buttonText,
                  onTap: () {
                    if (isComingSoon) {
                      showSecurityCamerasComingSoonSheet(context);
                    } else {
                      BottombarController.switchTab(1, arguments: {
                        'name': 'Fiber Optic Cables',
                        'categorySlug': 'fibre-cable',
                      });
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(items.length, (idx) {
              final isSel = idx == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isSel ? 18 : 6,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isSel
                      ? context.themePrimaryColor
                      : context.themeBorderColor.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class PromoStrip extends StatelessWidget {
  final HomeComponent? component;
  final HomeBannerItem? data;
  const PromoStrip({super.key, this.component, this.data});

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: VisionBannerCard(
          image: data!.imageUrl,
          subtitle: data!.subtitle,
          title: data!.title,
          detail: data!.detail,
          buttonText: data!.buttonText,
          height: 150,
          onTap: () {
            BottombarController.switchTab(1, arguments: {
              'name': 'All Products',
            });
          },
        ),
      );
    }
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

class ProductRail extends StatefulWidget {
  final List<CategoryProduct> products;
  final bool loading;
  const ProductRail({super.key, required this.products, required this.loading});

  @override
  State<ProductRail> createState() => _ProductRailState();
}

class _ProductRailState extends State<ProductRail> {
  late final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;
  static const double _cardWidth = 165.0;
  static const double _cardSpacing = 12.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollArrows());
  }

  @override
  void didUpdateWidget(covariant ProductRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.products.length != oldWidget.products.length) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _updateScrollArrows());
    }
  }

  void _onScroll() {
    _updateScrollArrows();
  }

  void _updateScrollArrows() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final maxScroll = pos.maxScrollExtent;
    final canLeft = pos.pixels > 10;
    final canRight = maxScroll > 0 && pos.pixels < (maxScroll - 10);
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      if (mounted) {
        setState(() {
          _canScrollLeft = canLeft;
          _canScrollRight = canRight;
        });
      }
    }
  }

  void _scrollLeft() {
    if (!_scrollController.hasClients) return;
    HapticFeedback.lightImpact();
    final target =
        (_scrollController.offset - (_cardWidth * 2 + _cardSpacing * 2))
            .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _scrollRight() {
    if (!_scrollController.hasClients) return;
    HapticFeedback.lightImpact();
    final target =
        (_scrollController.offset + (_cardWidth * 2 + _cardSpacing * 2))
            .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildFloatingArrow({
    required IconData icon,
    required bool isVisible,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      child: IgnorePointer(
        ignoring: !isVisible,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.white.withValues(alpha: 0.95),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: Icon(
                    icon,
                    size: 22,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = _cardHeight(context, _cardWidth);
    if (widget.products.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: widget.loading
              ? const CircularProgressIndicator(strokeWidth: 2.5)
              : Text('No products found.',
                  style: TextStyle(
                      fontFamily: _poppins, color: context.themeSecondrytext)),
        ),
      );
    }
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: widget.products.length,
            separatorBuilder: (_, __) => const SizedBox(width: _cardSpacing),
            itemBuilder: (_, i) => SizedBox(
                width: _cardWidth,
                child:
                    CategoryProductCard(product: widget.products[i], index: i)),
          ),
          // Left dynamic floating action arrow button
          Positioned(
            left: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildFloatingArrow(
                icon: Icons.chevron_left_rounded,
                isVisible: _canScrollLeft,
                onTap: _scrollLeft,
                isLeft: true,
              ),
            ),
          ),
          // Right dynamic floating action arrow button
          Positioned(
            right: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildFloatingArrow(
                icon: Icons.chevron_right_rounded,
                isVisible: _canScrollRight,
                onTap: _scrollRight,
                isLeft: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BestSellerSection extends StatelessWidget {
  final HomeComponent? component;
  final HomeBestSellersData? data;
  final HomeBannerItem? bannerItem;
  const BestSellerSection(
      {super.key, this.component, this.data, this.bannerItem});

  @override
  Widget build(BuildContext context) {
    final c = component;
    final controller = Get.find<HomepageController>();
    final title = (data != null && data!.title.isNotEmpty)
        ? data!.title
        : (c?.str('section_heading', 'Best Seller Products') ??
            'Best Seller Products');
    final banner = c?.image('banner_image');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title),
        if (bannerItem != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _BannerCard(
              image: bannerItem!.imageUrl,
              subtitle: bannerItem!.subtitle,
              title: bannerItem!.title,
              buttonText: bannerItem!.buttonText,
              height: 150,
              onTap: () {
                BottombarController.switchTab(1, arguments: {
                  'name': 'All Products',
                });
              },
            ),
          )
        else if (c != null && c.str('banner_title').isNotEmpty)
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
        if (data != null && data!.products.isNotEmpty)
          ProductRail(
            products: data!.products,
            loading: false,
          )
        else
          Obx(() {
            final items = controller.bestSellers.toList();
            return ProductRail(
              products: items,
              loading: items.isEmpty && controller.isBestLoading.value,
            );
          }),
      ],
    );
  }
}

class LatestProductsSection extends StatelessWidget {
  final HomeComponent? component;
  final HomeLatestProductsData? data;
  const LatestProductsSection({super.key, this.component, this.data});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomepageController>();
    final title = (data != null && data!.title.isNotEmpty)
        ? data!.title
        : (component?.str('section_heading', 'Latest Products') ??
            'Latest Products');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title),
        if (data != null && data!.products.isNotEmpty)
          ProductRail(
            products: data!.products,
            loading: false,
          )
        else
          Obx(() {
            final items = controller.latestProducts.toList();
            return ProductRail(
              products: items,
              loading: items.isEmpty && controller.isLatestLoading.value,
            );
          }),
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
      final _ = controller.isBrandsLoading.value;
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
