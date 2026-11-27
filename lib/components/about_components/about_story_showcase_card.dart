import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/shop/shop_navigation.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/foduuCachedImageNetwork.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

/// Story & Founder showcase card for the About Us page
/// (`slider` with slug `about-us-second-slider`).
///
/// Parses the HTML-embedded floating stat pills (`12+ Years of Excellence`,
/// `500k+ Happy Tech Buyers`), CTA button (`Explore Our Gear`), and founder
/// badge (`Marcus Vance — Founder & CEO`) into native Flutter widgets.
class AboutStoryShowcaseCard extends StatelessWidget {
  final Map<String, dynamic> contentJson;

  const AboutStoryShowcaseCard({super.key, required this.contentJson});

  static String _extractTagText(String html, String className) {
    final pattern = RegExp(
      'class=["\'][^"\']*\\b$className\\b[^"\']*["\'][^>]*>(.*?)</',
      caseSensitive: false,
      dotAll: true,
    );
    final match = pattern.firstMatch(html);
    if (match == null) return '';
    return _stripHtml(match.group(1) ?? '');
  }

  static String _extractImgSrc(String html) {
    final match = RegExp(
      '<img[^>]+src=["\']([^"\']+)["\']',
      caseSensitive: false,
    ).firstMatch(html);
    return (match?.group(1) ?? '').trim();
  }

  static String _extractCtaLabel(String html) {
    final match = RegExp(
      '<a[^>]*>(.*?)</a>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    if (match == null) return '';
    return _stripHtml(match.group(1) ?? '');
  }

  static String _stripHtml(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final slider = contentJson['slider'];
    final content = slider is Map ? slider['content'] : null;
    final Map first = (content is List && content.isNotEmpty && content.first is Map)
        ? content.first as Map
        : const {};

    final rawPath = (first['filePath'] ??
            first['download_url'] ??
            first['url'] ??
            '')
        .toString()
        .trim();
    final imageUrl =
        rawPath.isNotEmpty ? HelperFunctions().getImage(rawPath) : '';

    final headingHtml = (first['heading'] ?? '').toString();
    final subHeadingHtml = (first['sub_heading'] ?? '').toString();
    final descHtml = (first['description'] ?? '').toString();

    final topNum = _extractTagText(headingHtml, 'floating-num');
    final topLabel = _extractTagText(headingHtml, 'floating-label');

    final bottomNum = _extractTagText(subHeadingHtml, 'floating-num');
    final bottomLabel = _extractTagText(subHeadingHtml, 'floating-label');

    final ctaLabel = _extractCtaLabel(descHtml);
    final founderAvatar = _extractImgSrc(descHtml);
    final founderName = _extractTagText(descHtml, 'founder-name');
    final founderRole = _extractTagText(descHtml, 'founder-role');

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: context.outlineColor.withValues(alpha: 0.14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: double.infinity,
                    height: 210,
                    child: imageUrl.isNotEmpty
                        ? FoduuCachedNetworkImage(
                            image: imageUrl,
                            fit: BoxFit.cover,
                            radius: 14,
                          )
                        : Container(
                            color: context.primaryColor.withValues(alpha: 0.08),
                            child: Icon(
                              Icons.devices_other_rounded,
                              size: 48,
                              color: context.primaryColor,
                            ),
                          ),
                  ),
                ),
                if (topNum.isNotEmpty)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _FloatingStatPill(
                      icon: Icons.emoji_events_rounded,
                      number: topNum,
                      label: topLabel,
                    ),
                  ),
                if (bottomNum.isNotEmpty)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: _FloatingStatPill(
                      icon: Icons.groups_rounded,
                      number: bottomNum,
                      label: bottomLabel,
                    ),
                  ),
              ],
            ),
            if (ctaLabel.isNotEmpty || founderName.isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (ctaLabel.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => openShop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        foregroundColor: context.onPrimaryColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.shopping_bag_outlined, size: 15),
                      label: Text(
                        ctaLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (ctaLabel.isNotEmpty && founderName.isNotEmpty)
                    const SizedBox(width: 10),
                  if (founderName.isNotEmpty)
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  context.primaryColor.withValues(alpha: 0.10),
                              border: Border.all(
                                color: context.primaryColor
                                    .withValues(alpha: 0.25),
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: founderAvatar.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: founderAvatar.startsWith('http')
                                          ? founderAvatar
                                          : HelperFunctions()
                                              .getImage(founderAvatar),
                                      width: 38,
                                      height: 38,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Icon(
                                        Icons.person_rounded,
                                        size: 20,
                                        color: context.primaryColor,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person_rounded,
                                      size: 20,
                                      color: context.primaryColor,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  founderName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: context.onSurfaceColor,
                                  ),
                                ),
                                if (founderRole.isNotEmpty)
                                  Text(
                                    founderRole,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: context.onSurfaceColor
                                          .withValues(alpha: 0.65),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FloatingStatPill extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;

  const _FloatingStatPill({
    required this.icon,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: context.surfaceColor.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.outlineColor.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: context.primaryColor),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                number,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: context.onSurfaceColor,
                  height: 1.1,
                ),
              ),
              if (label.isNotEmpty)
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: context.onSurfaceColor.withValues(alpha: 0.70),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
