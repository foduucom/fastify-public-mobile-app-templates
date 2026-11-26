import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '/app/modules/shop/shop_navigation.dart';
import '/constants/helper_functions.dart';

/// Dual Promo Cards Component matching the Parent Website's (.promo-cards-section).
/// Displays promotional banners (e.g. Smart Camera 40% Off, Smart Watch 20% Off).
class DualPromoCardsWidget extends StatelessWidget {
  final Map<String, dynamic> sliderData;

  const DualPromoCardsWidget({Key? key, required this.sliderData})
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

  void _handleTap(Map<String, dynamic> item) {
    final name = (item['sub_heading'] ?? item['heading'] ?? 'Promotion')
        .toString()
        .replaceAll(RegExp(r'/n|\n'), ' ')
        .trim();
    openShop({'name': name, 'source': 'promo_banner'});
  }

  @override
  Widget build(BuildContext context) {
    final items = _getItems();
    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 185,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final item = items[index];
            final rawHeading = (item['heading'] ?? '').toString();
            final rawSub = (item['sub_heading'] ?? '').toString();

            // Extract Title & Discount from sub_heading (e.g. "Smart Camera /n 40% Off")
            String title = 'Featured Item';
            String discount = 'Special Deal';
            if (rawSub.contains('/n') || rawSub.contains('\n')) {
              final parts = rawSub.split(RegExp(r'/n|\n'));
              if (parts.isNotEmpty) title = parts[0].trim();
              if (parts.length > 1) discount = parts[1].trim();
            } else if (rawSub.isNotEmpty) {
              title = rawSub;
            }

            final subtitle =
                rawHeading.isNotEmpty ? rawHeading : 'Find The Best For You!';

            final imageUrl = HelperFunctions().getImage(item);
            final colorScheme = Theme.of(context).colorScheme;

            return GestureDetector(
              onTap: () => _handleTap(item),
              child: Container(
                width: (Get.width * 0.82).clamp(280.0, 340.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: colorScheme.surfaceVariant,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background Image
                      if (imageUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.centerRight,
                          errorWidget: (_, __, ___) => const SizedBox.shrink(),
                        ),

                      // Gradient Overlay for text contrast
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withOpacity(0.85),
                              Colors.black.withOpacity(0.55),
                              Colors.black.withOpacity(0.15),
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),

                      // Text Content
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.85),
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.28),
                                ),
                              ),
                              child: Text(
                                discount,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Shop Now',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 12,
                                    color: Colors.black87,
                                  ),
                                ],
                              ),
                            ),
                          ],
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
