import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class HelpandsupportController extends GetxController with BaseController {
  var isLoading = false.obs;
  var faqs = [].obs;
  final loadError = false.obs;
  final searchQuery = ''.obs;
  RxInt expandedIndex = RxInt(-1);

  List<dynamic> get filteredFaqs {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return faqs.toList();
    return faqs.where((faq) {
      if (faq is! Map) return false;
      final fields = [
        faq['question'],
        faq['name'],
        faq['title'],
        faq['answer'],
        faq['description'],
        faq['details']
      ];
      final parentMatches = fields.any(
          (value) => value?.toString().toLowerCase().contains(query) == true);
      final children = faq['faqs_detail'];
      final childMatches = children is List &&
          children.any((child) =>
              child is Map &&
              [
                child['question'],
                child['name'],
                child['answer'],
                child['description']
              ].any((value) =>
                  value?.toString().toLowerCase().contains(query) == true));
      return parentMatches || childMatches;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    getFaqs();
  }

  void toggleExpansion(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1;
    } else {
      expandedIndex.value = index;
    }
  }

  Future<void> getFaqs() async {
    try {
      isLoading.value = true;
      loadError.value = false;
      var response = await BasicProvider("frontend/faq")
          .getRequest()
          .catchError(handleError);
      final nextFaqs = _extractFaqs(response);
      if (nextFaqs == null) {
        loadError.value = true;
        return;
      }
      faqs.assignAll(nextFaqs);
    } catch (e) {
      loadError.value = true;
      debugPrint('FAQ load failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<dynamic>? _extractFaqs(dynamic response) {
    if (response is List) return response;
    if (response is! Map) return null;
    final status = response['status']?.toString().toLowerCase();
    if (response['success'] == false ||
        status == 'error' ||
        status == 'failed' ||
        status == 'failure') {
      return null;
    }
    for (final key in ['faqs', 'data', 'docs', 'results', 'items']) {
      if (!response.containsKey(key)) continue;
      final value = response[key];
      if (value is List) return value;
      if (value is Map) {
        final nested = _extractFaqs(value);
        if (nested != null) return nested;
      }
    }
    return null;
  }
}
