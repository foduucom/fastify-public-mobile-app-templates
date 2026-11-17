import 'package:flutter/foundation.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/data/models/about_us_sections.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/modules/homepage/controllers/homepage_controller.dart';
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

  @override
  void onInit() {
    super.onInit();
    _initDefaults();
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
      }
    } catch (e) {
      error(e.toString());
      if (rawSections.isNotEmpty) {
        _parseCmsSections(rawSections);
      } else {
        _applyDefaults();
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

    _loadStoreCategories(list);
  }

  /// Synchronizes About Us categories with the store's curated categories (from mobile-app/home)
  /// so it matches the Parent Website / Home Screen (Image 1) in exact order and priority.
  Future<void> _loadStoreCategories(List sections) async {
    // 1. If the about-us CMS section already provided multiple curated categories, use them
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'categories') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final rawCats = cj['categories'];
        if (rawCats is List && rawCats.length > 1) {
          _setCategoriesFromList(rawCats);
          return;
        }
      }
    }

    // 2. Otherwise sync with the Parent Website / Home Screen layout (mobile-app/home)
    // This gives the exact same categories, order, and icons as the Home Screen (Image 1)!
    List? homeCats;
    if (Get.isRegistered<HomepageController>()) {
      final homeCj =
          Get.find<HomepageController>().contentJsonFor('categories');
      if (homeCj != null &&
          homeCj['categories'] is List &&
          (homeCj['categories'] as List).isNotEmpty) {
        homeCats = homeCj['categories'] as List;
      }
    }

    if (homeCats == null || homeCats.isEmpty) {
      try {
        final homeResponse = await BasicProvider('mobile-app/home')
            .getRequest()
            .catchError((_) => null);
        if (homeResponse is Map && homeResponse['sections'] is List) {
          for (final s in homeResponse['sections']) {
            if (s is Map && s['type'] == 'categories') {
              final cj = s['content_json'] is Map
                  ? Map<String, dynamic>.from(s['content_json'])
                  : <String, dynamic>{};
              final cats = cj['categories'];
              if (cats is List && cats.isNotEmpty) {
                homeCats = cats;
                break;
              }
            }
          }
        }
      } catch (e) {
        debugPrint('AboutusController sync home categories error: $e');
      }
    }

    if (homeCats != null && homeCats.isNotEmpty) {
      _setCategoriesFromList(homeCats);
      return;
    }

    // 3. Fallback to canonical electronics store categories
    if (categories.value.categories.length <= 1) {
      categories.value = AboutCategoriesSection.fallback();
    }
  }

  void _setCategoriesFromList(List rawList) {
    final list = <AboutCategoryItem>[];
    for (final c in rawList) {
      if (c is Map) {
        final id = (c['_id'] ?? c['id'] ?? '').toString();
        final name = (c['name'] ?? '').toString();
        final slug = (c['slug'] ?? '').toString();

        String icon = '';
        final featIcon = c['featured_image_icon'];
        if (featIcon is Map) {
          icon = (featIcon['download_url'] ??
                  featIcon['filepath'] ??
                  featIcon['filePath'] ??
                  '')
              .toString();
        } else if (c['featured_image'] is Map) {
          final f = c['featured_image'] as Map;
          icon = (f['download_url'] ??
                  f['filepath'] ??
                  f['filePath'] ??
                  '')
              .toString();
        } else if (c['image'] != null) {
          icon = c['image'].toString();
        }

        if (name.isNotEmpty) {
          list.add(AboutCategoryItem(
            id: id,
            name: name,
            slug: slug,
            iconUrl: icon,
          ));
        }
      }
    }
    if (list.isNotEmpty) {
      categories.value = AboutCategoriesSection(categories: list);
    }
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
      bottomBar.currentPageIndex.value = 1;
      if (bottomBar.pageController.hasClients) {
        bottomBar.pageController.jumpToPage(1);
      }
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
