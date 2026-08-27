import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/my_reviews_controller.dart';

class MyReviewsView extends GetView<MyReviewsController> {
  const MyReviewsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Reviews'),
          elevation: 0,
        ),
        body: RefreshIndicator(
          color: colorScheme.primary,
          onRefresh: () => controller.fetchReviews(),
          child: Obx(() {
            if (controller.isLoading.isTrue && controller.reviewsList.isEmpty) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const _ReviewCardShimmer(),
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
                  onView: () => _showReviewDetailsDialog(context, review, colorScheme, textTheme),
                  onDelete: () => controller.confirmDeleteReview(context, review['id']),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  void _showReviewDetailsDialog(BuildContext context, Map<String, dynamic> review,
      ColorScheme colorScheme, TextTheme textTheme) {
    Get.dialog(
      Dialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(review['product_name'] ?? '',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _StarRow(rating: review['rating'] as int),
              const SizedBox(height: 12),
              Text(
                review['comment'] ?? '',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.8)),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
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
    required this.onView,
    required this.onDelete,
  });

  final Map<String, dynamic> review;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onView;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: review['product_image'] ?? '',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 64,
                height: 64,
                color: colorScheme.onSurface.withOpacity(0.06),
              ),
              errorWidget: (_, __, ___) => Container(
                width: 64,
                height: 64,
                color: colorScheme.onSurface.withOpacity(0.06),
                child: Icon(Icons.image_not_supported_outlined,
                    color: colorScheme.onSurface.withOpacity(0.3)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review['product_name'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                _StarRow(rating: review['rating'] as int),
                const SizedBox(height: 4),
                if ((review['created_at'] as String).isNotEmpty)
                  Text(
                    review['created_at'],
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              _CircleIconButton(icon: Icons.visibility_outlined, colorScheme: colorScheme, onTap: onView),
              const SizedBox(height: 8),
              _CircleIconButton(
                icon: Icons.delete_outline_rounded,
                colorScheme: colorScheme,
                isDestructive: true,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.colorScheme,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final ColorScheme colorScheme;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? colorScheme.error : colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});
  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
          size: 16,
          color: index < rating ? const Color(0xFFFFBA49) : const Color(0xFFEDEFF4),
        );
      }),
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
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.rate_review_outlined, size: 48, color: colorScheme.onSurface.withOpacity(0.35)),
          ),
          const SizedBox(height: 20),
          Text(
            'No Reviews Found',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Reviews you write for products will show up here.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}

class _ReviewCardShimmer extends StatelessWidget {
  const _ReviewCardShimmer();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.onSurface.withOpacity(0.06);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(10))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, width: double.infinity, color: base),
                const SizedBox(height: 8),
                Container(height: 10, width: 100, color: base),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
