import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zouhi/app/data/models/home_cms.dart';
import 'package:zouhi/constants/home_config.dart';

void main() {
  final content = jsonEncode([
    {
      'type': 'index_special-offers',
      'data': {
        'section_heading': 'Special Offers!',
        'discount_percent': '50% OFF',
        'countdown_until': '+10d'
      }
    },
    {
      'type': 'index_product-tabs',
      'data': {'items_per_tab': '6'}
    },
    {
      'type': 'index_category-banners',
      'data': {
        'banner_1_image': '/images/2026/09/03/camera-f4e9ce16.webp',
        'banner_1_url': '#'
      }
    },
    {
      'type': 'index_hero-banner',
      'data': {'hero_slide_primary_image': '{{baseUrl}}/assets/images/vision /slider3.png'}
    },
  ]);

  test('parses components in order and reads typed fields', () {
    final cms = HomeCms.fromContent(content);
    expect(cms.components.map((c) => c.type).toList(), [
      'index_special-offers',
      'index_product-tabs',
      'index_category-banners',
      'index_hero-banner',
    ]);
    expect(cms.byType('index_product-tabs')!.integer('items_per_tab', 0), 6);
    expect(cms.byType('index_special-offers')!.str('discount_percent'), '50% OFF');
    expect(cms.byType('index_blog-posts'), isNull);
  });

  test('resolves relative, templated and placeholder urls', () {
    final cms = HomeCms.fromContent(content);
    expect(cms.byType('index_category-banners')!.image('banner_1_image'),
        'https://vision.vbought.com/images/2026/09/03/camera-f4e9ce16.webp');
    expect(cms.byType('index_hero-banner')!.image('hero_slide_primary_image'),
        'https://vision.vbought.com/assets/images/vision%20/slider3.png');
    expect(HomeConfig.resolveUrl('#'), isNull);
    expect(HomeConfig.resolveUrl(''), isNull);
    expect(HomeConfig.resolveUrl(null), isNull);
  });

  test('bad or empty content falls back to the web section order', () {
    for (final bad in [null, 'not json', '{}', '[]', 42]) {
      final cms = HomeCms.fromContent(bad);
      expect(cms.components.first.type, 'index_hero-banner');
      expect(cms.byType('index_special-offers'), isNotNull);
    }
  });

  test('plain() strips tags from CMS headings', () {
    expect(HomeComponent.plain('High quality Electric <br/> Equipments'),
        'High quality Electric Equipments');
  });
}
