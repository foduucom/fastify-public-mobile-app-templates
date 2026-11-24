import 'package:flutter/foundation.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/data/models/about_us_sections.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_mixin.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutusController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  final isLoading = false.obs;
  final error = ''.obs;
  final rawSections = <dynamic>[].obs;

  // Structured Sections with Electronics Store Canonical Defaults
  late final Rx<AboutHeroHeader> header;
  late final Rx<AboutCategoriesSection> categories;
  late final Rx<AboutHeroStory> story;
  late final Rx<AboutStatsSection> stats;
  late final Rx<AboutBrandsSection> brands;
  late final Rx<AboutTeamSection> team;
  late final Rx<AboutPhilosophySection> philosophy;
  late final Rx<AboutWhyChooseSection> whyChoose;
  late final Rx<AboutFaqSection> faq;
  late final Rx<AboutConsultationCard> consultation;
  late final Rx<AboutBottomCta> bottomCta;

  final expandedFaqIndex = RxnInt();

  static final List<Map<String, dynamic>> defaultCanonicalAboutSections = [
    {
      "id": "slider",
      "type": "slider",
      "content_json": {
        "slider": {
          "name": "about-us",
          "slug": "about-us",
          "content": [
            {
              "heading": "About Us",
              "sub_heading":
                  "We're Here to Upgrade Your World With Technology",
              "description":
                  "Shop the latest electronics and smart devices, carefully selected to bring you better performance, smarter solutions, and a seamless digital lifestyle.",
              "filePath": "2026/11/17/appliance-lineup-f27d481f.webp"
            }
          ]
        }
      },
      "visible": true
    },
    {
      "id": "categories",
      "type": "categories",
      "content_json": {
        "title": "Shop By Category",
        "parent_type": "product",
        "categories": [
          {
            "id": "6ae96b20c7a7846a169e857b",
            "name": "Drones",
            "slug": "drones",
            "image": "2026/11/03/cat-drones-2fabeb64.svg"
          },
          {
            "id": "smart-home",
            "name": "Smart Home",
            "slug": "smart-home",
            "image": "2026/11/03/smart-home.svg"
          },
          {
            "id": "printers",
            "name": "Printers",
            "slug": "printers",
            "image": "2026/11/03/printer.svg"
          },
          {
            "id": "monitors",
            "name": "Monitors",
            "slug": "monitors",
            "image": "2026/11/03/monitor.svg"
          },
          {
            "id": "audio",
            "name": "Audio",
            "slug": "audio",
            "image": ""
          }
        ]
      },
      "visible": true
    },
    {
      "id": "trust_badges",
      "type": "trust_badges",
      "content_json": {
        "eyebrow": "GLOBAL FOOTPRINT",
        "title": "A Global Footprint of Sound",
        "subtitle":
            "Curated essentials with fast shipping, premium support, and verified reviews",
        "no_of_columns": 2,
        "cards": [
          {
            "heading": "120k+",
            "text": "Immersive Setups Deployed",
            "footer":
                "Acoustic systems deployed in designer living rooms and studio workflows"
          },
          {
            "heading": "4.9★",
            "text": "Expert & Customer Rating",
            "footer":
                "Consistently rated as the benchmark for tactile and acoustic precision"
          },
          {
            "heading": "2-Year",
            "text": "No-Hassle Direct Warranty",
            "footer":
                "We stand behind our materials, from magnesium alloys to custom drivers"
          },
          {
            "heading": "24/7",
            "text": "Bespoke Setup Assistance",
            "footer":
                "Direct line to acoustic advisors to fine-tune your listening environment"
          }
        ]
      },
      "visible": true
    },
    {
      "id": "slider",
      "type": "slider",
      "content_json": {
        "slider": {
          "name": "brand_slider",
          "slug": "brand_slider",
          "content": [
            {
              "heading": "Current assortment, 400 brands and counting...",
              "brand_images": [
                "2026/11/17/brand-razer.webp",
                "2026/11/17/brand-jbl.webp",
                "2026/11/17/brand-sony.webp",
                "2026/11/17/brand-audiotechnica.webp",
                "2026/11/17/brand-pioneer.webp",
                "2026/11/17/brand-philips.webp",
                "2026/11/17/brand-akg.webp",
                "2026/11/17/brand-sennheiser.webp"
              ]
            }
          ]
        }
      },
      "visible": true
    },
    {
      "id": "team_members",
      "type": "team_members",
      "content_json": {
        "eyebrow": "OUR PEOPLE",
        "title": "Meet the Sound Engineers & Curators",
        "subtitle":
            "Dedicated to bringing the ultimate listening experience to life.",
        "members": [
          {
            "name": "Liam Davis",
            "role": "Chief Acoustic Architect",
            "avatarImage": "2026/11/17/team-liam.webp"
          },
          {
            "name": "Maya Thorne",
            "role": "Lead Industrial Designer",
            "avatarImage": "2026/11/17/team-maya.webp"
          },
          {
            "name": "Ethan Vance",
            "role": "Head of Hardware Engineering",
            "avatarImage": "2026/11/17/team-ethan.webp"
          },
          {
            "name": "Aria Chen",
            "role": "Director of Sound Experience",
            "avatarImage": "2026/11/17/team-aria.webp"
          }
        ]
      },
      "visible": true
    },
    {
      "id": "slider",
      "type": "slider",
      "content_json": {
        "slider": {
          "name": "who-we-are",
          "slug": "who-we-are",
          "content": [
            {
              "heading": "Who We Are",
              "sub_heading":
                  "ENGINEERING THE FUTURE OF HOME SOUND & LIVING",
              "description":
                  "Founded by audio engineers and industrial designers, we combine acoustic precision with clean, minimal aesthetics. Every component in our catalog is rigorously verified.",
              "filePath": "2026/11/14/who-we-are-1763102422.webp"
            }
          ]
        }
      },
      "visible": true
    },
    {
      "id": "trust_badges",
      "type": "trust_badges",
      "content_json": {
        "eyebrow": "OUR PHILOSOPHY",
        "title": "Our Guiding Principles",
        "subtitle":
            "Every driver tuned, every material chosen, every package dispatched with purpose.",
        "cards": [
          {
            "title": "Acoustic Purity",
            "description":
                "Zero unnecessary DSP colorization; studio-grade precision delivered uncompressed."
          },
          {
            "title": "Sustainable Architecture",
            "description":
                "Aircraft-grade aluminum, recycled acoustic mesh, and plastic-free packaging."
          },
          {
            "title": "Bespoke Engineering",
            "description":
                "Custom drivers and tuned chambers developed in collaboration with top audio engineers."
          }
        ]
      },
      "visible": true
    },
    {
      "id": "trust_badges",
      "type": "trust_badges",
      "content_json": {
        "eyebrow": "WHY CHOOSE US",
        "title": "Sound You Can Rely On",
        "subtitle":
            "Industry-leading warranty, rapid delivery, and lifetime audio support.",
        "cards": [
          {
            "title": "Rapid Delivery",
            "description":
                "Same-day dispatch with insured worldwide courier options.",
            "footer": "Track Shipments"
          },
          {
            "title": "Direct Warranty",
            "description":
                "2-year no-hassle replacement coverage on all flagship gear.",
            "footer": "View Policy"
          },
          {
            "title": "24/7 Expert Audio Consultation",
            "description":
                "Dedicated specialists available anytime via live chat or phone.",
            "footer": "Book Call"
          },
          {
            "title": "Fair Trade & Sustainable",
            "description":
                "Responsibly sourced metals and ethical supplier auditing.",
            "footer": "Our Mission"
          }
        ]
      },
      "visible": true
    },
    {
      "id": "faq",
      "type": "faq",
      "content_json": {
        "title": "Frequently Asked Questions",
        "subtitle":
            "Everything you need to know about our audio gear, shipping, and warranty.",
        "items": [
          {
            "question":
                "What makes Foduu audio gear different from mainstream headphones?",
            "answer":
                "Every driver is acoustically tuned in-house with zero artificial DSP boosts. We prioritize high dynamic range and true reproduction."
          },
          {
            "question":
                "Do you offer international shipping and custom duties coverage?",
            "answer":
                "Yes, we ship to over 85 countries with full duties pre-paid at checkout, ensuring fast customs clearance."
          },
          {
            "question":
                "How does the 2-Year No-Hassle Direct Warranty work?",
            "answer":
                "If any mechanical or driver failure occurs within 24 months, we ship an immediate replacement without long bench repairs."
          },
          {
            "question":
                "Can I audition equipment before making a purchase?",
            "answer":
                "We offer a 30-day home audition period with risk-free return shipping so you can experience our gear in your space."
          }
        ]
      },
      "visible": true
    },
    {
      "id": "banner",
      "type": "banner",
      "content_json": {
        "slug": "consultation",
        "heading": "Need Expert Assistance?",
        "sub_heading":
            "Our product specialists are here to help you choose the right setup for your space.",
        "hours": "Available Monday–Saturday, 9AM–6PM EST",
        "email": "consultations@foduustore.com",
        "phone": "+1 202-555-0146",
        "buttonText": "Schedule Consultation",
        "trustedClientsText":
            "Trusted by 2,000+ discerning clients worldwide"
      },
      "visible": true
    },
    {
      "id": "slider",
      "type": "slider",
      "content_json": {
        "slider": {
          "name": "about-us-fourth-bottom-COA",
          "slug": "about-us-fourth-bottom-COA",
          "content": [
            {
              "sub_heading": "Ready to redefine your acoustics?",
              "description":
                  "Explore our current roster of precision-engineered headphones, reference monitors, and architectural home systems.",
              "primaryButtonText": "Browse New Arrivals",
              "secondaryButtonText": "Contact Acoustic Advisor",
              "filePath": "2026/11/17/gadgets-cta-6b257f41.webp"
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
    _initDefaults();

    // Instant zero-blank render with canonical layout
    buildLayout(defaultCanonicalAboutSections);

    fetchAboutUs();
  }

  void _initDefaults() {
    header = AboutHeroHeader.fallback().obs;
    categories = AboutCategoriesSection.fallback().obs;
    story = AboutHeroStory.fallback().obs;
    stats = AboutStatsSection.fallback().obs;
    brands = AboutBrandsSection.fallback().obs;
    team = AboutTeamSection.fallback().obs;
    philosophy = AboutPhilosophySection.fallback().obs;
    whyChoose = AboutWhyChooseSection.fallback().obs;
    faq = AboutFaqSection.fallback().obs;
    consultation = AboutConsultationCard.fallback().obs;
    bottomCta = AboutBottomCta.fallback().obs;
  }

  void _applyDefaults() {
    header.value = AboutHeroHeader.fallback();
    categories.value = AboutCategoriesSection.fallback();
    story.value = AboutHeroStory.fallback();
    stats.value = AboutStatsSection.fallback();
    brands.value = AboutBrandsSection.fallback();
    team.value = AboutTeamSection.fallback();
    philosophy.value = AboutPhilosophySection.fallback();
    whyChoose.value = AboutWhyChooseSection.fallback();
    faq.value = AboutFaqSection.fallback();
    consultation.value = AboutConsultationCard.fallback();
    bottomCta.value = AboutBottomCta.fallback();
  }

  /// Intercepts both initial fetch and live WebSocket broadcasts from FoduuStudioLayoutMixin
  @override
  void buildLayout(List sections) {
    super.buildLayout(sections);
    if (sections.isNotEmpty) {
      rawSections.assignAll(sections);
      _parseCmsSections(sections);
    }
  }

  Future<void> fetchAboutUs() async {
    isLoading(true);
    error('');
    try {
      // Tier 1: Fastify CMS Broadcasting layout
      try {
        final response = await fetchLayout('about-us');
        if (response != null && response is Map) {
          final list = response['sections'];
          if (list is List && list.isNotEmpty) {
            rawSections.assignAll(list);
            _parseCmsSections(list);
            return;
          }
        }
      } catch (cmsError) {
        debugPrint('AboutusController: CMS fetchLayout error: $cmsError');
      }

      // Tier 2: Fallback to legacy Page API (page/about)
      try {
        final pageResponse = await BasicProvider("page/about")
            .getRequest()
            .catchError((e, s) => null);
        if (pageResponse != null && pageResponse is Map) {
          final content = pageResponse["content"];
          if (content is String && content.trim().isNotEmpty) {
            story.value = AboutHeroStory(
              title: 'Who We Are',
              subtitle: 'Engineering the Future of Home Sound & Living',
              description: content.replaceAll(RegExp(r'<[^>]*>'), ' ').trim(),
              bannerImage: story.value.bannerImage,
            );
            return;
          }
        }
      } catch (pageError) {
        debugPrint('AboutusController: Legacy page API error: $pageError');
      }

      // Tier 3: Website Canonical Defaults
      if (rawSections.isNotEmpty) {
        _parseCmsSections(rawSections);
      } else {
        _applyDefaults();
        if (widgetList.isEmpty) {
          buildLayout(defaultCanonicalAboutSections);
        }
      }
    } catch (e) {
      error(e.toString());
      if (rawSections.isNotEmpty) {
        _parseCmsSections(rawSections);
      } else {
        _applyDefaults();
        if (widgetList.isEmpty) {
          buildLayout(defaultCanonicalAboutSections);
        }
      }
    } finally {
      isLoading(false);
    }
  }

  void _parseCmsSections(List list) {
    if (list.isEmpty) return;
    header.value = AboutHeroHeader.fromSections(list);
    categories.value = AboutCategoriesSection.fromSections(list);
    stats.value = AboutStatsSection.fromSections(list);
    brands.value = AboutBrandsSection.fromSections(list);
    team.value = AboutTeamSection.fromSections(list);
    story.value = AboutHeroStory.fromSections(list);
    philosophy.value = AboutPhilosophySection.fromSections(list);
    whyChoose.value = AboutWhyChooseSection.fromSections(list);
    faq.value = AboutFaqSection.fromSections(list);
    consultation.value = AboutConsultationCard.fromSections(list);
    bottomCta.value = AboutBottomCta.fromSections(list);
  }

  void toggleFaq(int index) {
    if (expandedFaqIndex.value == index) {
      expandedFaqIndex.value = null;
    } else {
      expandedFaqIndex.value = index;
    }
  }

  void visitStore() {
    if (Get.isRegistered<BottombarController>()) {
      Get.back();
      final bottomBar = Get.find<BottombarController>();
      bottomBar.onTabChange(1);
    } else {
      Get.toNamed(Routes.SHOPPRODUCTLISTVIEW);
    }
  }

  Future<void> callSupport([String? customPhone]) async {
    final rawPhone = customPhone ?? consultation.value.phone;
    final cleanPhone = rawPhone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> sendEmail([String? customEmail]) async {
    final targetEmail = customEmail ?? consultation.value.email;
    final uri = Uri(scheme: 'mailto', path: targetEmail);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void goToContact() {
    Get.toNamed(Routes.CONTACT);
  }
}
