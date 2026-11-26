import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/data/models/terms_sections.dart';
import 'package:zouhi/core/foduuStudio/foduu_studio_layout_mixin.dart';

class TermsandconditionController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  final termsAndConditinDetails = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    buildLayout(_canonicalSections);
    isLayoutLoading.value = false;
    await termsAndCondition();
  }

  List<Map<String, dynamic>> get _canonicalSections {
    final canonical = TermsPageData.canonical();
    final sections = <Map<String, dynamic>>[
      {
        'type': 'rich_text',
        'id': 'terms_header',
        'content_json': {
          '_page_slug': 'terms-and-conditions',
          '_section_type': 'rich_text',
          'html_content': '<h1>Terms & Conditions</h1>',
        },
      },
    ];
    for (final b in canonical.blocks) {
      if (b.type == TermsBlockType.heading) {
        sections.add({
          'type': 'rich_text',
          'id': b.id,
          'content_json': {
            '_page_slug': 'terms-and-conditions',
            '_section_type': 'rich_text',
            'html_content': '<h3>${b.text}</h3>',
          },
        });
      } else {
        sections.add({
          'type': 'text_block',
          'id': b.id,
          'content_json': {
            '_page_slug': 'terms-and-conditions',
            '_section_type': 'text_block',
            'text': b.text,
          },
        });
      }
    }
    return sections;
  }

  Future<void> termsAndCondition() async {
    try {
      final response = await fetchLayout(
        'terms-and-conditions',
        silent: widgetList.isNotEmpty,
      );
      if (response != null && response is Map) {
        final list = response['sections'];
        if (list is List && list.isNotEmpty) return;
      }
    } catch (e) {
      debugPrint('TermsandconditionController CMS fetch error: $e');
    }

    try {
      final response = await BasicProvider('page/terms-and-condition')
          .getRequest()
          .catchError(handleError);
      if (response != null && response['content'] != null) {
        termsAndConditinDetails.value = response['content'].toString();
      }
    } catch (_) {}
  }
}
