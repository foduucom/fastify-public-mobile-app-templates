import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

class MyReviewsController extends GetxController {
  final isLoading = false.obs;
  final reviewsList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    isLoading.value = true;
    try {
      final response = await BasicProvider('customer/reviews')
          .getRequest(queryParams: {'page': '1', 'limit': '50'});
      List? rawList;
      if (response != null) {
        if (response is List) {
          rawList = response;
        } else if (response is Map && response['reviews'] is List) {
          rawList = response['reviews'] as List;
        } else if (response is Map && response['data'] is List) {
          rawList = response['data'] as List;
        }
      }

      if (rawList != null) {
        final list = rawList
            .map((item) {
              if (item is Map) {
                return _normalizeReview(Map<String, dynamic>.from(item));
              }
              return <String, dynamic>{};
            })
            .where((element) => element.isNotEmpty)
            .toList();
        reviewsList.assignAll(list);
      } else {
        reviewsList.clear();
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
      reviewsList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _normalizeReview(Map<String, dynamic> item) {
    final rawProduct = item['product'] ?? item['product_id'];
    final productId =
        rawProduct is Map ? Map<String, dynamic>.from(rawProduct) : null;

    final id = item['id']?.toString() ?? item['_id']?.toString() ?? '';
    final productName = productId?['name']?.toString() ?? 'Product';
    final description = productId?['slug']?.toString() ?? productName;

    // Resolve image URL
    final productImage = HelperFunctions()
        .getImage(productId?['image'] ?? productId?['featured_image']);

    final rating = item['rating'] is int
        ? item['rating']
        : int.tryParse(item['rating']?.toString() ?? '5') ?? 5;
    final reviewComment = item['comment']?.toString() ?? '';

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
      'rating': rating,
      'submittedAt': submittedAt,
      'reviewComment': reviewComment,
    };
  }

  void confirmDeleteReview(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Delete Review',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          ),
          content: const Text(
            'Are you sure you want to delete this review? This action cannot be undone.',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: context.themeSecondrytext, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteReview(id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.themeRedColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(
                'Delete',
                style: TextStyle(color: context.colors.onPrimary, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteReview(String id) async {
    isLoading.value = true;
    try {
      final response =
          await BasicProvider('customer/reviews/$id').deleteRequest();
      if (response != null) {
        reviewsList.removeWhere((item) => item['id'] == id);
        HelperFunctions().showSnackBarSuccess('Review deleted successfully');
      } else {
        HelperFunctions().showSnackBarError('Failed to delete review');
      }
    } catch (e) {
      debugPrint('deleteReview error: $e');
      HelperFunctions().showSnackBarError('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateReview(String id, int newRating, String newComment) async {
    isLoading.value = true;
    try {
      final response = await BasicProvider('customer/reviews/$id')
          .patchRequest({'rating': newRating, 'comment': newComment});
      if (response != null) {
        final index = reviewsList.indexWhere((item) => item['id'] == id);
        if (index != -1) {
          reviewsList[index]['rating'] = newRating;
          reviewsList[index]['reviewComment'] = newComment;
          reviewsList.refresh();
        }
        HelperFunctions().showSnackBarSuccess('Review updated successfully');
      } else {
        HelperFunctions().showSnackBarError('Failed to update review');
      }
    } catch (e) {
      debugPrint('updateReview error: $e');
      HelperFunctions().showSnackBarError('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
