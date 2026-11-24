import 'package:flutter/widgets.dart';
import 'package:foddu/app/controllers/api_exception_handle_controller.dart';
import 'package:foddu/app/data/basic_provider.dart';
import 'package:get/get.dart';

class HelpandsupportController extends GetxController with BaseController {
  var isLoading = false.obs;
  var faqs = [].obs;
  RxInt expandedIndex = RxInt(-1);
  final faqSearchController = TextEditingController();
  final faqSearchQuery = ''.obs;

  List<dynamic> get filteredFaqs {
    final query = faqSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return faqs.toList(growable: false);
    return faqs.where((item) {
      if (item is! Map) return false;
      final textParts = [
        item['question'],
        item['name'],
        item['title'],
        item['answer'],
        item['description'],
        item['details'],
      ];
      final details = item['faqs_detail'];
      if (details is List) {
        for (final detail in details) {
          if (detail is Map) {
            textParts.add(detail['name']);
            textParts.add(detail['question']);
            textParts.add(detail['answer']);
            textParts.add(detail['description']);
          }
        }
      }
      return textParts.any(
        (part) => part?.toString().toLowerCase().contains(query) == true,
      );
    }).toList(growable: false);
  }

  void onFaqSearchChanged(String value) {
    faqSearchQuery.value = value;
    expandedIndex.value = -1;
  }

  void clearFaqSearch() {
    faqSearchController.clear();
    onFaqSearchChanged('');
  }

  @override
  void onInit() {
    super.onInit();
    getFaqs();
  }

  @override
  void onClose() {
    faqSearchController.dispose();
    super.onClose();
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
      var response = await BasicProvider("frontend/faq")
          .getRequest()
          .catchError(handleError);
      isLoading.value = false;
      if (response == null) return;
      faqs.clear();
      if (response is List) {
        faqs.addAll(response);
      } else if (response is Map) {
        final data = response['data'] ?? response['faqs'] ?? response['docs'];
        if (data is List) {
          faqs.addAll(data);
        }
      }
    } catch (e) {
      isLoading.value = false;
      print('faq and support error $e');
    }
  }
}
