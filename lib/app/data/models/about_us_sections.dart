import 'package:zouhi/app/data/models/page_model.dart';

String _s(Map<String, dynamic> f, String key, [String fallback = '']) {
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

  factory AboutHeroStory.fromComponent(PageComponent? c) {
    const defaultDesc =
        'Vision Infrastructure is a leading networking and optical cable provider in India. We deliver high-performance fiber optic solutions, structured cabling, server racks, and data center connectivity designed to meet the strict demands of modern enterprise infrastructure.';

    if (c == null) {
      return const AboutHeroStory(
        title: 'About Vision Infrastructure',
        description: defaultDesc,
        bannerImage: '/images/2026/08/29/3-aaed866d.webp',
        ctaText: '',
        ctaLink: '',
      );
    }
    final f = c.fields;
    final rawDesc = _s(f, 'section_description');
    final desc =
        (rawDesc.isEmpty || rawDesc.toLowerCase().startsWith('lorem ipsum'))
            ? defaultDesc
            : rawDesc;

    return AboutHeroStory(
      title: _s(f, 'section_title', 'About Vision Infrastructure'),
      description: desc,
      bannerImage: _s(f, 'banner_image', '/images/2026/08/29/3-aaed866d.webp'),
      ctaText: _s(f, 'cta_text', ''),
      ctaLink: _s(f, 'cta_link', ''),
    );
  }
}

class AboutWhyChooseItem {
  final String title;
  final String description;
  final String iconKey;

  const AboutWhyChooseItem({
    required this.title,
    required this.description,
    required this.iconKey,
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
}

class AboutProcessStep {
  final String stepNumber;
  final String title;
  final String description;

  const AboutProcessStep({
    required this.stepNumber,
    required this.title,
    required this.description,
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

    // Merge website standard steps if CMS only has 1 or incomplete steps
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
        items: defaultItems,
      );
    }
    final f = c.fields;
    return AboutTestimonialsSection(
      eyebrow: _s(f, 'section_subtitle', 'Testimonials'),
      title: _s(f, 'section_title', 'What Our Clients Say'),
      items: defaultItems,
    );
  }
}

class AboutTrustStat {
  final String value;
  final String label;

  const AboutTrustStat({required this.value, required this.label});
}
