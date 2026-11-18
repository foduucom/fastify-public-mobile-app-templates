/// Helper to safely trim and stringify dynamic values.
String _str(dynamic v) => (v ?? '').toString().trim();

// ─────────────────────────────────────────────────────────────────────────────
// 1. FAQ Hero Header (Top Slider: slug "faq")
// ─────────────────────────────────────────────────────────────────────────────
class FaqHeroData {
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;

  const FaqHeroData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
  });

  static const String defaultTitle = 'FAQ';
  static const String defaultSubtitle = 'How can we help you today?';
  static const String defaultDescription =
      'Search our comprehensive knowledge base or select a category below to quickly resolve queries about setup, billing, and integrations.';
  static const String defaultImage =
      '2026/11/17/appliance-lineup-f27d481f.webp';

  factory FaqHeroData.fallback() {
    return const FaqHeroData(
      title: defaultTitle,
      subtitle: defaultSubtitle,
      description: defaultDescription,
      imagePath: defaultImage,
    );
  }

  factory FaqHeroData.fromMap(Map<String, dynamic>? json) {
    if (json == null) return FaqHeroData.fallback();
    final slider = json['slider'] is Map ? json['slider'] as Map : json;
    final content = slider['content'];
    if (content is List && content.isNotEmpty && content.first is Map) {
      final first = content.first as Map;
      return FaqHeroData(
        title: _str(first['heading']).isNotEmpty
            ? _str(first['heading'])
            : defaultTitle,
        subtitle: _str(first['sub_heading']).isNotEmpty
            ? _str(first['sub_heading'])
            : defaultSubtitle,
        description: _str(first['description']).isNotEmpty
            ? _str(first['description'])
            : defaultDescription,
        imagePath: _str(first['filePath'] ??
                    first['download_url'] ??
                    first['filepath'] ??
                    first['url'])
                .isNotEmpty
            ? _str(first['filePath'] ??
                first['download_url'] ??
                first['filepath'] ??
                first['url'])
            : defaultImage,
      );
    }
    return FaqHeroData.fallback();
  }

  factory FaqHeroData.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'slider' || s['id'] == 'slider') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final slider = cj['slider'] is Map ? cj['slider'] as Map : cj;
        final slug = _str(slider['slug'] ?? slider['name']).toLowerCase();
        if (slug == 'faq' ||
            slug.contains('faq-hero') ||
            slug.contains('faq-header')) {
          return FaqHeroData.fromMap(cj);
        }
      }
    }
    return FaqHeroData.fallback();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. FAQ Search (type: search, name: "faq-search")
// ─────────────────────────────────────────────────────────────────────────────
class FaqSearchData {
  final String name;
  final String placeholder;

  const FaqSearchData({
    required this.name,
    required this.placeholder,
  });

  static const String defaultPlaceholder = 'How do I change my billing cycle?';

  factory FaqSearchData.fallback() {
    return const FaqSearchData(
      name: 'faq-search',
      placeholder: defaultPlaceholder,
    );
  }

  factory FaqSearchData.fromMap(Map<String, dynamic>? json) {
    if (json == null) return FaqSearchData.fallback();
    return FaqSearchData(
      name: _str(json['name']).isNotEmpty ? _str(json['name']) : 'faq-search',
      placeholder: _str(json['placeholder']).isNotEmpty
          ? _str(json['placeholder'])
          : defaultPlaceholder,
    );
  }

  factory FaqSearchData.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'search' || s['id'] == 'search') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final name = _str(cj['name']).toLowerCase();
        if (name == 'faq-search' || name.contains('faq')) {
          return FaqSearchData.fromMap(cj);
        }
      }
    }
    return FaqSearchData.fallback();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. FAQ Topic Badges / Category Overview Cards (type: trust_badges, columns: 3)
// ─────────────────────────────────────────────────────────────────────────────
class FaqTopicBadge {
  final String image;
  final String heading;
  final String articleCount;

  const FaqTopicBadge({
    required this.image,
    required this.heading,
    required this.articleCount,
  });

  factory FaqTopicBadge.fromMap(Map<String, dynamic> map) {
    return FaqTopicBadge(
      image: _str(map['image'] ?? map['icon']),
      heading: _str(map['heading'] ?? map['title']),
      articleCount: _str(map['text'] ?? map['description']),
    );
  }
}

class FaqTopicBadgesSection {
  final int noOfColumns;
  final List<FaqTopicBadge> badges;

  const FaqTopicBadgesSection({
    required this.noOfColumns,
    required this.badges,
  });

  static const List<FaqTopicBadge> defaultBadges = [
    FaqTopicBadge(
      image: '2026/11/17/scan-eye-b10a477e.svg',
      heading: 'Account & Access',
      articleCount: '14 articles',
    ),
    FaqTopicBadge(
      image: '2026/11/17/faq-billing-46d9e471.svg',
      heading: 'Billing & Plans',
      articleCount: '8 articles',
    ),
    FaqTopicBadge(
      image: '2026/11/17/globe-lock-65e15bdf.svg',
      heading: 'Platform Security',
      articleCount: '11 articles',
    ),
    FaqTopicBadge(
      image: '2026/11/17/handshake-6430019d.svg',
      heading: 'Partners & Teams',
      articleCount: '9 articles',
    ),
  ];

  factory FaqTopicBadgesSection.fallback() {
    return const FaqTopicBadgesSection(
      noOfColumns: 3,
      badges: defaultBadges,
    );
  }

  factory FaqTopicBadgesSection.fromMap(Map<String, dynamic>? json) {
    if (json == null) return FaqTopicBadgesSection.fallback();
    final rawCards = json['cards'] ?? json['items'];
    final list = <FaqTopicBadge>[];
    if (rawCards is List) {
      for (final item in rawCards) {
        if (item is Map) {
          list.add(FaqTopicBadge.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }
    return FaqTopicBadgesSection(
      noOfColumns: int.tryParse(_str(json['no_of_columns'])) ?? 3,
      badges: list.isNotEmpty ? list : defaultBadges,
    );
  }

  factory FaqTopicBadgesSection.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'trust_badges') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final cols = int.tryParse(_str(cj['no_of_columns'])) ?? 0;
        final rawCards = cj['cards'] is List ? cj['cards'] as List : [];
        final hasArticleText = rawCards.any((c) =>
            c is Map && _str(c['text']).toLowerCase().contains('article'));

        if (cols >= 2 || hasArticleText) {
          return FaqTopicBadgesSection.fromMap(cj);
        }
      }
    }
    return FaqTopicBadgesSection.fallback();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. FAQ Accordion Q&A Items (type: trust_badges, columns: 1)
// ─────────────────────────────────────────────────────────────────────────────
class FaqItem {
  final String question;
  final String answer;

  const FaqItem({
    required this.question,
    required this.answer,
  });

  factory FaqItem.fromMap(Map<String, dynamic> map) {
    return FaqItem(
      question: _str(map['heading'] ?? map['title'] ?? map['question']),
      answer: _str(map['text'] ?? map['description'] ?? map['answer']),
    );
  }
}

class FaqAccordionSectionData {
  final String eyebrow;
  final String title;
  final String subtitle;
  final List<FaqItem> items;

  const FaqAccordionSectionData({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  static const List<FaqItem> defaultFaqs = [
    FaqItem(
      question: 'How do I create an Foduu Store account?',
      answer:
          'Choose Create Account at checkout or from the profile menu, confirm your email, and your order history, saved addresses and wishlist start syncing straight away.',
    ),
    FaqItem(
      question: 'Can I change the email address on my account?',
      answer:
          'Yes. Open Profile, then Account details, enter the new address and confirm it from the verification link we send. Your order history, saved cards and wishlist move across untouched.\n\nIf you no longer have access to the old inbox, our support team can verify you against a recent order and make the change for you.',
    ),
    FaqItem(
      question: 'How do I reset a forgotten password?',
      answer:
          'Choose Forgotten password on the sign-in screen and we will email you a reset link that stays valid for one hour. For security the link can only be used once.',
    ),
    FaqItem(
      question: 'What do I get with a membership account?',
      answer:
          'Members get order tracking, extended returns, early access to sale events, and a saved warranty record for every device bought through us.',
    ),
    FaqItem(
      question: 'Can I merge two accounts I created by mistake?',
      answer:
          'Send us the addresses on both accounts and we will move orders, warranties and wishlist items onto the one you want to keep, then close the other.',
    ),
    FaqItem(
      question: 'How do I close my account and remove my data?',
      answer:
          'Request closure from Profile, then Privacy. We keep purchase records for the length of each warranty, as the law requires, and remove everything else within 30 days.',
    ),
  ];

  factory FaqAccordionSectionData.fallback() {
    return const FaqAccordionSectionData(
      eyebrow: 'Categories',
      title: 'Account & Access',
      subtitle: 'General Membership (6)',
      items: defaultFaqs,
    );
  }

  factory FaqAccordionSectionData.fromMap(Map<String, dynamic>? json) {
    if (json == null) return FaqAccordionSectionData.fallback();
    final rawCards = json['cards'] ?? json['items'];
    final list = <FaqItem>[];
    if (rawCards is List) {
      for (final item in rawCards) {
        if (item is Map) {
          list.add(FaqItem.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }
    return FaqAccordionSectionData(
      eyebrow: _str(json['eyebrow']).isNotEmpty
          ? _str(json['eyebrow'])
          : 'Categories',
      title: _str(json['title']).isNotEmpty
          ? _str(json['title'])
          : 'Account & Access',
      subtitle: _str(json['subtitle']).isNotEmpty
          ? _str(json['subtitle'])
          : 'General Membership (${list.isNotEmpty ? list.length : defaultFaqs.length})',
      items: list.isNotEmpty ? list : defaultFaqs,
    );
  }

  factory FaqAccordionSectionData.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'trust_badges') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final cols = int.tryParse(_str(cj['no_of_columns'])) ?? 0;
        final eyebrow = _str(cj['eyebrow']).toLowerCase();
        final title = _str(cj['title']).toLowerCase();

        if (cols == 1 ||
            eyebrow.contains('categor') ||
            title.contains('account') ||
            title.contains('faq')) {
          return FaqAccordionSectionData.fromMap(cj);
        }
      }
    }
    return FaqAccordionSectionData.fallback();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. FAQ Still Stuck CTA Support Banner (slider: slug "faq-center-slider")
// ─────────────────────────────────────────────────────────────────────────────
class FaqStillStuckData {
  final String heading;
  final String subtitle;
  final String description;
  final String imagePath;
  final String rawLinks;

  const FaqStillStuckData({
    required this.heading,
    required this.subtitle,
    required this.description,
    required this.imagePath,
    required this.rawLinks,
  });

  static const String defaultHeading = 'Still Stuck?';
  static const String defaultSubtitle = 'Can’t find what you’re looking for?';
  static const String defaultDescription =
      'Our expert agents and developers are standing by around the clock to assist you with deep infrastructure setup or payment resolution.';
  static const String defaultImage = '2026/11/17/cta-gear-9f7e301e.svg';

  factory FaqStillStuckData.fallback() {
    return const FaqStillStuckData(
      heading: defaultHeading,
      subtitle: defaultSubtitle,
      description: defaultDescription,
      imagePath: defaultImage,
      rawLinks: '',
    );
  }

  factory FaqStillStuckData.fromMap(Map<String, dynamic>? json) {
    if (json == null) return FaqStillStuckData.fallback();
    final slider = json['slider'] is Map ? json['slider'] as Map : json;
    final content = slider['content'];
    if (content is List && content.isNotEmpty && content.first is Map) {
      final first = content.first as Map;
      return FaqStillStuckData(
        heading: _str(first['heading']).isNotEmpty
            ? _str(first['heading'])
            : defaultHeading,
        subtitle: _str(first['sub_heading']).isNotEmpty
            ? _str(first['sub_heading'])
            : defaultSubtitle,
        description: _str(first['description']).isNotEmpty
            ? _str(first['description'])
            : defaultDescription,
        imagePath: _str(first['filePath'] ??
                    first['download_url'] ??
                    first['filepath'] ??
                    first['url'])
                .isNotEmpty
            ? _str(first['filePath'] ??
                first['download_url'] ??
                first['filepath'] ??
                first['url'])
            : defaultImage,
        rawLinks: _str(first['link']),
      );
    }
    return FaqStillStuckData.fallback();
  }

  factory FaqStillStuckData.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'slider' || s['id'] == 'slider') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final slider = cj['slider'] is Map ? cj['slider'] as Map : cj;
        final slug = _str(slider['slug'] ?? slider['name']).toLowerCase();
        if (slug == 'faq-center-slider' || slug.contains('stuck')) {
          return FaqStillStuckData.fromMap(cj);
        }
      }
    }
    return FaqStillStuckData.fallback();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Combined FAQ Page Data Model
// ─────────────────────────────────────────────────────────────────────────────
class FaqPageData {
  final FaqHeroData hero;
  final FaqSearchData search;
  final FaqTopicBadgesSection topicBadges;
  final FaqAccordionSectionData accordion;
  final FaqStillStuckData stillStuck;

  const FaqPageData({
    required this.hero,
    required this.search,
    required this.topicBadges,
    required this.accordion,
    required this.stillStuck,
  });

  factory FaqPageData.canonical() {
    return FaqPageData(
      hero: FaqHeroData.fallback(),
      search: FaqSearchData.fallback(),
      topicBadges: FaqTopicBadgesSection.fallback(),
      accordion: FaqAccordionSectionData.fallback(),
      stillStuck: FaqStillStuckData.fallback(),
    );
  }

  factory FaqPageData.fromSections(List sections) {
    return FaqPageData(
      hero: FaqHeroData.fromSections(sections),
      search: FaqSearchData.fromSections(sections),
      topicBadges: FaqTopicBadgesSection.fromSections(sections),
      accordion: FaqAccordionSectionData.fromSections(sections),
      stillStuck: FaqStillStuckData.fromSections(sections),
    );
  }
}
