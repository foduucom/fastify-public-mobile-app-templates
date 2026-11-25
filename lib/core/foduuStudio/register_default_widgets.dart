import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/data/models/contact_sections.dart';
import 'package:foduu_ecommerce/app/modules/contact/controller/contact_controller.dart';
import 'package:foduu_ecommerce/components/about_components/about_widgets.dart';
import 'package:foduu_ecommerce/components/blog_components/blog_feed_section.dart';
import 'package:foduu_ecommerce/components/blog_components/blog_hero_card.dart';
import 'package:foduu_ecommerce/components/blog_components/blog_search_bar.dart';
import 'package:foduu_ecommerce/components/contact_component/contact_widgets.dart';
import 'package:foduu_ecommerce/components/faq_components/faq_accordion_section.dart';
import 'package:foduu_ecommerce/components/faq_components/faq_hero_card.dart';
import 'package:foduu_ecommerce/components/faq_components/faq_search_bar.dart';
import 'package:foduu_ecommerce/components/faq_components/faq_still_stuck_card.dart';
import 'package:foduu_ecommerce/components/faq_components/faq_topic_badges.dart';
import 'package:foduu_ecommerce/components/home_component/hero_flash_deal_banner.dart';
import 'package:foduu_ecommerce/components/home_component/flash_sale_countdown_card.dart';
import 'package:foduu_ecommerce/components/home_component/smart_assistant_showcase_card.dart';
import 'package:foduu_ecommerce/components/search_bar_rounded.dart';
import 'package:url_launcher/url_launcher.dart';
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

bool _isFaqHeroSlider(Map? json) {
  if (json == null) return false;
  final slider = json['slider'];
  if (slider is Map) {
    final slug =
        (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();
    if (slug == 'faq' || slug == 'faq-slider' || slug.contains('faq-hero')) {
      return true;
    }
    final content = slider['content'];
    if (content is List && content.isNotEmpty && content.first is Map) {
      final first = content.first as Map;
      final heading = (first['heading'] ?? '').toString().toLowerCase();
      final sub = (first['sub_heading'] ?? '').toString().toLowerCase();
      if ((heading == 'faq' || sub.contains('help you today')) &&
          !heading.contains('stuck')) {
        return true;
      }
    }
  }
  return false;
}

bool _isFaqStillStuckSlider(Map? json) {
  if (json == null) return false;
  final slider = json['slider'];
  if (slider is Map) {
    final slug =
        (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();
    if (slug == 'faq-center-slider' || slug.contains('stuck')) {
      return true;
    }
    final content = slider['content'];
    if (content is List && content.isNotEmpty && content.first is Map) {
      final first = content.first as Map;
      final heading = (first['heading'] ?? '').toString().toLowerCase();
      if (heading.contains('stuck') || heading.contains('can’t find')) {
        return true;
      }
    }
  }
  return false;
}

bool _isFaqAccordion(Map? json) {
  if (json == null) return false;
  final cols = int.tryParse((json['no_of_columns'] ?? '').toString()) ?? 0;
  final eyebrow = (json['eyebrow'] ?? '').toString().toLowerCase();
  final title = (json['title'] ?? '').toString().toLowerCase();
  final cards = json['cards'] ?? json['items'];

  if (cols == 1 ||
      eyebrow.contains('categor') ||
      title.contains('account') ||
      title.contains('faq')) {
    if (cards is List && cards.isNotEmpty) {
      final first = cards.first;
      if (first is Map) {
        final heading = (first['heading'] ?? '').toString();
        final text = (first['text'] ?? '').toString();
        if (heading.contains('?') || (text.length > 50 && first['image'] == null)) {
          return true;
        }
      }
    }
  }
  return false;
}

bool _isFaqTopicBadges(Map? json) {
  if (json == null) return false;
  final cards = json['cards'] ?? json['items'];
  if (cards is List && cards.isNotEmpty) {
    final hasArticles = cards.any((c) =>
        c is Map &&
        (c['text'] ?? '').toString().toLowerCase().contains('article'));
    if (hasArticles) return true;
  }
  return false;
}

bool _isContactHeroSlider(Map? json) {
  if (json == null) return false;
  final slider = json['slider'];
  if (slider is Map) {
    final slug =
        (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();
    if (slug == 'contact-us-slider' ||
        slug == 'contact-us' ||
        slug.contains('contact-us')) {
      return true;
    }
    final content = slider['content'];
    if (content is List && content.isNotEmpty && content.first is Map) {
      final first = content.first as Map;
      final heading = (first['heading'] ?? '').toString().toLowerCase();
      final sub = (first['sub_heading'] ?? '').toString().toLowerCase();
      if (heading == 'contact us' || sub.contains('get in touch')) {
        return true;
      }
    }
  }
  return false;
}

bool _isContactChannels(Map? json) {
  if (json == null) return false;
  final title = (json['title'] ?? '').toString().toLowerCase();
  if (title.contains('contact channel') || title.contains('channels')) {
    return true;
  }
  return false;
}

bool _isContactFaqAccordion(Map? json) {
  if (json == null) return false;
  final title = (json['title'] ?? '').toString().toLowerCase();
  final eyebrow = (json['eyebrow'] ?? '').toString().toLowerCase();
  return (title.contains('account') ||
          title.contains('access') ||
          eyebrow.contains('categories')) &&
      Get.isRegistered<ContactController>();
}

void _handleContactCardTap(ContactChannelCard card) async {
  if (card.isEmail) {
    final email = card.text.trim();
    if (email.isNotEmpty) {
      try {
        await launchUrl(Uri(scheme: 'mailto', path: email),
            mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  } else if (card.isPhone) {
    final phone = card.cleanPhone;
    if (phone.isNotEmpty) {
      try {
        await launchUrl(Uri(scheme: 'tel', path: phone),
            mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }
}

bool _isBlogHeroSlider(Map? json) {
  if (json == null) return false;
  final slider = json['slider'];
  if (slider is Map) {
    final slug =
        (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();
    if (slug == 'blog-slider' || slug == 'blog' || slug.contains('blog-hero')) {
      return true;
    }
    final content = slider['content'];
    if (content is List && content.isNotEmpty && content.first is Map) {
      final first = content.first as Map;
      final heading = (first['heading'] ?? '').toString().toLowerCase();
      final sub = (first['sub_heading'] ?? '').toString().toLowerCase();
      if (heading == 'blog' || sub.contains('stories powered by tech')) {
        return true;
      }
    }
  }
  return false;
}

bool _isBlogSearchBar(Map? json) {
  if (json == null) return false;
  final name = (json['name'] ?? '').toString().toLowerCase();
  final placeholder = (json['placeholder'] ?? '').toString().toLowerCase();
  if (name == 'search' &&
      (placeholder.contains('articles') ||
          placeholder.contains('guides') ||
          placeholder.contains('reviews'))) {
    return true;
  }
  return false;
}

bool _isBlogCategorySection(Map? json) {
  if (json == null) return false;
  final blogType = json['blog_type']?.toString();
  if (blogType == 'blog_category') return true;
  final categoryIds = json['category_ids'];
  if (categoryIds is List && categoryIds.isNotEmpty) return true;
  return false;
}

bool _isAboutHeroSlider(Map? json) {
  if (json == null) return false;
  final slider = json['slider'];
  if (slider is Map) {
    final slug =
        (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();
    if (slug == 'about-us' || slug == 'about-us-slider') return true;
    final content = slider['content'];
    if (content is List && content.isNotEmpty && content.first is Map) {
      final first = content.first as Map;
      final heading = (first['heading'] ?? '').toString().toLowerCase();
      final sub = (first['sub_heading'] ?? '').toString().toLowerCase();
      if (heading == 'about us' || sub.contains('upgrade your world')) return true;
    }
  }
  return false;
}

bool _isAboutStorySlider(Map? json) {
  if (json == null) return false;
  final slider = json['slider'];
  if (slider is Map) {
    final slug =
        (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();
    if (slug == 'who-we-are' || slug == 'about-us-second') return true;
    final content = slider['content'];
    if (content is List && content.isNotEmpty && content.first is Map) {
      final first = content.first as Map;
      final heading = (first['heading'] ?? '').toString().toLowerCase();
      final sub = (first['sub_heading'] ?? '').toString().toLowerCase();
      if (heading == 'who we are' || sub.contains('home sound')) return true;
    }
  }
  return false;
}

bool _isAboutBrandsSlider(Map? json) {
  if (json == null) return false;
  final slider = json['slider'];
  if (slider is Map) {
    final slug =
        (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();
    if (slug == 'brand_slider' || slug == 'about-brands') return true;
    final content = slider['content'];
    if (content is List && content.isNotEmpty && content.first is Map) {
      final first = content.first as Map;
      final heading = (first['heading'] ?? '').toString().toLowerCase();
      if (heading.contains('400 brands') || heading.contains('assortment')) {
        return true;
      }
    }
  }
  return false;
}

bool _isAboutBottomCtaSlider(Map? json) {
  if (json == null) return false;
  final slider = json['slider'];
  if (slider is Map) {
    final slug =
        (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();
    if (slug.contains('fourth-bottom') ||
        slug.contains('coa') ||
        slug.contains('bottom-cta')) {
      return true;
    }
    final content = slider['content'];
    if (content is List && content.isNotEmpty && content.first is Map) {
      final first = content.first as Map;
      final sub = (first['sub_heading'] ?? '').toString().toLowerCase();
      if (sub.contains('redefine your acoustics') ||
          sub.contains('elevate your soundscape')) {
        return true;
      }
    }
  }
  return false;
}

bool _isAboutStats(Map? json) {
  if (json == null) return false;
  final eyebrow = (json['eyebrow'] ?? '').toString().toLowerCase();
  final title = (json['title'] ?? '').toString().toLowerCase();
  if (eyebrow.contains('footprint') || title.contains('footprint')) return true;
  final cards = json['cards'] ?? json['items'];
  if (cards is List && cards.isNotEmpty) {
    final has120k = cards
        .any((c) => c is Map && (c['heading'] ?? '').toString().contains('120k'));
    if (has120k) return true;
  }
  return false;
}

bool _isAboutPhilosophy(Map? json) {
  if (json == null) return false;
  final eyebrow = (json['eyebrow'] ?? '').toString().toLowerCase();
  final title = (json['title'] ?? '').toString().toLowerCase();
  if (eyebrow.contains('philosophy') || title.contains('guiding principles')) {
    return true;
  }
  final cards = json['cards'] ?? json['items'];
  if (cards is List && cards.isNotEmpty) {
    final hasPurity = cards.any((c) =>
        c is Map &&
        (c['title'] ?? c['heading'] ?? '')
            .toString()
            .toLowerCase()
            .contains('acoustic purity'));
    if (hasPurity) return true;
  }
  return false;
}

bool _isAboutWhyChoose(Map? json) {
  if (json == null) return false;
  final eyebrow = (json['eyebrow'] ?? '').toString().toLowerCase();
  final title = (json['title'] ?? '').toString().toLowerCase();
  if (eyebrow.contains('why choose') || title.contains('sound you can rely on')) {
    return true;
  }
  final cards = json['cards'] ?? json['items'];
  if (cards is List && cards.isNotEmpty) {
    final hasRapid = cards.any((c) =>
        c is Map &&
        (c['title'] ?? c['heading'] ?? '')
            .toString()
            .toLowerCase()
            .contains('rapid delivery'));
    if (hasRapid) return true;
  }
  return false;
}

bool _isAboutConsultationBanner(Map? json) {
  if (json == null) return false;
  final heading = (json['heading'] ?? '').toString().toLowerCase();
  final sub = (json['sub_heading'] ?? '').toString().toLowerCase();
  final slug = (json['slug'] ?? '').toString().toLowerCase();
  if (slug == 'consultation' ||
      heading.contains('assistance') ||
      heading.contains('consultation') ||
      sub.contains('consultation')) {
    return true;
  }
  return false;
}

bool _isAboutBottomCtaBanner(Map? json) {
  if (json == null) return false;
  final heading = (json['heading'] ?? '').toString().toLowerCase();
  final sub = (json['sub_heading'] ?? '').toString().toLowerCase();
  final slug = (json['slug'] ?? '').toString().toLowerCase();
  if (slug == 'bottom-cta' ||
      heading.contains('soundscape') ||
      sub.contains('soundscape') ||
      heading.contains('redefine your acoustics')) {
    return true;
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
    final name = (json?['name'] ?? '').toString().toLowerCase();
    if (name == 'faq-search' || name.contains('faq')) {
      return FaqSearchBar.fromMap(json);
    }
    if (_isBlogSearchBar(json)) {
      return BlogSearchBar.fromMap(json);
    }
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
      // About Us Hero Header
      if (_isAboutHeroSlider(json)) {
        return AboutHeroBannerWidget.fromMap(json);
      }
      // About Us K7 Audio Engineering Story Card
      if (_isAboutStorySlider(json)) {
        return AboutStorySectionWidget.fromMap(json);
      }
      // About Us Brands Showcase Grid
      if (_isAboutBrandsSlider(json)) {
        return AboutBrandsSectionWidget.fromMap(json);
      }
      // About Us Bottom CTA
      if (_isAboutBottomCtaSlider(json)) {
        return AboutBottomCtaWidget.fromMap(json);
      }
      // Blog Hero Header
      if (_isBlogHeroSlider(json)) {
        return BlogHeroCard.fromMap(json);
      }
      // Contact Us Hero Header
      if (_isContactHeroSlider(json)) {
        return ContactHeroBannerWidget(
            data: ContactHeroHeaderData.fromContentJson(json));
      }
      // FAQ Hero Header
      if (_isFaqHeroSlider(json)) {
        return FaqHeroCard.fromMap(json);
      }
      // FAQ Still Stuck Support CTA Card
      if (_isFaqStillStuckSlider(json)) {
        return FaqStillStuckCard.fromMap(json);
      }
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
    if (json is Map<String, dynamic>) {
      final parentType = json['parent_type']?.toString().toLowerCase();
      final title = (json['title'] ?? '').toString().toLowerCase();
      // If categories section on About Us (title Shop By Category)
      if (title.contains('shop by category') || parentType == 'product') {
        return AboutCategoriesRailWidget.fromMap(json);
      }
    }
    return CategoryHome(categoryData: json ?? {});
  });

  // ─── Blog Section ───────────────────────────────────────────
  r.register('blog', (json) {
    if (json is Map<String, dynamic> && _isBlogCategorySection(json)) {
      return BlogFeedSection.fromMap(json);
    }
    return BlogSection(blogData: json);
  });

  // ─── Banner ─────────────────────────────────────────────────
  r.register('banner', (json) {
    if (json != null) {
      if (json is Map<String, dynamic>) {
        if (_isAboutConsultationBanner(json)) {
          return AboutConsultationSectionWidget.fromMap(json);
        }
        if (_isAboutBottomCtaBanner(json)) {
          return AboutBottomCtaWidget.fromMap(json);
        }
      }
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

  // ─── Trust Badges / Testimonials ────────────────────────────
  r.register('trust_badges', (json) {
    if (json is Map<String, dynamic>) {
      if (_isContactChannels(json)) {
        return ContactChannelsWidget(
          data: ContactChannelsData.fromContentJson(json),
          onCardTap: _handleContactCardTap,
        );
      }
      if (_isContactFaqAccordion(json)) {
        return ContactFaqAccordionWidget(
          data: ContactFaqSectionData.fromContentJson(json),
        );
      }
      if (_isFaqAccordion(json)) {
        return FaqAccordionSection.fromMap(json);
      }
      if (_isFaqTopicBadges(json)) {
        return FaqTopicBadges.fromMap(json);
      }
      // About Us Stats Grid
      if (_isAboutStats(json)) {
        return AboutStatsSectionWidget.fromMap(json);
      }
      // About Us Philosophy
      if (_isAboutPhilosophy(json)) {
        return AboutPhilosophySectionWidget.fromMap(json);
      }
      // About Us Why Choose Us
      if (_isAboutWhyChoose(json)) {
        return AboutWhyChooseWidget.fromMap(json);
      }
    }
    return TrustBadgesComponent(contentJson: json ?? {});
  });

  // ─── Team Members ───────────────────────────────────────────
  r.register('team_members', (json) {
    if (json is Map<String, dynamic>) {
      return AboutTeamSectionWidget.fromMap(json);
    }
    return const SizedBox.shrink();
  });

  // ─── FAQ ────────────────────────────────────────────────────
  r.register('faq', (json) {
    if (json is Map<String, dynamic>) {
      final items = json['items'] ??
          (json['content_json'] is Map ? json['content_json']['items'] : null);
      if (items is List &&
          items.isNotEmpty &&
          items.first is Map &&
          (items.first['question'] != null || items.first['answer'] != null)) {
        return AboutFaqSectionWidget.fromMap(json);
      }
      return FaqAccordionSection.fromMap(json);
    }
    return const SizedBox.shrink();
  });

  // ─── Form Builder ───────────────────────────────────────────
  Widget buildFormBuilder(dynamic json) {
    final contentJson = json is Map<String, dynamic>
        ? json
        : (json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{});
    final formData = ContactFormBuilderData.fromContentJson(contentJson);
    return ContactFormCardWidget(data: formData);
  }

  r.register('formbuilder', buildFormBuilder);
  r.register('form_builder', buildFormBuilder);
}
