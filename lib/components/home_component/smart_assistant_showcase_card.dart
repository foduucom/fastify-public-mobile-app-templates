import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/shop/shop_navigation.dart';
import 'package:foduu_ecommerce/components/app_image_placeholder.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

class SmartAssistantShowcaseCard extends StatelessWidget {
  final Map<String, dynamic> sliderData;

  const SmartAssistantShowcaseCard({Key? key, required this.sliderData})
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

  List<String> _extractBadges(String headingHtml) {
    if (headingHtml.isEmpty) {
      return ['SMART ECOSYSTEM', 'PREMIUM EXPERIENCE'];
    }
    // Extract contents of each <span>...</span> or <li>...</li> atomically
    final tagMatches = RegExp(r'<span[^>]*>(.*?)<\/span>', dotAll: true)
        .allMatches(headingHtml);
    final badges = <String>[];
    for (final m in tagMatches) {
      final raw = m.group(1) ?? '';
      final clean = raw
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');
      if (clean.isNotEmpty) {
        badges.add(clean.toUpperCase());
      }
    }
    if (badges.isNotEmpty) {
      return badges;
    }
    return ['SMART ECOSYSTEM', 'PREMIUM EXPERIENCE'];
  }

  @override
  Widget build(BuildContext context) {
    final item = _getFirstItem();

    final rawHeading = (item['heading'] ?? '').toString();
    final badges = _extractBadges(rawHeading);

    final rawSub = (item['sub_heading'] ?? '').toString().trim();
    final title = rawSub.isNotEmpty ? rawSub : 'Meet Your Smart Home Assistant';

    final rawDesc = (item['description'] ?? '').toString().trim();
    final description = rawDesc.isNotEmpty
        ? rawDesc
        : 'Powerful audio, intelligent voice control, and seamless smart home integration designed to make every day easier.';

    final rawBtn = (item['button_text'] ?? '').toString().trim();
    final buttonText = rawBtn.isNotEmpty ? rawBtn : 'Shop Smart Devices';

    final imageUrl = HelperFunctions().getImage(item);

    // Deep slate/navy card container matching parent website (.showcase-banner bg-dark: #0F172A)
    const cardBgColor = Color(0xFF0F172A);
    final borderColor = Colors.white.withOpacity(0.08);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: cardBgColor,
          // 30px radius matching web standard border-radius: 2rem
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Top Product Visual (Echo Dot with Ambient Glow) ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                alignment: Alignment.center,
                child: SizedBox(
                  height: 195,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Atmospheric Radial Glow behind Echo Dot LED ring
                      Container(
                        width: 210,
                        height: 210,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF3B82F6).withOpacity(0.30),
                              const Color(0xFF2563EB).withOpacity(0.12),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),

                      // Smart Speaker Product Cutout
                      (imageUrl.isNotEmpty &&
                              imageUrl != HelperFunctions.getNoImage())
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.contain,
                              progressIndicatorBuilder: (_, __, ___) =>
                                  HelperFunctions().loadingIndicator(),
                              errorWidget: (_, __, ___) =>
                                  const AppImagePlaceholder(radius: 12),
                            )
                          : const AppImagePlaceholder(radius: 12),
                    ],
                  ),
                ),
              ),

              // ─── Details Section ───
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dual Compact Inline Eyebrow Badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (badges.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF3B82F6).withOpacity(0.35),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              badges.first,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF60A5FA),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        if (badges.length > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              badges[1],
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Main Headline (H2)
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -0.4,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Lead Description
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF94A3B8),
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Full-Width Stacked Feature Spec Tiles (Zero Truncation)
                    Column(
                      children: [
                        _buildSpecTile(
                          eyebrow: 'SMART HOME HUB',
                          title: 'Premium Automation',
                          status: 'Enabled',
                        ),
                        const SizedBox(height: 10),
                        _buildSpecTile(
                          eyebrow: 'VOICE ASSISTANT',
                          title: 'Multi-Room Audio',
                          status: 'Enabled',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Refined Capsule Pill Button (Left-aligned, proportional like parent web)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            openShop({
                              'name': 'Smart Devices',
                              'source': 'showcase_banner',
                            });
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 26, vertical: 12.5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withOpacity(0.40),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  buttonText,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildSpecTile({
    required String eyebrow,
    required String title,
    required String status,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF93C5FD),
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.65),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.10),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 0.6,
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
