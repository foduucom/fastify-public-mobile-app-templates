import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/data/models/faq_sections.dart';
import 'package:foduu_ecommerce/app/modules/helpandsupport/controllers/helpandsupport_controller.dart';
import 'package:foduu_ecommerce/constants/foduuCachedImageNetwork.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';

class FaqTopicBadges extends StatelessWidget {
  final FaqTopicBadgesSection data;

  const FaqTopicBadges({Key? key, required this.data}) : super(key: key);

  factory FaqTopicBadges.fromMap(Map<String, dynamic> json) {
    return FaqTopicBadges(data: FaqTopicBadgesSection.fromMap(json));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final helpController = Get.isRegistered<HelpandsupportController>()
        ? Get.find<HelpandsupportController>()
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Explore Topics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                  ),
                ),
                if (helpController != null)
                  Obx(() {
                    final selected = helpController.selectedTopic.value;
                    if (selected.isEmpty) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: () => helpController.selectTopic(''),
                      child: Text(
                        'Show All',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 105,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: data.badges.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final badge = data.badges[index];
                final imageUrl = badge.image.isNotEmpty
                    ? HelperFunctions().getImage(badge.image)
                    : '';

                if (helpController != null) {
                  return Obx(() {
                    final isSelected =
                        helpController.selectedTopic.value.toLowerCase() ==
                            badge.heading.toLowerCase();
                    return _buildBadgeCard(
                      context: context,
                      badge: badge,
                      imageUrl: imageUrl,
                      isSelected: isSelected,
                      onTap: () {
                        if (isSelected) {
                          helpController.selectTopic('');
                        } else {
                          helpController.selectTopic(badge.heading);
                        }
                      },
                    );
                  });
                }

                return _buildBadgeCard(
                  context: context,
                  badge: badge,
                  imageUrl: imageUrl,
                  isSelected: false,
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard({
    required BuildContext context,
    required FaqTopicBadge badge,
    required String imageUrl,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: isDark ? 0.22 : 0.1)
              : (isDark
                  ? colorScheme.surfaceContainerHigh
                  : colorScheme.surface),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant
                    .withValues(alpha: isDark ? 0.3 : 0.5),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: isSelected ? 10 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (imageUrl.isNotEmpty)
                  FoduuCachedNetworkImage(
                    image: imageUrl,
                    height: 28,
                    width: 28,
                    fit: BoxFit.contain,
                    colorFilter: isSelected
                        ? ColorFilter.mode(colorScheme.primary, BlendMode.srcIn)
                        : null,
                  )
                else
                  Icon(
                    Icons.folder_outlined,
                    size: 24,
                    color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.heading,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  badge.articleCount,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
