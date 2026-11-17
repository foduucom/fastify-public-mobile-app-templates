// ─────────────────────────────────────────────────────────────────────────────
// 1. Hero Header Banner (Top Slider: about-us)
// ─────────────────────────────────────────────────────────────────────────────
class AboutHeroHeader {
  final String title;
  final String subtitle;
  final String description;
  final String backgroundImage;

  const AboutHeroHeader({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.backgroundImage,
  });

  static const String defaultTitle = 'About Us';
  static const String defaultSubtitle =
      'We’re Here to Upgrade Your World With Technology';
  static const String defaultDescription =
      'Shop the latest electronics and smart devices, carefully selected to bring you better performance, smarter solutions, and a seamless digital lifestyle.';
  static const String defaultImage =
      '2026/11/17/appliance-lineup-f27d481f.webp';

  factory AboutHeroHeader.fallback() {
    return const AboutHeroHeader(
      title: defaultTitle,
      subtitle: defaultSubtitle,
      description: defaultDescription,
      backgroundImage: defaultImage,
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

      if (type == 'slider' || id == 'slider') {
        final slider = cj['slider'] is Map
            ? Map<String, dynamic>.from(cj['slider'])
            : <String, dynamic>{};
        final slug =
            (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();

        if (slug == 'about-us' || slug.contains('about-us-slider') || slug == 'slider') {
          final content = slider['content'];
          if (content is List && content.isNotEmpty && content.first is Map) {
            final first = content.first as Map;
            final path = (first['filePath'] ??
                    first['download_url'] ??
                    first['url'] ??
                    '')
                .toString()
                .trim();
            final heading = first['heading']?.toString().trim() ?? '';
            final sub = first['sub_heading']?.toString().trim() ?? '';
            final desc = first['description']?.toString().trim() ?? '';

            return AboutHeroHeader(
              title: heading.isNotEmpty ? heading : defaultTitle,
              subtitle: sub.isNotEmpty ? sub : defaultSubtitle,
              description: desc.isNotEmpty ? desc : defaultDescription,
              backgroundImage: path.isNotEmpty ? path : defaultImage,
            );
          }
        }
      }
    }
    return AboutHeroHeader.fallback();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1b. Circular Category Rail (type: categories)
// ─────────────────────────────────────────────────────────────────────────────
class AboutCategoryItem {
  final String id;
  final String name;
  final String slug;
  final String iconUrl;

  const AboutCategoryItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.iconUrl,
  });
}

class AboutCategoriesSection {
  final List<AboutCategoryItem> categories;

  const AboutCategoriesSection({required this.categories});

  factory AboutCategoriesSection.fallback() {
    return const AboutCategoriesSection(
      categories: [
        AboutCategoryItem(
          id: 'test',
          name: 'Test',
          slug: 'test',
          iconUrl: '',
        ),
        AboutCategoryItem(
          id: '6ae96b20c7a7846a169e857b',
          name: 'Drones',
          slug: 'drones',
          iconUrl: '2026/11/03/cat-drones-2fabeb64.svg',
        ),
        AboutCategoryItem(
          id: 'smart-home',
          name: 'Smart Home',
          slug: 'smart-home',
          iconUrl: '2026/11/03/smart-home.svg',
        ),
        AboutCategoryItem(
          id: 'printers',
          name: 'Printers',
          slug: 'printers',
          iconUrl: '2026/11/03/printer.svg',
        ),
        AboutCategoryItem(
          id: 'monitors',
          name: 'Monitors',
          slug: 'monitors',
          iconUrl: '2026/11/03/monitor.svg',
        ),
      ],
    );
  }

  factory AboutCategoriesSection.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'categories') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final rawCats = cj['categories'];
        if (rawCats is List && rawCats.isNotEmpty) {
          final list = <AboutCategoryItem>[];
          for (final c in rawCats) {
            if (c is Map) {
              final id = (c['_id'] ?? c['id'] ?? '').toString();
              final name = (c['name'] ?? '').toString();
              final slug = (c['slug'] ?? '').toString();

              String icon = '';
              final featIcon = c['featured_image_icon'];
              if (featIcon is Map) {
                icon = (featIcon['download_url'] ??
                        featIcon['filepath'] ??
                        featIcon['filePath'] ??
                        '')
                    .toString();
              } else if (c['image'] != null) {
                icon = c['image'].toString();
              }

              if (name.isNotEmpty) {
                list.add(AboutCategoryItem(
                  id: id,
                  name: name,
                  slug: slug,
                  iconUrl: icon,
                ));
              }
            }
          }
          if (list.isNotEmpty) {
            return AboutCategoriesSection(categories: list);
          }
        }
      }
    }
    return AboutCategoriesSection.fallback();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Who We Are Story (Slider: about-us-second)
// ─────────────────────────────────────────────────────────────────────────────
class AboutHeroStory {
  final String title;
  final String subtitle;
  final String description;
  final String bannerImage;

  const AboutHeroStory({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.bannerImage,
  });

  static const String defaultTitle = 'Who We Are';
  static const String defaultSubtitle =
      'Engineering the Future of Home Sound & Living';
  static const String defaultDescription =
      'We believe technology shouldn’t just exist in your space — it should elevate it. Foduu Store was born from a simple obsession: to design and curate highly immersive hardware that seamlessly translates studio-grade performance into daily routines.';
  static const String defaultImage =
      '2026/11/17/k7-audio-banner-1ba355b3.webp';

  factory AboutHeroStory.fallback() {
    return const AboutHeroStory(
      title: defaultTitle,
      subtitle: defaultSubtitle,
      description: defaultDescription,
      bannerImage: defaultImage,
    );
  }

  factory AboutHeroStory.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      final type = s['type']?.toString();
      final id = s['id']?.toString();
      final cj = s['content_json'] is Map
          ? Map<String, dynamic>.from(s['content_json'])
          : <String, dynamic>{};

      if (type == 'slider' || id == 'slider') {
        final slider = cj['slider'] is Map
            ? Map<String, dynamic>.from(cj['slider'])
            : <String, dynamic>{};
        final slug =
            (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();

        if (slug.contains('second') ||
            slug.contains('who-we-are') ||
            slug.contains('story')) {
          final content = slider['content'];
          if (content is List && content.isNotEmpty && content.first is Map) {
            final first = content.first as Map;
            final path = (first['filePath'] ??
                    first['download_url'] ??
                    first['url'] ??
                    '')
                .toString()
                .trim();
            final heading = first['heading']?.toString().trim() ?? '';
            final sub = first['sub_heading']?.toString().trim() ?? '';
            final desc = first['description']?.toString().trim() ?? '';

            return AboutHeroStory(
              title: heading.isNotEmpty ? heading : defaultTitle,
              subtitle: sub.isNotEmpty ? sub : defaultSubtitle,
              description: desc.isNotEmpty ? desc : defaultDescription,
              bannerImage: path.isNotEmpty ? path : defaultImage,
            );
          }
        }
      }
    }
    return AboutHeroStory.fallback();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Global Footprint Stats (trust_badges: A Global Footprint of Sound)
// ─────────────────────────────────────────────────────────────────────────────
class AboutStatItem {
  final String heading;
  final String text;
  final String footer;

  const AboutStatItem({
    required this.heading,
    required this.text,
    required this.footer,
  });
}

class AboutStatsSection {
  final String title;
  final String subtitle;
  final List<AboutStatItem> stats;

  const AboutStatsSection({
    required this.title,
    required this.subtitle,
    required this.stats,
  });

  static const List<AboutStatItem> defaultStats = [
    AboutStatItem(
      heading: '120k+',
      text: 'Immersive Setups Delivered',
      footer: 'Acoustic systems deployed in designer living rooms worldwide.',
    ),
    AboutStatItem(
      heading: '4.9★',
      text: 'Expert & Customer Reviews',
      footer:
          'Consistently rated as the benchmark for tactile and acoustic quality.',
    ),
    AboutStatItem(
      heading: '2-Year',
      text: 'No-Hassle Direct Warranty',
      footer:
          'We stand behind our materials, from magnesium alloys to custom silicon.',
    ),
    AboutStatItem(
      heading: '24/7',
      text: 'Bespoke Setup Assistance',
      footer:
          'Direct line to acoustic advisors to fine-tune your interior response.',
    ),
  ];

  factory AboutStatsSection.fallback() {
    return const AboutStatsSection(
      title: 'A Global Footprint of Sound',
      subtitle:
          'Curated essentials with fast shipping, premium support, and verified reviews.',
      stats: defaultStats,
    );
  }

  factory AboutStatsSection.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'trust_badges') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final title = (cj['title'] ?? '').toString();
        final rawCards = cj['cards'] ?? cj['items'];

        if (title.toLowerCase().contains('footprint') ||
            title.toLowerCase().contains('sound') ||
            (rawCards is List &&
                rawCards.any((c) =>
                    c is Map &&
                    (c['heading'] ?? '').toString().contains('+')))) {
          final list = <AboutStatItem>[];
          if (rawCards is List) {
            for (final c in rawCards) {
              if (c is Map) {
                list.add(AboutStatItem(
                  heading: (c['heading'] ?? '').toString(),
                  text: (c['text'] ?? '').toString(),
                  footer: (c['footer'] ?? '').toString(),
                ));
              }
            }
          }
          return AboutStatsSection(
            title: title.isNotEmpty ? title : 'A Global Footprint of Sound',
            subtitle: (cj['subtitle'] ?? '').toString(),
            stats: list.isNotEmpty ? list : defaultStats,
          );
        }
      }
    }
    return AboutStatsSection.fallback();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Brand Showcase (trust_badges: Current assortment, 400 brands...)
// ─────────────────────────────────────────────────────────────────────────────
class AboutBrandsSection {
  final String title;
  final String subtitle;
  final List<String> brandImages;

  const AboutBrandsSection({
    required this.title,
    required this.subtitle,
    required this.brandImages,
  });

  static const List<String> defaultBrandImages = [
    '2026/11/17/aoc-bc460da5.webp',
    '2026/11/17/apc-e1a048e8.webp',
    '2026/11/17/ariete-2d1bce4d.webp',
    '2026/11/17/kindle-9b6e819f.webp',
    '2026/11/17/apogee-2-d7369cca.webp',
    '2026/11/17/ardo-2-2360d23b.webp',
    '2026/11/17/dell-emc-2-b5bed048.webp',
    '2026/11/17/benq-2-3f05965f.webp',
  ];

  factory AboutBrandsSection.fallback() {
    return const AboutBrandsSection(
      title: 'Current assortment, 400 brands and more than 200 thousand products.',
      subtitle:
          'Shop the latest electronics and smart devices, carefully selected to bring you better performance, smarter solutions, and a seamless digital lifestyle.',
      brandImages: defaultBrandImages,
    );
  }

  factory AboutBrandsSection.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'trust_badges') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final title = (cj['title'] ?? '').toString();
        final rawCards = cj['cards'] ?? cj['items'];
        final cols = int.tryParse('${cj['no_of_columns']}') ?? 0;

        if (title.toLowerCase().contains('brand') ||
            title.toLowerCase().contains('assortment') ||
            (cols == 4 &&
                rawCards is List &&
                rawCards.isNotEmpty &&
                rawCards.every((c) =>
                    c is Map &&
                    (c['heading'] ?? '').toString().trim().isEmpty &&
                    (c['image'] ?? '').toString().trim().isNotEmpty))) {
          final images = <String>[];
          if (rawCards is List) {
            for (final c in rawCards) {
              if (c is Map) {
                final img = (c['image'] ?? '').toString().trim();
                if (img.isNotEmpty) images.add(img);
              }
            }
          }
          return AboutBrandsSection(
            title: title.isNotEmpty
                ? title
                : 'Current assortment, 400 brands and more than 200 thousand products.',
            subtitle: (cj['subtitle'] ?? '').toString(),
            brandImages: images.isNotEmpty ? images : defaultBrandImages,
          );
        }
      }
    }
    return AboutBrandsSection.fallback();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Our Team (trust_badges: Our Team)
// ─────────────────────────────────────────────────────────────────────────────
class AboutTeamMember {
  final String name;
  final String role;
  final String avatarImage;

  const AboutTeamMember({
    required this.name,
    required this.role,
    required this.avatarImage,
  });
}

class AboutTeamSection {
  final String title;
  final String subtitle;
  final List<AboutTeamMember> members;

  const AboutTeamSection({
    required this.title,
    required this.subtitle,
    required this.members,
  });

  static const List<AboutTeamMember> defaultMembers = [
    AboutTeamMember(
      name: 'Sarah Miller',
      role: 'Creative Director',
      avatarImage: '2026/11/17/team-1-401d8081.webp',
    ),
    AboutTeamMember(
      name: 'James Carter',
      role: 'Head of Product',
      avatarImage: '2026/11/17/team-2-d2dc4e17.webp',
    ),
    AboutTeamMember(
      name: 'Elena Fischer',
      role: 'Customer Experience Lead',
      avatarImage: '2026/11/17/team-3-0e8d1981.webp',
    ),
    AboutTeamMember(
      name: 'Maya Robinson',
      role: 'Operations Director',
      avatarImage: '2026/11/17/team-4-ca258e94.webp',
    ),
  ];

  factory AboutTeamSection.fallback() {
    return const AboutTeamSection(
      title: 'Our Team',
      subtitle:
          'Curated essentials with fast shipping, premium support, and verified reviews',
      members: defaultMembers,
    );
  }

  factory AboutTeamSection.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'trust_badges') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final title = (cj['title'] ?? '').toString();

        if (title.toLowerCase().contains('team')) {
          final rawCards = cj['cards'] ?? cj['items'];
          final list = <AboutTeamMember>[];
          if (rawCards is List) {
            for (final c in rawCards) {
              if (c is Map) {
                list.add(AboutTeamMember(
                  name: (c['heading'] ?? '').toString(),
                  role: (c['text'] ?? '').toString(),
                  avatarImage: (c['image'] ?? '').toString(),
                ));
              }
            }
          }
          return AboutTeamSection(
            title: title.isNotEmpty ? title : 'Our Team',
            subtitle: (cj['subtitle'] ?? '').toString(),
            members: list.isNotEmpty ? list : defaultMembers,
          );
        }
      }
    }
    return AboutTeamSection.fallback();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. Guiding Philosophy (trust_badges: Our Guiding Philosophy)
// ─────────────────────────────────────────────────────────────────────────────
class AboutPhilosophyItem {
  final String title;
  final String description;
  final String iconUrl;

  const AboutPhilosophyItem({
    required this.title,
    required this.description,
    required this.iconUrl,
  });
}

class AboutPhilosophySection {
  final String title;
  final String subtitle;
  final List<AboutPhilosophyItem> items;

  const AboutPhilosophySection({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  static const List<AboutPhilosophyItem> defaultItems = [
    AboutPhilosophyItem(
      title: 'Obsessive Quality',
      description:
          'Every frequency, curve, and interface element is calibrated twice. We do not negotiate on audio resolution or build premium-grade materials.',
      iconUrl: '2026/11/17/value-quality-452cb6e7.svg',
    ),
    AboutPhilosophyItem(
      title: 'Immersive Design',
      description:
          'Tech should enrich your space, not crowd it. We design in architectural, matte silhouettes that feel premium and integrate effortlessly.',
      iconUrl: '2026/11/17/value-design-2-656427c2.svg',
    ),
    AboutPhilosophyItem(
      title: 'Direct Support',
      description:
          'When you buy an Foduu Store device, you secure a lifetime contract. Enjoy a direct, no-filler 2-year warranty and bespoke setup guidance.',
      iconUrl: '2026/11/17/value-support-ce371995.svg',
    ),
  ];

  factory AboutPhilosophySection.fallback() {
    return const AboutPhilosophySection(
      title: 'Our Guiding Philosophy',
      subtitle:
          'We structure our operation around three uncompromising pillars of modern hardware excellence.',
      items: defaultItems,
    );
  }

  factory AboutPhilosophySection.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'trust_badges') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final title = (cj['title'] ?? '').toString();

        if (title.toLowerCase().contains('philosophy') ||
            title.toLowerCase().contains('guiding')) {
          final rawCards = cj['cards'] ?? cj['items'];
          final list = <AboutPhilosophyItem>[];
          if (rawCards is List) {
            for (final c in rawCards) {
              if (c is Map) {
                list.add(AboutPhilosophyItem(
                  title: (c['heading'] ?? '').toString(),
                  description: (c['text'] ?? '').toString(),
                  iconUrl: (c['image'] ?? '').toString(),
                ));
              }
            }
          }
          return AboutPhilosophySection(
            title: title.isNotEmpty ? title : 'Our Guiding Philosophy',
            subtitle: (cj['subtitle'] ?? '').toString(),
            items: list.isNotEmpty ? list : defaultItems,
          );
        }
      }
    }
    return AboutPhilosophySection.fallback();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. Why Choose Us (trust_badges: Why Choose Us?)
// ─────────────────────────────────────────────────────────────────────────────
class AboutWhyChooseItem {
  final String title;
  final String description;
  final String iconUrl;
  final String footer;

  const AboutWhyChooseItem({
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.footer,
  });
}

class AboutWhyChooseSection {
  final String title;
  final String subtitle;
  final List<AboutWhyChooseItem> features;

  const AboutWhyChooseSection({
    required this.title,
    required this.subtitle,
    required this.features,
  });

  static const List<AboutWhyChooseItem> defaultFeatures = [
    AboutWhyChooseItem(
      title: 'Acoustic Precision',
      description:
          'Immerse yourself in high-fidelity sound. Our signature active noise canceling actively adapts to your environment for uninterrupted clarity.',
      iconUrl: '2026/11/17/shopping-basket-d4e4a8ec.svg',
      footer: 'See Products',
    ),
    AboutWhyChooseItem(
      title: 'Seamless eSIM',
      description:
          'Stay untethered with built-in digital SIM support. Direct cellular capability guarantees instant access without needing your phone nearby.',
      iconUrl: '2026/11/17/wallpaper-751ba035.svg',
      footer: 'Configure Cellular',
    ),
    AboutWhyChooseItem(
      title: 'Premium Store',
      description:
          'Unlock exclusive companion accessories, tailored travel cases, and designer studio editions straight from our dedicated ecosystem store.',
      iconUrl: '2026/11/17/badge-check-5b717ea7.svg',
      footer: 'Visit Store',
    ),
    AboutWhyChooseItem(
      title: 'Expert Warranty',
      description:
          'Every purchase is covered by our comprehensive two-year hardware warranty and round-the-clock dedicated expert support.',
      iconUrl: '2026/11/17/shield-check-f96af099.svg',
      footer: 'Read Protection',
    ),
  ];

  factory AboutWhyChooseSection.fallback() {
    return const AboutWhyChooseSection(
      title: 'Why Choose Us?',
      subtitle:
          'Engineered for pure acoustics and seamless day-to-day integration. Discover the unique hardware advantages that define our premium lineup of smart devices.',
      features: defaultFeatures,
    );
  }

  factory AboutWhyChooseSection.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'trust_badges') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final title = (cj['title'] ?? '').toString();

        if (title.toLowerCase().contains('why choose')) {
          final rawCards = cj['cards'] ?? cj['items'];
          final list = <AboutWhyChooseItem>[];
          if (rawCards is List) {
            for (final c in rawCards) {
              if (c is Map) {
                list.add(AboutWhyChooseItem(
                  title: (c['heading'] ?? '').toString(),
                  description: (c['text'] ?? '').toString(),
                  iconUrl: (c['image'] ?? '').toString(),
                  footer: (c['footer'] ?? '').toString(),
                ));
              }
            }
          }
          return AboutWhyChooseSection(
            title: title.isNotEmpty ? title : 'Why Choose Us?',
            subtitle: (cj['subtitle'] ?? '').toString(),
            features: list.isNotEmpty ? list : defaultFeatures,
          );
        }
      }
    }
    return AboutWhyChooseSection.fallback();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. Frequently Asked Questions (trust_badges: Frequently Asked Questions)
// ─────────────────────────────────────────────────────────────────────────────
class AboutFaqItem {
  final String question;
  final String answer;

  const AboutFaqItem({
    required this.question,
    required this.answer,
  });
}

class AboutFaqSection {
  final String title;
  final String subtitle;
  final List<AboutFaqItem> items;

  const AboutFaqSection({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  static const List<AboutFaqItem> defaultFaqs = [
    AboutFaqItem(
      question: 'What brands and product ranges do you carry?',
      answer:
          'We carry Apple, Samsung, Sony, LG, Philips and more across smartphones, laptops, tablets, audio, TVs, gaming and home appliances — every unit sourced through authorised channels.',
    ),
    AboutFaqItem(
      question: 'Do you provide custom bundle and configuration options?',
      answer:
          'Yes, we build tailored bundles across selected ranges. You can pair a device with the storage tier, colour, accessory kit, warranty extension and setup options that match how you actually use it.',
    ),
    AboutFaqItem(
      question: 'How long does shipping and delivery take?',
      answer:
          'Standard delivery lands in two to four working days, and orders over \$150 ship free. Large appliances are booked in on a delivery window you choose at checkout.',
    ),
    AboutFaqItem(
      question: 'Are your products energy efficient and responsibly sourced?',
      answer:
          'Every appliance carries its energy rating on the product page, and we run a free take-back scheme so your old device is recycled rather than binned.',
    ),
    AboutFaqItem(
      question: 'Will my device need setup after delivery?',
      answer:
          'Most devices arrive ready to switch on. For TVs, smart home kit and large appliances you can add installation at checkout, and our specialists will walk you through pairing and transfer.',
    ),
    AboutFaqItem(
      question: 'What is your return and exchange policy?',
      answer:
          'Return anything unopened within 30 days for a full refund, or exchange it for a different model. Faulty hardware is covered by our two-year direct warranty.',
    ),
  ];

  factory AboutFaqSection.fallback() {
    return const AboutFaqSection(
      title: 'Frequently Asked Questions',
      subtitle:
          'Find answers about our product range, configuration options, delivery process, warranty cover, setup support, and more.',
      items: defaultFaqs,
    );
  }

  factory AboutFaqSection.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'trust_badges') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final title = (cj['title'] ?? '').toString();

        if (title.toLowerCase().contains('frequently') ||
            title.toLowerCase().contains('faq') ||
            title.toLowerCase().contains('question')) {
          final rawCards = cj['cards'] ?? cj['items'];
          final list = <AboutFaqItem>[];
          if (rawCards is List) {
            for (final c in rawCards) {
              if (c is Map) {
                list.add(AboutFaqItem(
                  question: (c['heading'] ?? '').toString(),
                  answer: (c['text'] ?? '').toString(),
                ));
              }
            }
          }
          return AboutFaqSection(
            title: title.isNotEmpty ? title : 'Frequently Asked Questions',
            subtitle: (cj['subtitle'] ?? '').toString(),
            items: list.isNotEmpty ? list : defaultFaqs,
          );
        }
      }
    }
    return AboutFaqSection.fallback();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 9. Expert Consultation Card (Slider: about-us-bottom-left-slider)
// ─────────────────────────────────────────────────────────────────────────────
class AboutConsultationCard {
  final String heading;
  final String subHeading;
  final String hours;
  final String email;
  final String phone;
  final String buttonText;
  final String image;
  final String trustedClientsText;

  const AboutConsultationCard({
    required this.heading,
    required this.subHeading,
    required this.hours,
    required this.email,
    required this.phone,
    required this.buttonText,
    required this.image,
    required this.trustedClientsText,
  });

  factory AboutConsultationCard.fallback() {
    return const AboutConsultationCard(
      heading: 'Need Expert Assistance?',
      subHeading:
          'Our product specialists are here to help you choose the right setup for your space.',
      hours: 'Available Monday–Saturday, 9AM–6PM EST',
      email: 'consultation@foduustore.com',
      phone: '+1 202-555-0146',
      buttonText: 'Schedule Consultation',
      image: '2026/11/17/appliance-lineup-f27d481f.webp',
      trustedClientsText: 'Trusted by 2,000+ discerning clients worldwide',
    );
  }

  factory AboutConsultationCard.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'slider') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final slider = cj['slider'] is Map
            ? Map<String, dynamic>.from(cj['slider'])
            : <String, dynamic>{};
        final slug =
            (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();

        if (slug.contains('bottom-left') ||
            slug.contains('assistance') ||
            slug.contains('consultation')) {
          final content = slider['content'];
          if (content is List && content.isNotEmpty && content.first is Map) {
            final first = content.first as Map;
            final heading = first['heading']?.toString().trim() ?? '';
            final sub = first['sub_heading']?.toString().trim() ?? '';
            final desc = first['description']?.toString() ?? '';
            final btn = first['button_text']?.toString() ?? '';
            final img = (first['filePath'] ?? '').toString();

            // Extract email & phone from HTML description if present
            String email = 'consultation@foduustore.com';
            final emailMatch =
                RegExp(r'mailto:([^\s">]+)').firstMatch(desc);
            if (emailMatch != null) {
              final val = emailMatch.group(1);
              if (val != null && val.isNotEmpty) email = val;
            }

            String phone = '+1 202-555-0146';
            final phoneMatch = RegExp(r'tel:([^\s">]+)').firstMatch(desc);
            if (phoneMatch != null) {
              final val = phoneMatch.group(1);
              if (val != null && val.isNotEmpty) phone = val;
            }

            String hours = 'Available Monday–Saturday, 9AM–6PM EST';
            final hoursMatch =
                RegExp(r'>([^<]*Monday[^<]*)<').firstMatch(desc);
            if (hoursMatch != null) {
              final val = hoursMatch.group(1);
              if (val != null && val.isNotEmpty) hours = val;
            }

            return AboutConsultationCard(
              heading:
                  heading.isNotEmpty ? heading : 'Need Expert Assistance?',
              subHeading: sub.isNotEmpty
                  ? sub
                  : 'Our product specialists are here to help you choose the right setup for your space.',
              hours: hours,
              email: email,
              phone: phone,
              buttonText: btn.isNotEmpty ? btn : 'Schedule Consultation',
              image: img.isNotEmpty
                  ? img
                  : '2026/11/17/appliance-lineup-f27d481f.webp',
              trustedClientsText:
                  'Trusted by 2,000+ discerning clients worldwide',
            );
          }
        }
      }
    }
    return AboutConsultationCard.fallback();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 10. Bottom CTA Banner (Slider: about-us-fourth-bottom-COA)
// ─────────────────────────────────────────────────────────────────────────────
class AboutBottomCta {
  final String subHeading;
  final String description;
  final String primaryButtonText;
  final String secondaryButtonText;
  final String image;
  final List<String> tags;

  const AboutBottomCta({
    required this.subHeading,
    required this.description,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    required this.image,
    required this.tags,
  });

  factory AboutBottomCta.fallback() {
    return const AboutBottomCta(
      subHeading: 'Ready to redefine your acoustics?',
      description:
          'Explore our current roster of precision-engineered headphones, reference monitors, and architectural home systems.',
      primaryButtonText: 'Browse New Arrivals',
      secondaryButtonText: 'Contact Acoustic Advisor',
      image: '2026/11/17/gadgets-cta-6b257f41.webp',
      tags: ['Obsessive Acousticians', 'Join The Experience'],
    );
  }

  factory AboutBottomCta.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'slider') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final slider = cj['slider'] is Map
            ? Map<String, dynamic>.from(cj['slider'])
            : <String, dynamic>{};
        final slug =
            (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();

        if (slug.contains('coa') ||
            slug.contains('cta') ||
            slug.contains('fourth-bottom')) {
          final content = slider['content'];
          if (content is List && content.isNotEmpty && content.first is Map) {
            final first = content.first as Map;
            final sub = first['sub_heading']?.toString().trim() ?? '';
            final desc = first['description']?.toString().trim() ?? '';
            final img = (first['filePath'] ?? '').toString();

            return AboutBottomCta(
              subHeading: sub.isNotEmpty
                  ? sub
                  : 'Ready to redefine your acoustics?',
              description: desc.isNotEmpty
                  ? desc
                  : 'Explore our current roster of precision-engineered headphones, reference monitors, and architectural home systems.',
              primaryButtonText: 'Browse New Arrivals',
              secondaryButtonText: 'Contact Acoustic Advisor',
              image: img.isNotEmpty
                  ? img
                  : '2026/11/17/gadgets-cta-6b257f41.webp',
              tags: const ['Obsessive Acousticians', 'Join The Experience'],
            );
          }
        }
      }
    }
    return AboutBottomCta.fallback();
  }
}
