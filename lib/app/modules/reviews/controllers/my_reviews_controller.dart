import 'package:flutter/material.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/constants/helper_functions.dart';
import '/constants/product_helper.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Ported near-verbatim from SOURCE's MyReviewsController (data-fetch/delete logic
// unchanged); restyling lives entirely in my_reviews_view.dart.
// TODO(backend-contract): confirm the `customer/reviews` list/delete endpoints
// against the live API — this app doesn't otherwise call them anywhere else, so
// there's no existing TARGET call site to cross-check against.
class MyReviewsController extends GetxController with BaseController {
  var isLoading = false.obs;
  var reviewsList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      isLoading.value = true;
      var response = await BasicProvider("customer/reviews")
          .getRequest(queryParams: {'page': 1, 'limit': 50})
          .catchError(handleError);

      reviewsList.clear();
      List rawReviews = [];
      if (response is List) {
        rawReviews = response;
      } else if (response is Map) {
        final reviews = response['reviews'] ?? response['data'] ?? response['docs'];
        if (reviews is List) {
          rawReviews = reviews;
        } else if (reviews is Map && reviews['reviews'] is List) {
          rawReviews = reviews['reviews'];
        }
      }
      reviewsList.addAll(rawReviews.whereType<Map>().map((e) => _normalizeReview(e)));
    } catch (e) {
      debugPrint('fetchReviews error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _normalizeReview(dynamic item) {
    final product = item['product'];
    final productName =
        product is Map ? (product['name']?.toString() ?? '') : '';
    final productSlug =
        product is Map ? (product['slug']?.toString() ?? '') : '';
    final productImage = product is Map
        ? ProductHelper.getProductImage(Map<String, dynamic>.from(product))
        : HelperFunctions.getNoImage();

    String formattedDate = '';
    final createdAt = item['created_at']?.toString();
    if (createdAt != null && createdAt.isNotEmpty) {
      final parsed = DateTime.tryParse(createdAt);
      if (parsed != null) {
        formattedDate = DateFormat('dd MMM yyyy').format(parsed);
      }
    }

    return {
      'id': (item['id'] ?? item['_id']).toString(),
      'product_name': productName,
      'product_slug': productSlug,
      'product_image': productImage,
      'rating': int.tryParse((item['rating'] ?? 5).toString()) ?? 5,
      'comment': item['comment']?.toString() ?? '',
      'created_at': formattedDate,
    };
  }

  void confirmDeleteReview(BuildContext context, String id) {
    final colorScheme = Theme.of(context).colorScheme;
    Get.dialog(
      AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('Delete Review',
            style: TextStyle(color: colorScheme.onSurface)),
        content: Text(
          'Are you sure you want to delete this review?',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel',
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              deleteReview(id);
            },
            child: Text('Delete', style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
  }

  Future<void> deleteReview(String id) async {
    try {
      await BasicProvider("customer/reviews/$id")
          .deleteRequest()
          .catchError(handleError);
      reviewsList.removeWhere((element) => element['id'] == id);
      HelperFunctions().showSnackBarSuccess('Review deleted successfully');
    } catch (e) {
      debugPrint('deleteReview error: $e');
      HelperFunctions().showSnackBarError('Failed to delete review');
    }
  }
}
