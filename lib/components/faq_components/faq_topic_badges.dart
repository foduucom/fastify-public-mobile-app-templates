import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/data/models/faq_sections.dart';
import 'package:foduu_ecommerce/constants/foduuCachedImageNetwork.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Explore Topics',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 132,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: data.badges.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final badge = data.badges[index];
                final imageUrl = badge.image.isNotEmpty
                    ? HelperFunctions().getImage(badge.image)
                    : '';

                return _buildTopic(
                  context,
                  badge,
                  imageUrl,
                  isSelected: false,
                  onTap: null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopic(
    BuildContext context,
    FaqTopicBadge badge,
    String imageUrl, {
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isSelected ? colorScheme.primary : colorScheme.onSurface;
    final circleColor = isSelected
        ? colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1)
        : colorScheme.surface;

    return Semantics(
      button: onTap != null,
      selected: isSelected,
      label: '${badge.heading}. ${badge.articleCount}',
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 92,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant
                                .withValues(alpha: isDark ? 0.55 : 0.28),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.16 : 0.035,
                          ),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: imageUrl.isNotEmpty
                          ? FoduuCachedNetworkImage(
                              image: imageUrl,
                              height: 32,
                              width: 32,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                iconColor,
                                BlendMode.srcIn,
                              ),
                            )
                          : Icon(
                              Icons.folder_outlined,
                              size: 30,
                              color: iconColor,
                            ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    badge.heading,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    badge.articleCount,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
