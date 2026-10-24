import 'package:flutter/material.dart';
import 'package:zouhi/components/search_bar_rounded.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/home_component/home_products.dart';
import 'package:zouhi/components/home_component/home_rich_text_component.dart';
import 'package:zouhi/components/home_component/home_slider.dart';
import 'package:zouhi/components/home_component/home_trust_badges.dart';
import 'package:zouhi/components/home_component/home_banner.dart';
import 'package:zouhi/components/home_component/home_blogs.dart';
import 'package:zouhi/components/home_component/home_category.dart';
import 'package:zouhi/components/home_component/home_common_widgets.dart';
import 'package:zouhi/components/home_component/home_price_filter.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:get/get.dart';

import 'widget_registry.dart';

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
      return HomeBanner(bannerData: json);
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
    return const Text('Count down timeer maintendedddd ');
  });

  // r.register('icon_button', (json) {
  //   return IconButtonComponent(contentJson: json ?? {});
  // });

  // ─── Trust Badges / Testimonials ────────────────────────────
  r.register('trust_badges', (json) {
    return TrustBadgesComponent(contentJson: json ?? {});
  });
}
