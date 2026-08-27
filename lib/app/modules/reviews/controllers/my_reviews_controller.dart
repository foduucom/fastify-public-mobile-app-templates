import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
      var response = await BasicProvider("customer-reviews")
          .getRequest()
          .catchError(handleError);

      reviewsList.clear();
      if (response is List) {
        reviewsList.addAll(response.map((e) => _normalizeReview(e)));
      } else if (response is Map && response['data'] is List) {
        reviewsList
            .addAll((response['data'] as List).map((e) => _normalizeReview(e)));
      }
    } catch (e) {
      debugPrint('fetchReviews error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _normalizeReview(dynamic item) {
    final product = item['product_id'];
    final productName =
        product is Map ? (product['name']?.toString() ?? '') : '';
    final productSlug =
        product is Map ? (product['slug']?.toString() ?? '') : '';
    final productImage = product is Map
        ? HelperFunctions().getImage(product['featured_image'])
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
      await BasicProvider("product-reviews/$id")
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
