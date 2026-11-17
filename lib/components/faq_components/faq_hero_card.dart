import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/data/models/faq_sections.dart';
import 'package:foduu_ecommerce/constants/foduuCachedImageNetwork.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

class FaqHeroCard extends StatelessWidget {
  final FaqHeroData data;

  const FaqHeroCard({Key? key, required this.data}) : super(key: key);

  factory FaqHeroCard.fromMap(Map<String, dynamic> json) {
    return FaqHeroCard(data: FaqHeroData.fromMap(json));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final imageUrl = data.imagePath.isNotEmpty
        ? HelperFunctions().getImage(data.imagePath)
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    colorScheme.surfaceContainerHigh,
                    colorScheme.surface,
                  ]
                : [
                    colorScheme.primary.withValues(alpha: 0.08),
                    colorScheme.surface,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: colorScheme.outlineVariant
                .withValues(alpha: isDark ? 0.3 : 0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.help_center_outlined,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      data.title.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Subheading
              Text(
                data.subtitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 21,
                  height: 1.25,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                data.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  height: 1.45,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (imageUrl.isNotEmpty) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: FoduuCachedNetworkImage(
                      image: imageUrl,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
