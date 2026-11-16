import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '/app/modules/shop/shop_navigation.dart';
import '/app/routes/app_pages.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';

/// Smartwatch Promotional Deal Banner matching Image 4 on the Parent Website.
/// Features:
/// - Full-width landscape banner with rich dark-to-amber background
/// - Dual smartwatches visual with flowing orange ribbon
/// - "LIMITED TIME OFFER!" eyebrow tag
/// - Bold "UP TO 30% OFF" headline
/// - "on select smart gadgets" context
/// - "Shop Sale" vibrant blue action pill button
/// - Discrete floating dark countdown card: "Hurry! Offer ends in: 00 DAYS : 00 HOURS : 00 MIN : 00 SEC"
class HeroFlashDealBanner extends StatefulWidget {
  final Map<String, dynamic> sliderData;

  const HeroFlashDealBanner({
    super.key,
    required this.sliderData,
  });

  @override
  State<HeroFlashDealBanner> createState() => _HeroFlashDealBannerState();
}

class _HeroFlashDealBannerState extends State<HeroFlashDealBanner> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Default rolling 7-day flash sale timer matching website standards
    _remaining = const Duration(days: 6, hours: 23, minutes: 59, seconds: 48);
    _initExpirationFromData();
    _startTimer();
  }

  void _initExpirationFromData() {
    final item = _getFirstItem();
    final expiryStr = item['expiry_date'] ?? item['end_date'] ?? item['expiry'];
    if (expiryStr != null) {
      try {
        final parsedDate = DateTime.parse(expiryStr.toString());
        final diff = parsedDate.difference(DateTime.now());
        if (diff.inSeconds > 0) {
          _remaining = diff;
        }
      } catch (_) {}
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining = _remaining - const Duration(seconds: 1);
        } else {
          _remaining = const Duration(days: 6, hours: 23, minutes: 59, seconds: 59);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Map<String, dynamic> _getFirstItem() {
    final slider = widget.sliderData['slider'];
    if (slider is Map) {
      final content = slider['content'];
      if (content is List && content.isNotEmpty && content.first is Map) {
        return Map<String, dynamic>.from(content.first);
      }
    }
    return {};
  }

  String _cleanHtml(String text) {
    if (text.isEmpty) return '';
    return text
        .replaceAll(RegExp(r'</?(li|p|div|h[1-6]|br)[^>]*>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _handleTap(Map<String, dynamic> item) async {
    final link = item['link']?.toString() ?? '';
    final sliderType = item['sliderType']?.toString();

    if (sliderType == 'categories' && link.isNotEmpty) {
      openShop({
        'source': 'category',
        'productId': link,
        'name': item['heading'] ?? 'Sale',
      });
    } else if (link.isNotEmpty) {
      if (link.startsWith('http')) {
        final uri = Uri.parse(link);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      } else if (link.startsWith('/shop') || link.contains('shop')) {
        openShop({'source': 'sale'});
        return;
      }
    }

    openShop({'source': 'sale'});
  }

  @override
  Widget build(BuildContext context) {
    final item = _getFirstItem();
    final rawTitle = (item['heading'] ?? '').toString();
    final rawDesc = (item['description'] ?? '').toString();
    final cleanTitle = _cleanHtml(rawTitle);
    final cleanDesc = _cleanHtml(rawDesc);
    final imageUrl = HelperFunctions().getImage(item);

    // Copy with smart fallback to website defaults (Image 4)
    String eyebrow = "LIMITED TIME OFFER!";
    String headline = "UP TO 30% OFF";
    String subtitle = "on select smart gadgets";

    if (cleanTitle.isNotEmpty) {
      if (cleanTitle.toLowerCase().contains("offer")) {
        eyebrow = cleanTitle.toUpperCase();
      } else if (cleanTitle.toLowerCase().contains("%") ||
          cleanTitle.toLowerCase().contains("off")) {
        headline = cleanTitle.toUpperCase();
      }
    }

    if (cleanDesc.isNotEmpty) {
      if (cleanDesc.toLowerCase().contains("%") ||
          cleanDesc.toLowerCase().contains("off")) {
        headline = cleanDesc.toUpperCase();
      } else {
        subtitle = cleanDesc;
      }
    }

    final days = _remaining.inDays.toString().padLeft(2, '0');
    final hours = (_remaining.inHours % 24).toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Padding(
      padding: pageSurroundingPadding,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: const Color(0xFF0F0E13),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.40),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // 1. Background image: Aligned center-left to preserve the dual watches visual!
              if (imageUrl.isNotEmpty && imageUrl != HelperFunctions.getNoImage())
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                    placeholder: (_, __) => const SizedBox(),
                    errorWidget: (_, __, ___) => const SizedBox(),
                  ),
                ),

              // 2. High-contrast ambient gradient ensuring text and countdown are always readable
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.20),
                        Colors.black.withOpacity(0.60),
                        Colors.black.withOpacity(0.92),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // Ambient warm orange glow matching website banner
              Positioned(
                left: -20,
                top: -20,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFD95B14).withOpacity(0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Content Layout (Matching Image 4)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eyebrow Tag + Shop Sale Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Eyebrow Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE65100).withOpacity(0.25),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFE65100).withOpacity(0.55),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            eyebrow,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFF9E66),
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),

                        // "Shop Sale" Action Button (Matching Image 4)
                        GestureDetector(
                          onTap: () => _handleTap(item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB), // Website royal blue
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withOpacity(0.45),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Shop Sale",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Main Headline (UP TO 30% OFF)
                    Text(
                      headline,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.3,
                        height: 1.15,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.9),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.90),
                        shadows: const [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 14),

                    // 4. Urgency Countdown Sub-Card (Matching Image 4)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_filled_rounded,
                                color: Color(0xFFFF9E66),
                                size: 13,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "Hurry! Offer ends in",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 7),

                          // 4-Block Countdown Timer: DAYS : HOURS : MIN : SEC
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTimerCell(days, "DAYS"),
                              _buildTimerSeparator(),
                              _buildTimerCell(hours, "HOURS"),
                              _buildTimerSeparator(),
                              _buildTimerCell(minutes, "MIN"),
                              _buildTimerSeparator(),
                              _buildTimerCell(seconds, "SEC"),
                            ],
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
  }

  Widget _buildTimerCell(String value, String label) {
    return Container(
      width: 54,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24).withOpacity(0.9),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.60),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Text(
        ":",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }
}
