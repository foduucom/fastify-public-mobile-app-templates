import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/data/models/about_us_sections.dart';
import 'package:foduu_ecommerce/app/modules/aboutus/controllers/aboutus_controller.dart';
import 'package:foduu_ecommerce/app/modules/shop/shop_navigation.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/foduuCachedImageNetwork.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';

// Helper shadow function identical to current AboutusView
List<BoxShadow> _cardShadow(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}

String _imageUrl(String path) {
  if (path.isEmpty) return '';
  return HelperFunctions().getImage(path);
}

Widget _buildEyebrowBadge(BuildContext context, String text) {
  if (text.isEmpty) return const SizedBox.shrink();
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
    decoration: BoxDecoration(
      color: context.primaryColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: context.primaryColor,
        letterSpacing: 0.5,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────
// 1. Hero Header Banner
// ─────────────────────────────────────────────────────────────────────────
class AboutHeroBannerWidget extends StatelessWidget {
  final AboutHeroHeader header;

  const AboutHeroBannerWidget({Key? key, required this.header}) : super(key: key);

  factory AboutHeroBannerWidget.fromMap(Map<String, dynamic>? json) {
    if (json == null) return AboutHeroBannerWidget(header: AboutHeroHeader.fallback());
    return AboutHeroBannerWidget(header: AboutHeroHeader.fromSections([json]));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 175,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (header.backgroundImage.isNotEmpty)
            CachedNetworkImage(
              imageUrl: _imageUrl(header.backgroundImage),
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  Container(color: const Color(0xFF0F172A)),
            )
          else
            Container(color: const Color(0xFF0F172A)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0F172A).withValues(alpha: 0.78),
                  const Color(0xFF1E293B).withValues(alpha: 0.92),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home_outlined,
                            size: 13, color: Colors.white70),
                        SizedBox(width: 4),
                        Text(
                          'Home  /  About Us',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    header.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (header.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      header.subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 2. Circular Categories Rail
// ─────────────────────────────────────────────────────────────────────────
class AboutCategoriesRailWidget extends StatelessWidget {
  final AboutCategoriesSection categories;

  const AboutCategoriesRailWidget({Key? key, required this.categories})
      : super(key: key);

  factory AboutCategoriesRailWidget.fromMap(Map<String, dynamic>? json) {
    if (json == null) {
      return AboutCategoriesRailWidget(
          categories: AboutCategoriesSection.fallback());
    }
    return AboutCategoriesRailWidget(
        categories: AboutCategoriesSection.fromSections([json]));
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('drone')) return Icons.flight_takeoff_rounded;
    if (lower.contains('smart home') || lower.contains('home')) {
      return Icons.home_outlined;
    }
    if (lower.contains('print')) return Icons.print_outlined;
    if (lower.contains('monitor') || lower.contains('display')) {
      return Icons.desktop_windows_outlined;
    }
    if (lower.contains('appliance')) return Icons.kitchen_outlined;
    if (lower.contains('camera')) return Icons.camera_alt_outlined;
    if (lower.contains('audio') ||
        lower.contains('headphone') ||
        lower.contains('sound')) {
      return Icons.headphones_outlined;
    }
    if (lower.contains('accessor')) return Icons.devices_other_outlined;
    if (lower.contains('phone') ||
        lower.contains('smartphone') ||
        lower.contains('mobile')) {
      return Icons.smartphone_outlined;
    }
    if (lower.contains('tablet') || lower.contains('ipad')) {
      return Icons.tablet_mac_outlined;
    }
    if (lower.contains('watch') || lower.contains('smartwatch')) {
      return Icons.watch_outlined;
    }
    if (lower.contains('tv') || lower.contains('television')) {
      return Icons.tv_outlined;
    }
    if (lower.contains('game') || lower.contains('gaming')) {
      return Icons.sports_esports_outlined;
    }
    if (lower.contains('laptop') || lower.contains('computer')) {
      return Icons.laptop_outlined;
    }
    if (lower.contains('speaker')) return Icons.speaker_outlined;
    return Icons.category_outlined;
  }

  Widget _buildCategoryIcon(String name, String iconUrl, BuildContext context) {
    final hasValidImage = iconUrl.isNotEmpty &&
        iconUrl != HelperFunctions.getNoImage() &&
        !iconUrl.contains('app_logo');

    if (hasValidImage) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: FoduuCachedNetworkImage(
          image: _imageUrl(iconUrl),
          fit: BoxFit.contain,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.primaryColor.withValues(alpha: 0.08),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(name),
          size: 26,
          color: context.primaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (categories.categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: SizedBox(
        height: 96,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: categories.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final cat = categories.categories[index];
            return GestureDetector(
              onTap: () {
                openShop({'category': cat.id, 'name': cat.name});
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.outlineColor.withValues(alpha: 0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _buildCategoryIcon(cat.name, cat.iconUrl, context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 64,
                    child: Text(
                      cat.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: context.onSurfaceColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 3. Who We Are Story Section (K7 Audio Banner)
// ─────────────────────────────────────────────────────────────────────────
class AboutStorySectionWidget extends StatelessWidget {
  final AboutHeroStory story;

  const AboutStorySectionWidget({Key? key, required this.story}) : super(key: key);

  factory AboutStorySectionWidget.fromMap(Map<String, dynamic>? json) {
    if (json == null) return AboutStorySectionWidget(story: AboutHeroStory.fallback());
    return AboutStorySectionWidget(story: AboutHeroStory.fromSections([json]));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.outlineColor.withValues(alpha: 0.15)),
          boxShadow: _cardShadow(context),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (story.bannerImage.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: _imageUrl(story.bannerImage),
                  width: double.infinity,
                  height: 185,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 185,
                    color: Colors.grey.withValues(alpha: 0.1),
                    child: Center(child: HelperFunctions().loadingIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 185,
                    color: Colors.grey.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(
                        Icons.devices_other_rounded,
                        size: 48,
                        color: context.onSurfaceColor.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            _buildEyebrowBadge(context, story.subtitle),
            const SizedBox(height: 8),
            Text(
              story.title,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: context.onSurfaceColor,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              story.description,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.6,
                color: context.onSurfaceColor.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 4. Stats Section (2x2 Grid)
// ─────────────────────────────────────────────────────────────────────────
class AboutStatsSectionWidget extends StatelessWidget {
  final AboutStatsSection stats;

  const AboutStatsSectionWidget({Key? key, required this.stats}) : super(key: key);

  factory AboutStatsSectionWidget.fromMap(Map<String, dynamic>? json) {
    if (json == null) return AboutStatsSectionWidget(stats: AboutStatsSection.fallback());
    return AboutStatsSectionWidget(stats: AboutStatsSection.fromSections([json]));
  }

  @override
  Widget build(BuildContext context) {
    if (stats.stats.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEyebrowBadge(context, 'GLOBAL FOOTPRINT'),
          const SizedBox(height: 6),
          Text(
            stats.title,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: context.onSurfaceColor,
            ),
          ),
          if (stats.subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              stats.subtitle,
              style: TextStyle(
                fontSize: 13,
                color: context.onSurfaceColor.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.stats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final item = stats.stats[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: context.outlineColor.withValues(alpha: 0.15)),
                  boxShadow: _cardShadow(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.heading,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: context.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.onSurfaceColor,
                      ),
                    ),
                    if (item.footer.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.footer,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.3,
                          color: context.onSurfaceColor.withValues(alpha: 0.6),
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

// ─────────────────────────────────────────────────────────────────────────
// 5. Brand Showcase
// ─────────────────────────────────────────────────────────────────────────
class AboutBrandsSectionWidget extends StatelessWidget {
  final AboutBrandsSection brands;

  const AboutBrandsSectionWidget({Key? key, required this.brands}) : super(key: key);

  factory AboutBrandsSectionWidget.fromMap(Map<String, dynamic>? json) {
    if (json == null) return AboutBrandsSectionWidget(brands: AboutBrandsSection.fallback());
    return AboutBrandsSectionWidget(brands: AboutBrandsSection.fromSections([json]));
  }

  @override
  Widget build(BuildContext context) {
    if (brands.brandImages.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEyebrowBadge(context, 'TRUSTED BRANDS'),
          const SizedBox(height: 6),
          Text(
            brands.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.onSurfaceColor,
            ),
          ),
          if (brands.subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              brands.subtitle,
              style: TextStyle(
                fontSize: 13,
                color: context.onSurfaceColor.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: brands.brandImages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final img = brands.brandImages[index];
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: context.outlineColor.withValues(alpha: 0.15)),
                  boxShadow: _cardShadow(context),
                ),
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: _imageUrl(img),
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.business_rounded,
                      size: 22,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 6. Guiding Philosophy (3 Pillars)
// ─────────────────────────────────────────────────────────────────────────
class AboutPhilosophySectionWidget extends StatelessWidget {
  final AboutPhilosophySection philosophy;

  const AboutPhilosophySectionWidget({Key? key, required this.philosophy})
      : super(key: key);

  factory AboutPhilosophySectionWidget.fromMap(Map<String, dynamic>? json) {
    if (json == null) {
      return AboutPhilosophySectionWidget(
          philosophy: AboutPhilosophySection.fallback());
    }
    return AboutPhilosophySectionWidget(
        philosophy: AboutPhilosophySection.fromSections([json]));
  }

  @override
  Widget build(BuildContext context) {
    if (philosophy.items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEyebrowBadge(context, 'OUR PHILOSOPHY'),
          const SizedBox(height: 6),
          Text(
            philosophy.title,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: context.onSurfaceColor,
            ),
          ),
          if (philosophy.subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              philosophy.subtitle,
              style: TextStyle(
                fontSize: 13,
                color: context.onSurfaceColor.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...philosophy.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: context.outlineColor.withValues(alpha: 0.15)),
                  boxShadow: _cardShadow(context),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: item.iconUrl.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FoduuCachedNetworkImage(
                                  image: _imageUrl(item.iconUrl),
                                  fit: BoxFit.contain,
                                  colorFilter: ColorFilter.mode(
                                    context.primaryColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.verified_rounded,
                                color: context.primaryColor,
                                size: 24,
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: context.onSurfaceColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: context.onSurfaceColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 7. Why Choose Us Section
// ─────────────────────────────────────────────────────────────────────────
class AboutWhyChooseWidget extends StatelessWidget {
  final AboutWhyChooseSection whyChoose;

  const AboutWhyChooseWidget({Key? key, required this.whyChoose})
      : super(key: key);

  factory AboutWhyChooseWidget.fromMap(Map<String, dynamic>? json) {
    if (json == null) {
      return AboutWhyChooseWidget(whyChoose: AboutWhyChooseSection.fallback());
    }
    return AboutWhyChooseWidget(
        whyChoose: AboutWhyChooseSection.fromSections([json]));
  }

  @override
  Widget build(BuildContext context) {
    if (whyChoose.features.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEyebrowBadge(context, 'WHY CHOOSE US'),
          const SizedBox(height: 6),
          Text(
            whyChoose.title,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: context.onSurfaceColor,
            ),
          ),
          if (whyChoose.subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              whyChoose.subtitle,
              style: TextStyle(
                fontSize: 13,
                color: context.onSurfaceColor.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...whyChoose.features.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: context.outlineColor.withValues(alpha: 0.15)),
                  boxShadow: _cardShadow(context),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: item.iconUrl.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FoduuCachedNetworkImage(
                                  image: _imageUrl(item.iconUrl),
                                  fit: BoxFit.contain,
                                  colorFilter: ColorFilter.mode(
                                    context.primaryColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.check_circle_rounded,
                                color: context.primaryColor,
                                size: 24,
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: context.onSurfaceColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: context.onSurfaceColor.withValues(alpha: 0.7),
                            ),
                          ),
                          if (item.footer.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: openShop,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.footer,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: context.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: context.primaryColor,
                                  ),
                                ],
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
          }).toList(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 8. Team Grid Section
// ─────────────────────────────────────────────────────────────────────────
class AboutTeamSectionWidget extends StatelessWidget {
  final AboutTeamSection team;

  const AboutTeamSectionWidget({Key? key, required this.team}) : super(key: key);

  factory AboutTeamSectionWidget.fromMap(Map<String, dynamic>? json) {
    if (json == null) return AboutTeamSectionWidget(team: AboutTeamSection.fallback());
    return AboutTeamSectionWidget(team: AboutTeamSection.fromSections([json]));
  }

  @override
  Widget build(BuildContext context) {
    if (team.members.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEyebrowBadge(context, 'OUR PEOPLE'),
          const SizedBox(height: 6),
          Text(
            team.title,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: context.onSurfaceColor,
            ),
          ),
          if (team.subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              team.subtitle,
              style: TextStyle(
                fontSize: 13,
                color: context.onSurfaceColor.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: team.members.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final member = team.members[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: context.outlineColor.withValues(alpha: 0.15)),
                  boxShadow: _cardShadow(context),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: CachedNetworkImage(
                        imageUrl: _imageUrl(member.avatarImage),
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => CircleAvatar(
                          radius: 36,
                          backgroundColor:
                              context.primaryColor.withValues(alpha: 0.15),
                          child: Text(
                            member.name.isNotEmpty
                                ? member.name[0].toUpperCase()
                                : 'F',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: context.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      member.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.role,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: context.onSurfaceColor.withValues(alpha: 0.65),
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────
// 9. FAQ Section with Expandable Accordion
// ─────────────────────────────────────────────────────────────────────────
class AboutFaqSectionWidget extends StatefulWidget {
  final AboutFaqSection faq;

  const AboutFaqSectionWidget({Key? key, required this.faq}) : super(key: key);

  factory AboutFaqSectionWidget.fromMap(Map<String, dynamic>? json) {
    if (json == null) return AboutFaqSectionWidget(faq: AboutFaqSection.fallback());
    return AboutFaqSectionWidget(faq: AboutFaqSection.fromSections([json]));
  }

  @override
  State<AboutFaqSectionWidget> createState() => _AboutFaqSectionWidgetState();
}

class _AboutFaqSectionWidgetState extends State<AboutFaqSectionWidget> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final faq = widget.faq;
    if (faq.items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEyebrowBadge(context, 'COMMON QUESTIONS'),
          const SizedBox(height: 6),
          Text(
            faq.title,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: context.onSurfaceColor,
            ),
          ),
          if (faq.subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              faq.subtitle,
              style: TextStyle(
                fontSize: 13,
                color: context.onSurfaceColor.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...faq.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isExpanded = _expandedIndex == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isExpanded
                        ? context.primaryColor.withValues(alpha: 0.35)
                        : context.outlineColor.withValues(alpha: 0.15),
                  ),
                  boxShadow: _cardShadow(context),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      _expandedIndex = isExpanded ? null : index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.question,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isExpanded
                                      ? context.primaryColor
                                      : context.onSurfaceColor,
                                ),
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: isExpanded
                                  ? context.primaryColor
                                  : context.onSurfaceColor.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 10),
                          Divider(
                              color: context.outlineColor.withValues(alpha: 0.1),
                              height: 1),
                          const SizedBox(height: 10),
                          Text(
                            item.answer,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.55,
                              color: context.onSurfaceColor.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 10. Consultation & Expert Assistance Card
// ─────────────────────────────────────────────────────────────────────────
class AboutConsultationSectionWidget extends StatelessWidget {
  final AboutConsultationCard card;

  const AboutConsultationSectionWidget({Key? key, required this.card})
      : super(key: key);

  factory AboutConsultationSectionWidget.fromMap(Map<String, dynamic>? json) {
    if (json == null) {
      return AboutConsultationSectionWidget(
          card: AboutConsultationCard.fallback());
    }
    return AboutConsultationSectionWidget(
        card: AboutConsultationCard.fromSections([json]));
  }

  Future<void> _callSupport(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (clean.isNotEmpty) {
      await HelperFunctions().openUrl('tel:$clean');
    }
  }

  Future<void> _sendEmail(String email) async {
    final clean = email.trim();
    if (clean.isNotEmpty) {
      await HelperFunctions().openUrl('mailto:$clean');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.primaryColor.withValues(alpha: 0.2)),
          boxShadow: _cardShadow(context),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.headset_mic_rounded,
                    color: context.primaryColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.heading,
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: context.onSurfaceColor,
                        ),
                      ),
                      Text(
                        card.subHeading,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.onSurfaceColor.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 16,
                          color: context.onSurfaceColor.withValues(alpha: 0.7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          card.hours,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.onSurfaceColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _sendEmail(card.email),
                    child: Row(
                      children: [
                        Icon(Icons.email_outlined,
                            size: 16, color: context.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          card.email,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _callSupport(card.phone),
                    child: Row(
                      children: [
                        Icon(Icons.phone_outlined,
                            size: 16, color: context.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          card.phone,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Get.toNamed(Routes.CONTACT),
                icon: const Icon(Icons.calendar_today_rounded,
                    size: 16, color: Colors.white),
                label: Text(
                  card.buttonText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (card.trustedClientsText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_outlined,
                        size: 14, color: context.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      card.trustedClientsText,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: context.onSurfaceColor.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 11. Bottom CTA Banner
// ─────────────────────────────────────────────────────────────────────────
class AboutBottomCtaWidget extends StatelessWidget {
  final AboutBottomCta cta;

  const AboutBottomCtaWidget({Key? key, required this.cta}) : super(key: key);

  factory AboutBottomCtaWidget.fromMap(Map<String, dynamic>? json) {
    if (json == null) return AboutBottomCtaWidget(cta: AboutBottomCta.fallback());
    return AboutBottomCtaWidget(cta: AboutBottomCta.fromSections([json]));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _cardShadow(context),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (cta.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: cta.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 10),
            Text(
              cta.subHeading,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              cta.description,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: openShop,
                      child: Text(
                        cta.primaryButtonText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Get.toNamed(Routes.CONTACT),
                      child: Text(
                        cta.secondaryButtonText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
