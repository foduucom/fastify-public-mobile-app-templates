import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '/app/modules/shop/shop_navigation.dart';
import '/constants/helper_functions.dart';

/// Dual Promotional Deals Component matching the Parent Website's
/// `.dual-promo-section` (Light + Dark editorial contrast cards with
/// right-aligned product imagery and backend `colorScheme` tokens).
class DualPromotionalDealsWidget extends StatelessWidget {
  final Map<String, dynamic> sliderData;

  const DualPromotionalDealsWidget({Key? key, required this.sliderData})
      : super(key: key);

  List<Map<String, dynamic>> _getItems() {
    final slider = sliderData['slider'];
    if (slider is Map) {
      final content = slider['content'];
      if (content is List) {
        return content
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return [];
  }

  IconData _extractIcon(String heading) {
    final lower = heading.toLowerCase();
    if (lower.contains('camera')) return Icons.camera_alt_outlined;
    if (lower.contains('bolt') ||
        lower.contains('sale') ||
        lower.contains('flash') ||
        lower.contains('weekend')) {
      return Icons.bolt_rounded;
    }
    if (lower.contains('audio') || lower.contains('headphone')) {
      return Icons.headphones_outlined;
    }
    return Icons.local_offer_outlined;
  }

  String _cleanText(String s) {
    return s
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _handleTap(Map<String, dynamic> item) {
    final title = _cleanText(
        (item['sub_heading'] ?? item['heading'] ?? 'Deals').toString());
    openShop({'name': title, 'source': 'promotional_deals'});
  }

  @override
  Widget build(BuildContext context) {
    final items = _getItems();
    if (items.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        height: 232,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final item = items[index];
            final rawHeading = (item['heading'] ?? '').toString();
            final rawSub = (item['sub_heading'] ?? '').toString();
            final rawDesc = (item['description'] ?? '').toString();

            final badgeText = _cleanText(rawHeading);
            final badgeIcon = _extractIcon(rawHeading);
            final title = _cleanText(rawSub);
            final desc = _cleanText(rawDesc);
            final buttonText =
                _cleanText((item['button_text'] ?? '').toString());

            final imageUrl = HelperFunctions().getImage(item);
            final hasImage = imageUrl.isNotEmpty &&
                imageUrl != HelperFunctions.getNoImage();

            // Parent website Light + Dark editorial pairing derived from theme
            final isDarkEditorial = index.isOdd;
            final cardBg = isDarkEditorial
                ? (isDark
                    ? colorScheme.surfaceVariant
                    : colorScheme.inverseSurface)
                : (isDark
                    ? colorScheme.surface
                    : colorScheme.surfaceVariant.withOpacity(0.32));

            final cardBorder = isDarkEditorial
                ? colorScheme.outline.withOpacity(0.22)
                : colorScheme.outline.withOpacity(0.18);

            final titleColor = isDarkEditorial
                ? (isDark ? colorScheme.onSurface : colorScheme.onInverseSurface)
                : colorScheme.onSurface;

            final subtitleColor = isDarkEditorial
                ? titleColor.withOpacity(0.75)
                : colorScheme.onSurfaceVariant;

            final badgeBg = isDarkEditorial
                ? Colors.white.withOpacity(0.12)
                : colorScheme.surface;

            final badgeBorder = isDarkEditorial
                ? Colors.white.withOpacity(0.18)
                : colorScheme.outline.withOpacity(0.18);

            final badgeFg = isDarkEditorial ? titleColor : colorScheme.onSurface;

            final ctaBg =
                isDarkEditorial ? Colors.white : colorScheme.primary;
            final ctaFg =
                isDarkEditorial ? Colors.black87 : colorScheme.onPrimary;

            final ctaLabel = buttonText.isNotEmpty
                ? buttonText
                : (isDarkEditorial ? 'Explore Deals' : 'Shop Collection');

            return GestureDetector(
              onTap: () => _handleTap(item),
              child: Container(
                width: (Get.width * 0.85).clamp(290.0, 360.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: cardBg,
                  border: Border.all(color: cardBorder, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.28 : 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Right-anchored product artwork (matching parent site)
                      if (hasImage)
                        Positioned(
                          right: -12,
                          top: 12,
                          bottom: 12,
                          width: 148,
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,
                            alignment: Alignment.centerRight,
                            errorWidget: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),

                      // Soft directional fade so left copy stays 100% legible
                      if (hasImage)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  cardBg,
                                  cardBg.withOpacity(0.92),
                                  cardBg.withOpacity(0.15),
                                ],
                                stops: const [0.0, 0.56, 1.0],
                              ),
                            ),
                          ),
                        ),

                      // Left editorial content column
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SizedBox(
                          width: hasImage ? 195 : double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (badgeText.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                        color: badgeBorder, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        badgeIcon,
                                        size: 13,
                                        color: isDarkEditorial
                                            ? Colors.amber.shade300
                                            : colorScheme.primary,
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          badgeText.toUpperCase(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: badgeFg,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 12),

                              // Title
                              Text(
                                title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: titleColor,
                                  letterSpacing: -0.3,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),

                              // Description
                              if (desc.isNotEmpty)
                                Text(
                                  desc,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: subtitleColor,
                                    height: 1.38,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const Spacer(),

                              // Pill CTA matching parent website
                              ElevatedButton(
                                onPressed: () => _handleTap(item),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ctaBg,
                                  foregroundColor: ctaFg,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  minimumSize: const Size(0, 36),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      ctaLabel,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: ctaFg,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: ctaFg,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
