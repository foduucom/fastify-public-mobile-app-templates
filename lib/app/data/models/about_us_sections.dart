import 'package:zouhi/app/data/models/page_model.dart';

String _s(dynamic f, String key, [String fallback = '']) {
  if (f is! Map) return fallback;
  final v = f[key]?.toString().trim() ?? '';
  return v.isEmpty ? fallback : v;
}

class AboutHeroHeader {
  final String title;
  final String backgroundImage;

  const AboutHeroHeader({
    required this.title,
    required this.backgroundImage,
  });

  factory AboutHeroHeader.fromComponent(PageComponent? c) {
    if (c == null) {
      return const AboutHeroHeader(
        title: 'About Us',
        backgroundImage: '/images/2026/08/31/3-9d37ade8.webp',
      );
    }
    final f = c.fields;
    return AboutHeroHeader(
      title: _s(f, 'h1_about_us', 'About Us'),
      backgroundImage:
          _s(f, 'header_image', '/images/2026/08/31/3-9d37ade8.webp'),
    );
  }

  factory AboutHeroHeader.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      final type = s['type']?.toString();
      final id = s['id']?.toString();
      final cj = s['content_json'] is Map
          ? Map<String, dynamic>.from(s['content_json'])
          : <String, dynamic>{};

      if (type == 'header' || id == 'header') {
        return AboutHeroHeader(
          title: _s(cj, 'title', 'About Us'),
          backgroundImage:
              _s(cj, 'backgroundImage', '/images/2026/08/31/3-9d37ade8.webp'),
        );
      }

      // Fastify Studio CMS layout sends the top header as a slider section
      if (type == 'slider' || id == 'slider') {
        final slider = cj['slider'] is Map
            ? Map<String, dynamic>.from(cj['slider'])
            : <String, dynamic>{};
        final name = (slider['name'] ?? slider['slug'] ?? '').toString().toLowerCase();
        if (name.contains('about-us-slider') ||
            name.contains('header') ||
            name == 'about-us-slider') {
          final content = slider['content'];
          if (content is List && content.isNotEmpty && content.first is Map) {
            final first = content.first as Map;
            final path = first['filePath'] ?? first['download_url'] ?? first['url'] ?? '';
            final heading = first['heading']?.toString().trim() ?? '';
            return AboutHeroHeader(
              title: heading.isNotEmpty ? heading : 'About Us',
              backgroundImage: path.toString().trim().isNotEmpty
                  ? path.toString().trim()
                  : '/images/2026/08/31/3-9d37ade8.webp',
            );
          }
        }
      }
    }
    return const AboutHeroHeader(
      title: 'About Us',
      backgroundImage: '/images/2026/08/31/3-9d37ade8.webp',
    );
  }
}

class AboutHeroStory {
  final String title;
  final String description;
  final String bannerImage;
  final String ctaText;
  final String ctaLink;

  const AboutHeroStory({
    required this.title,
    required this.description,
    required this.bannerImage,
    required this.ctaText,
    required this.ctaLink,
  });

  static const String defaultDescription =
      'Vision Infrastructure is a leading networking and optical cable provider in India. We deliver high-performance fiber optic solutions, structured cabling, server racks, and data center connectivity designed to meet the strict demands of modern enterprise infrastructure.';

  factory AboutHeroStory.fromComponent(PageComponent? c) {
    if (c == null) {
      return const AboutHeroStory(
        title: 'About Vision Infrastructure',
        description: defaultDescription,
        bannerImage: '/images/2026/08/29/3-aaed866d.webp',
        ctaText: '',
        ctaLink: '',
      );
    }
    final f = c.fields;
    final rawDesc = _s(f, 'section_description');
    final desc = rawDesc.isNotEmpty ? rawDesc : defaultDescription;

    return AboutHeroStory(
      title: _s(f, 'section_title', 'About Vision Infrastructure'),
      description: desc,
      bannerImage: _s(f, 'banner_image', '/images/2026/08/29/3-aaed866d.webp'),
      ctaText: _s(f, 'cta_text', ''),
      ctaLink: _s(f, 'cta_link', ''),
    );
  }

  factory AboutHeroStory.fromSections(List sections) {
    String bannerImg = '/images/2026/08/29/3-aaed866d.webp';
    String title = 'About Vision Infrastructure';
    String desc = defaultDescription;

    for (final s in sections) {
      if (s is! Map) continue;
      final type = s['type']?.toString();
      final id = s['id']?.toString();
      final cj = s['content_json'] is Map
          ? Map<String, dynamic>.from(s['content_json'])
          : <String, dynamic>{};

      // 1. Fastify Studio CMS sends the main banner story as a slider (e.g. "about-us-main-banner")
      if (type == 'slider' || id == 'slider') {
        final slider = cj['slider'] is Map
            ? Map<String, dynamic>.from(cj['slider'])
            : <String, dynamic>{};
        final name = (slider['name'] ?? slider['slug'] ?? '').toString().toLowerCase();
        if (name.contains('main-banner') ||
            name.contains('story') ||
            name.contains('about-us-main')) {
          final content = slider['content'];
          if (content is List && content.isNotEmpty && content.first is Map) {
            final first = content.first as Map;
            final path = first['filePath'] ?? first['download_url'] ?? first['url'];
            if (path != null && path.toString().trim().isNotEmpty) {
              bannerImg = path.toString().trim();
            }
            final h = first['heading']?.toString().trim() ?? '';
            if (h.isNotEmpty) {
              title = h;
            }
            final d = first['description']?.toString().trim() ?? '';
            if (d.isNotEmpty) {
              desc = d;
            }
          }
        }
      } else if (type == 'banner' || id == 'banner') {
        final banners = cj['banners'];
        if (banners is List && banners.isNotEmpty) {
          final firstBanner = banners.first;
          if (firstBanner is Map) {
            final items = firstBanner['items'];
            if (items is List && items.isNotEmpty) {
              final item = items.first;
              if (item is Map) {
                final feat = item['featured_image'];
                if (feat is Map) {
                  final url = feat['download_url'] ?? feat['filepath'] ?? feat['filePath'];
                  if (url != null && url.toString().trim().isNotEmpty) {
                    bannerImg = url.toString().trim();
                  }
                }
              }
            }
          }
        }
      } else if (type == 'text_block' || id == 'text_block') {
        final rawText = cj['text']?.toString().trim() ?? '';
        if (rawText.isNotEmpty) {
          final lines = rawText
              .split('\n')
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty)
              .toList();
          if (lines.isNotEmpty) {
            title = lines.first;
            if (lines.length > 1) {
              final remaining = lines.sublist(1).join(' ').trim();
              if (remaining.isNotEmpty) {
                desc = remaining;
              }
            }
          }
        }
      }
    }

    return AboutHeroStory(
      title: title,
      description: desc,
      bannerImage: bannerImg,
      ctaText: '',
      ctaLink: '',
    );
  }
}

class AboutWhyChooseItem {
  final String title;
  final String description;
  final String iconKey;
  final String imageUrl;

  const AboutWhyChooseItem({
    required this.title,
    required this.description,
    required this.iconKey,
    this.imageUrl = '',
  });
}

class AboutWhyChooseSection {
  final String eyebrow;
  final String title;
  final String subtitle;
  final List<AboutWhyChooseItem> features;

  const AboutWhyChooseSection({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.features,
  });

  static const List<AboutWhyChooseItem> defaultFeatures = [
    AboutWhyChooseItem(
      title: 'Certified Quality',
      description:
          'Every product meets strict industry standards for performance and durability.',
      iconKey: 'verification',
    ),
    AboutWhyChooseItem(
      title: 'Expert Support',
      description:
          'Our technical team is with you from product selection through installation.',
      iconKey: 'headset',
    ),
    AboutWhyChooseItem(
      title: 'Reliable Delivery',
      description:
          'Timely, competitive delivery for projects of every scale, across India.',
      iconKey: 'truck',
    ),
    AboutWhyChooseItem(
      title: 'Competitive Pricing',
      description:
          'Single-source procurement that keeps your infrastructure budget on track.',
      iconKey: 'tags',
    ),
  ];

  factory AboutWhyChooseSection.fromComponent(PageComponent? c) {
    if (c == null) {
      return const AboutWhyChooseSection(
        eyebrow: 'WHY VISION INFRASTRUCTURE',
        title: 'Why Choose Vision Infrastructure',
        subtitle:
            'Everything you need from a single, dependable network infrastructure partner.',
        features: defaultFeatures,
      );
    }

    final f = c.fields;
    final dynamicTitle = _s(f, 'feature_title');
    final dynamicDesc = _s(f, 'feature_description');

    final list = <AboutWhyChooseItem>[];
    if (dynamicTitle.isNotEmpty) {
      list.add(AboutWhyChooseItem(
        title: dynamicTitle,
        description: dynamicDesc.isNotEmpty
            ? dynamicDesc
            : defaultFeatures.first.description,
        iconKey: 'verification',
      ));
    }

    // Merge the remaining canonical features from the website
    for (final def in defaultFeatures) {
      if (!list.any((item) =>
          item.title.toLowerCase().trim() == def.title.toLowerCase().trim())) {
        list.add(def);
      }
    }

    return AboutWhyChooseSection(
      eyebrow: _s(f, 'section_eyebrow', 'WHY VISION INFRASTRUCTURE'),
      title: _s(f, 'section_title', 'Why Choose Vision Infrastructure'),
      subtitle: _s(f, 'section_subtitle',
          'Everything you need from a single, dependable network infrastructure partner.'),
      features: list.isEmpty ? defaultFeatures : list,
    );
  }

  factory AboutWhyChooseSection.fromSections(List sections) {
    Map<String, dynamic>? targetJson;

    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'trust_badges' || s['id'] == 'trust_badges') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final eyebrow = (cj['eyebrow'] ?? '').toString().toUpperCase();
        final title = (cj['title'] ?? '').toString().toUpperCase();
        if (eyebrow.contains('WHY') ||
            title.contains('WHY') ||
            title.contains('CHOOSE')) {
          targetJson = cj;
          break;
        }
      }
    }

    if (targetJson == null) {
      for (final s in sections) {
        if (s is Map &&
            (s['type'] == 'trust_badges' || s['id'] == 'trust_badges')) {
          targetJson = s['content_json'] is Map
              ? Map<String, dynamic>.from(s['content_json'])
              : <String, dynamic>{};
          break;
        }
      }
    }

    if (targetJson == null) {
      return const AboutWhyChooseSection(
        eyebrow: 'WHY VISION INFRASTRUCTURE',
        title: 'Why Choose Vision Infrastructure',
        subtitle:
            'Everything you need from a single, dependable network infrastructure partner.',
        features: defaultFeatures,
      );
    }

    final eyebrow = _s(targetJson, 'eyebrow', 'WHY VISION INFRASTRUCTURE');
    final title = _s(targetJson, 'title', 'Why Choose Vision Infrastructure');
    final subtitle = _s(targetJson, 'subtitle',
        'Everything you need from a single, dependable network infrastructure partner.');

    final rawCards = targetJson['cards'] ?? targetJson['items'];
    final list = <AboutWhyChooseItem>[];

    if (rawCards is List && rawCards.isNotEmpty) {
      for (final c in rawCards) {
        if (c is! Map) continue;
        final heading = _s(c, 'heading', _s(c, 'title'));
        final text = _s(c, 'text', _s(c, 'description'));

        String img = '';
        if (c['image'] is Map) {
          final m = c['image'] as Map;
          img = (m['download_url'] ?? m['filepath'] ?? m['filePath'] ?? m['url'] ?? '').toString();
        } else if (c['image'] != null && c['image'].toString().trim().isNotEmpty) {
          img = c['image'].toString().trim();
        } else if (c['icon'] is Map) {
          final m = c['icon'] as Map;
          img = (m['download_url'] ?? m['filepath'] ?? m['filePath'] ?? m['url'] ?? '').toString();
        } else if (c['icon'] != null && c['icon'].toString().trim().isNotEmpty) {
          img = c['icon'].toString().trim();
        }

        String iconKey = 'verification';
        final lowerHeading = heading.toLowerCase();
        if (lowerHeading.contains('quality') ||
            lowerHeading.contains('certified')) {
          iconKey = 'quality';
        } else if (lowerHeading.contains('support') ||
            lowerHeading.contains('expert')) {
          iconKey = 'support';
        } else if (lowerHeading.contains('delivery') ||
            lowerHeading.contains('truck')) {
          iconKey = 'delivery';
        } else if (lowerHeading.contains('price') ||
            lowerHeading.contains('pricing')) {
          iconKey = 'pricing';
        }

        list.add(AboutWhyChooseItem(
          title: heading,
          description: text,
          iconKey: iconKey,
          imageUrl: img,
        ));
      }
    }

    return AboutWhyChooseSection(
      eyebrow: eyebrow,
      title: title,
      subtitle: subtitle,
      features: list.isEmpty ? defaultFeatures : list,
    );
  }
}

class AboutProcessStep {
  final String stepNumber;
  final String title;
  final String description;
  final String imageUrl;

  const AboutProcessStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.imageUrl = '',
  });
}

class AboutProcessSection {
  final String eyebrow;
  final String title;
  final String subtitle;
  final List<AboutProcessStep> steps;

  const AboutProcessSection({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.steps,
  });

  static const List<AboutProcessStep> defaultSteps = [
    AboutProcessStep(
      stepNumber: '01',
      title: 'Consultation',
      description:
          'We assess your requirements and site conditions to scope the right solution.',
    ),
    AboutProcessStep(
      stepNumber: '02',
      title: 'Custom Design',
      description:
          'Our engineers design a scalable, future-ready network tailored to your budget.',
    ),
    AboutProcessStep(
      stepNumber: '03',
      title: 'Procurement & Delivery',
      description:
          'We source and deliver every component from a single, reliable supply chain.',
    ),
    AboutProcessStep(
      stepNumber: '04',
      title: 'Install & Support',
      description:
          'On-site installation followed by ongoing technical and after-sales support.',
    ),
  ];

  factory AboutProcessSection.fromComponent(PageComponent? c) {
    if (c == null) {
      return const AboutProcessSection(
        eyebrow: 'How We Work',
        title: 'Our Process',
        subtitle:
            "From first consultation to post-deployment support, here's how we work with you.",
        steps: defaultSteps,
      );
    }

    final f = c.fields;
    final steps = <AboutProcessStep>[];

    for (int i = 1; i <= 10; i++) {
      final t = _s(f, 'step_${i}_title');
      if (t.isEmpty) continue;
      final rawNum = _s(f, 'step_${i}_number', '$i');
      final num = rawNum.length == 1 ? '0$rawNum' : rawNum;
      final d = _s(f, 'step_${i}_description');
      steps.add(AboutProcessStep(stepNumber: num, title: t, description: d));
    }

    if (steps.length < defaultSteps.length) {
      for (final def in defaultSteps) {
        if (!steps.any((s) =>
            s.title.toLowerCase().trim() == def.title.toLowerCase().trim() ||
            s.stepNumber == def.stepNumber)) {
          steps.add(def);
        }
      }
      steps.sort((a, b) => a.stepNumber.compareTo(b.stepNumber));
    }

    return AboutProcessSection(
      eyebrow: _s(f, 'section_subtitle', 'How We Work'),
      title: _s(f, 'section_title', 'Our Process'),
      subtitle: _s(f, 'section_description',
          "From first consultation to post-deployment support, here's how we work with you."),
      steps: steps.isEmpty ? defaultSteps : steps,
    );
  }

  factory AboutProcessSection.fromSections(List sections) {
    Map<String, dynamic>? targetJson;

    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'trust_badges' || s['id'] == 'trust_badges') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final eyebrow = (cj['eyebrow'] ?? '').toString().toLowerCase();
        final title = (cj['title'] ?? '').toString().toLowerCase();
        if (eyebrow.contains('work') ||
            title.contains('process') ||
            eyebrow.contains('how')) {
          targetJson = cj;
          break;
        }
      }
    }

    if (targetJson == null) {
      final allBadges = sections
          .where((s) =>
              s is Map &&
              (s['type'] == 'trust_badges' || s['id'] == 'trust_badges'))
          .toList();
      if (allBadges.length > 1) {
        final s = allBadges[1];
        if (s is Map && s['content_json'] is Map) {
          targetJson = Map<String, dynamic>.from(s['content_json']);
        }
      }
    }

    if (targetJson == null) {
      return const AboutProcessSection(
        eyebrow: 'How We Work',
        title: 'Our Process',
        subtitle:
            "From first consultation to post-deployment support, here's how we work with you.",
        steps: defaultSteps,
      );
    }

    final eyebrow = _s(targetJson, 'eyebrow', 'How We Work');
    final title = _s(targetJson, 'title', 'Our Process');
    final subtitle = _s(targetJson, 'subtitle',
        "From first consultation to post-deployment support, here's how we work with you.");

    final rawCards = targetJson['cards'] ?? targetJson['items'];
    final steps = <AboutProcessStep>[];

    if (rawCards is List && rawCards.isNotEmpty) {
      for (int i = 0; i < rawCards.length; i++) {
        final c = rawCards[i];
        if (c is! Map) continue;
        final heading = _s(c, 'heading', _s(c, 'title'));
        final text = _s(c, 'text', _s(c, 'description'));
        final img = _s(c, 'image', _s(c, 'icon'));
        final num = (i + 1).toString().padLeft(2, '0');

        steps.add(AboutProcessStep(
          stepNumber: num,
          title: heading,
          description: text,
          imageUrl: img,
        ));
      }
    }

    return AboutProcessSection(
      eyebrow: eyebrow,
      title: title,
      subtitle: subtitle,
      steps: steps.isEmpty ? defaultSteps : steps,
    );
  }
}

class AboutTestimonialItem {
  final String name;
  final String role;
  final String avatarUrl;
  final String review;
  final double rating;

  const AboutTestimonialItem({
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.review,
    this.rating = 5.0,
  });
}

class AboutTestimonialsSection {
  final String eyebrow;
  final String title;
  final List<AboutTestimonialItem> items;

  const AboutTestimonialsSection({
    required this.eyebrow,
    required this.title,
    required this.items,
  });

  static const List<AboutTestimonialItem> defaultItems = [
    AboutTestimonialItem(
      name: 'Ajish Mehta',
      role: 'IT Manager, TechCorp India',
      avatarUrl:
          'https://6a92a52778a2a51e604f819d.vbought.com/images/2026/09/03/download-0286a194.webp',
      review:
          'Vision Infrastructure has been our go-to partner for all fiber optic and network cabling needs. Their products are top quality and their technical team resolved our data center cabling in record time.',
      rating: 5.0,
    ),
    AboutTestimonialItem(
      name: 'Amiti Verma',
      role: 'Operations Head, DataLink Systems',
      avatarUrl:
          'https://6a92a52778a2a51e604f819d.vbought.com/images/2026/09/03/download-63541a90.webp',
      review:
          'From server racks to optical transceivers, Vision Infrastructure is a one-stop shop. Their knowledgeable team helped us choose the right solution within our budget — highly recommended!',
      rating: 5.0,
    ),
    AboutTestimonialItem(
      name: 'Rajesh Mehta',
      role: 'Network Engineer, Infosys Ltd.',
      avatarUrl:
          'https://6a92a52778a2a51e604f819d.vbought.com/images/2026/09/03/download-fd3ea20d.webp',
      review:
          'We ordered MTP/MPO trunk cables for a large-scale campus deployment. Vision Infrastructure delivered on time with excellent quality and provided full on-site support throughout the installation.',
      rating: 5.0,
    ),
  ];

  factory AboutTestimonialsSection.fromComponent(PageComponent? c) {
    if (c == null) {
      return const AboutTestimonialsSection(
        eyebrow: 'Testimonials',
        title: 'What Our Clients Say',
        items: [],
      );
    }
    final f = c.fields;
    return AboutTestimonialsSection(
      eyebrow: _s(f, 'section_subtitle', 'Testimonials'),
      title: _s(f, 'section_title', 'What Our Clients Say'),
      items: const [],
    );
  }

  factory AboutTestimonialsSection.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      final type = s['type']?.toString();
      final id = s['id']?.toString();
      if (type == 'testimonials' || id == 'testimonials') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final cards = cj['cards'] ?? cj['items'] ?? cj['reviews'];
        if (cards is List && cards.isNotEmpty) {
          final items = <AboutTestimonialItem>[];
          for (final c in cards) {
            if (c is Map) {
              items.add(AboutTestimonialItem(
                name: _s(c, 'name', _s(c, 'title')),
                role: _s(c, 'role', _s(c, 'designation')),
                avatarUrl: _s(c, 'avatar', _s(c, 'image')),
                review: _s(c, 'review', _s(c, 'text')),
              ));
            }
          }
          if (items.isNotEmpty) {
            return AboutTestimonialsSection(
              eyebrow: _s(cj, 'eyebrow', 'Testimonials'),
              title: _s(cj, 'title', 'What Our Clients Say'),
              items: items,
            );
          }
        }
      }
    }
    return const AboutTestimonialsSection(
      eyebrow: 'Testimonials',
      title: 'What Our Clients Say',
      items: [],
    );
  }
}

class AboutTrustStat {
  final String value;
  final String label;

  const AboutTrustStat({required this.value, required this.label});
}
