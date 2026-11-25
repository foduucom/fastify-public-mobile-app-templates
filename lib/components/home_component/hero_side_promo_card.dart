import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '/app/modules/shop/shop_navigation.dart';
import '/app/routes/app_pages.dart';
import '/constants/constants.dart';
import '/constants/dynamic_theme.dart';
import '/constants/helper_functions.dart';

/// Hero Side Promo Card matching the Parent Website's Hero Side Banner (.hero-side-banner).
/// Features:
/// - Top floating pill badge: Save $XX.XX (dark capsule) + Special Offer
/// - Device showcase visual with gradient overlay
/// - Bottom frosted glass card (.hero-side-floating-card):
///   - Category (e.g. SmartPhone)
///   - Product Title (e.g. Apple iPad Mini G2356)
///   - Pricing: Strikethrough old price ($1,250.00) + Bold new price ($1,050.00)
///   - "Buy Now" button with shopping cart icon
class HeroSidePromoCard extends StatelessWidget {
  final Map<String, dynamic> sliderData;

  const HeroSidePromoCard({Key? key, required this.sliderData})
      : super(key: key);

  Map<String, dynamic> _getFirstItem() {
    final slider = sliderData['slider'];
    if (slider is Map) {
      final content = slider['content'];
      if (content is List && content.isNotEmpty && content.first is Map) {
        return Map<String, dynamic>.from(content.first);
      }
    }
    return {};
  }

  String _extractBadgeSave(String heading) {
    final match = RegExp(r'<span[^>]*class=["\x27][^"\x27]*badge-save[^"\x27]*["\x27][^>]*>(.*?)</span>',
            caseSensitive: false)
        .firstMatch(heading);
    if (match != null && match.group(1) != null) {
      return _stripTags(match.group(1)!).trim();
    }
    final priceMatch = RegExp(r'Save\s*[\$₹\d,.]+', caseSensitive: false)
        .firstMatch(heading);
    if (priceMatch != null) return priceMatch.group(0)!;
    return 'Save \$48.00';
  }

  String _extractBadgeText(String heading) {
    final match = RegExp(r'<span[^>]*class=["\x27][^"\x27]*badge-text[^"\x27]*["\x27][^>]*>(.*?)</span>',
            caseSensitive: false)
        .firstMatch(heading);
    if (match != null && match.group(1) != null) {
      return _stripTags(match.group(1)!).trim();
    }
    return 'Special Offer';
  }

  String _extractCategory(String sub) {
    if (sub.contains('<')) {
      final beforeTag = sub.split('<').first.trim();
      if (beforeTag.isNotEmpty) return beforeTag;
    }
    final match = RegExp(r'<span[^>]*class=["\x27][^"\x27]*card-category[^"\x27]*["\x27][^>]*>(.*?)</span>',
            caseSensitive: false)
        .firstMatch(sub);
    if (match != null && match.group(1) != null) {
      return _stripTags(match.group(1)!).trim();
    }
    return 'SmartPhone';
  }

  String _extractTitle(String sub) {
    final h3Match = RegExp(r'<h3[^>]*>(.*?)</h3>', caseSensitive: false)
        .firstMatch(sub);
    if (h3Match != null && h3Match.group(1) != null) {
      return _stripTags(h3Match.group(1)!).replaceAll(RegExp(r'\s+'), ' ').trim();
    }
    final clean = _stripTags(sub).trim();
    if (clean.isNotEmpty) {
      final cat = _extractCategory(sub);
      if (clean.startsWith(cat)) {
        return clean.substring(cat.length).trim();
      }
      return clean;
    }
    return 'Apple iPad Mini G2356';
  }

  String _extractOldPrice(String desc) {
    final delMatch = RegExp(r'<del[^>]*>(.*?)</del>', caseSensitive: false)
        .firstMatch(desc);
    if (delMatch != null && delMatch.group(1) != null) {
      return _stripTags(delMatch.group(1)!).trim();
    }
    final allPrices = RegExp(r'[\$₹][\d,.]+').allMatches(desc).map((m) => m.group(0)!).toList();
    if (allPrices.length >= 2) {
      return allPrices[0];
    }
    return '\$1,250.00';
  }

  String _extractNewPrice(String desc) {
    final match = RegExp(r'<span[^>]*class=["\x27][^"\x27]*card-new-price[^"\x27]*["\x27][^>]*>(.*?)</span>',
            caseSensitive: false)
        .firstMatch(desc);
    if (match != null && match.group(1) != null) {
      return _stripTags(match.group(1)!).trim();
    }
    final allPrices = RegExp(r'[\$₹][\d,.]+').allMatches(desc).map((m) => m.group(0)!).toList();
    if (allPrices.length >= 2) {
      return allPrices[1];
    } else if (allPrices.isNotEmpty) {
      return allPrices[0];
    }
    return '\$1,050.00';
  }

  String _stripTags(String s) {
    return s
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _handleTap(Map<String, dynamic> item, String title) {
    final link = item['link']?.toString() ?? '';
    if (link.isNotEmpty) {
      if (link.startsWith('http')) {
        Get.toNamed(Routes.PRODUCTDETAILS, arguments: {'productId': link});
        return;
      }
      openShop({'name': title, 'source': 'hero_promo', 'productId': link});
    } else {
      openShop({'name': title, 'source': 'hero_promo'});
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _getFirstItem();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semantic = context.semanticColors;
    final isDark = theme.brightness == Brightness.dark;

    final rawHeading = (item['heading'] ?? '').toString();
    final rawSub = (item['sub_heading'] ?? '').toString();
    final rawDesc = (item['description'] ?? '').toString();

    final badgeSave = _extractBadgeSave(rawHeading);
    final badgeText = _extractBadgeText(rawHeading);
    final category = _extractCategory(rawSub);
    final title = _extractTitle(rawSub);
    final oldPrice = _extractOldPrice(rawDesc);
    final newPrice = _extractNewPrice(rawDesc);
    final buttonText = (item['button_text'] ?? 'Buy Now').toString().trim();

    final imageUrl = HelperFunctions().getImage(item);

    return Padding(
      padding: pageSurroundingPadding,
      child: GestureDetector(
        onTap: () => _handleTap(item, title),
        child: Container(
          height: 172,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: colorScheme.surfaceVariant,
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Row(
              children: [
                // ─── Left: Product / Device Visual ───
                SizedBox(
                  width: 126,
                  height: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorWidget: (_, __, ___) => Container(
                            color: colorScheme.surface,
                            child: Icon(
                              Icons.tablet_mac_rounded,
                              size: 44,
                              color: colorScheme.primary.withOpacity(0.35),
                            ),
                          ),
                        )
                      else
                        Container(
                          color: colorScheme.surface,
                          child: Icon(
                            Icons.tablet_mac_rounded,
                            size: 44,
                            color: colorScheme.primary.withOpacity(0.35),
                          ),
                        ),
                      // Subtle edge gradient into card body
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              colorScheme.surfaceVariant.withOpacity(0.35),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Right: Deal Details & CTA ───
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 1. Compact Savings Pill
                        Container(
                          padding: const EdgeInsets.fromLTRB(3, 3, 8, 3),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.14),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  badgeSave,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: colorScheme.onPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  badgeText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: colorScheme.onSurface,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 2. Category & Title
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              category.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),

                        // 3. Pricing & Buy Now CTA
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  newPrice,
                                  maxLines: 1,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: semantic.discountPrice,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  oldPrice,
                                  maxLines: 1,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: semantic.mutedText,
                                    color: semantic.mutedText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              height: 28,
                              child: ElevatedButton.icon(
                                onPressed: () => _handleTap(item, title),
                                icon: Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 13,
                                  color: colorScheme.onPrimary,
                                ),
                                label: Text(
                                  buttonText.isNotEmpty ? buttonText : 'Buy Now',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  elevation: 0,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
