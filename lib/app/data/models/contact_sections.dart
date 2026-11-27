import 'package:foduu_ecommerce/constants/constants.dart';

/// Sanitizes relative, internal, or absolute image URLs.
String _cleanUrl(dynamic val) {
  if (val == null) return '';
  String str = val.toString().trim();
  if (str.isEmpty) return '';

  if (str.startsWith('http://') || str.startsWith('https://')) return str;
  if (str.startsWith('//')) return 'https:$str';

  final normalized = str.startsWith('/') ? str.substring(1) : str;
  if (normalized.startsWith('images/')) {
    return '$url$normalized';
  }
  return '$assetURL$normalized';
}

String _s(Map<String, dynamic> m, String key, [String fallback = '']) {
  final v = m[key]?.toString().trim() ?? '';
  return v.isEmpty ? fallback : v;
}

const _defaultHeroImage = '2026/11/24/contact-us-2173b173.webp';
const _defaultCtaImage = '2026/11/17/cta-gear-9f7e301e.svg';

// ─────────────────────────────────────────────────────────────────────────────
// 1. Hero Header Banner (contact-us-slider)
// ─────────────────────────────────────────────────────────────────────────────
class ContactHeroHeaderData {
  final String heading;
  final String subHeading;
  final String description;
  final String imageUrl;
  final double height;

  const ContactHeroHeaderData({
    required this.heading,
    required this.subHeading,
    required this.description,
    required this.imageUrl,
    this.height = 185,
  });

  factory ContactHeroHeaderData.fromContentJson(Map<String, dynamic> json) {
    String heading = 'Contact Us';
    String subHeading = '';
    String description = '';
    String img = _defaultHeroImage;
    double h = 185.0;

    if (json['height'] != null) {
      final parsedH = double.tryParse(json['height'].toString());
      if (parsedH != null && parsedH > 50) h = parsedH;
    }

    final slider = json['slider'];
    if (slider is Map) {
      final content = slider['content'];
      if (content is List && content.isNotEmpty && content.first is Map) {
        final first = Map<String, dynamic>.from(content.first as Map);
        heading = _s(first, 'heading', heading);
        subHeading = (first['sub_heading'] ?? '').toString().trim();
        description = (first['description'] ?? '').toString().trim();
        final rawImg = first['download_url'] ??
            first['filePath'] ??
            first['filepath'] ??
            first['image'];
        if (rawImg != null && rawImg.toString().trim().isNotEmpty) {
          img = rawImg.toString().trim();
        }
      }
    }

    return ContactHeroHeaderData(
      heading: heading,
      subHeading: subHeading,
      description: description,
      imageUrl: _cleanUrl(img),
      height: h,
    );
  }

  factory ContactHeroHeaderData.canonical() => ContactHeroHeaderData(
        heading: 'Contact Us',
        subHeading: 'Get in touch',
        description:
            'We are here for you! how can we help, We are here for you!',
        imageUrl: _cleanUrl(_defaultHeroImage),
        height: 185,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Form Builder Meta Section (formbuilder)
// ─────────────────────────────────────────────────────────────────────────────
class ContactFormBuilderData {
  final String badgeText;
  final String badgeSubtitle;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String formSlug;
  final String formId;

  const ContactFormBuilderData({
    this.badgeText = 'Get in touch',
    this.badgeSubtitle =
        'We are here for you! how can we help, We are here for you!',
    this.eyebrow = "Let's Connect",
    required this.title,
    this.subtitle =
        'Have questions or feedback? Fill out the form below and our team will get back to you shortly.',
    required this.formSlug,
    required this.formId,
  });

  factory ContactFormBuilderData.fromContentJson(Map<String, dynamic> json) {
    final badgeText = _s(json, 'badge', _s(json, 'badge_text', 'Get in touch'));
    final badgeSubtitle = _s(json, 'badge_subtitle',
        'We are here for you! how can we help, We are here for you!');
    final eyebrow = _s(json, 'eyebrow', "Let's Connect");
    final title = _s(json, 'title', 'Send Your Message');
    final subtitle = _s(
      json,
      'subtitle',
      'Have questions or feedback? Fill out the form below and our team will get back to you shortly.',
    );
    String slug = 'contact';
    String id = '6afc23c408a059f9a214f5d5';

    final fId = json['form_id'];
    if (fId is Map) {
      slug = fId['slug']?.toString().trim() ?? slug;
      id = fId['value']?.toString().trim() ?? id;
    } else if (fId != null) {
      id = fId.toString();
    }

    return ContactFormBuilderData(
      badgeText: badgeText,
      badgeSubtitle: badgeSubtitle,
      eyebrow: eyebrow,
      title: title,
      subtitle: subtitle,
      formSlug: slug,
      formId: id,
    );
  }

  factory ContactFormBuilderData.canonical() => const ContactFormBuilderData(
        badgeText: 'Get in touch',
        badgeSubtitle:
            'We are here for you! how can we help, We are here for you!',
        eyebrow: "Let's Connect",
        title: 'Send Your Message',
        subtitle:
            'Have questions or feedback? Fill out the form below and our team will get back to you shortly.',
        formSlug: 'contact',
        formId: '6afc23c408a059f9a214f5d5',
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Location Map Card Section (contact_map)
// ─────────────────────────────────────────────────────────────────────────────
// class ContactLocationMapData {
//   final String city;
//   final String addressLabel;
//   final String mapsUrl;

//   const ContactLocationMapData({
//     required this.city,
//     required this.addressLabel,
//     required this.mapsUrl,
//   });

//   factory ContactLocationMapData.fromContentJson(Map<String, dynamic> json) {
//     final city = _s(json, 'city', _s(json, 'title', 'New York'));
//     final addressLabel =
//         _s(json, 'address', _s(json, 'subtitle', 'New York, NY, USA'));
//     final mapsUrl = _s(
//       json,
//       'maps_url',
//       'https://maps.google.com/maps?q=${Uri.encodeComponent(addressLabel)}',
//     );
//     return ContactLocationMapData(
//       city: city,
//       addressLabel: addressLabel,
//       mapsUrl: mapsUrl,
//     );
//   }

//   factory ContactLocationMapData.canonical() => const ContactLocationMapData(
//         city: 'New York',
//         addressLabel: 'New York, NY, USA',
//         mapsUrl: 'https://maps.google.com/maps?q=New%20York%2C%20NY%2C%20USA',
//       );
// }

// ─────────────────────────────────────────────────────────────────────────────
// 4. Contact Channels Section (trust_badges: Contact Channels / Info Cards)
// ─────────────────────────────────────────────────────────────────────────────
class ContactChannelCard {
  final String image;
  final String heading;
  final String text;
  final String footer;

  const ContactChannelCard({
    required this.image,
    required this.heading,
    required this.text,
    required this.footer,
  });

  String get fullImageUrl => _cleanUrl(image);

  bool get isWebsite =>
      heading.toLowerCase().contains('website') ||
      text.toLowerCase().startsWith('www.') ||
      text.toLowerCase().startsWith('http://') ||
      text.toLowerCase().startsWith('https://');

  bool get isAddress =>
      heading.toLowerCase().contains('address') ||
      heading.toLowerCase().contains('headquarter') ||
      heading.toLowerCase().contains('location');

  bool get isEmail =>
      heading.toLowerCase().contains('email') ||
      heading.toLowerCase().contains('mail') ||
      text.contains('@') ||
      image.toLowerCase().contains('mail');

  bool get isPhone =>
      heading.toLowerCase().contains('call') ||
      heading.toLowerCase().contains('phone') ||
      heading.toLowerCase().contains('telephone') ||
      image.toLowerCase().contains('phone') ||
      (!isAddress && text.replaceAll(RegExp(r'[^0-9]'), '').length >= 7);

  String get cleanPhone => text.replaceAll(RegExp(r'[^0-9+]'), '');

  String get normalizedWebsiteUrl {
    final trimmed = text.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  factory ContactChannelCard.fromMap(Map<String, dynamic> m) {
    return ContactChannelCard(
      image: m['image']?.toString().trim() ?? '',
      heading: m['heading']?.toString().trim() ?? '',
      text: m['text']?.toString().trim() ?? '',
      footer: m['footer']?.toString().trim() ?? '',
    );
  }
}

// class ContactChannelsData {
//   final String eyebrow;
//   final String title;
//   final String subtitle;
//   final int noOfColumns;
//   final List<ContactChannelCard> cards;

//   const ContactChannelsData({
//     required this.eyebrow,
//     required this.title,
//     required this.subtitle,
//     required this.noOfColumns,
//     required this.cards,
//   });

//   static const List<ContactChannelCard> defaultCards = [
//     ContactChannelCard(
//       image: '',
//       heading: 'Website',
//       text: 'www.example.com',
//       footer: '',
//     ),
//     ContactChannelCard(
//       image: '',
//       heading: 'Address',
//       text: '123 Street, New York, USA',
//       footer: '',
//     ),
//     ContactChannelCard(
//       image: '',
//       heading: 'Mail Us',
//       text: 'info@foduu.com',
//       footer: '',
//     ),
//     ContactChannelCard(
//       image: '',
//       heading: 'Telephone',
//       text: '+012 3456 7890',
//       footer: '',
//     ),
//   ];

//   factory ContactChannelsData.fromContentJson(Map<String, dynamic> json) {
//     final rawCards = json['cards'] ?? json['items'];
//     final list = <ContactChannelCard>[];
//     if (rawCards is List) {
//       for (final c in rawCards) {
//         if (c is Map) {
//           list.add(ContactChannelCard.fromMap(Map<String, dynamic>.from(c)));
//         }
//       }
//     }

//     return ContactChannelsData(
//       eyebrow: _s(json, 'eyebrow'),
//       title: _s(json, 'title', 'Contact Information'),
//       subtitle: _s(json, 'subtitle'),
//       noOfColumns: int.tryParse(json['no_of_columns']?.toString() ?? '2') ?? 2,
//       cards: list.isNotEmpty ? list : defaultCards,
//     );
//   }

//   factory ContactChannelsData.canonical() => const ContactChannelsData(
//         eyebrow: '',
//         title: 'Contact Information',
//         subtitle: '',
//         noOfColumns: 2,
//         cards: defaultCards,
//       );
// }

// ─────────────────────────────────────────────────────────────────────────────
// 4. Frequently Asked Questions Section (trust_badges: Account & Access)
// ─────────────────────────────────────────────────────────────────────────────
class ContactFaqItem {
  final String question;
  final String answer;

  const ContactFaqItem({
    required this.question,
    required this.answer,
  });
}

class ContactFaqSectionData {
  final String eyebrow;
  final String title;
  final String subtitle;
  final List<ContactFaqItem> items;

  const ContactFaqSectionData({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  static const List<ContactFaqItem> defaultFaqs = [
    ContactFaqItem(
      question: 'How do I create an Foduu Store account?',
      answer:
          'Choose Create Account at checkout or from the profile menu, confirm your email, and your order history, saved addresses and wishlist start syncing straight away.',
    ),
    ContactFaqItem(
      question: 'Can I change the email address on my account?',
      answer:
          'Yes. Open Profile, then Account details, enter the new address and confirm it from the verification link we send. Your order history, saved cards and wishlist move across untouched.\n\nIf you no longer have access to the old inbox, our support team can verify you against a recent order and make the change for you.',
    ),
    ContactFaqItem(
      question: 'How do I reset a forgotten password?',
      answer:
          'Choose Forgotten password on the sign-in screen and we will email you a reset link that stays valid for one hour. For security the link can only be used once.',
    ),
    ContactFaqItem(
      question: 'What do I get with a membership account?',
      answer:
          'Members get order tracking, extended returns, early access to sale events, and a saved warranty record for every device bought through us.',
    ),
    ContactFaqItem(
      question: 'Can I merge two accounts I created by mistake?',
      answer:
          'Send us the addresses on both accounts and we will move orders, warranties and wishlist items onto the one you want to keep, then close the other.',
    ),
    ContactFaqItem(
      question: 'How do I close my account and remove my data?',
      answer:
          'Request closure from Profile, then Privacy. We keep purchase records for the length of each warranty, as the law requires, and remove everything else within 30 days.',
    ),
  ];

  factory ContactFaqSectionData.fromContentJson(Map<String, dynamic> json) {
    final rawCards = json['cards'] ?? json['items'];
    final list = <ContactFaqItem>[];
    if (rawCards is List) {
      for (final c in rawCards) {
        if (c is Map) {
          final q = (c['heading'] ?? c['title'] ?? '').toString().trim();
          final a = (c['text'] ?? c['description'] ?? '').toString().trim();
          if (q.isNotEmpty) {
            list.add(ContactFaqItem(question: q, answer: a));
          }
        }
      }
    }

    return ContactFaqSectionData(
      eyebrow: _s(json, 'eyebrow', 'Categories'),
      title: _s(json, 'title', 'Account & Access'),
      subtitle: _s(json, 'subtitle', 'General Membership (6)'),
      items: list.isNotEmpty ? list : defaultFaqs,
    );
  }

  factory ContactFaqSectionData.canonical() => const ContactFaqSectionData(
        eyebrow: 'Categories',
        title: 'Account & Access',
        subtitle: 'General Membership (6)',
        items: defaultFaqs,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Still Stuck? Support CTA Banner (slider: faq-center-slider)
// ─────────────────────────────────────────────────────────────────────────────
class ContactFaqCtaData {
  final String heading;
  final String subHeading;
  final String description;
  final String imageUrl;

  const ContactFaqCtaData({
    required this.heading,
    required this.subHeading,
    required this.description,
    required this.imageUrl,
  });

  factory ContactFaqCtaData.fromContentJson(Map<String, dynamic> json) {
    String heading = 'Still Stuck?';
    String subHeading = 'Can’t find what you’re looking for?';
    String description =
        'Our expert agents and developers are standing by around the clock to assist you with deep infrastructure setup or payment resolution.';
    String img = _defaultCtaImage;

    final slider = json['slider'];
    if (slider is Map) {
      final content = slider['content'];
      if (content is List && content.isNotEmpty && content.first is Map) {
        final first = Map<String, dynamic>.from(content.first as Map);
        heading = _s(first, 'heading', heading);
        subHeading = _s(first, 'sub_heading', subHeading);
        description = _s(first, 'description', description);
        final rawImg = first['download_url'] ??
            first['filePath'] ??
            first['filepath'] ??
            first['image'];
        if (rawImg != null && rawImg.toString().trim().isNotEmpty) {
          img = rawImg.toString().trim();
        }
      }
    }

    return ContactFaqCtaData(
      heading: heading,
      subHeading: subHeading,
      description: description,
      imageUrl: _cleanUrl(img),
    );
  }

  factory ContactFaqCtaData.canonical() => const ContactFaqCtaData(
        heading: 'Still Stuck?',
        subHeading: 'Can’t find what you’re looking for?',
        description:
            'Our expert agents and developers are standing by around the clock to assist you with deep infrastructure setup or payment resolution.',
        imageUrl: _defaultCtaImage,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Overall Container: ContactBroadcastSectionsData
// ─────────────────────────────────────────────────────────────────────────────
class ContactBroadcastSectionsData {
  final ContactHeroHeaderData heroHeader;
  final ContactFormBuilderData formBuilder;
  //final ContactChannelsData channels;
  final ContactFaqSectionData faq;
  final ContactFaqCtaData faqCta;

  const ContactBroadcastSectionsData({
    required this.heroHeader,
    required this.formBuilder,
    // required this.channels,
    required this.faq,
    required this.faqCta,
  });

  factory ContactBroadcastSectionsData.fromSections(List sections) {
    ContactHeroHeaderData? hero;
    ContactFormBuilderData? form;
    //ContactChannelsData? channels;
    ContactFaqSectionData? faq;
    ContactFaqCtaData? cta;

    for (final sec in sections) {
      if (sec is! Map) continue;
      final type = sec['type']?.toString().toLowerCase() ?? '';
      final visible = sec['visible'] != false;
      if (!visible) continue;

      final content = sec['content_json'];
      final contentMap = content is Map<String, dynamic>
          ? content
          : (content is Map
              ? Map<String, dynamic>.from(content)
              : <String, dynamic>{});

      switch (type) {
        case 'slider':
          final slider =
              contentMap['slider'] is Map ? contentMap['slider'] : {};
          final slug =
              (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();
          if (slug.contains('faq') || slug.contains('stuck')) {
            cta = ContactFaqCtaData.fromContentJson(contentMap);
          } else {
            hero = ContactHeroHeaderData.fromContentJson(contentMap);
          }
          break;

        case 'formbuilder':
        case 'form_builder':
          form = ContactFormBuilderData.fromContentJson(contentMap);
          break;

        case 'trust_badges':
          final title = (contentMap['title'] ?? '').toString().toLowerCase();
          final eyebrow =
              (contentMap['eyebrow'] ?? '').toString().toLowerCase();
          final noOfCols =
              int.tryParse(contentMap['no_of_columns']?.toString() ?? '2') ?? 2;

          if (title.contains('account') ||
              title.contains('access') ||
              title.contains('faq') ||
              title.contains('question') ||
              eyebrow.contains('categories') ||
              noOfCols == 1) {
            faq = ContactFaqSectionData.fromContentJson(contentMap);
          } else {
            //channels = ContactChannelsData.fromContentJson(contentMap);
          }
          break;
      }
    }

    return ContactBroadcastSectionsData(
      heroHeader: hero ?? ContactHeroHeaderData.canonical(),
      formBuilder: form ?? ContactFormBuilderData.canonical(),
      //channels: channels ?? ContactChannelsData.canonical(),
      faq: faq ?? ContactFaqSectionData.canonical(),
      faqCta: cta ?? ContactFaqCtaData.canonical(),
    );
  }

  factory ContactBroadcastSectionsData.canonical() =>
      ContactBroadcastSectionsData(
        heroHeader: ContactHeroHeaderData.canonical(),
        formBuilder: ContactFormBuilderData.canonical(),
        //channels: ContactChannelsData.canonical(),
        faq: ContactFaqSectionData.canonical(),
        faqCta: ContactFaqCtaData.canonical(),
      );
}
