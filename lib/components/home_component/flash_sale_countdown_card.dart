import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/shop/shop_navigation.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/app_image_placeholder.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';

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
    // Default matching parent website (P6DT21H48M15S: 6 days, 21h, 48m, 15s)
    _remaining = const Duration(days: 6, hours: 21, minutes: 48, seconds: 15);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining = _remaining - const Duration(seconds: 1);
        } else {
          // Loop duration so sale never sits at zero
          _remaining = const Duration(days: 6, hours: 21, minutes: 48, seconds: 15);
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
    final match = RegExp(r'\$[\d,.]+').firstMatch(desc);
    return match != null ? match.group(0)! : '\$2199.00';
  }

  String _cleanOffer(String desc) {
    final lines = desc.split('\n');
    for (final line in lines) {
      if (!line.contains('\$') && line.trim().isNotEmpty) {
        return line.trim();
      }
    }
    return 'Today Only UP TO 20% Off';
  }

  @override
  Widget build(BuildContext context) {
    final item = _getFirstItem();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final rawSub = (item['sub_heading'] ?? '').toString();
    final title = _cleanSubHeading(rawSub);
    final desc = (item['description'] ?? '').toString();
    final price = _cleanPrice(desc);
    final offerNote = _cleanOffer(desc);
    final imageUrl = HelperFunctions().getImage(item);

    final days = _remaining.inDays.toString().padLeft(2, '0');
    final hours = (_remaining.inHours % 24).toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eyebrow / Badges Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Flash Sale',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Limited Time Offer',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Countdown Clock Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildClockCell(days, 'Days', isDark, colorScheme),
                        _buildClockSeparator(colorScheme),
                        _buildClockCell(hours, 'Hrs', isDark, colorScheme),
                        _buildClockSeparator(colorScheme),
                        _buildClockCell(minutes, 'Min', isDark, colorScheme),
                        _buildClockSeparator(colorScheme),
                        _buildClockCell(seconds, 'Sec', isDark, colorScheme),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Product & Offer Details
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Copy
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                offerNote,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                price,
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () => _handleTap(item),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Shop Now',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 14,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right Product Image
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 110,
                            child: (imageUrl.isNotEmpty &&
                                    imageUrl != HelperFunctions.getNoImage())
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.contain,
                                    progressIndicatorBuilder: (_, __, ___) =>
                                        HelperFunctions().loadingIndicator(),
                                    errorWidget: (_, __, ___) =>
                                        const AppImagePlaceholder(radius: 8),
                                  )
                                : const AppImagePlaceholder(radius: 8),
                          ),
                        ),
                      ],
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

  Widget _buildClockCell(
      String value, String unit, bool isDark, ColorScheme colorScheme) {
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockSeparator(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
      ),
    );
  }

  void _handleTap(Map<String, dynamic> item) {
    final link = item['link']?.toString() ?? '';
    if (link.isNotEmpty) {
      Get.toNamed(Routes.PRODUCTDETAILS, arguments: {'productId': link});
    } else {
      openShop({'name': 'iPhone 15 Pro', 'source': 'flash_sale'});
    }
  }
}

