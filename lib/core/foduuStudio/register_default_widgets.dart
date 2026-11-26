import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/data/models/home_sections.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/about_components/about_widgets.dart';
import 'package:zouhi/components/cable_assemblies_components/cable_assemblies_widgets.dart';
import 'package:zouhi/components/contact_component/contact_widgets.dart';
import 'package:zouhi/components/home_component/category_home.dart';
import 'package:zouhi/components/home_component/home_blogs.dart';
import 'package:zouhi/components/home_component/home_common_widgets.dart';
import 'package:zouhi/components/home_component/home_price_filter.dart';
import 'package:zouhi/components/home_component/home_products.dart';
import 'package:zouhi/components/home_component/home_rich_text_component.dart';
import 'package:zouhi/components/home_component/parent_sections.dart';
import 'package:zouhi/components/home_component/vision_hero_slider.dart';
import 'package:zouhi/components/mtp_solution_components/mtp_solution_widgets.dart';
import 'package:zouhi/components/policy_components/policy_widgets.dart';
import 'package:zouhi/components/search_bar_rounded.dart';
import 'package:zouhi/components/solutions_components/solutions_widgets.dart';
import 'package:zouhi/constants/constants.dart';

import 'widget_registry.dart';

HomepageController? get _homepageController =>
    Get.isRegistered<HomepageController>() ? Get.find<HomepageController>() : null;

String _pageSlug(Map<String, dynamic>? json) =>
    (json?['_page_slug'] ?? '').toString().toLowerCase();

String _sectionSlug(Map<String, dynamic>? json) {
  if (json == null) return '';
  final sliderObj = json['slider'] is Map ? json['slider'] as Map : json;
  return (sliderObj['slug'] ??
          sliderObj['name'] ??
          json['slug'] ??
          json['id'] ??
          json['name'] ??
          '')
      .toString()
      .toLowerCase();
}

String _formSlug(Map<String, dynamic>? json) {
  if (json == null) return '';
  final formIdObj = json['form_id'];
  if (formIdObj is Map && formIdObj['slug'] != null) {
    return formIdObj['slug'].toString().toLowerCase();
  }
  return (json['form_slug'] ?? json['slug'] ?? json['id'] ?? '')
      .toString()
      .toLowerCase();
}

/// Intelligent Slider & Banner Dispatcher:
/// In Fastify Studio CMS, multiple banners are sent as type `slider` or `banner`.
/// This dispatcher inspects page context (`_page_slug`), slug, and metadata
/// to render the exact approved widget with zero visual regression.
Widget _buildSliderOrBanner(Map<String, dynamic>? json) {
  if (json == null) return const SizedBox.shrink();

  final page = _pageSlug(json);
  final slug = _sectionSlug(json);
  final sectionType = (json['_section_type'] ?? '').toString().toLowerCase();
  final sliderObj = json['slider'] is Map ? json['slider'] as Map : json;
  final contentList = sliderObj['content'] is List && (sliderObj['content'] as List).isNotEmpty
      ? (sliderObj['content'] as List)
      : (json['content'] is List && (json['content'] as List).isNotEmpty
          ? (json['content'] as List)
          : []);

  // ── Page-Scoped Module Dispatchers ───────────────────────────────
  // 1. About Us
  if (page == 'about-us' ||
      slug.contains('about-us-slider') ||
      slug.contains('about-us-main-banner') ||
      slug == 'about-us-header' ||
      slug == 'about-us-story') {
    if (slug.contains('main-banner') ||
        slug.contains('story') ||
        slug == 'about-us-story') {
      return AboutStorySectionWidget.fromContentJson(json);
    }
    if (slug.contains('about-us-slider') ||
        slug == 'about-us-header' ||
        slug == 'about-us') {
      return AboutHeroBannerWidget.fromContentJson(json);
    }
  }

  // 2. Solutions
  if (page == 'solution' ||
      page == 'solutions' ||
      slug.startsWith('solutions-')) {
    if (sectionType == 'banner' || slug == 'solutions-header') {
      return SolutionsHeaderWidget.fromContentJson(json);
    }
    if (slug.contains('main') || slug.contains('intro')) {
      return SolutionsIntroWidget.fromContentJson(json);
    }
    if (slug.contains('cta') || slug.contains('consultation')) {
      return SolutionsCtaWidget.fromContentJson(json);
    }
    // Disambiguate by first slide heading
    if (contentList.isNotEmpty && contentList.first is Map) {
      final heading = (contentList.first['heading'] ?? '').toString();
      if (heading.contains('What We Deliver') ||
          heading.contains('Industries Served')) {
        return SolutionsIntroWidget.fromContentJson(json);
      }
    }
    return SolutionsCtaWidget.fromContentJson(json);
  }

  // 3. Contact Us
  if (page == 'contact-us' ||
      page == 'contact' ||
      slug.contains('contact-us-slider') ||
      slug == 'contact-hero' ||
      slug == 'contact-promo-banner') {
    if (sectionType == 'banner' || slug.contains('promo')) {
      return ContactIllustrationBannerWidget.fromContentJson(json);
    }
    return ContactHeroBannerWidget.fromContentJson(json);
  }

  // 4. Cable Assemblies
  if (page == 'cable-assemblies' || slug == 'cable-assemblies-banner') {
    return CableSchematicBannerWidget.fromContentJson(json);
  }

  // 5. MTP Solution
  if (page == 'mtp-solution' || slug == 'mtp-solution-banner') {
    return MtpSchematicBannerWidget.fromContentJson(json);
  }

  // ── Home Page Dispatchers (Golden Standard) ──────────────────────
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
  r.register('header', (json) {
    if (_pageSlug(json) == 'about-us') {
      return AboutHeroBannerWidget.fromContentJson(json ?? {});
    }
    return _buildSliderOrBanner(json);
  });
  r.register('category_banners', _buildSliderOrBanner);
  r.register('promo_strip', _buildSliderOrBanner);

  // ─── 2. Trust Badges / Value Strip / Module Cards ───────────────
  r.register('trust_badges', (json) {
    final map = json ?? <String, dynamic>{};
    final page = _pageSlug(map);
    final id = (map['id'] ?? '').toString().toLowerCase();
    final eyebrow = (map['eyebrow'] ?? '').toString().toLowerCase();
    final title = (map['title'] ?? '').toString().toLowerCase();

    // About Us
    if (page == 'about-us' ||
        id == 'why_choose' ||
        id == 'our_process' ||
        eyebrow.contains('why choose') ||
        title.contains('why choose')) {
      if (id == 'our_process' ||
          eyebrow.contains('how we work') ||
          title.contains('our process')) {
        return AboutProcessSectionWidget.fromContentJson(map);
      }
      return AboutWhyChooseWidget.fromContentJson(map);
    }

    // Solutions
    if (page == 'solution' ||
        page == 'solutions' ||
        id.startsWith('solutions-')) {
      if (id == 'solutions-by-industry' ||
          eyebrow.contains('industry') ||
          title.contains('environment')) {
        return SolutionsIndustryGridWidget.fromContentJson(map);
      }
      return SolutionsCapabilitiesWidget.fromContentJson(map);
    }

    // Contact Us
    if (page == 'contact-us' ||
        page == 'contact' ||
        id == 'contact-info-badges' ||
        title.contains('contact information')) {
      return ContactInfoBadgesWidget.fromContentJson(map);
    }

    // Home Page Default
    return Obx(() {
      final ctrl = _homepageController;
      final badgesData = ctrl != null
          ? ctrl.trustBadges.value
          : HomeTrustBadgesData.fromSections([
              {'type': 'trust_badges', 'content_json': map}
            ]);
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: FeatureStrip(data: badgesData),
      );
    });
  });

  // ─── 2b. Testimonials (About Us) ────────────────────────────────
  r.register('testimonials', (json) {
    return AboutTestimonialsWidget.fromContentJson(json ?? {});
  });

  // ─── 2c. Dynamic FormBuilder Dispatcher (Contact, Cable, MTP) ───
  Widget buildFormBuilder(Map<String, dynamic>? json) {
    final map = json ?? <String, dynamic>{};
    final page = _pageSlug(map);
    final fSlug = _formSlug(map);

    if (page == 'cable-assemblies' || fSlug == 'cable-form') {
      return CableConfiguratorFormWidget.fromContentJson(map);
    }
    if (page == 'mtp-solution' || fSlug == 'mtp-solution') {
      return MtpConfiguratorFormWidget.fromContentJson(map);
    }
    return ContactFormCardWidget.fromContentJson(map);
  }

  r.register('formbuilder', buildFormBuilder);
  r.register('form_builder', buildFormBuilder);

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
        bannerItem: bannerItem,
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
          bannerItem: bannerItem,
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
    final map = json ?? <String, dynamic>{};
    final page = _pageSlug(map);

    if (page == 'privacy-policy' || page == 'privacy') {
      return PolicySectionWidget.fromContentJson(map, isPrivacy: true);
    }
    if (page == 'terms-and-conditions' ||
        page == 'terms-conditions' ||
        page == 'terms') {
      return PolicySectionWidget.fromContentJson(map, isPrivacy: false);
    }
    if (page == 'cable-assemblies' || page == 'mtp-solution') {
      // Inspection caption is rendered inside the schematic banner card
      return const SizedBox.shrink();
    }
    if (page == 'about-us') {
      return AboutStorySectionWidget.fromContentJson(map);
    }

    final text = (map['text'] ?? map['content'] ?? map['title'] ?? '').toString().toLowerCase();
    if (text.contains('best seller')) {
      return const SizedBox.shrink();
    }
    return TextBlockComponent(contentJson: map);
  });

  r.register('rich_text', (json) {
    final map = json ?? <String, dynamic>{};
    final page = _pageSlug(map);

    if (page == 'privacy-policy' || page == 'privacy') {
      return PolicySectionWidget.fromContentJson(map, isPrivacy: true);
    }
    if (page == 'terms-and-conditions' ||
        page == 'terms-conditions' ||
        page == 'terms') {
      return PolicySectionWidget.fromContentJson(map, isPrivacy: false);
    }
    if (page == 'cable-assemblies') {
      return CableEngineeringNotesWidget.fromContentJson(map);
    }
    if (page == 'mtp-solution') {
      return MtpEngineeringNotesWidget.fromContentJson(map);
    }

    final html = (map['html_content'] ?? map['content'] ?? '').toString().toLowerCase();
    final heading = (map['heading'] ?? map['title'] ?? '').toString().toLowerCase();
    if (html.contains('best seller') || heading.contains('best seller')) {
      return const SizedBox.shrink();
    }
    return RichTextComponent(contentJson: map);
  });
}
