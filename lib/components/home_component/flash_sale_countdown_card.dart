import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '/app/modules/shop/shop_navigation.dart';
import '/app/routes/app_pages.dart';
import '/components/app_image_placeholder.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';

/// Flash Sale Countdown Card matching the Parent Website's Hero Sidebar (Image 3).
/// Features:
/// - Dark top header with countdown timer: `02 DAYS : 23 HOURS : 32 MINS : 01 SECS`
/// - Crisp card body with:
///   - Left: "iPhone 15 Pro" title, "Today Only UP TO 20% Off", Price "₹2199.00", and "Shop Now >" link
///   - Right: iPhone 15 Pro product visual
/// - Solid vibrant blue bottom ribbon: "Limited Time Offer"
class FlashSaleCountdownCard extends StatefulWidget {
  final Map<String, dynamic> sliderData;

  const FlashSaleCountdownCard({Key? key, required this.sliderData})
      : super(key: key);

  @override
  State<FlashSaleCountdownCard> createState() => _FlashSaleCountdownCardState();
}

class _FlashSaleCountdownCardState extends State<FlashSaleCountdownCard> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Default matching parent website (P2DT23H32M1S: 2 days, 23h, 32m, 1s)
    _remaining = const Duration(days: 2, hours: 23, minutes: 32, seconds: 1);
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
          // Loop duration so sale never sits at zero
          _remaining = const Duration(days: 2, hours: 23, minutes: 32, seconds: 1);
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

  String _cleanSubHeading(String s) {
    if (s.isEmpty) return 'iPhone 15 Pro';
    return s.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
  }

  String _cleanPrice(String desc) {
    // Check for ₹ price or $ price or raw price in desc
    final inrMatch = RegExp(r'₹[\d,.]+').firstMatch(desc);
    if (inrMatch != null) return inrMatch.group(0)!;
    final dollarMatch = RegExp(r'\$[\d,.]+').firstMatch(desc);
    if (dollarMatch != null) {
      // Convert to ₹ format if appropriate or keep symbol
      return '₹${dollarMatch.group(0)!.replaceAll('\$', '')}';
    }
    return '₹2199.00';
  }

  String _cleanOffer(String desc) {
    final lines = desc.split('\n');
    for (final line in lines) {
      if (!line.contains('\$') && !line.contains('₹') && line.trim().isNotEmpty) {
        return line.trim();
      }
    }
    return 'Today Only UP TO 20% Off';
  }

  void _handleTap(Map<String, dynamic> item) {
    final link = item['link']?.toString() ?? '';
    if (link.isNotEmpty) {
      if (link.startsWith('http')) {
        Get.toNamed(Routes.PRODUCTDETAILS, arguments: {'productId': link});
        return;
      }
      openShop({'name': 'iPhone 15 Pro', 'source': 'flash_sale', 'productId': link});
    } else {
      openShop({'name': 'iPhone 15 Pro', 'source': 'flash_sale'});
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _getFirstItem();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final rawHeading = (item['heading'] ?? '').toString();
    final rawSub = (item['sub_heading'] ?? '').toString();
    String title = _cleanSubHeading(rawSub.isNotEmpty ? rawSub : rawHeading);
    if (title.isEmpty || title.toLowerCase().contains('offer')) {
      title = 'iPhone 15 Pro';
    }

    final desc = (item['description'] ?? '').toString();
    final price = _cleanPrice(desc);
    final offerNote = _cleanOffer(desc);
    final imageUrl = HelperFunctions().getImage(item);

    final days = _remaining.inDays.toString().padLeft(2, '0');
    final hours = (_remaining.inHours % 24).toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Padding(
      padding: pageSurroundingPadding,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── 1. TOP DARK COUNTDOWN HEADER (Matching Image 3) ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A), // Deep navy / charcoal matching parent site
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeaderDigit(days, 'DAYS'),
                    _buildHeaderSeparator(),
                    _buildHeaderDigit(hours, 'HOURS'),
                    _buildHeaderSeparator(),
                    _buildHeaderDigit(minutes, 'MINS'),
                    _buildHeaderSeparator(),
                    _buildHeaderDigit(seconds, 'SECS'),
                  ],
                ),
              ),

              // ─── 2. PRODUCT BODY (Left text, Right iPhone image) ───
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left Column: Title, Offer Subtitle, Price, Shop Now CTA
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              letterSpacing: -0.4,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            offerNote,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white.withOpacity(0.7)
                                  : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            price,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () => _handleTap(item),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Shop Now',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2563EB), // Website action blue
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 11,
                                    color: Color(0xFF2563EB),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Right Column: iPhone 15 Pro Image
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 125,
                        child: (imageUrl.isNotEmpty &&
                                imageUrl != HelperFunctions.getNoImage())
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.contain,
                                placeholder: (_, __) =>
                                    const AppImagePlaceholder(radius: 8),
                                errorWidget: (_, __, ___) =>
                                    _buildIPhoneFallback(),
                              )
                            : _buildIPhoneFallback(),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── 3. BOTTOM SOLID BLUE RIBBON: "Limited Time Offer" (Matching Image 3) ───
              InkWell(
                onTap: () => _handleTap(item),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB), // Vibrant website royal blue
                  ),
                  child: Center(
                    child: Text(
                      'Limited Time Offer',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderDigit(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 7.5,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.55),
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildIPhoneFallback() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.phone_iphone_rounded,
          size: 60,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}
