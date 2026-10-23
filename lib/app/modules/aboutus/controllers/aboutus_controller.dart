import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/models/about_us_sections.dart';
import 'package:zouhi/app/data/models/page_model.dart';
import 'package:zouhi/app/data/services/page_api_service.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/constants.dart';

class AboutusController extends GetxController with BaseController {
  final PageApiService _apiService = PageApiService();

  final isLoading = false.obs;
  final error = ''.obs;
  final components = <PageComponent>[].obs;

  // Structured Sections with Website Canonical Defaults
  late final Rx<AboutHeroHeader> header;
  late final Rx<AboutHeroStory> story;
  late final Rx<AboutWhyChooseSection> whyChoose;
  late final Rx<AboutProcessSection> process;
  late final Rx<AboutTestimonialsSection> testimonials;

  final currentTestimonialIndex = 0.obs;

  final stats = <AboutTrustStat>[
    const AboutTrustStat(value: '500+', label: 'Projects Done'),
    const AboutTrustStat(value: '100%', label: 'Tested Quality'),
    const AboutTrustStat(value: '24/7', label: 'Tech Support'),
    const AboutTrustStat(value: 'Pan-India', label: 'Express Delivery'),
  ].obs;

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

  Future<void> fetchAboutUs() async {
    isLoading(true);
    error('');
    try {
      final response = await _apiService.getPageByType('about');
      final content = response.data?.content ?? [];
      components.assignAll(content);
      _parseComponents(content);
    } catch (e) {
      error(e.toString());
      // Ensure defaults remain active even on error
      _parseComponents(components);
    } finally {
      isLoading(false);
    }
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

