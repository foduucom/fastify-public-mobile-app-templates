import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/components/home_component/icon_button_section.dart';
import 'package:foduu_ecommerce/components/search_bar_rounded.dart';
import '/app/routes/app_pages.dart';
import '/components/home_component/home_products.dart';
import '/components/home_component/home_rich_text_component.dart';
import '/components/home_component/home_slider.dart';
import '/components/home_component/home_banner.dart';
import '/components/home_component/home_blogs.dart';
import '/components/home_component/home_category.dart';
import '/components/home_component/home_common_widgets.dart';
import '/components/home_component/home_price_filter.dart';
import '/constants/constants.dart';
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
    return Text('Count down timeer maintendedddd ');
  });

  // r.register('icon_button', (json) {
  //   return IconButtonComponent(contentJson: json ?? {});
  // });
}
