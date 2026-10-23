import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/models/page_model.dart';
import 'package:zouhi/app/data/services/page_api_service.dart';

class ServicesController extends GetxController with BaseController {
  final PageApiService _apiService = PageApiService();
  final GetStorage _box = GetStorage();
  static const _cacheKey = 'cms_page_services_content';

  final isLoading = false.obs;
  final error = ''.obs;
  final components = <PageComponent>[].obs;
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCached();
    fetchServices();
  }

  void loadCached() {
    try {
      final cached = _box.read(_cacheKey);
      if (cached != null && cached is List) {
        final list = cached
            .map((e) => PageComponent.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        if (list.isNotEmpty) {
          components.assignAll(list);
        }
      }
    } catch (_) {}
  }

  Future<void> fetchServices() async {
    if (components.isEmpty) {
      isLoading(true);
    }
    error('');
    try {
      final response = await _apiService.getServicesPage();
      final content = response.data?.content ?? [];
      if (content.isNotEmpty) {
        components.assignAll(content);
        _box.write(_cacheKey, content.map((c) => c.toJson()).toList());
      } else if (components.isEmpty) {
        // Safe fallback defaults based on official website data
        components.assignAll(_defaultFallbackComponents());
      }
    } catch (e) {
      if (components.isEmpty) {
        // Populate fallback on error so user always gets a rich UI
        components.assignAll(_defaultFallbackComponents());
      }
    } finally {
      isLoading(false);
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    try {
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      final uri = Uri.parse('tel:$cleanNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  List<PageComponent> _defaultFallbackComponents() {
    return [
      PageComponent(
        id: 'ujod6kbdl',
        type: 'services_page-header',
        fields: {
          'h1_services': 'Services',
          'background_image': '',
          'header_image': '/images/2026/08/29/slide-2-73b3aa6d.webp',
          'header_image_alt': 'Services',
        },
        rawJson: {},
      ),
      PageComponent(
        id: 'z4bl1dezg',
        type: 'services_services-intro',
        fields: {
          'section_tagline': 'Support You Can Rely On',
          'section_title': 'Real Support, Before And After The Sale',
          'section_description':
              'Buying the right hardware is only half the job. Our team backs every order with hands-on technical support, professional installation, and a straightforward warranty process — so your network stays up and your team isn\'t left troubleshooting alone.',
          'cta_link': 'contact-us.html',
          'cta_text': 'Contact Support',
          'hero_image': '/images/2026/08/29/1-959e8014.webp',
          'hero_image_alt': 'Technical support and services',
        },
        rawJson: {},
      ),
      PageComponent(
        id: 'rrref6hnq',
        type: 'services_core-services-tabs',
        fields: {
          'section_subtitle': 'What We Offer',
          'section_title': 'Our Core Services',
          'section_description':
              'From the first question to long after installation, here\'s how we support you.',
          'tab1_heading': 'Technical Support',
          'tab1_paragraph':
              'Our engineers help you choose the right products, troubleshoot issues, and answer configuration questions by phone, chat, or email — before and after your purchase.',
          'tab1_feature': 'Pre-sales product guidance',
          'tab1_image': '/images/2026/08/29/2-1a3e1162.webp',
          'tab2_heading': 'Installation & Deployment',
          'tab2_paragraph':
              'Need it done right the first time? Our technicians handle on-site installation, cabling, and testing so your network goes live without surprises.',
          'tab2_feature': 'On-site installation & cabling',
          'tab2_image': '/images/2026/08/29/3-aaed866d.webp',
          'tab3_heading': 'Warranty & RMA',
          'tab3_paragraph':
              'Every product we sell is backed by manufacturer warranty and a simple, transparent return process — no runaround if something goes wrong.',
          'tab3_feature': 'Manufacturer-backed warranty',
          'tab3_image': '/images/2026/08/29/2-1a3e1162.webp',
        },
        rawJson: {},
      ),
      PageComponent(
        id: '183s60in3',
        type: 'about-us_why-choose',
        fields: {
          'feature_title': 'Certified Quality',
          'feature_description':
              'Every product meets strict industry standards for performance and durability.',
          'feature_heading': 'Why Choose Vision Infrastructure',
          'feature_paragraph':
              'Everything you need from a single, dependable network infrastructure partner.',
        },
        rawJson: {},
      ),
      PageComponent(
        id: 'gls0f3fvo',
        type: 'services_services-cta',
        fields: {
          'section_heading': 'Need Help With An Order Or Installation?',
          'section_description':
              'Our support team is ready to help — reach out and we\'ll get back to you with next steps.',
          'cta_link': 'contact',
          'cta_button_text': 'Get In Touch',
        },
        rawJson: {},
      ),
    ];
  }
}
