import 'dart:convert';

import 'package:zouhi/constants/home_config.dart';

/// One block of the parent site's home page layout (`GET pages/home`).
class HomeComponent {
  final String type;
  final Map<String, dynamic> data;

  const HomeComponent(this.type, this.data);

  String str(String key, [String fallback = '']) {
    final v = data[key];
    if (v == null) return fallback;
    final s = v.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  int integer(String key, int fallback) =>
      int.tryParse(data[key]?.toString() ?? '') ?? fallback;

  /// Absolute URL of a media field, or null when unset.
  String? image(String key) => HomeConfig.resolveUrl(data[key]);

  /// CMS headings contain `<br/>`; the app lays text out itself.
  static String plain(String s) =>
      s.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}

class HomeCms {
  final List<HomeComponent> components;

  const HomeCms(this.components);

  /// Web order with no config, used until/unless the CMS call succeeds so the
  /// home page never renders empty.
  factory HomeCms.fallback() => const HomeCms([
        HomeComponent('index_hero-banner', {}),
        HomeComponent('index_feature-strip', {}),
        HomeComponent('index_category-banners', {}),
        HomeComponent('index_seller-products', {}),
        HomeComponent('index_promo-strip', {}),
        HomeComponent('index_picos-platform', {}),
        HomeComponent('index_products-section', {}),
      ]);

  HomeComponent? byType(String type) {
    for (final c in components) {
      if (c.type == type) return c;
    }
    return null;
  }

  /// Takes the `data` of `GET pages/home` (a page object whose `content` is a
  /// JSON string). Only `content` is read; the page's `owner_id` is ignored.
  factory HomeCms.fromPage(dynamic page) {
    dynamic content = page is Map ? page['content'] : null;
    return HomeCms.fromContent(content);
  }

  factory HomeCms.fromContent(dynamic content) {
    try {
      if (content is String) content = jsonDecode(content);
      if (content is! List) return HomeCms.fallback();
      final out = <HomeComponent>[];
      for (final c in content) {
        if (c is! Map || c['type'] == null) continue;
        final d = c['data'];
        out.add(HomeComponent(c['type'].toString(),
            d is Map ? Map<String, dynamic>.from(d) : const {}));
      }
      return out.isEmpty ? HomeCms.fallback() : HomeCms(out);
    } catch (_) {
      return HomeCms.fallback();
    }
  }
}
