import 'package:flutter/material.dart';
import 'package:zouhi/app/data/models/page_model.dart';

String _s(dynamic f, String key, [String fallback = '']) {
  if (f is! Map) return fallback;
  final v = f[key]?.toString().trim() ?? '';
  return v.isEmpty ? fallback : v;
}

/// Helper to sanitize relative or absolute image URLs
String resolveImageUrl(String path, String baseUrl) {
  if (path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
  final cleanPath = path.startsWith('/') ? path : '/$path';
  return '$cleanBase$cleanPath';
}

/// Section 1: Hero Banner Header
class SolutionsBannerHeader {
  final String imageUrl;
  final String altText;
  final double height;

  const SolutionsBannerHeader({
    required this.imageUrl,
    this.altText = 'Solutions',
    this.height = 145.0,
  });

  factory SolutionsBannerHeader.fromSection(Map<String, dynamic> section) {
    final cj = section['content_json'] is Map
        ? Map<String, dynamic>.from(section['content_json'])
        : <String, dynamic>{};

    final banners = cj['banners'];
    if (banners is List && banners.isNotEmpty && banners.first is Map) {
      final firstBanner = banners.first as Map;
      final items = firstBanner['items'];
      if (items is List && items.isNotEmpty && items.first is Map) {
        final firstItem = items.first as Map;
        final featImg = firstItem['featured_image'];
        if (featImg is Map) {
          final url = featImg['download_url'] ?? featImg['filepath'] ?? '';
          final alt = featImg['alt_text']?.toString() ?? 'Solutions';
          return SolutionsBannerHeader(
            imageUrl: url.toString().trim(),
            altText: alt,
          );
        }
      }
    }

    return canonical();
  }

  static SolutionsBannerHeader canonical() {
    return const SolutionsBannerHeader(
      imageUrl: '2026/10/23/Solutions-on-Navy-Gradient-7ce8fd80.webp',
      altText: 'Solutions On Navy Gradient',
      height: 145.0,
    );
  }
}

/// Section 2: "What We Deliver" Intro Hero Card
class SolutionsIntroSection {
  final String eyebrow;
  final String title;
  final String description;
  final String statItem;
  final String buttonText;
  final String imageUrl;

  const SolutionsIntroSection({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.statItem,
    required this.buttonText,
    required this.imageUrl,
  });

  factory SolutionsIntroSection.fromSliderContent(Map<String, dynamic> item) {
    final rawHeading = _s(item, 'heading');
    String eyebrow = 'WHAT WE DELIVER';
    String title = 'Network Infrastructure Solutions Built Around Your Industry';

    // Parse: What We Deliver["Network Infrastructure Solutions Built Around Your Industry"]
    if (rawHeading.contains('[') && rawHeading.contains(']')) {
      final reg = RegExp(r'^(.*?)\["?(.*?)"?\]$');
      final match = reg.firstMatch(rawHeading);
      if (match != null) {
        final eb = match.group(1)?.trim();
        final tit = match.group(2)?.trim();
        if (eb != null && eb.isNotEmpty) eyebrow = eb.toUpperCase();
        if (tit != null && tit.isNotEmpty) title = tit;
      }
    } else if (rawHeading.isNotEmpty) {
      title = rawHeading;
    }

    final rawDesc = _s(item, 'description');
    String desc = rawDesc;
    String stat = '10+ Industries Served';

    // Extract stat item e.g. "10+\nIndustries Served"
    if (rawDesc.contains('Industries Served')) {
      final parts = rawDesc.split(RegExp(r'\n\n(?=10\+)|\n\n(?=10\+ Industries Served)'));
      if (parts.length > 1) {
        desc = parts[0].trim();
        stat = parts[1].replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
      } else {
        // Fallback regex extraction
        final statReg = RegExp(r'(10\+\s*Industries Served)', caseSensitive: false);
        final match = statReg.firstMatch(rawDesc);
        if (match != null) {
          stat = match.group(1)!.replaceAll(RegExp(r'\s+'), ' ').trim();
          desc = rawDesc.replaceFirst(match.group(0)!, '').trim();
        }
      }
    }

    final btnText = _s(item, 'button_text', 'Talk To Our Team');
    final img = _s(item, 'filePath', _s(item, 'download_url', '2026/10/26/solution-image-ce87585b.webp'));

    return SolutionsIntroSection(
      eyebrow: eyebrow,
      title: title,
      description: desc.isNotEmpty
          ? desc
          : 'From data centers to retail chains, Vision Infrastructure designs, supplies, and supports the fiber optic, switching, and surveillance backbone that keeps your operations connected. We match the right products to your environment, then stand behind them with hands-on technical support.',
      statItem: stat.isNotEmpty ? stat : '10+ Industries Served',
      buttonText: btnText,
      imageUrl: img,
    );
  }

  factory SolutionsIntroSection.fromLegacyFields(Map<String, dynamic> f) {
    return SolutionsIntroSection(
      eyebrow: _s(f, 'section_subtitle', 'WHAT WE DELIVER').toUpperCase(),
      title: _s(f, 'section_title', 'Network Infrastructure Solutions Built Around Your Industry'),
      description: _s(f, 'section_description', 'From data centers to retail chains, Vision Infrastructure designs, supplies, and supports the fiber optic, switching, and surveillance backbone that keeps your operations connected.'),
      statItem: _s(f, 'stat_item', '10+ Industries Served'),
      buttonText: _s(f, 'cta_text', 'Talk To Our Team'),
      imageUrl: _s(f, 'background_image', '2026/10/26/solution-image-ce87585b.webp'),
    );
  }

  static SolutionsIntroSection canonical() {
    return const SolutionsIntroSection(
      eyebrow: 'WHAT WE DELIVER',
      title: 'Network Infrastructure Solutions Built Around Your Industry',
      description: 'From data centers to retail chains, Vision Infrastructure designs, supplies, and supports the fiber optic, switching, and surveillance backbone that keeps your operations connected. We match the right products to your environment, then stand behind them with hands-on technical support.',
      statItem: '10+ Industries Served',
      buttonText: 'Talk To Our Team',
      imageUrl: '2026/10/26/solution-image-ce87585b.webp',
    );
  }
}

/// Helper to resolve card cover images using url + assets/images + footer
String resolveFooterCoverUrl(String footer, [String defaultRelativePath = '']) {
  final raw = footer.trim().isNotEmpty ? footer.trim() : defaultRelativePath.trim();
  if (raw.isEmpty) return '';
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

  const baseUrl = 'https://vision.foduu.store/';
  if (raw.startsWith('assets/images/')) {
    return '$baseUrl$raw';
  }
  if (raw.startsWith('/assets/images/')) {
    return '$baseUrl${raw.substring(1)}';
  }
  final cleanPath = raw.startsWith('/') ? raw.substring(1) : raw;
  return '${baseUrl}assets/images/$cleanPath';
}

/// Item in Section 3: Industry Solution Card
class IndustryCardItem {
  final String title;
  final String description;
  final String coverImageUrl;
  final String iconUrl;
  final IconData fallbackIcon;
  final String categorySlug;
  final String categoryName;

  // Backwards compatibility getter so .imageUrl continues to work
  String get imageUrl => coverImageUrl;

  const IndustryCardItem({
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.iconUrl,
    required this.fallbackIcon,
    required this.categorySlug,
    required this.categoryName,
  });

  factory IndustryCardItem.fromMap(Map<String, dynamic> map) {
    final rawHeading = _s(map, 'heading', _s(map, 'title', 'Industry Solution'));
    final rawText = _s(map, 'text', _s(map, 'desc', ''));
    // Clean text by stripping "Explore Products" if present at the end
    final cleanDesc = rawText
        .replaceAll(RegExp(r'\s*Explore Products\s*', caseSensitive: false), '')
        .trim();
    final rawFooter = _s(map, 'footer');
    final rawImage = _s(map, 'image', _s(map, 'imageUrl', ''));

    final mapping = _inferCategory(rawHeading);
    final defaultCover = mapping['defaultCover'] as String? ?? '';
    final coverUrl = resolveFooterCoverUrl(rawFooter, defaultCover);

    return IndustryCardItem(
      title: rawHeading,
      description: cleanDesc,
      coverImageUrl: coverUrl,
      iconUrl: rawImage,
      fallbackIcon: mapping['icon'] as IconData,
      categorySlug: mapping['slug'] as String,
      categoryName: mapping['name'] as String,
    );
  }

  static Map<String, dynamic> _inferCategory(String heading) {
    final lower = heading.toLowerCase();
    if (lower.contains('data center') || lower.contains('enterprise')) {
      return {
        'slug': 'networking',
        'name': 'Networking',
        'icon': Icons.dns_rounded,
        'defaultCover': 'demos/demo15/categories/Networking.webp',
      };
    } else if (lower.contains('telecom') || lower.contains('isp')) {
      return {
        'slug': 'fiber-cables',
        'name': 'Fiber Cables',
        'icon': Icons.cell_tower_rounded,
        'defaultCover': 'demos/demo15/categories/Fiber%20Cables.webp',
      };
    } else if (lower.contains('retail') || lower.contains('warehousing')) {
      return {
        'slug': 'transceivers',
        'name': 'Transceivers',
        'icon': Icons.storefront_rounded,
        'defaultCover': 'demos/demo15/categories/Transceivers.webp',
      };
    } else if (lower.contains('education') || lower.contains('campus')) {
      return {
        'slug': 'panels-enclosures-and-racks',
        'name': 'Panels, Enclosures & Racks',
        'icon': Icons.school_rounded,
        'defaultCover': 'demos/demo15/categories/Panels,%20Enclosures%20&%20Racks.webp',
      };
    } else if (lower.contains('healthcare') || lower.contains('medical')) {
      return {
        'slug': 'switches',
        'name': 'Switches',
        'icon': Icons.local_hospital_rounded,
        'defaultCover': 'demos/demo15/categories/Switches.webp',
      };
    } else if (lower.contains('security') || lower.contains('surveillance')) {
      return {
        'slug': 'security-and-surveillance',
        'name': 'Security & Surveillance',
        'icon': Icons.videocam_rounded,
        'defaultCover': 'pages/about_us/4.jpg',
      };
    }
    return {
      'slug': 'networking',
      'name': 'Networking',
      'icon': Icons.business_center_rounded,
      'defaultCover': 'demos/demo15/categories/Networking.webp',
    };
  }
}

/// Section 3: Solutions By Industry
class SolutionsByIndustrySection {
  final String eyebrow;
  final String title;
  final String subtitle;
  final List<IndustryCardItem> cards;

  const SolutionsByIndustrySection({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.cards,
  });

  factory SolutionsByIndustrySection.fromSection(Map<String, dynamic> section) {
    final cj = section['content_json'] is Map
        ? Map<String, dynamic>.from(section['content_json'])
        : <String, dynamic>{};

    final eyebrow = _s(cj, 'eyebrow', 'Solutions By Industry');
    final title = _s(cj, 'title', 'Built For Every Environment');
    final subtitle = _s(cj, 'subtitle', "Every industry has different demands on its network. Here's how we solve for each one.");

    final rawCards = cj['cards'];
    final List<IndustryCardItem> items = [];
    if (rawCards is List) {
      for (final c in rawCards) {
        if (c is Map) {
          items.add(IndustryCardItem.fromMap(Map<String, dynamic>.from(c)));
        }
      }
    }

    return SolutionsByIndustrySection(
      eyebrow: eyebrow,
      title: title,
      subtitle: subtitle,
      cards: items.isNotEmpty ? items : canonical().cards,
    );
  }

  static SolutionsByIndustrySection canonical() {
    return const SolutionsByIndustrySection(
      eyebrow: 'Solutions By Industry',
      title: 'Built For Every Environment',
      subtitle: "Every industry has different demands on its network. Here's how we solve for each one.",
      cards: [
        IndustryCardItem(
          title: 'Data Center & Enterprise',
          description: 'High-density fiber cabling, switching, and rack infrastructure engineered for uptime and scale.',
          coverImageUrl: 'https://vision.foduu.store/assets/images/demos/demo15/categories/Networking.webp',
          iconUrl: '2026/10/23/server-4d6920b5.webp',
          fallbackIcon: Icons.dns_rounded,
          categorySlug: 'networking',
          categoryName: 'Networking',
        ),
        IndustryCardItem(
          title: 'ISP & Telecom',
          description: 'FTTH drop cables, splitters, and outside-plant fiber built for large-scale last-mile rollouts.',
          coverImageUrl: 'https://vision.foduu.store/assets/images/demos/demo15/categories/Fiber%20Cables.webp',
          iconUrl: '2026/10/23/tower-857f82bb.webp',
          fallbackIcon: Icons.cell_tower_rounded,
          categorySlug: 'fiber-cables',
          categoryName: 'Fiber Cables',
        ),
        IndustryCardItem(
          title: 'Retail & Warehousing',
          description: 'PoE switching and surveillance-ready networking for multi-site retail and logistics operations.',
          coverImageUrl: 'https://vision.foduu.store/assets/images/demos/demo15/categories/Transceivers.webp',
          iconUrl: '2026/10/23/shop-ff809775.webp',
          fallbackIcon: Icons.storefront_rounded,
          categorySlug: 'transceivers',
          categoryName: 'Transceivers',
        ),
        IndustryCardItem(
          title: 'Education Campuses',
          description: 'Structured cabling and patch panels that scale across classrooms, labs, and administration buildings.',
          coverImageUrl: 'https://vision.foduu.store/assets/images/demos/demo15/categories/Panels,%20Enclosures%20&%20Racks.webp',
          iconUrl: '2026/10/23/degree-hat-582acdff.webp',
          fallbackIcon: Icons.school_rounded,
          categorySlug: 'panels-enclosures-and-racks',
          categoryName: 'Panels, Enclosures & Racks',
        ),
        IndustryCardItem(
          title: 'Healthcare Facilities',
          description: 'Reliable, redundant network paths for mission-critical systems and always-on patient care.',
          coverImageUrl: 'https://vision.foduu.store/assets/images/demos/demo15/categories/Switches.webp',
          iconUrl: '2026/10/23/clinic-medical-a8ba927f.webp',
          fallbackIcon: Icons.local_hospital_rounded,
          categorySlug: 'switches',
          categoryName: 'Switches',
        ),
        IndustryCardItem(
          title: 'Security & Surveillance',
          description: 'Bandwidth-ready backbones and PoE switching purpose-built for city-wide and campus camera networks.',
          coverImageUrl: 'https://vision.foduu.store/assets/images/pages/about_us/4.jpg',
          iconUrl: '2026/10/23/video-d0fac565.webp',
          fallbackIcon: Icons.videocam_rounded,
          categorySlug: 'security-and-surveillance',
          categoryName: 'Security & Surveillance',
        ),
      ],
    );
  }
}

/// Item in Section 4: Capability Card
class NeedCardItem {
  final String title;
  final String description;
  final String imageUrl;
  final IconData fallbackIcon;

  const NeedCardItem({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.fallbackIcon,
  });

  factory NeedCardItem.fromMap(Map<String, dynamic> map) {
    final title = _s(map, 'heading', _s(map, 'title', 'Capability'));
    final desc = _s(map, 'text', _s(map, 'desc', ''));
    final img = _s(map, 'image', _s(map, 'imageUrl', ''));

    return NeedCardItem(
      title: title,
      description: desc,
      imageUrl: img,
      fallbackIcon: _inferIcon(title),
    );
  }

  static IconData _inferIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('design') || lower.contains('plan')) {
      return Icons.schema_rounded;
    } else if (lower.contains('security') || lower.contains('redundancy')) {
      return Icons.security_rounded;
    } else if (lower.contains('upgrade') || lower.contains('legacy')) {
      return Icons.published_with_changes_rounded;
    } else if (lower.contains('support') || lower.contains('deployment')) {
      return Icons.support_agent_rounded;
    }
    return Icons.lightbulb_outline_rounded;
  }
}

/// Section 4: Solutions By Need
class SolutionsByNeedSection {
  final String eyebrow;
  final String title;
  final String subtitle;
  final List<NeedCardItem> cards;

  const SolutionsByNeedSection({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.cards,
  });

  factory SolutionsByNeedSection.fromSection(Map<String, dynamic> section) {
    final cj = section['content_json'] is Map
        ? Map<String, dynamic>.from(section['content_json'])
        : <String, dynamic>{};

    final eyebrow = _s(cj, 'eyebrow', 'Solutions By Need');
    final title = _s(cj, 'title', 'Whatever The Challenge, We Have A Solution');
    final subtitle = _s(cj, 'subtitle', '');

    final rawCards = cj['cards'];
    final List<NeedCardItem> items = [];
    if (rawCards is List) {
      for (final c in rawCards) {
        if (c is Map) {
          items.add(NeedCardItem.fromMap(Map<String, dynamic>.from(c)));
        }
      }
    }

    return SolutionsByNeedSection(
      eyebrow: eyebrow,
      title: title,
      subtitle: subtitle,
      cards: items.isNotEmpty ? items : canonical().cards,
    );
  }

  static SolutionsByNeedSection canonical() {
    return const SolutionsByNeedSection(
      eyebrow: 'Solutions By Need',
      title: 'Whatever The Challenge, We Have A Solution',
      subtitle: '',
      cards: [
        NeedCardItem(
          title: 'Network Design & Planning',
          description: 'Site surveys, capacity planning, and topology design that scale with your growth, not against it.',
          imageUrl: '2026/10/23/project-diagram-98515ef2.webp',
          fallbackIcon: Icons.schema_rounded,
        ),
        NeedCardItem(
          title: 'Network Security & Redundancy',
          description: 'Failover paths, managed switching, and access control designed to keep critical systems online.',
          imageUrl: '2026/10/23/shild-366b966a.webp',
          fallbackIcon: Icons.security_rounded,
        ),
        NeedCardItem(
          title: 'Legacy Network Upgrades',
          description: 'Migrate aging copper and unmanaged gear to fiber-ready, centrally managed infrastructure with minimal downtime.',
          imageUrl: '2026/10/23/reload-657990ce.webp',
          fallbackIcon: Icons.published_with_changes_rounded,
        ),
        NeedCardItem(
          title: 'Deployment & After-Sales Support',
          description: 'On-site installation, testing, and ongoing technical support long after the network goes live.',
          imageUrl: '2026/10/23/microphone-567a0cab.webp',
          fallbackIcon: Icons.support_agent_rounded,
        ),
      ],
    );
  }
}

/// Section 5: Consultation CTA Banner
class SolutionsConsultationCta {
  final String heading;
  final String description;
  final String buttonText;
  final String imageUrl;

  const SolutionsConsultationCta({
    required this.heading,
    required this.description,
    required this.buttonText,
    required this.imageUrl,
  });

  factory SolutionsConsultationCta.fromSliderContent(Map<String, dynamic> item) {
    return SolutionsConsultationCta(
      heading: _s(item, 'heading', 'Not Sure Which Solution Fits Your Project?'),
      description: _s(item, 'description', 'Tell us about your site and requirements — our engineers will recommend the right infrastructure and a bill of materials to match.'),
      buttonText: _s(item, 'button_text', 'Request A Consultation'),
      imageUrl: _s(item, 'filePath', _s(item, 'download_url', '2026/10/23/Polished-Blue-Gradient-Banner-91ccabda.webp')),
    );
  }

  factory SolutionsConsultationCta.fromLegacyFields(Map<String, dynamic> f) {
    return SolutionsConsultationCta(
      heading: _s(f, 'cta_heading', 'Not Sure Which Solution Fits Your Project?'),
      description: _s(f, 'cta_description', 'Tell us about your site and requirements — our engineers will recommend the right infrastructure and a bill of materials to match.'),
      buttonText: _s(f, 'cta_button_text', 'Request A Consultation'),
      imageUrl: '2026/10/23/Polished-Blue-Gradient-Banner-91ccabda.webp',
    );
  }

  static SolutionsConsultationCta canonical() {
    return const SolutionsConsultationCta(
      heading: 'Not Sure Which Solution Fits Your Project?',
      description: 'Tell us about your site and requirements — our engineers will recommend the right infrastructure and a bill of materials to match.',
      buttonText: 'Request A Consultation',
      imageUrl: '2026/10/23/Polished-Blue-Gradient-Banner-91ccabda.webp',
    );
  }
}

/// Aggregated Root Container for the complete Solutions Page
class SolutionsSectionsData {
  final SolutionsBannerHeader header;
  final SolutionsIntroSection intro;
  final SolutionsByIndustrySection byIndustry;
  final SolutionsByNeedSection byNeed;
  final SolutionsConsultationCta cta;

  const SolutionsSectionsData({
    required this.header,
    required this.intro,
    required this.byIndustry,
    required this.byNeed,
    required this.cta,
  });

  factory SolutionsSectionsData.fromSections(List sections) {
    SolutionsBannerHeader header = SolutionsBannerHeader.canonical();
    SolutionsIntroSection intro = SolutionsIntroSection.canonical();
    SolutionsByIndustrySection byIndustry = SolutionsByIndustrySection.canonical();
    SolutionsByNeedSection byNeed = SolutionsByNeedSection.canonical();
    SolutionsConsultationCta cta = SolutionsConsultationCta.canonical();

    int trustBadgesCount = 0;

    for (final s in sections) {
      if (s is! Map) continue;
      final map = Map<String, dynamic>.from(s);
      final type = map['type']?.toString().toLowerCase() ?? '';
      final cj = map['content_json'] is Map ? Map<String, dynamic>.from(map['content_json']) : <String, dynamic>{};

      if (type == 'banner') {
        header = SolutionsBannerHeader.fromSection(map);
      } else if (type == 'slider') {
        final slider = cj['slider'] is Map ? Map<String, dynamic>.from(cj['slider']) : <String, dynamic>{};
        final slug = (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();
        final content = slider['content'];
        Map<String, dynamic>? firstItem;
        if (content is List && content.isNotEmpty && content.first is Map) {
          firstItem = Map<String, dynamic>.from(content.first as Map);
        }

        if (firstItem != null) {
          if (slug.contains('main') || slug.contains('intro')) {
            intro = SolutionsIntroSection.fromSliderContent(firstItem);
          } else if (slug.contains('solution') || slug.contains('consultation')) {
            cta = SolutionsConsultationCta.fromSliderContent(firstItem);
          } else {
            // Check content fields to disambiguate
            final heading = firstItem['heading']?.toString() ?? '';
            if (heading.contains('What We Deliver') || heading.contains('Industries Served')) {
              intro = SolutionsIntroSection.fromSliderContent(firstItem);
            } else {
              cta = SolutionsConsultationCta.fromSliderContent(firstItem);
            }
          }
        }
      } else if (type == 'trust_badges') {
        trustBadgesCount++;
        final eyebrow = cj['eyebrow']?.toString().toLowerCase() ?? '';
        final title = cj['title']?.toString().toLowerCase() ?? '';

        if (eyebrow.contains('industry') || title.contains('environment') || trustBadgesCount == 1) {
          byIndustry = SolutionsByIndustrySection.fromSection(map);
        } else {
          byNeed = SolutionsByNeedSection.fromSection(map);
        }
      }
    }

    return SolutionsSectionsData(
      header: header,
      intro: intro,
      byIndustry: byIndustry,
      byNeed: byNeed,
      cta: cta,
    );
  }

  factory SolutionsSectionsData.fromPageComponents(List<PageComponent> components) {
    SolutionsBannerHeader header = SolutionsBannerHeader.canonical();
    SolutionsIntroSection intro = SolutionsIntroSection.canonical();
    SolutionsByIndustrySection byIndustry = SolutionsByIndustrySection.canonical();
    SolutionsByNeedSection byNeed = SolutionsByNeedSection.canonical();
    SolutionsConsultationCta cta = SolutionsConsultationCta.canonical();

    for (final c in components) {
      final f = c.fields;
      switch (c.type) {
        case 'about-us_page-header':
        case 'solutions_page-header':
          header = SolutionsBannerHeader(
            imageUrl: _s(f, 'header_image', '2026/10/23/Solutions-on-Navy-Gradient-7ce8fd80.webp'),
            altText: _s(f, 'h1_about_us', 'Solutions'),
          );
          break;
        case 'solutions_solutions-intro':
          intro = SolutionsIntroSection.fromLegacyFields(f);
          break;
        case 'solutions_industry-solutions':
          // Keep canonical industry list which mirrors live site
          byIndustry = SolutionsByIndustrySection.canonical();
          break;
        case 'solutions_solution-capabilities':
          // Keep canonical need capabilities which mirrors live site
          byNeed = SolutionsByNeedSection.canonical();
          break;
        case 'solutions_solution-cta':
          cta = SolutionsConsultationCta.fromLegacyFields(f);
          break;
      }
    }

    return SolutionsSectionsData(
      header: header,
      intro: intro,
      byIndustry: byIndustry,
      byNeed: byNeed,
      cta: cta,
    );
  }

  static SolutionsSectionsData canonical() {
    return SolutionsSectionsData(
      header: SolutionsBannerHeader.canonical(),
      intro: SolutionsIntroSection.canonical(),
      byIndustry: SolutionsByIndustrySection.canonical(),
      byNeed: SolutionsByNeedSection.canonical(),
      cta: SolutionsConsultationCta.canonical(),
    );
  }
}
