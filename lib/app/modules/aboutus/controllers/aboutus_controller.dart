import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_mixin.dart';
import 'package:get/get.dart';

/// Controller for the About Us screen, driven by Foduu Studio CMS
/// (`mobile-app/about-us`) and live WebSocket broadcasting.
class AboutusController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  @override
  void onInit() {
    super.onInit();
    fetchAboutUs();
  }

  /// Fetches the `about-us` CMS layout and falls back to canonical
  /// `foduu-electro.foduu.store` sections if the backend/cache is empty.
  Future<void> fetchAboutUs() async {
    await fetchLayout('about-us');
    if (widgetList.isEmpty) {
      hasError.value = false;
      errorMessage.value = '';
      buildLayout(_canonicalFallbackSections);
    }
  }

  void goToContact() {
    Get.toNamed(Routes.CONTACT);
  }

  static final List<Map<String, dynamic>> _canonicalFallbackSections = [
    {
      'id': 'slider',
      'type': 'slider',
      'visible': true,
      'content_json': {
        'slider': {
          'slug': 'about-us-slider',
          'content': [
            {
              'heading': 'About Us',
              'sub_heading': '',
              'filePath': '2026/11/24/about-us-f88907bf.webp',
            },
          ],
        },
      },
    },
    {
      'id': 'trust_badges',
      'type': 'trust_badges',
      'visible': true,
      'content_json': {
        'eyebrow': 'Our Mission',
        'title': 'Empowering Tech Creators & Innovators',
        'subtitle':
            'Since 2012, Shopwise connects creators and tech enthusiasts with certified genuine gear, transparent pricing, and fast global delivery.',
        'no_of_columns': 2,
        'cards': [
          {
            'image': '2026/11/24/pasted-9fba0d8b.svg',
            'heading': '100% Genuine',
            'text': 'Official brand warranty',
          },
          {
            'image': '2026/11/24/bus-10d425e1.svg',
            'heading': 'Fast Delivery',
            'text': 'Express 48h dispatch',
          },
          {
            'image': '2026/11/24/brad-ea3855ba.svg',
            'heading': 'Easy Returns',
            'text': '30-day money back',
          },
          {
            'image': '2026/11/24/music-d1e78c8d.svg',
            'heading': '24/7 Support',
            'text': 'Dedicated specialists',
          },
        ],
      },
    },
    {
      'id': 'slider',
      'type': 'slider',
      'visible': true,
      'content_json': {
        'slider': {
          'slug': 'about-us-second-slider',
          'content': [
            {
              'filePath': '2026/11/24/about-banner-img-203ab8b6.webp',
              'heading':
                  '<div class="about-floating-badge"><div class="floating-num">12+</div><div class="floating-label">Years of Excellence</div></div>',
              'sub_heading':
                  '<div class="about-floating-badge"><div class="floating-num">500k+</div><div class="floating-label">Happy Tech Buyers</div></div>',
              'description':
                  '<div class="about-action-strip"><a href="/shop">Explore Our Gear</a><div class="founder-note"><img src="https://foduu-electro.foduu.store/images/2026/11/14/c7d90e0548ef1a331b929abfb6c86739-e27404c6.webp"><h6 class="founder-name">Marcus Vance</h6><span class="founder-role">Founder &amp; CEO</span></div></div>',
            },
          ],
        },
      },
    },
    {
      'id': 'trust_badges',
      'type': 'trust_badges',
      'visible': true,
      'content_json': {
        'eyebrow': '',
        'title': '',
        'subtitle': '',
        'no_of_columns': 1,
        'cards': [
          {
            'image': '2026/11/24/cart-board-76fcf37b.svg',
            'heading': '15M+',
            'text': 'Products Delivered',
          },
          {
            'image': '2026/11/24/smile-e157106b.svg',
            'heading': '99.8%',
            'text': 'Customer Satisfaction',
          },
          {
            'image': '2026/11/24/handshake-15da5cfd.svg',
            'heading': '150+',
            'text': 'Brand Partnerships',
          },
          {
            'image': '2026/11/24/amernica-globe-0ce51741.svg',
            'heading': '120+',
            'text': 'Countries Served',
          },
        ],
      },
    },
    {
      'id': 'trust_badges',
      'type': 'trust_badges',
      'visible': true,
      'content_json': {
        'eyebrow': 'Why Choose Shopwise',
        'title': 'The Standards That Set Us Apart',
        'subtitle':
            'We engineered every touchpoint of our shopping experience around reliability, speed, and customer peace of mind.',
        'no_of_columns': 2,
        'cards': [
          {
            'image': '2026/11/24/pasted-9fba0d8b.svg',
            'heading': 'Certified Genuine',
            'text':
                'Zero counterfeit risk. Every device comes sealed with official factory warranties, verified serial numbers, and authenticity seals.',
          },
          {
            'image': '2026/11/24/shiping-fast-98c5712b.svg',
            'heading': 'Express Logistics',
            'text':
                'Custom shock-proof multi-layer packaging, temperature monitoring, real-time live GPS tracking, and insured express delivery.',
          },
          {
            'image': '2026/11/24/tags-0b3cdd6b.svg',
            'heading': 'Price Guarantee',
            'text':
                'Transparent market pricing with zero surprise markups. We honor official manufacturer rebates and trade-in bonuses.',
          },
          {
            'image': '2026/11/24/undo-all-90964cd2.svg',
            'heading': '30-Day Free Return',
            'text':
                'Test your equipment with total confidence. If you aren\'t completely thrilled, return it within 30 days for a swift, full refund.',
          },
        ],
      },
    },
  ];
}
