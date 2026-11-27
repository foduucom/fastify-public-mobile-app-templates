import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/foduuCachedImageNetwork.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

/// Shared header for About Us `trust_badges` sections.
class _AboutSectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const _AboutSectionHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              eyebrow.toUpperCase(),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: context.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (title.isNotEmpty)
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: context.onSurfaceColor,
              letterSpacing: -0.3,
              height: 1.25,
            ),
          ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: context.onSurfaceColor.withValues(alpha: 0.72),
            ),
          ),
        ],
      ],
    );
  }
}

List<Map<String, dynamic>> _extractCards(Map<String, dynamic> contentJson) {
  final raw = contentJson['cards'] ?? contentJson['items'] ?? contentJson['badges'];
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

List<BoxShadow> _aboutCardShadow(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.045),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}

Widget _buildIconBadge(
  BuildContext context,
  String imagePath, {
  double size = 40,
  bool circular = false,
  IconData fallbackIcon = Icons.verified_outlined,
}) {
  final url = imagePath.isNotEmpty ? HelperFunctions().getImage(imagePath) : '';
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: context.primaryColor.withValues(alpha: 0.10),
      shape: circular ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circular ? null : BorderRadius.circular(10),
    ),
    child: Center(
      child: url.isNotEmpty
          ? Padding(
              padding: EdgeInsets.all(size * 0.22),
              child: FoduuCachedNetworkImage(
                image: url,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  context.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            )
          : Icon(fallbackIcon, size: size * 0.52, color: context.primaryColor),
    ),
  );
}

/// Renders the "Our Mission" section (`Empowering Tech Creators & Innovators`
/// + 2x2 mini-feature grid).
class AboutMissionSection extends StatelessWidget {
  final Map<String, dynamic> contentJson;

  const AboutMissionSection({super.key, required this.contentJson});

  @override
  Widget build(BuildContext context) {
    final cards = _extractCards(contentJson);
    if (cards.isEmpty) return const SizedBox.shrink();

    final eyebrow = (contentJson['eyebrow'] ?? '').toString().trim();
    final title = (contentJson['title'] ?? '').toString().trim();
    final subtitle = (contentJson['subtitle'] ?? '').toString().trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AboutSectionHeader(
            eyebrow: eyebrow,
            title: title,
            subtitle: subtitle,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (context, index) {
              final card = cards[index];
              final heading = (card['heading'] ?? card['title'] ?? '').toString().trim();
              final text = (card['text'] ?? card['description'] ?? '').toString().trim();
              final image = (card['image'] ?? '').toString().trim();

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: context.outlineColor.withValues(alpha: 0.14),
                  ),
                  boxShadow: _aboutCardShadow(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconBadge(context, image, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      heading,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: context.onSurfaceColor,
                      ),
                    ),
                    if (text.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: context.onSurfaceColor.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Renders the 2x2 KPI stat counter grid (`15M+ Products Delivered`,
/// `99.8% Customer Satisfaction`, `150+ Brand Partnerships`, `120+ Countries Served`).
class AboutKpiStatsGrid extends StatelessWidget {
  final Map<String, dynamic> contentJson;

  const AboutKpiStatsGrid({super.key, required this.contentJson});

  static IconData _kpiIconFor(String number, String label) {
    final combined = '$number $label'.toLowerCase();
    if (combined.contains('deliver') || combined.contains('product')) {
      return Icons.inventory_2_outlined;
    }
    if (combined.contains('satisf') || combined.contains('99')) {
      return Icons.sentiment_satisfied_alt_rounded;
    }
    if (combined.contains('brand') || combined.contains('partner')) {
      return Icons.handshake_outlined;
    }
    if (combined.contains('countr') || combined.contains('served')) {
      return Icons.public_rounded;
    }
    return Icons.analytics_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final cards = _extractCards(contentJson);
    if (cards.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.65,
        ),
        itemBuilder: (context, index) {
          final card = cards[index];
          final number = (card['heading'] ?? card['title'] ?? '').toString().trim();
          final label = (card['text'] ?? card['description'] ?? '').toString().trim();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: context.outlineColor.withValues(alpha: 0.14),
              ),
              boxShadow: _aboutCardShadow(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        number,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: context.primaryColor,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _kpiIconFor(number, label),
                        size: 18,
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: context.onSurfaceColor.withValues(alpha: 0.78),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Renders the "Why Choose Shopwise" standards cards
/// (`Certified Genuine`, `Express Logistics`, `Price Guarantee`, `30-Day Free Return`).
class AboutStandardsSection extends StatelessWidget {
  final Map<String, dynamic> contentJson;

  const AboutStandardsSection({super.key, required this.contentJson});

  @override
  Widget build(BuildContext context) {
    final cards = _extractCards(contentJson);
    if (cards.isEmpty) return const SizedBox.shrink();

    final eyebrow = (contentJson['eyebrow'] ?? '').toString().trim();
    final title = (contentJson['title'] ?? '').toString().trim();
    final subtitle = (contentJson['subtitle'] ?? '').toString().trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AboutSectionHeader(
            eyebrow: eyebrow,
            title: title,
            subtitle: subtitle,
          ),
          const SizedBox(height: 16),
          ...cards.map((card) {
            final heading = (card['heading'] ?? card['title'] ?? '').toString().trim();
            final text = (card['text'] ?? card['description'] ?? '').toString().trim();
            final image = (card['image'] ?? '').toString().trim();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: context.outlineColor.withValues(alpha: 0.14),
                  ),
                  boxShadow: _aboutCardShadow(context),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIconBadge(context, image, size: 44),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            heading,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: context.onSurfaceColor,
                            ),
                          ),
                          if (text.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              text,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: context.onSurfaceColor
                                    .withValues(alpha: 0.72),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
