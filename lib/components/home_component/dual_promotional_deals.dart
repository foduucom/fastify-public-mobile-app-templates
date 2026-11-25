import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '/app/modules/shop/shop_navigation.dart';

/// Dual Promotional Deals Component matching the Parent Website's (.dual-promo-section).
/// Displays rich tech deal cards (e.g. Special Creator Deal: EOS Rebel T7i Studio Kit).
class DualPromotionalDealsWidget extends StatelessWidget {
  final Map<String, dynamic> sliderData;

  const DualPromotionalDealsWidget({Key? key, required this.sliderData})
      : super(key: key);

  List<Map<String, dynamic>> _getItems() {
    final slider = sliderData['slider'];
    if (slider is Map) {
      final content = slider['content'];
      if (content is List) {
        return content.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
    }
    return [];
  }

  IconData _extractIcon(String heading) {
    final lower = heading.toLowerCase();
    if (lower.contains('camera')) return Icons.camera_alt_outlined;
    if (lower.contains('bolt') || lower.contains('sale') || lower.contains('flash')) {
      return Icons.bolt_rounded;
    }
    if (lower.contains('audio') || lower.contains('headphone')) return Icons.headphones_outlined;
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
    final title = _cleanText((item['sub_heading'] ?? item['heading'] ?? 'Deals').toString());
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
        height: 248,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
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

            final isFirstCard = index == 0;
            final accentColor = isFirstCard
                ? const Color(0xFFC2410C)
                : const Color(0xFF0284C7);
            final onAccentColor = Colors.white;

            final cardBg = isFirstCard
                ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFFFF7ED))
                : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F9FF));

            final cardBorder = isFirstCard
                ? const Color(0xFFFDBA74).withOpacity(0.5)
                : const Color(0xFFBAE6FD).withOpacity(0.5);

            return Container(
              width: (Get.width * 0.85).clamp(290.0, 360.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: cardBg,
                border: Border.all(color: cardBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Badge Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: accentColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(badgeIcon, size: 14, color: accentColor),
                                const SizedBox(width: 6),
                                Text(
                                  badgeText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: accentColor,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 2. Title
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.3,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // 3. Description
                          Text(
                            desc,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              color: colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),

                          // 4. Pricing & Action Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        isFirstCard ? '\$699.99' : '\$149.99',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: accentColor,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isFirstCard ? '\$1,199.99' : '\$249.99',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.lineThrough,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colorScheme.error,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isFirstCard ? 'Save 40% Off' : 'Save 30% Off',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onError,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // CTA Button
                              ElevatedButton.icon(
                                onPressed: () => _handleTap(item),
                                icon: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 15,
                                  color: onAccentColor,
                                ),
                                label: Text(
                                  'Shop',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: onAccentColor,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: onAccentColor,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
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
        ),
      ),
    );
  }
}
