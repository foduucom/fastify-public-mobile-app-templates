import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:zouhi/components/product_image_placeholder.dart';
import '../controllers/my_reviews_controller.dart';

class MyReviewsView extends GetView<MyReviewsController> {
  const MyReviewsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'My Reviews',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: context.themeTextColor,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: context.themeTextColor, size: 20),
            onPressed: () => Get.back(),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            controller.fetchReviews();
          },
          color: themePrimaryColor,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: themePrimaryColor,
                ),
              );
            }

            if (controller.reviewsList.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12.0),
              itemCount: controller.reviewsList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = controller.reviewsList[index];
                return _buildReviewCard(context, item);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: Get.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.themegreyColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rate_review_outlined,
                  size: 80,
                  color: context.themeSecondrytext,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Reviews Found',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: context.themeTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You haven\'t reviewed any products yet.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: context.themeSecondrytext,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(BuildContext context, Map<String, dynamic> item) {
    final int ratingValue = item['rating'];

    return Container(
      decoration: BoxDecoration(
        color: context.themeWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.themeBorderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 65,
                    height: 65,
                    color: context.themegreyColor,
                    child: CachedNetworkImage(
                      imageUrl: item['productImage'] ?? '',
                      width: 65,
                      height: 65,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        width: 65,
                        height: 65,
                        color: context.themegreyColor,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: themePrimaryColor,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const SizedBox(
                        width: 65,
                        height: 65,
                        child: ProductImagePlaceholder(radius: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['productName'],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: context.themeTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            Icons.star_rounded,
                            color: index < ratingValue
                                ? const Color(0xFFFFA800)
                                : const Color(0xFFEDEFF4),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                // Submission Date
                Text(
                  item['submittedAt'],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: context.themeSecondrytext,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionIconButton(
                  icon: Icons.visibility_outlined,
                  color: themePrimaryColor,
                  onPressed: () => _showReviewDetailsDialog(context, item),
                ),
                const SizedBox(width: 8),
                _buildActionIconButton(
                  icon: Icons.edit_outlined,
                  color: themePrimaryColor,
                  onPressed: () => _showEditReviewDialog(context, item),
                ),
                const SizedBox(width: 8),
                // Delete button (Trash icon)
                _buildActionIconButton(
                  icon: Icons.delete_outline_rounded,
                  color: themeRedColor,
                  onPressed: () =>
                      controller.confirmDeleteReview(context, item['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.15), width: 0.6),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        color: color,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }

  void _showReviewDetailsDialog(
      BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: context.themeWhiteColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Review Details',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: context.themeTextColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          size: 22, color: context.themeTextColor),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Divider(color: context.themeBorderColor, thickness: 1),
                const SizedBox(height: 8),
                // Product Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 50,
                        height: 50,
                        color: context.themegreyColor,
                        child: CachedNetworkImage(
                          imageUrl: item['productImage'] ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                          errorWidget: (context, url, error) => const SizedBox(
                            width: 50,
                            height: 50,
                            child: ProductImagePlaceholder(radius: 6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['productName'],
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: context.themeTextColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                Icons.star_rounded,
                                color: index < item['rating']
                                    ? const Color(0xFFFFA800)
                                    : const Color(0xFFEDEFF4),
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Review:',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: context.themeTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                // Review Text Body
                Flexible(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.themegreyColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: context.themeBorderColor, width: 0.6),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        item['reviewComment'],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          height: 1.4,
                          color: context.themeTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Close button
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themePrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditReviewDialog(BuildContext context, Map<String, dynamic> item) {
    int localRating = item['rating'];
    final commentController =
        TextEditingController(text: item['reviewComment']);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: context.themeWhiteColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Review',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: context.themeTextColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            size: 22, color: context.themeTextColor),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  Divider(color: context.themeBorderColor, thickness: 1),
                  const SizedBox(height: 10),
                  // Rating selection (StatefulBuilder)
                  Text(
                    'Your Rating:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: context.themeTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: StatefulBuilder(
                      builder: (context, setLocalState) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                setLocalState(() {
                                  localRating = index + 1;
                                });
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Icon(
                                  Icons.star_rounded,
                                  color: index < localRating
                                      ? const Color(0xFFFFA800)
                                      : const Color(0xFFEDEFF4),
                                  size: 36,
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Review Comment input
                  Text(
                    'Review Comment:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: context.themeTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: commentController,
                    maxLines: 4,
                    style:
                        TextStyle(color: context.themeTextColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText:
                          'Share details of your experience with this product...',
                      hintStyle: TextStyle(
                          color: context.themeSecondrytext, fontSize: 13),
                      contentPadding: const EdgeInsets.all(12),
                      fillColor: context.themegreyColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: context.themeBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: themePrimaryColor),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a review comment';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: context.themeBorderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: context.themeSecondrytext,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.of(context).pop();
                              controller.updateReview(
                                item['id'],
                                localRating,
                                commentController.text,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themePrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
