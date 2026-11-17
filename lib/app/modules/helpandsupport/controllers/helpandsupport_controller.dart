import 'package:flutter/foundation.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/data/models/faq_sections.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_mixin.dart';
import 'package:get/get.dart';

class HelpandsupportController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  final isLoading = false.obs;
  final faqs = [].obs;
  final RxInt expandedIndex = RxInt(-1);

  // Search & Topic Filtering
  final RxString searchQuery = ''.obs;
  final RxString selectedTopic = ''.obs;

  // Structured Section Data with Electronics Store Canonical Defaults
  late final Rx<FaqPageData> pageData;
  final rawSections = <dynamic>[].obs;

  static final List<Map<String, dynamic>> defaultCanonicalFaqSections = [
    {
      "id": "slider",
      "type": "slider",
      "content_json": {
        "slider_id": "6afc0eb19535c13e3e57d315",
        "full_screen": false,
        "height": 200,
        "slider": {
          "name": "faq",
          "slug": "faq",
          "content": [
            {
              "heading": "FAQ",
              "sub_heading": "How can we help you today?",
              "description":
                  "Search our comprehensive knowledge base or select a category below to quickly resolve queries about setup, billing, and integrations.",
              "filePath": "2026/11/17/appliance-lineup-f27d481f.webp",
            }
          ]
        }
      },
      "visible": true
    },
    {
      "id": "search",
      "type": "search",
      "content_json": {
        "name": "faq-search",
        "placeholder": "How do I change my billing cycle?"
      },
      "visible": true
    },
    {
      "id": "trust_badges",
      "type": "trust_badges",
      "content_json": {
        "eyebrow": "",
        "title": "",
        "subtitle": "",
        "no_of_columns": 3,
        "cards": [
          {
            "image": "2026/11/17/scan-eye-b10a477e.svg",
            "heading": "Account & Access",
            "text": "14 articles",
            "footer": ""
          },
          {
            "image": "2026/11/17/faq-billing-46d9e471.svg",
            "heading": "Billing & Plans",
            "text": "8 articles",
            "footer": ""
          },
          {
            "image": "2026/11/17/globe-lock-65e15bdf.svg",
            "heading": "Platform Security",
            "text": "11 articles",
            "footer": ""
          },
          {
            "image": "2026/11/17/handshake-6430019d.svg",
            "heading": "Partners & Teams",
            "text": "9 articles",
            "footer": ""
          }
        ]
      },
      "visible": true
    },
    {
      "id": "trust_badges",
      "type": "trust_badges",
      "content_json": {
        "eyebrow": "Categories",
        "title": "Account & Access",
        "subtitle": "General Membership (6)",
        "no_of_columns": 1,
        "cards": [
          {
            "image": null,
            "heading": "How do I create an Foduu Store account? ",
            "text":
                "Choose Create Account at checkout or from the profile menu, confirm your email, and your order history, saved addresses and wishlist start syncing straight away.",
            "footer": ""
          },
          {
            "image": null,
            "heading": "Can I change the email address on my account? ",
            "text":
                "Yes. Open Profile, then Account details, enter the new address and confirm it from the verification link we send. Your order history, saved cards and wishlist move across untouched.\n\nIf you no longer have access to the old inbox, our support team can verify you against a recent order and make the change for you.",
            "footer": ""
          },
          {
            "image": null,
            "heading": "How do I reset a forgotten password? ",
            "text":
                "Choose Forgotten password on the sign-in screen and we will email you a reset link that stays valid for one hour. For security the link can only be used once. ",
            "footer": ""
          },
          {
            "image": null,
            "heading": " What do I get with a membership account? ",
            "text":
                "Members get order tracking, extended returns, early access to sale events, and a saved warranty record for every device bought through us.",
            "footer": ""
          },
          {
            "image": null,
            "heading": "Can I merge two accounts I created by mistake? ",
            "text":
                "Send us the addresses on both accounts and we will move orders, warranties and wishlist items onto the one you want to keep, then close the other.",
            "footer": ""
          },
          {
            "image": null,
            "heading": "How do I close my account and remove my data?",
            "text":
                "Request closure from Profile, then Privacy. We keep purchase records for the length of each warranty, as the law requires, and remove everything else within 30 days. ",
            "footer": ""
          }
        ]
      },
      "visible": true
    },
    {
      "id": "slider",
      "type": "slider",
      "content_json": {
        "slider_id": "6afc16448d0a476f10e098a6",
        "full_screen": false,
        "height": 200,
        "slider": {
          "name": "faq-center-slider",
          "slug": "faq-center-slider",
          "content": [
            {
              "heading": "Still Stuck?",
              "sub_heading": "Can’t find what you’re looking for?",
              "description":
                  "Our expert agents and developers are standing by around the clock to assist you with deep infrastructure setup or payment resolution.",
              "filePath": "2026/11/17/cta-gear-9f7e301e.svg"
            }
          ]
        }
      },
      "visible": true
    }
  ];

  @override
  void onInit() {
    super.onInit();
    pageData = FaqPageData.canonical().obs;

    // Instant zero-blank render with canonical layout
    buildLayout(defaultCanonicalFaqSections);

    getFaqs();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void selectTopic(String topic) {
    selectedTopic.value = topic;
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedTopic.value = '';
  }

  void toggleExpansion(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1;
    } else {
      expandedIndex.value = index;
    }
  }

  /// Intercepts both initial fetch and live WebSocket broadcasts from FoduuStudioLayoutMixin
  @override
  void buildLayout(List sections) {
    super.buildLayout(sections);
    if (sections.isNotEmpty) {
      rawSections.assignAll(sections);
      pageData.value = FaqPageData.fromSections(sections);

      // Backwards compatibility with any legacy faqs consumers
      faqs.clear();
      for (final s in sections) {
        if (s is Map && s['type'] == 'trust_badges') {
          final cj = s['content_json'] is Map ? s['content_json'] as Map : {};
          final cards = cj['cards'] ?? cj['items'];
          if (cards is List) {
            faqs.addAll(cards);
          }
        }
      }
    }
  }

  /// Multi-tier fetching strategy for FAQ matching Fastify CMS broadcasting
  Future<void> getFaqs() async {
    try {
      isLoading.value = true;

      // Tier 1: Fastify CMS Broadcasting layout (mobile-app/faq)
      try {
        final response = await fetchLayout('faq');
        if (response != null && response is Map) {
          final list = response['sections'];
          if (list is List && list.isNotEmpty) {
            rawSections.assignAll(list);
            pageData.value = FaqPageData.fromSections(list);
            isLoading.value = false;
            return;
          }
        }
      } catch (cmsError) {
        debugPrint('HelpandsupportController: CMS fetchLayout error: $cmsError');
      }

      // Tier 2: Legacy API fallback (frontend/faq)
      try {
        final response = await BasicProvider("frontend/faq")
            .getRequest()
            .catchError(handleError);

        if (response != null) {
          faqs.clear();
          if (response is List) {
            faqs.addAll(response);
          } else if (response is Map) {
            final data =
                response['data'] ?? response['faqs'] ?? response['docs'];
            if (data is List) {
              faqs.addAll(data);
            }
          }
        }
      } catch (legacyError) {
        debugPrint('HelpandsupportController: Legacy API error: $legacyError');
      }

      // Tier 3: Canonical Defaults if widgetList is still empty
      if (widgetList.isEmpty) {
        buildLayout(defaultCanonicalFaqSections);
      }
    } catch (e) {
      debugPrint('HelpandsupportController error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
