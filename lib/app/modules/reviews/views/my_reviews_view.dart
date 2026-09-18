import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/my_reviews_controller.dart';

class MyReviewsView extends GetView<MyReviewsController> {
  const MyReviewsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Reviews'),
          centerTitle: true,
          elevation: 0,
        ),
        body: RefreshIndicator(
          color: theme.primaryColor,
          onRefresh: () => controller.fetchReviews(),
          child: Obx(() {
            if (controller.isLoading.isTrue && controller.reviewsList.isEmpty) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => _ReviewCardShimmer(colorScheme: colorScheme),
              );
            }

            if (controller.reviewsList.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: _EmptyState(colorScheme: colorScheme, textTheme: textTheme),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.reviewsList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final review = controller.reviewsList[index];
                return _ReviewCard(
                  review: review,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  onDelete: () => controller.confirmDeleteReview(context, review['id']),
                  onProductTap: () {
                    final slug = review['product_slug'];
                    if (slug != null && slug.toString().isNotEmpty) {
                      Get.toNamed(Routes.PRODUCTDETAILS, arguments: {'slug': slug});
                    }
                  },
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.colorScheme,
    required this.textTheme,
    required this.onDelete,
    required this.onProductTap,
  });

  final Map<String, dynamic> review;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onDelete;
  final VoidCallback onProductTap;

  @override
  Widget build(BuildContext context) {
    final productName = review['product_name'] ?? 'Product';
    final productImage = review['product_image'] ?? '';
    final rating = (review['rating'] as int?) ?? 5;
    final comment = review['comment'] ?? '';
    final date = review['created_at'] ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onProductTap,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: productImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 50,
                      height: 50,
                      color: colorScheme.onSurface.withOpacity(0.05),
                      child: Icon(Icons.image_not_supported, size: 24, color: colorScheme.onSurface.withOpacity(0.3)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < rating ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              comment,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.8)),
            ),
          ],
          if (date.isNotEmpty) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                date,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colorScheme, required this.textTheme});
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: colorScheme.onSurface.withOpacity(0.06), shape: BoxShape.circle),
            child: Icon(Icons.rate_review_outlined, size: 48, color: colorScheme.onSurface.withOpacity(0.35)),
          ),
          const SizedBox(height: 20),
          Text('No Reviews Yet', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Reviews you submit for products will appear here.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}

class _ReviewCardShimmer extends StatelessWidget {
  const _ReviewCardShimmer({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? colorScheme.surfaceVariant : Colors.grey.shade300;
    final highlight = isDark ? colorScheme.surface : Colors.white;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(width: 50, height: 50, color: base),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 120, color: base),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 80, color: base),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
