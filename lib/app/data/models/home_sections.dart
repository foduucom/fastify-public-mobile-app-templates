import 'package:zouhi/app/data/models/category_products_page.dart';
import 'package:zouhi/constants/constants.dart';

String _cleanStr(dynamic val, [String fallback = '']) {
  if (val == null) return fallback;
  final s = val.toString().trim();
  return s.isEmpty ? fallback : s;
}

String? _cleanImage(dynamic raw) {
  if (raw == null) return null;
  if (raw is Map) {
    // Prioritize filepath for 200 OK image loading
    final dp = raw['filepath'] ??
        raw['filePath'] ??
        raw['filename'] ??
        raw['path'] ??
        raw['download_url'] ??
        raw['url'];
    if (dp != null && dp.toString().trim().isNotEmpty) {
      return _cleanImage(dp);
    }
  }
  var s = raw.toString().trim();
  if (s.isEmpty || s == '#') return null;
  if (s.startsWith('http://') || s.startsWith('https://')) {
    final baseUri = Uri.tryParse(url);
    if (baseUri != null && baseUri.hasAuthority) {
      s = s.replaceAll(
        RegExp(r'^https?://[a-zA-Z0-9_\.-]+\.(vbought\.com|foduu\.store)/images/'),
        '${baseUri.origin}/images/',
      );
    }
    return s;
  }
  final base = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  if (s.startsWith('images/')) return '$base/$s';
  if (s.startsWith('/images/')) return '$base$s';
  if (s.startsWith('/')) return '$base$s';
  return '$base/images/$s';
}

/// ── 1. Hero Slider ────────────────────────────────────────────────────────

class HomeSlideItem {
  final String heading;
  final String subheading;
  final String btnText;
  final String btnUrl;
  final String imageUrl;

  const HomeSlideItem({
    required this.heading,
    required this.subheading,
    required this.btnText,
    required this.btnUrl,
    required this.imageUrl,
  });

  factory HomeSlideItem.fromJson(Map<String, dynamic> json) {
    return HomeSlideItem(
      heading: _cleanStr(json['heading'] ?? json['title']),
      subheading: _cleanStr(json['subheading'] ?? json['subtitle'] ?? json['description']),
      btnText: _cleanStr(json['btn_text'] ?? json['button_text'], 'Explore Products'),
      btnUrl: _cleanStr(json['btn_url'] ?? json['button_url'] ?? json['link'], '/product'),
      imageUrl: _cleanImage(json['download_url'] ?? json['filepath'] ?? json['image']) ??
          'https://vision.foduu.store/images/2026/10/22/ss-8d154415-93660c0e.webp',
    );
  }
}

class HomeHeroSliderData {
  final List<HomeSlideItem> slides;

  const HomeHeroSliderData({required this.slides});

  factory HomeHeroSliderData.fallback() {
    return const HomeHeroSliderData(slides: [
      HomeSlideItem(
        heading: 'Deals and Promotions',
        subheading: 'High quality Electric Equipments',
        btnText: 'Explore Products',
        btnUrl: '/product',
        imageUrl: 'https://vision.foduu.store/images/2026/10/22/ss-8d154415-93660c0e.webp',
      ),
      HomeSlideItem(
        heading: 'High Performance Fiber Optic',
        subheading: 'This Week Only! DEALS AND PROMOTIONS',
        btnText: 'SHOP NOW',
        btnUrl: '/product',
        imageUrl: 'https://vision.foduu.store/images/2026/10/22/slider4-092e092b-0145dfcf.webp',
      ),
      HomeSlideItem(
        heading: 'High quality Electric Equipments',
        subheading: 'Free shipping on all orders',
        btnText: 'Explore Products',
        btnUrl: '/product',
        imageUrl: 'https://vision.foduu.store/images/2026/10/22/slider3-172a7885-853bdcb3.webp',
      ),
    ]);
  }

  factory HomeHeroSliderData.fromSections(List sections) {
    for (final s in sections) {
      if (s is Map) {
        final type = _cleanStr(s['type']);
        final id = _cleanStr(s['id']);
        final cj = s['content_json'] is Map ? s['content_json'] : (s['data'] is Map ? s['data'] : {});
        final slug = _cleanStr(cj['slug'] ?? cj['name'] ?? id).toLowerCase();

        if (type == 'slider' && (slug == 'home-slider' || slug == 'slider' || id == 'slider')) {
          final content = cj['content'] ?? cj['slides'] ?? cj['images'];
          if (content is List && content.isNotEmpty) {
            final items = <HomeSlideItem>[];
            for (final c in content) {
              if (c is Map) {
                items.add(HomeSlideItem.fromJson(Map<String, dynamic>.from(c)));
              }
            }
            if (items.isNotEmpty) {
              return HomeHeroSliderData(slides: items);
            }
          }
        }
      }
    }
    return HomeHeroSliderData.fallback();
  }
}

/// ── 2. Trust Badges ────────────────────────────────────────────────────────

class HomeTrustBadgeItem {
  final String iconKey;
  final String title;
  final String description;
  final String? imageUrl;

  const HomeTrustBadgeItem({
    required this.iconKey,
    required this.title,
    required this.description,
    this.imageUrl,
  });
}

class HomeTrustBadgesData {
  final List<HomeTrustBadgeItem> badges;

  const HomeTrustBadgesData({required this.badges});

  factory HomeTrustBadgesData.fallback() {
    return const HomeTrustBadgesData(badges: [
      HomeTrustBadgeItem(
        iconKey: 'truck',
        title: 'Free Shipping & Returns',
        description: 'For all orders over \$500',
      ),
      HomeTrustBadgeItem(
        iconKey: 'bag',
        title: 'Secure Payment',
        description: 'We ensure secure payment',
      ),
      HomeTrustBadgeItem(
        iconKey: 'money',
        title: 'Quality Assured',
        description: 'Products selected for quality',
      ),
      HomeTrustBadgeItem(
        iconKey: 'chat',
        title: 'Call Us',
        description: 'Call or email us',
      ),
    ]);
  }

  factory HomeTrustBadgesData.fromSections(List sections) {
    for (final s in sections) {
      if (s is Map) {
        final type = _cleanStr(s['type']);
        final id = _cleanStr(s['id']);
        if (type == 'trust_badges' || id == 'trust_badges') {
          final cj = s['content_json'] is Map ? s['content_json'] : (s['data'] is Map ? s['data'] : {});
          final cards = cj['cards'] ?? cj['items'] ?? cj['badges'];
          if (cards is List && cards.isNotEmpty) {
            final list = <HomeTrustBadgeItem>[];
            const defaultTitles = [
              'Free Shipping & Returns',
              'Secure Payment',
              'Quality Assured',
              'Call Us',
            ];
            const defaultIcons = [
              'truck',
              'bag',
              'money',
              'chat',
            ];

            for (var i = 0; i < cards.length; i++) {
              final c = cards[i];
              if (c is Map) {
                final rawDesc = _cleanStr(c['description'] ?? c['subheading'] ?? c['subtitle'] ?? c['text']);
                var rawTitle = _cleanStr(c['heading'] ?? c['title']);
                if (rawTitle.isEmpty || rawTitle.toLowerCase() == 'feature') {
                  final descLower = rawDesc.toLowerCase();
                  if (descLower.contains('shipping') || descLower.contains('order')) {
                    rawTitle = 'Free Shipping & Returns';
                  } else if (descLower.contains('payment') || descLower.contains('secure')) {
                    rawTitle = 'Secure Payment';
                  } else if (descLower.contains('quality') || descLower.contains('selected')) {
                    rawTitle = 'Quality Assured';
                  } else if (descLower.contains('call') || descLower.contains('email') || descLower.contains('support')) {
                    rawTitle = 'Call Us';
                  } else if (i < defaultTitles.length) {
                    rawTitle = defaultTitles[i];
                  } else {
                    rawTitle = 'Feature';
                  }
                }

                final img = _cleanImage(c['image'] ?? c['icon_url'] ?? c['icon']);
                var iconKey = _cleanStr(c['icon_key'] ?? c['icon'] ?? (i < defaultIcons.length ? defaultIcons[i] : 'truck'));
                if (iconKey.contains('/') || iconKey.contains('http')) {
                  iconKey = (i < defaultIcons.length ? defaultIcons[i] : 'truck');
                }

                final descLower = rawDesc.toLowerCase();
                if (descLower.contains('order') || descLower.contains('shipping')) {
                  iconKey = 'truck';
                } else if (descLower.contains('payment') || descLower.contains('secure')) {
                  iconKey = 'bag';
                } else if (descLower.contains('quality') || descLower.contains('selected')) {
                  iconKey = 'money';
                } else if (descLower.contains('call') || descLower.contains('email')) {
                  iconKey = 'chat';
                }

                list.add(HomeTrustBadgeItem(
                  iconKey: iconKey,
                  title: rawTitle,
                  description: rawDesc,
                  imageUrl: img,
                ));
              }
            }
            if (list.isNotEmpty) return HomeTrustBadgesData(badges: list);
          }
        }
      }
    }
    return HomeTrustBadgesData.fallback();
  }
}

/// ── 3. Top Categories of The Month ─────────────────────────────────────────

class HomeCategoryItem {
  final String id;
  final String name;
  final String slug;
  final String imageUrl;

  const HomeCategoryItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
  });
}

class HomeTopCategoriesData {
  final String heading;
  final List<HomeCategoryItem> categories;

  const HomeTopCategoriesData({
    required this.heading,
    required this.categories,
  });

  factory HomeTopCategoriesData.fallback() {
    return const HomeTopCategoriesData(
      heading: 'Top Categories of The Month',
      categories: [
        HomeCategoryItem(
          id: 'cable-assemblies',
          name: 'Cable assemblies',
          slug: 'cable-assemblies',
          imageUrl: 'https://vision.foduu.store/images/2026/10/23/RF-Cable-Assemblies-28c6f0e1.webp',
        ),
        HomeCategoryItem(
          id: 'mtp-solution',
          name: 'MTP Solution',
          slug: 'mtp-solution',
          imageUrl: 'https://vision.foduu.store/images/2026/10/23/mtp-89b9bc19.webp',
        ),
        HomeCategoryItem(
          id: 'cleaning-1',
          name: 'Cleaning, Tooling & Consumables',
          slug: 'cleaning-1',
          imageUrl: 'https://vision.foduu.store/images/2026/10/23/leaninig-f7fd5666.webp',
        ),
        HomeCategoryItem(
          id: 'fibre-optic-connectors-and-adap',
          name: 'Connectors and Adaptors',
          slug: 'fibre-optic-connectors-and-adap',
          imageUrl: 'https://vision.foduu.store/images/2026/10/23/connectors-90adcf53.webp',
        ),
        HomeCategoryItem(
          id: 'copper-leads',
          name: 'Copper leads',
          slug: 'copper-leads',
          imageUrl: 'https://vision.foduu.store/images/2026/10/23/copper-leads-332ce100.webp',
        ),
        HomeCategoryItem(
          id: 'enclosures',
          name: 'Enclosures and Racks',
          slug: 'enclosures',
          imageUrl: 'https://vision.foduu.store/images/2026/10/23/Rack-8c1775a7.webp',
        ),
        HomeCategoryItem(
          id: 'fibre-cable',
          name: 'Fibre Cable',
          slug: 'fibre-cable',
          imageUrl: 'https://vision.foduu.store/images/2026/10/23/fibre-cable-8aaee4e9.webp',
        ),
        HomeCategoryItem(
          id: 'passive-devices',
          name: 'Passive Devices',
          slug: 'passive-devices',
          imageUrl: 'https://vision.foduu.store/images/2026/10/23/passive-devices-257a0fd7.webp',
        ),
        HomeCategoryItem(
          id: 'patch-lead-1',
          name: 'Patch lead',
          slug: 'patch-lead-1',
          imageUrl: 'https://vision.foduu.store/images/2026/10/23/Patch-Lead-08ef1612.webp',
        ),
      ],
    );
  }

  factory HomeTopCategoriesData.fromSections(List sections) {
    for (final s in sections) {
      if (s is Map) {
        final type = _cleanStr(s['type']);
        final id = _cleanStr(s['id']);
        if (type == 'categories' || id == 'categories') {
          final cj = s['content_json'] is Map ? s['content_json'] : (s['data'] is Map ? s['data'] : {});
          final heading = _cleanStr(cj['heading'] ?? cj['title'], 'Top Categories of The Month');
          final rawCategories = cj['categories'] ?? cj['items'] ?? cj['data'];
          if (rawCategories is List && rawCategories.isNotEmpty) {
            final list = <HomeCategoryItem>[];
            for (final cat in rawCategories) {
              if (cat is Map) {
                final cId = _cleanStr(cat['_id'] ?? cat['id']);
                final name = _cleanStr(cat['name'] ?? cat['title']);
                final slug = _cleanStr(cat['slug'] ?? cId);
                final img = _cleanImage(cat['image'] ?? cat['icon'] ?? cat['featured_image']);
                list.add(HomeCategoryItem(
                  id: cId,
                  name: name,
                  slug: slug,
                  imageUrl: img ?? 'https://vision.foduu.store/images/2026/10/23/RF-Cable-Assemblies-28c6f0e1.webp',
                ));
              }
            }
            if (list.isNotEmpty) {
              return HomeTopCategoriesData(heading: heading, categories: list);
            }
          }
        }
      }
    }
    return HomeTopCategoriesData.fallback();
  }
}

/// ── 4. Special Offers Section ──────────────────────────────────────────────

class HomeSpecialOffersData {
  final String heading;
  final String subheading;
  final String discount;
  final String countdownLabel;
  final List<CategoryProduct> products;

  const HomeSpecialOffersData({
    required this.heading,
    required this.subheading,
    required this.discount,
    required this.countdownLabel,
    required this.products,
  });

  factory HomeSpecialOffersData.fallback() {
    return const HomeSpecialOffersData(
      heading: 'Special Offers!',
      subheading: 'Hurry Up! Offer End In:',
      discount: '50% OFF',
      countdownLabel: 'Hurry Up! Offer End In:',
      products: [],
    );
  }

  factory HomeSpecialOffersData.fromSections(List sections) {
    for (final s in sections) {
      if (s is Map) {
        final type = _cleanStr(s['type']);
        final cj = s['content_json'] is Map ? s['content_json'] : (s['data'] is Map ? s['data'] : {});
        final heading = _cleanStr(cj['heading'] ?? cj['title'] ?? s['heading']);

        if (type == 'products' && heading.toLowerCase().contains('special offers')) {
          final subheading = _cleanStr(cj['subheading'] ?? cj['subtitle'], 'Hurry Up! Offer End In:');
          final rawProducts = cj['products'] is Map
              ? (cj['products']['data'] ?? cj['products']['items'])
              : (cj['products'] ?? cj['data']);

          final list = <CategoryProduct>[];
          if (rawProducts is List) {
            for (final p in rawProducts) {
              if (p is Map) {
                try {
                  list.add(CategoryProduct.fromJson(Map<String, dynamic>.from(p)));
                } catch (_) {}
              }
            }
          }

          return HomeSpecialOffersData(
            heading: heading,
            subheading: subheading,
            discount: '50% OFF',
            countdownLabel: subheading,
            products: list,
          );
        }
      }
    }
    return HomeSpecialOffersData.fallback();
  }
}

/// ── 5. Promotional Banners ─────────────────────────────────────────────────

class HomeBannerItem {
  final String id;
  final String title;
  final String subtitle;
  final String? detail;
  final String buttonText;
  final String imageUrl;
  final String linkUrl;

  const HomeBannerItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.detail,
    required this.buttonText,
    required this.imageUrl,
    required this.linkUrl,
  });
}

class HomeBannersData {
  final HomeBannerItem enterpriseNetworking;
  final HomeBannerItem fiberCable;
  final HomeBannerItem fiberOpticAccessories;
  final HomeBannerItem nextGenNetworking;

  const HomeBannersData({
    required this.enterpriseNetworking,
    required this.fiberCable,
    required this.fiberOpticAccessories,
    required this.nextGenNetworking,
  });

  factory HomeBannersData.fallback() {
    return const HomeBannersData(
      enterpriseNetworking: HomeBannerItem(
        id: 'home-camera',
        title: 'Cameras',
        subtitle: 'ENTERPRISE NETWORKING',
        detail: null,
        buttonText: 'Coming Soon',
        imageUrl: 'https://vision.foduu.store/images/2026/10/24/camera-f4e9ce16-b3f65853.webp',
        linkUrl: '/security-cameras',
      ),
      fiberCable: HomeBannerItem(
        id: 'home-fiber-cable',
        title: 'Fiber Optic Cables',
        subtitle: 'BEST SELLER',
        detail: 'Starting From ₹299',
        buttonText: 'SHOP NOW',
        imageUrl: 'https://vision.foduu.store/images/2026/10/24/home-fiber-cable-5b14d336.webp',
        linkUrl: '/product?category=fibre-cable',
      ),
      fiberOpticAccessories: HomeBannerItem(
        id: 'home-fiber-optic-and-accessories',
        title: 'Fiber Optic Cables & Accessories',
        subtitle: 'Top Seller',
        buttonText: 'Shop Now',
        imageUrl: 'https://vision.foduu.store/images/2026/10/24/home-fiber-accessories-2a971bf3.webp',
        linkUrl: '/product',
      ),
      nextGenNetworking: HomeBannerItem(
        id: 'home-next-gen-networking',
        title: 'NEXT-GEN NETWORKING',
        subtitle: '',
        detail: 'Use code CONNECT2026 to get best offer.',
        buttonText: 'Shop Now',
        imageUrl: 'https://vision.foduu.store/images/2026/08/29/ss-d0e33464.webp',
        linkUrl: '/product',
      ),
    );
  }

  factory HomeBannersData.fromSections(List sections) {
    HomeBannerItem? camera;
    HomeBannerItem? fiber;
    HomeBannerItem? accessories;
    HomeBannerItem? nextGen;

    for (final s in sections) {
      if (s is Map) {
        final cj = s['content_json'] is Map ? s['content_json'] : (s['data'] is Map ? s['data'] : {});
        final sliderObj = cj['slider'] is Map ? cj['slider'] : cj;
        final slug = _cleanStr(sliderObj['slug'] ?? sliderObj['name'] ?? cj['slug'] ?? cj['name'] ?? s['id'] ?? s['name']).toLowerCase();

        final contentList = sliderObj['content'] is List && (sliderObj['content'] as List).isNotEmpty
            ? (sliderObj['content'] as List)
            : (cj['content'] is List && (cj['content'] as List).isNotEmpty ? (cj['content'] as List) : []);
        final content = contentList.isNotEmpty ? contentList.first : sliderObj;
        final cMap = content is Map ? Map<String, dynamic>.from(content) : <String, dynamic>{};

        final rawHeading = _cleanStr(cMap['heading'] ?? cMap['title'] ?? cj['heading']);
        final rawDesc = _cleanStr(cMap['description'] ?? cMap['subheading'] ?? cMap['subtitle'] ?? cj['subheading']);
        final btnText = _cleanStr(cMap['btn_text'] ?? cMap['button_text']);
        final btnUrl = _cleanStr(cMap['btn_url'] ?? cMap['button_url'] ?? cMap['link'], '/product');
        final img = _cleanImage(cMap['filePath'] ?? cMap['filepath'] ?? cMap['download_url'] ?? cMap['image']);

        if (slug.contains('camera')) {
          camera = HomeBannerItem(
            id: 'home-camera',
            title: rawHeading.toLowerCase().contains('enterprise') ? 'Cameras' : (rawHeading.isNotEmpty ? rawHeading : 'Cameras'),
            subtitle: rawHeading.toLowerCase().contains('enterprise') ? rawHeading : 'ENTERPRISE NETWORKING',
            detail: rawDesc.isNotEmpty ? rawDesc : null,
            buttonText: (btnText.isNotEmpty &&
                    btnText.toLowerCase() != 'explore' &&
                    btnText.toLowerCase() != 'explore now')
                ? btnText
                : 'Coming Soon',
            imageUrl: img ?? 'https://vision.foduu.store/images/2026/10/24/camera-f4e9ce16-b3f65853.webp',
            linkUrl: btnUrl,
          );
        } else if (slug.contains('fiber-cable')) {
          fiber = HomeBannerItem(
            id: 'home-fiber-cable',
            title: 'Fiber Optic Cables',
            subtitle: rawHeading.isNotEmpty ? rawHeading : 'BEST SELLER',
            detail: rawDesc.isNotEmpty ? rawDesc : 'Starting From ₹299',
            buttonText: btnText.isNotEmpty ? btnText : 'SHOP NOW',
            imageUrl: img ?? 'https://vision.foduu.store/images/2026/10/24/home-fiber-cable-5b14d336.webp',
            linkUrl: btnUrl.isNotEmpty && btnUrl != '/product' ? btnUrl : '/product?category=fibre-cable',
          );
        } else if (slug.contains('accessories') || slug.contains('optic')) {
          accessories = HomeBannerItem(
            id: 'home-fiber-optic-and-accessories',
            title: rawDesc.isNotEmpty ? rawDesc : 'Fiber Optic Cables & Accessories',
            subtitle: rawHeading.isNotEmpty ? rawHeading : 'Top Seller',
            buttonText: btnText.isNotEmpty ? btnText : 'Shop Now',
            imageUrl: img ?? 'https://vision.foduu.store/images/2026/10/24/home-fiber-accessories-2a971bf3.webp',
            linkUrl: btnUrl,
          );
        } else if (slug.contains('next-gen') || slug.contains('networking')) {
          final couponCode = _cleanStr(cMap['coupon_code'] ?? cj['coupon_code']);
          final couponPrefix = _cleanStr(cMap['coupon_prefix'] ?? cj['coupon_prefix'], 'Use code');
          final couponSuffix = _cleanStr(cMap['coupon_suffix'] ?? cj['coupon_suffix'], 'to get best offer.');
          String? computedDetail;
          if (couponCode.isNotEmpty) {
            computedDetail = '$couponPrefix $couponCode $couponSuffix'.trim();
          } else {
            final rawDetail = _cleanStr(cMap['detail'] ?? cMap['description'] ?? cj['detail']);
            computedDetail = rawDetail.isNotEmpty ? rawDetail : 'Use code CONNECT2026 to get best offer.';
          }

          nextGen = HomeBannerItem(
            id: 'home-next-gen-networking',
            title: rawHeading.isNotEmpty ? rawHeading : 'NEXT-GEN NETWORKING',
            subtitle: rawDesc,
            detail: computedDetail,
            buttonText: (btnText.isNotEmpty &&
                    btnText.toLowerCase() != 'explore solutions')
                ? btnText
                : 'Shop Now',
            imageUrl: img ?? 'https://vision.foduu.store/images/2026/08/29/ss-d0e33464.webp',
            linkUrl: btnUrl,
          );
        }
      }
    }

    final fallback = HomeBannersData.fallback();
    return HomeBannersData(
      enterpriseNetworking: camera ?? fallback.enterpriseNetworking,
      fiberCable: fiber ?? fallback.fiberCable,
      fiberOpticAccessories: accessories ?? fallback.fiberOpticAccessories,
      nextGenNetworking: nextGen ?? fallback.nextGenNetworking,
    );
  }
}

/// ── 6. Best Sellers Products ───────────────────────────────────────────────

class HomeBestSellersData {
  final String title;
  final List<CategoryProduct> products;

  const HomeBestSellersData({
    required this.title,
    required this.products,
  });

  factory HomeBestSellersData.fallback() {
    return const HomeBestSellersData(
      title: 'Best Seller Products',
      products: [],
    );
  }

  factory HomeBestSellersData.fromSections(List sections) {
    String title = 'Best Seller Products';
    final list = <CategoryProduct>[];

    for (final s in sections) {
      if (s is Map) {
        final type = _cleanStr(s['type']);
        final cj = s['content_json'] is Map ? s['content_json'] : (s['data'] is Map ? s['data'] : {});
        final heading = _cleanStr(cj['heading'] ?? cj['title'] ?? s['heading']);

        if (type == 'rich_text' && heading.toLowerCase().contains('best seller')) {
          title = heading.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
        }

        if (type == 'products') {
          final catType = _cleanStr(cj['category_type']);
          final isBestSeller = heading.toLowerCase().contains('best seller') ||
              catType.contains('best_seller') ||
              cj['list_view_type'] == 'horizontal';

          if (isBestSeller && !heading.toLowerCase().contains('special offers')) {
            final rawProducts = cj['products'] is Map
                ? (cj['products']['data'] ?? cj['products']['items'])
                : (cj['products'] ?? cj['data']);

            if (rawProducts is List) {
              for (final p in rawProducts) {
                if (p is Map) {
                  try {
                    list.add(CategoryProduct.fromJson(Map<String, dynamic>.from(p)));
                  } catch (_) {}
                }
              }
            }
          }
        }
      }
    }

    return HomeBestSellersData(title: title, products: list);
  }
}

/// ── 7. Latest Products ─────────────────────────────────────────────────────

class HomeLatestProductsData {
  final String title;
  final List<CategoryProduct> products;

  const HomeLatestProductsData({
    required this.title,
    required this.products,
  });

  factory HomeLatestProductsData.fallback() {
    return const HomeLatestProductsData(
      title: 'Latest Products',
      products: [],
    );
  }

  factory HomeLatestProductsData.fromSections(List sections) {
    String title = 'Latest Products';
    final list = <CategoryProduct>[];

    for (final s in sections) {
      if (s is Map) {
        final type = _cleanStr(s['type']);
        final cj = s['content_json'] is Map ? s['content_json'] : (s['data'] is Map ? s['data'] : {});
        final heading = _cleanStr(cj['heading'] ?? cj['title'] ?? s['heading']);
        final catType = _cleanStr(cj['category_type']);

        if (type == 'products' &&
            (heading.toLowerCase().contains('latest') || catType.contains('recently_created'))) {
          title = heading.isNotEmpty ? heading : 'Latest Products';
          final rawProducts = cj['products'] is Map
              ? (cj['products']['data'] ?? cj['products']['items'])
              : (cj['products'] ?? cj['data']);

          if (rawProducts is List) {
            for (final p in rawProducts) {
              if (p is Map) {
                try {
                  list.add(CategoryProduct.fromJson(Map<String, dynamic>.from(p)));
                } catch (_) {}
              }
            }
          }
        }
      }
    }

    return HomeLatestProductsData(title: title, products: list);
  }
}
