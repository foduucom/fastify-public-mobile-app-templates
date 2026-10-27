import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/models/about_us_sections.dart';
import 'package:zouhi/app/data/models/page_model.dart';
import 'package:zouhi/app/data/services/page_api_service.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/core/foduuStudio/foduu_studio_layout_mixin.dart';

class AboutusController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  final PageApiService _pageApiService = PageApiService();

  final isLoading = false.obs;
  final error = ''.obs;
  final rawSections = <dynamic>[].obs;

  // Structured Sections with Website Canonical Defaults
  late final Rx<AboutHeroHeader> header;
  late final Rx<AboutHeroStory> story;
  late final Rx<AboutWhyChooseSection> whyChoose;
  late final Rx<AboutProcessSection> process;
  late final Rx<AboutTestimonialsSection> testimonials;

  final currentTestimonialIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initDefaults();
    fetchAboutUs();
  }

  void _initDefaults() {
    header = AboutHeroHeader.fromComponent(null).obs;
    story = AboutHeroStory.fromComponent(null).obs;
    whyChoose = AboutWhyChooseSection.fromComponent(null).obs;
    process = AboutProcessSection.fromComponent(null).obs;
    testimonials = AboutTestimonialsSection.fromComponent(null).obs;
  }

  void _applyDefaults() {
    header.value = AboutHeroHeader.fromComponent(null);
    story.value = AboutHeroStory.fromComponent(null);
    whyChoose.value = AboutWhyChooseSection.fromComponent(null);
    process.value = AboutProcessSection.fromComponent(null);
    testimonials.value = AboutTestimonialsSection.fromComponent(null);
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

      // Tier 2: Fallback to legacy Page API (/pages?type=about)
      try {
        final pageResponse = await _pageApiService.getPageByType('about');
        final content = pageResponse.data?.content ?? [];
        if (content.isNotEmpty) {
          _parseComponents(content);
          return;
        }
      } catch (pageError) {
        debugPrint('AboutusController: Legacy PageApiService error: $pageError');
      }

      // Tier 3: Website Canonical Defaults (https://vision.foduu.store/about)
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
    story.value = AboutHeroStory.fromSections(list);
    whyChoose.value = AboutWhyChooseSection.fromSections(list);
    process.value = AboutProcessSection.fromSections(list);
    testimonials.value = AboutTestimonialsSection.fromSections(list);
  }

  void _parseComponents(List<PageComponent> list) {
    PageComponent? headerComp;
    PageComponent? storyComp;
    PageComponent? whyComp;
    PageComponent? processComp;
    PageComponent? testimonialComp;

    for (final c in list) {
      switch (c.type) {
        case 'about-us_page-header':
          headerComp = c;
          break;
        case 'about-us_hero-banner':
          storyComp = c;
          break;
        case 'about-us_why-choose':
          whyComp = c;
          break;
        case 'about-us_our-process':
          processComp = c;
          break;
        case 'about-us_testimonials':
          testimonialComp = c;
          break;
      }
    }

    header.value = AboutHeroHeader.fromComponent(headerComp);
    story.value = AboutHeroStory.fromComponent(storyComp);
    whyChoose.value = AboutWhyChooseSection.fromComponent(whyComp);
    process.value = AboutProcessSection.fromComponent(processComp);
    testimonials.value = AboutTestimonialsSection.fromComponent(testimonialComp);
  }

  void visitStore() {
    if (Get.isRegistered<BottombarController>()) {
      Get.back();
      BottombarController.switchTab(1);
    } else {
      Get.toNamed(Routes.SHOP);
    }
  }

  Future<void> callSupport() async {
    final cleanPhone = supportContact.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void goToContact() {
    Get.toNamed(Routes.CONTACT);
  }
}
