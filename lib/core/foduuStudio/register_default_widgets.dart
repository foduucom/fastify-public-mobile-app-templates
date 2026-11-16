import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/data/models/home_sections.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/home_component/category_home.dart';
import 'package:zouhi/components/home_component/home_banner.dart';
import 'package:zouhi/components/home_component/home_blogs.dart';
import 'package:zouhi/components/home_component/home_common_widgets.dart';
import 'package:zouhi/components/home_component/home_price_filter.dart';
import 'package:zouhi/components/home_component/home_products.dart';
import 'package:zouhi/components/home_component/home_rich_text_component.dart';
import 'package:zouhi/components/home_component/parent_sections.dart';
import 'package:zouhi/components/home_component/vision_hero_slider.dart';
import 'package:zouhi/components/search_bar_rounded.dart';
import 'package:zouhi/constants/constants.dart';

import 'widget_registry.dart';

HomepageController? get _homepageController =>
    Get.isRegistered<HomepageController>() ? Get.find<HomepageController>() : null;

/// Intelligent Slider & Banner Dispatcher:
/// In Fastify Studio CMS, multiple banners are sent as type `slider` or `banner`.
/// This dispatcher inspects the slug, metadata, and slide content to render the
/// specific client-approved widget instead of defaulting everything to the Top Hero Slider.
Widget _buildSliderOrBanner(Map<String, dynamic>? json) {
  if (json == null) return const SizedBox.shrink();

  final sliderObj = json['slider'] is Map ? json['slider'] as Map : json;
  final slug = (sliderObj['slug'] ??
          sliderObj['name'] ??
          json['slug'] ??
          json['id'] ??
          json['name'] ??
          '')
      .toString()
      .toLowerCase();

  final contentList = sliderObj['content'] is List && (sliderObj['content'] as List).isNotEmpty
      ? (sliderObj['content'] as List)
      : (json['content'] is List && (json['content'] as List).isNotEmpty
          ? (json['content'] as List)
          : []);

  // 1. Top Main Hero Carousel Banner (Home Hero Slider)
  if (slug == 'home-slider' || slug == 'slider' || slug.contains('hero')) {
    return Obx(() {
      final ctrl = _homepageController;
      final heroData = ctrl != null
          ? ctrl.heroSlider.value
          : HomeHeroSliderData.fromContentJson(json);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: VisionHeroSlider(data: heroData),
      );
    });
  }

  // 2. Category Dual Banners (Enterprise Networking / Security Cameras / Fiber Cable)
  if (slug.contains('camera') ||
      slug.contains('fiber-cable') ||
      slug.contains('side') ||
      slug.contains('category')) {
    return Obx(() {
      final ctrl = _homepageController;
      final bannersData = ctrl?.banners.value ?? HomeBannersData.fallback();
      return CategoryBanners(data: bannersData);
    });
  }

  // 3. Next-Gen Networking Promo Strip Banner
  if (slug.contains('next-gen') ||
      slug.contains('networking') ||
      slug.contains('promo')) {
    return Obx(() {
      final ctrl = _homepageController;
      final promoItem = ctrl?.banners.value.nextGenNetworking ??
          HomeBannersData.fallback().nextGenNetworking;
      return PromoStrip(data: promoItem);
    });
  }

  // 4. Top Seller Fiber Optic Cables & Accessories Banner
  if (slug.contains('accessories') || slug.contains('optic')) {
    // Absorbed directly into BestSellerSection (positioned between Heading and Products)
    return const SizedBox.shrink();
  }

  // 5. If it contains multiple slides that don't match the top hero:
  if (contentList.length > 1) {
    final customSliderData = HomeHeroSliderData.fromContentJson(json);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: VisionHeroSlider(data: customSliderData),
    );
  }

  // 6. Generic Single Banner fallback from CMS
  final bannerItem = HomeBannerItem.fromContentJson(json);
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: VisionBannerCard(
      image: bannerItem.imageUrl,
      subtitle: bannerItem.subtitle,
      title: bannerItem.title,
      detail: bannerItem.detail,
      buttonText: bannerItem.buttonText,
      height: 150,
      onTap: () {
        BottombarController.switchTab(1, arguments: {
          'name': 'All Products',
        });
      },
    ),
  );
}

/// Register all default section widget builders.
///
/// Call this once in `main()` before `runApp(...)`.
void registerDefaultWidgets() {
  final r = WidgetRegistry();

  // ─── 0. Search Bar ──────────────────────────────────────────────
  r.register('search', (json) {
    return Padding(
      padding: pageSurroundingPadding,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => Get.toNamed(Routes.SEARCH),
        child: AbsorbPointer(
          child: SearchBarRounded(
            onChanged: (_) {},
            searchHintText: json?['placeholder'] ?? 'Search...',
            SearchsController: SearchController(),
          ),
        ),
      ),
    );
  });

  // ─── 1. Unified Slider & Banner Dispatchers ─────────────────────
  r.register('slider', _buildSliderOrBanner);
  r.register('banner', _buildSliderOrBanner);
  r.register('category_banners', _buildSliderOrBanner);
  r.register('promo_strip', _buildSliderOrBanner);

  // ─── 2. Trust Badges / Value Strip ─────────────────────────────
  r.register('trust_badges', (json) {
    return Obx(() {
      final ctrl = _homepageController;
      final badgesData = ctrl != null
          ? ctrl.trustBadges.value
          : (json != null
              ? HomeTrustBadgesData.fromSections([
                  {'type': 'trust_badges', 'content_json': json}
                ])
              : HomeTrustBadgesData.fallback());
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: FeatureStrip(data: badgesData),
      );
    });
  });

  // ─── 3. Top Categories of The Month ────────────────────────────
  r.register('categories', (json) {
    return Obx(() {
      final ctrl = _homepageController;
      final title = ctrl != null
          ? ctrl.topCategories.value.heading
          : (json?['title'] ?? json?['heading'] ?? 'Top Categories of The Month');
      final isLoading = ctrl?.isLoading.value ?? false;
      final catList = ctrl?.productCategoryList.toList() ?? [];
      return CategoryHome(
        title: title,
        itemLimit: 10,
        isLoading: isLoading,
        productCategoryList: catList,
      );
    });
  });

  // ─── 4. Special Offers Section (Countdown + Products Rail) ──────
  Widget buildSpecialOffers(Map<String, dynamic>? json) {
    return Obx(() {
      final ctrl = _homepageController;
      final offersData = ctrl != null
          ? ctrl.specialOffersSection.value
          : (json != null
              ? HomeSpecialOffersData.fromSections([
                  {'type': 'special_offers', 'content_json': json}
                ])
              : HomeSpecialOffersData.fallback());
      return SpecialOffersSection(data: offersData);
    });
  }

  r.register('special_offers', buildSpecialOffers);
  r.register('countdown', buildSpecialOffers);

  // ─── 5. Best Seller Products Section ────────────────────────────
  r.register('best_sellers', (json) {
    return Obx(() {
      final ctrl = _homepageController;
      final bestSellersData = ctrl != null
          ? ctrl.bestSellersSection.value
          : HomeBestSellersData.fallback();
      final bannerItem = ctrl?.banners.value.fiberOpticAccessories ??
          HomeBannersData.fallback().fiberOpticAccessories;
      return BestSellerSection(
        data: bestSellersData,
        bannerItem: bannerItem, // Positioned between Heading and Products Rail
      );
    });
  });

  // ─── 6. Latest Products Section ─────────────────────────────────
  r.register('latest_products', (json) {
    return Obx(() {
      final ctrl = _homepageController;
      final latestProductsData = ctrl != null
          ? ctrl.latestProductsSection.value
          : HomeLatestProductsData.fallback();
      return LatestProductsSection(data: latestProductsData);
    });
  });

  // ─── 7. General Products Dispatcher ───────────────────────────
  r.register('products', (json) {
    final heading = (json?['heading'] ?? json?['title'] ?? '').toString().toLowerCase();
    final catType = (json?['category_type'] ?? '').toString().toLowerCase();
    final slug = (json?['slug'] ?? json?['id'] ?? '').toString().toLowerCase();

    if (heading.contains('latest') || catType.contains('recently_created') || slug.contains('latest')) {
      return Obx(() {
        final ctrl = _homepageController;
        final latestData = ctrl?.latestProductsSection.value ?? HomeLatestProductsData.fallback();
        return LatestProductsSection(data: latestData);
      });
    }

    if (heading.contains('best seller') ||
        catType.contains('best_seller') ||
        slug.contains('best') ||
        json?['list_view_type'] == 'horizontal') {
      return Obx(() {
        final ctrl = _homepageController;
        final bestData = ctrl?.bestSellersSection.value ?? HomeBestSellersData.fallback();
        final bannerItem = ctrl?.banners.value.fiberOpticAccessories ??
            HomeBannersData.fallback().fiberOpticAccessories;
        return BestSellerSection(
          data: bestData,
          bannerItem: bannerItem, // Positioned between Heading and Products Rail
        );
      });
    }

    if (heading.contains('special') || heading.contains('offer') || slug.contains('special')) {
      return Obx(() {
        final ctrl = _homepageController;
        final offersData = ctrl?.specialOffersSection.value ?? HomeSpecialOffersData.fallback();
        return SpecialOffersSection(data: offersData);
      });
    }

    return TrendingProductSection(contentJson: json);
  });

  // ─── 8. Blog Section ───────────────────────────────────────────
  r.register('blog', (json) {
    return BlogSection(blogData: json);
  });

  // ─── 9. Price Filter ───────────────────────────────────────────
  r.register('price_filter', (json) {
    return PriceFilter(contentJson: json ?? {});
  });

  // ─── 10. Common Layout & Formatting Blocks ─────────────────────
  r.register('spacer', (json) {
    return SpacerComponent(contentJson: json ?? {});
  });

  r.register('divider', (json) {
    return DividerComponent(contentJson: json ?? {});
  });

  r.register('text_block', (json) {
    final text = (json?['text'] ?? json?['content'] ?? json?['title'] ?? '').toString().toLowerCase();
    if (text.contains('best seller')) {
      return const SizedBox.shrink(); // BestSellerSection already has its branded _SectionTitle
    }
    return TextBlockComponent(contentJson: json ?? {});
  });

  r.register('rich_text', (json) {
    final html = (json?['html_content'] ?? json?['content'] ?? '').toString().toLowerCase();
    final heading = (json?['heading'] ?? json?['title'] ?? '').toString().toLowerCase();
    if (html.contains('best seller') || heading.contains('best seller')) {
      return const SizedBox.shrink(); // BestSellerSection already has its branded _SectionTitle
    }
    return RichTextComponent(contentJson: json ?? {});
  });
}
