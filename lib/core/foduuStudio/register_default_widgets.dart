import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/components/home_component/hero_flash_deal_banner.dart';
import 'package:foduu_ecommerce/components/home_component/flash_sale_countdown_card.dart';
import 'package:foduu_ecommerce/components/home_component/smart_assistant_showcase_card.dart';
import 'package:foduu_ecommerce/components/home_component/icon_button_section.dart';
import 'package:foduu_ecommerce/components/search_bar_rounded.dart';
import '/app/routes/app_pages.dart';
import '/components/home_component/home_products.dart';
import '/components/home_component/home_rich_text_component.dart';
import '/components/home_component/home_slider.dart';
import '/components/home_component/home_trust_badges.dart';
import '/components/home_component/home_banner.dart';
import '/components/home_component/home_blogs.dart';
import '/components/home_component/home_category.dart';
import '/components/home_component/home_common_widgets.dart';
import '/components/home_component/home_price_filter.dart';
import '/constants/constants.dart';
import 'package:get/get.dart';

import 'widget_registry.dart';

/// Checks for Component 1 (Parent Website Hero Sidebar: iPhone 15 Pro, Image 3)
bool _isFlashSaleSlider(Map? json) {
  if (json == null) return false;
  final slider = json['slider'];
  if (slider is Map) {
    final slug =
        (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();
    if (slug == 'home-side-slider' || slug.contains('side-slider')) {
      return true;
    }
    final content = slider['content'];
    if (content is List && content.isNotEmpty && content.first is Map) {
      final first = content.first as Map;
      final heading = (first['heading'] ?? '').toString().toLowerCase();
      final sub = (first['sub_heading'] ?? '').toString().toLowerCase();
      final desc = (first['description'] ?? '').toString().toLowerCase();

      if (sub.contains('iphone') ||
          heading.contains('iphone') ||
          desc.contains('today only') ||
          desc.contains('2199') ||
          desc.contains('20% off') ||
          (heading.contains('flash sale') && !desc.contains('smart gadgets'))) {
        return true;
      }
    }
  }
  return false;
}

/// Checks for Component 2 (Parent Website Lower Banner: Smartwatch 30% OFF, Image 4)
bool _isSmartwatchDealBanner(Map? json) {
  if (json == null) return false;
  final slider = json['slider'];
  if (slider is Map) {
    final slug =
        (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();
    // Exclude the hero side slider
    if (slug == 'home-side-slider' || slug.contains('side-slider')) {
      return false;
    }

    final content = slider['content'];
    if (content is List && content.isNotEmpty && content.first is Map) {
      final first = content.first as Map;
      final heading = (first['heading'] ?? '').toString().toLowerCase();
      final sub = (first['sub_heading'] ?? '').toString().toLowerCase();
      final desc = (first['description'] ?? '').toString().toLowerCase();

      if (heading.contains('30%') ||
          desc.contains('30%') ||
          heading.contains('smart gadgets') ||
          desc.contains('smart gadgets') ||
          sub.contains('smart gadgets') ||
          (heading.contains('limited time offer') && !sub.contains('iphone')) ||
          slug.contains('watch') ||
          slug.contains('smartwatch')) {
        return true;
      }
    }
  }
  return false;
}

bool _isShowcaseSlider(Map? json) {
  if (json == null) return false;
  final slider = json['slider'];
  if (slider is Map) {
    final slug = (slider['slug'] ?? slider['name'] ?? '').toString();
    if (slug == 'home-second-slider') return true;
    final content = slider['content'];
    if (content is List && content.isNotEmpty && content.first is Map) {
      final sub = (content.first['sub_heading'] ?? '').toString();
      final heading = (content.first['heading'] ?? '').toString();
      final desc = (content.first['description'] ?? '').toString();
      if (sub.contains('Smart Home Assistant') ||
          heading.contains('Smart Ecosystem') ||
          desc.contains('smart home integration')) {
        return true;
      }
    }
  }
  return false;
}

/// Register all default section widget builders.
///
/// Call this once in `main()` before `runApp(...)`.

void registerDefaultWidgets() {
  final r = WidgetRegistry();

  // ─── Search Bar ──────────────────────────────────────────────
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

  // ─── Slider / Carousel ──────────────────────────────────────
  r.register('slider', (json) {
    if (json is Map<String, dynamic>) {
      // 1. Image 3: Hero Sidebar Flash Sale Card (iPhone 15 Pro)
      if (_isFlashSaleSlider(json)) {
        return FlashSaleCountdownCard(sliderData: json);
      }
      // 2. Image 4: Lower Smartwatch 30% OFF Deal Banner
      if (_isSmartwatchDealBanner(json)) {
        return HeroFlashDealBanner(sliderData: json);
      }
      // 3. Smart Assistant Showcase
      if (_isShowcaseSlider(json)) {
        return SmartAssistantShowcaseCard(sliderData: json);
      }
    }
    // 4. Image 3 Left: Main Hero Carousel (Headphones / Audio)
    return FoduuSlider(sliderData: json ?? {});
  });

  // ─── Categories ─────────────────────────────────────────────
  r.register('categories', (json) {
    return CategoryHome(categoryData: json ?? {});
  });

  // ─── Blog Section ───────────────────────────────────────────
  r.register('blog', (json) {
    return BlogSection(blogData: json);
  });

  // ─── Banner ─────────────────────────────────────────────────
  r.register('banner', (json) {
    if (json != null) {
      return HomeBanner(bannerContent: json);
    }
    return const SizedBox.shrink();
  });

  // ─── Price Filter ───────────────────────────────────────────
  r.register('price_filter', (json) {
    return PriceFilter(contentJson: json ?? {});
  });

  // ─── Spacer ─────────────────────────────────────────────────
  r.register('spacer', (json) {
    return SpacerComponent(contentJson: json ?? {});
  });

  // ─── Divider ────────────────────────────────────────────────
  r.register('divider', (json) {
    return DividerComponent(contentJson: json ?? {});
  });

  // ─── Text Block ─────────────────────────────────────────────
  r.register('text_block', (json) {
    return TextBlockComponent(contentJson: json ?? {});
  });

  // ─── Products ───────────────────────────────────────────────
  r.register('products', (json) {
    return TrendingProductSection(contentJson: json);
  });

  // ─── Rich Text ──────────────────────────────────────────────
  r.register('rich_text', (json) {
    return RichTextComponent(contentJson: json ?? {});
  });

  r.register('countdown', (json) {
    return FlashSaleCountdownCard(sliderData: json is Map<String, dynamic> ? json : {});
  });

  // r.register('icon_button', (json) {
  //   return IconButtonComponent(contentJson: json ?? {});
  // });

  // ─── Trust Badges / Testimonials ────────────────────────────
  r.register('trust_badges', (json) {
    return TrustBadgesComponent(contentJson: json ?? {});
  });
}
