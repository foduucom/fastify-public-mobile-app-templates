import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

class MyQuotesRequestController extends GetxController {
  final isLoading = false.obs;
  final quoteRequests = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchQuoteRequests();
  }

  Future<void> fetchQuoteRequests() async {
    isLoading.value = true;
    try {
      final response = await BasicProvider('customer/quotes').getRequest();
      if (response != null && response is List) {
        final list = response
            .map((item) {
              if (item is Map) {
                return _normalizeQuote(Map<String, dynamic>.from(item));
              }
              return <String, dynamic>{};
            })
            .where((element) => element.isNotEmpty)
            .toList();
        quoteRequests.assignAll(list);
      } else {
        quoteRequests.clear();
      }
    } catch (e) {
      debugPrint("Error fetching quote requests: $e");
      quoteRequests.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _normalizeQuote(Map<String, dynamic> item) {
    final productId = item['product_id'] as Map<String, dynamic>?;
    final value = item['value'] as Map<String, dynamic>? ?? {};

    final id = item['id']?.toString() ?? item['_id']?.toString() ?? '';
    final productName =
        productId?['name']?.toString() ?? 'Product Quote Request';
    final description = productName;

    // Resolve image URL
    final productImage =
        HelperFunctions().getImage(productId?['featured_image']);

    final quantity = value['quantity']?.toString() ?? '0';
    final urgency = value['urgency']?.toString() ?? 'flexible';
    final additionalRequirements =
        value['additional_requirements']?.toString() ?? '';

    String submittedAt = '';
    if (item['created_at'] != null) {
      try {
        final parsedDate =
            DateTime.parse(item['created_at'].toString()).toLocal();
        submittedAt = DateFormat('dd MMM yyyy').format(parsedDate);
      } catch (e) {
        submittedAt = item['created_at'].toString();
      }
    }

    return {
      'id': id,
      'productName': productName,
      'description': description,
      'productImage': productImage,
      'quantity': quantity,
      'urgency': urgency,
      'submittedAt': submittedAt,
      'additionalRequirements': additionalRequirements,
    };
  }

  void confirmDeleteQuote(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Delete Quote Request',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          ),
          content: const Text(
            'Are you sure you want to delete this quote request? This action cannot be undone.',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: context.themeSecondrytext,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteQuote(id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.themeRedColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(
                'Delete',
                style: TextStyle(
                    color: context.colors.onPrimary,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteQuote(String id) async {
    isLoading.value = true;
    try {
      final response =
          await BasicProvider('customer/quotes/$id').deleteRequest();
      if (response != null) {
        quoteRequests.removeWhere((item) => item['id'] == id);
        HelperFunctions()
            .showSnackBarSuccess('Quote request deleted successfully');
      } else {
        HelperFunctions().showSnackBarError('Failed to delete quote request');
      }
    } catch (e) {
      debugPrint('deleteQuote error: $e');
      HelperFunctions().showSnackBarError('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
