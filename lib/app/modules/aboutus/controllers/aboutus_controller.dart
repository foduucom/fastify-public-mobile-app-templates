import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/models/about_us_sections.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/core/foduuStudio/foduu_studio_layout_mixin.dart';

class AboutusController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
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

  /// Intercepts both initial fetch and live WebSocket broadcasts from FoduuStudioLayoutMixin
  @override
  void buildLayout(List sections) {
    super.buildLayout(sections);
    _parseCmsSections(sections);
  }

  Future<void> fetchAboutUs() async {
    isLoading(true);
    error('');
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
      _parseCmsSections(rawSections);
    } catch (e) {
      error(e.toString());
      _parseCmsSections(rawSections);
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
