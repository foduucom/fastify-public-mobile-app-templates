import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/data/models/faq_sections.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/foduuCachedImageNetwork.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';

class FaqStillStuckCard extends StatelessWidget {
  final FaqStillStuckData data;

  const FaqStillStuckCard({Key? key, required this.data}) : super(key: key);

  factory FaqStillStuckCard.fromMap(Map<String, dynamic> json) {
    return FaqStillStuckCard(
      data: FaqStillStuckData.fromMap(json),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                    colorScheme.surfaceVariant,
                    colorScheme.surface,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: colorScheme.outlineVariant
                .withValues(alpha: isDark ? 0.35 : 0.5),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subtitle pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            data.subtitle,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.heading,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (imageUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: FoduuCachedNetworkImage(
                        image: imageUrl,
                        height: 68,
                        width: 68,
                        fit: BoxFit.contain,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                data.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  height: 1.45,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              // Action Buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed(Routes.CONTACT);
                    },
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text(
                      'Open Direct Ticket',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      minimumSize: const Size.fromHeight(48),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => Get.toNamed(Routes.SEARCH),
                    icon: const Icon(Icons.forum_outlined, size: 16),
                    label: const Text(
                      'Search Community',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(
                        color: colorScheme.outlineVariant
                            .withValues(alpha: isDark ? 0.4 : 0.7),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
  }
}
