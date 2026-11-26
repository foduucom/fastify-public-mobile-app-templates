import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/models/page_model.dart';
import 'package:zouhi/app/data/models/solutions_sections.dart';
import 'package:zouhi/app/data/services/page_api_service.dart';
import 'package:zouhi/core/foduuStudio/foduu_studio_layout_mixin.dart';

class SolutionsController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  final PageApiService _apiService = PageApiService();
  final GetStorage _box = GetStorage();
  static const _cacheKey = 'cms_page_solution_content';

  final isLoading = false.obs;
  final error = ''.obs;
  final rawSections = <dynamic>[].obs;

  late final Rx<SolutionsSectionsData> data;

  // Backwards compatibility getter
  List<PageComponent> get components => [];

  @override
  void onInit() {
    super.onInit();
    data = SolutionsSectionsData.canonical().obs;
    loadCached();
    if (widgetList.isEmpty) {
      buildLayout(_canonicalSections);
    }
    isLayoutLoading.value = false;
    fetchSolutions();
  }

  List<Map<String, dynamic>> get _canonicalSections => [
        {
          'type': 'banner',
          'id': 'solutions-header',
          'content_json': {
            '_page_slug': 'solution',
            'banners': [
              {
                'items': [
                  {
                    'featured_image': {
                      'download_url': SolutionsBannerHeader.canonical().imageUrl,
                      'alt_text': SolutionsBannerHeader.canonical().altText,
                    }
                  }
                ]
              }
            ],
          },
        },
        {
          'type': 'slider',
          'id': 'solutions-intro',
          'content_json': {
            '_page_slug': 'solution',
            'slider': {
              'slug': 'solutions-main-intro',
              'content': [
                {
                  'heading': 'What We Deliver["${SolutionsIntroSection.canonical().title}"]',
                  'description':
                      '${SolutionsIntroSection.canonical().description}\n\n${SolutionsIntroSection.canonical().statItem}',
                  'button_text': SolutionsIntroSection.canonical().buttonText,
                  'filePath': SolutionsIntroSection.canonical().imageUrl,
                }
              ],
            },
          },
        },
        {
          'type': 'trust_badges',
          'id': 'solutions-by-industry',
          'content_json': {
            '_page_slug': 'solution',
            'eyebrow': SolutionsByIndustrySection.canonical().eyebrow,
            'title': SolutionsByIndustrySection.canonical().title,
            'subtitle': SolutionsByIndustrySection.canonical().subtitle,
            'cards': SolutionsByIndustrySection.canonical()
                .cards
                .map((c) => {
                      'heading': c.title,
                      'text': c.description,
                      'icon': c.iconUrl,
                      'cover': c.coverImageUrl,
                    })
                .toList(),
          },
        },
        {
          'type': 'trust_badges',
          'id': 'solutions-by-need',
          'content_json': {
            '_page_slug': 'solution',
            'eyebrow': SolutionsByNeedSection.canonical().eyebrow,
            'title': SolutionsByNeedSection.canonical().title,
            'subtitle': SolutionsByNeedSection.canonical().subtitle,
            'cards': SolutionsByNeedSection.canonical()
                .cards
                .map((c) => {
                      'heading': c.title,
                      'text': c.description,
                      'icon': c.imageUrl,
                    })
                .toList(),
          },
        },
        {
          'type': 'slider',
          'id': 'solutions-cta',
          'content_json': {
            '_page_slug': 'solution',
            'slider': {
              'slug': 'solutions-consultation-cta',
              'content': [
                {
                  'heading': SolutionsConsultationCta.canonical().heading,
                  'description': SolutionsConsultationCta.canonical().description,
                  'button_text': SolutionsConsultationCta.canonical().buttonText,
                  'filePath': SolutionsConsultationCta.canonical().imageUrl,
                }
              ],
            },
          },
        },
      ];

  void loadCached() {
    try {
      final cached = _box.read(_cacheKey);
      if (cached != null && cached is List && cached.isNotEmpty) {
        rawSections.assignAll(cached);
        data.value = SolutionsSectionsData.fromSections(cached);
        buildLayout(cached);
      }
    } catch (_) {}
  }

  /// Intercepts both initial fetch and live WebSocket broadcasts from FoduuStudioLayoutMixin
  @override
  void buildLayout(List sections) {
    super.buildLayout(sections);
    if (sections.isNotEmpty) {
      rawSections.assignAll(sections);
      data.value = SolutionsSectionsData.fromSections(sections);
      try {
        _box.write(_cacheKey, sections);
      } catch (_) {}
    }
  }

  Future<void> fetchSolutions() async {
    isLoading(true);
    error('');
    try {
      // Tier 1: Fastify CMS Broadcasting layout (GET /api/mobile-app/solution)
      try {
        final response = await fetchLayout('solution');
        if (response != null && response is Map) {
          final list = response['sections'];
          if (list is List && list.isNotEmpty) {
            rawSections.assignAll(list);
            data.value = SolutionsSectionsData.fromSections(list);
            _box.write(_cacheKey, list);
            return;
          }
        }
      } catch (cmsError) {
        debugPrint('SolutionsController: CMS fetchLayout error: $cmsError');
      }

      // Tier 2: Fallback to legacy Page API (/pages?type=solution)
      try {
        final pageResponse = await _apiService.getSolutionsPage();
        final content = pageResponse.data?.content ?? [];
        if (content.isNotEmpty) {
          data.value = SolutionsSectionsData.fromPageComponents(content);
          return;
        }
      } catch (pageError) {
        debugPrint('SolutionsController: Legacy PageApiService error: $pageError');
      }

      // Tier 3: Website Canonical Defaults (https://vision.foduu.store/solution)
      if (rawSections.isNotEmpty) {
        data.value = SolutionsSectionsData.fromSections(rawSections);
      } else {
        data.value = SolutionsSectionsData.canonical();
      }
    } catch (e) {
      error(e.toString());
      if (rawSections.isNotEmpty) {
        data.value = SolutionsSectionsData.fromSections(rawSections);
      } else {
        data.value = SolutionsSectionsData.canonical();
      }
    } finally {
      isLoading(false);
    }
  }
}

