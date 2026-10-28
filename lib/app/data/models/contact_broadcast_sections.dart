import 'package:zouhi/app/data/models/page_model.dart';
import 'package:zouhi/constants/constants.dart';

/// Sanitizes relative, internal, or absolute image URLs.
/// Automatically rewrites internal store-ID subdomains (e.g. 6a92a527...foduu.store)
/// to the public store domain (vision.foduu.store), permanently preventing 404 image errors.
String _cleanUrl(dynamic val) {
  if (val == null) return '';
  String str = val.toString().trim();
  if (str.isEmpty) return '';

  // Rewrite internal hexadecimal website ID subdomains to the public store domain
  str = str.replaceAll(
    RegExp(r'https?://[a-f0-9]{24}\.foduu\.store', caseSensitive: false),
    'https://vision.foduu.store',
  );

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

/// Verified parent website optical fiber enterprise hero banner
const _parentWebHeroBanner = '2026/08/29/slide-2-73b3aa6d.webp';

/// Verified parent website contact illustration banner
const _parentWebIllustrationBanner = '2026/08/29/3-aaed866d.webp';

/// Section 1: Hero Slider / Header Banner
class ContactHeroSliderData {
  final String heading;
  final String description;
  final String imageUrl;
  final double height;

  const ContactHeroSliderData({
    required this.heading,
    required this.description,
    required this.imageUrl,
    this.height = 200,
  });

  factory ContactHeroSliderData.fromContentJson(Map<String, dynamic> json) {
    String heading = 'Contact Us';
    String description = '';
    String img = _parentWebHeroBanner;
    double h = 200.0;

    if (json['height'] != null) {
      final parsedH = double.tryParse(json['height'].toString());
      if (parsedH != null && parsedH > 50) h = parsedH;
    }

    final slider = json['slider'];
    if (slider is Map<String, dynamic>) {
      final content = slider['content'];
      if (content is List && content.isNotEmpty) {
        final first = content.first;
        if (first is Map<String, dynamic>) {
          heading = _s(first, 'heading', heading);
          description = _s(first, 'description', description);
          final rawImg = first['download_url'] ??
              first['filePath'] ??
              first['filepath'] ??
              first['image'];
          if (rawImg != null && rawImg.toString().trim().isNotEmpty) {
            final rawStr = rawImg.toString().trim();
            // If API delivers the domestic appliance test graphic, override with parent site enterprise optical banner
            if (rawStr.contains('contact-us-banner-c99b0d5f.webp')) {
              img = _parentWebHeroBanner;
            } else {
              img = rawStr;
            }
          }
        }
      }
    }

    return ContactHeroSliderData(
      heading: heading,
      description: description,
      imageUrl: _cleanUrl(img),
      height: h,
    );
  }

  factory ContactHeroSliderData.canonical() => ContactHeroSliderData(
        heading: 'Contact Us',
        description: '',
        imageUrl: _cleanUrl(_parentWebHeroBanner),
        height: 200,
      );
}

/// Single Contact Card (E-mail, Phone, etc.)
class ContactInfoCard {
  final String image;
  final String heading;
  final String text;
  final String footer;

  const ContactInfoCard({
    required this.image,
    required this.heading,
    required this.text,
    this.footer = '',
  });

  String get fullImageUrl => _cleanUrl(image);

  bool get isEmail =>
      heading.toLowerCase().contains('email') ||
      text.contains('@') ||
      image.toLowerCase().contains('mail');

  bool get isPhone =>
      heading.toLowerCase().contains('phone') ||
      heading.toLowerCase().contains('mobile') ||
      heading.toLowerCase().contains('call') ||
      text.contains('+') ||
      RegExp(r'^\+?[0-9\s\-()]{7,20}$').hasMatch(text.trim());

  String get cleanPhone => text.replaceAll(RegExp(r'[^\d+]'), '');

  factory ContactInfoCard.fromJson(Map<String, dynamic> json) {
    return ContactInfoCard(
      image: _s(json, 'image', _s(json, 'icon')),
      heading: _s(json, 'heading', _s(json, 'title')),
      text: _s(json, 'text', _s(json, 'value', _s(json, 'subtitle'))),
      footer: _s(json, 'footer'),
    );
  }
}

/// Section 2: Contact Information Badges / Cards
class ContactInfoBadgesData {
  final String eyebrow;
  final String title;
  final String subtitle;
  final int noOfColumns;
  final List<ContactInfoCard> cards;

  const ContactInfoBadgesData({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.noOfColumns,
    required this.cards,
  });

  factory ContactInfoBadgesData.fromContentJson(Map<String, dynamic> json) {
    final rawCards = json['cards'];
    final cardsList = <ContactInfoCard>[];
    if (rawCards is List) {
      for (final c in rawCards) {
        if (c is Map<String, dynamic>) {
          cardsList.add(ContactInfoCard.fromJson(c));
        } else if (c is Map) {
          cardsList.add(ContactInfoCard.fromJson(Map<String, dynamic>.from(c)));
        }
      }
    }

    final effectiveCards = cardsList.isNotEmpty
        ? cardsList
        : ContactInfoBadgesData.canonical().cards;

    String sub = _s(json, 'subtitle');
    if (sub.isEmpty || sub.toLowerCase().startsWith('lorem ipsum')) {
      sub =
          'Have questions about our fiber optic products or enterprise networking? Our technical team is here to assist.';
    }

    return ContactInfoBadgesData(
      eyebrow: _s(json, 'eyebrow', 'GET IN TOUCH'),
      title: _s(json, 'title', 'Contact Information'),
      subtitle: sub,
      noOfColumns: int.tryParse(json['no_of_columns']?.toString() ?? '2') ?? 2,
      cards: effectiveCards,
    );
  }

  factory ContactInfoBadgesData.canonical() => const ContactInfoBadgesData(
        eyebrow: 'GET IN TOUCH',
        title: 'Contact Information',
        subtitle:
            'Have questions about our fiber optic products or enterprise networking? Our technical team is here to assist.',
        noOfColumns: 2,
        cards: [
          ContactInfoCard(
            image: '2026/10/23/mail-e965f363.webp',
            heading: 'E-mail Address',
            text: 'support@vbought.com',
          ),
          ContactInfoCard(
            image: '2026/10/23/svgviewer-png-output-1-650a0ab8.webp',
            heading: 'Phone Number',
            text: '+91 98765 43210',
          ),
        ],
      );
}

/// Section 3: Mid-page Promotional Banner / Illustration
class ContactPromoBannerData {
  final String imageUrl;
  final double borderRadius;
  final double height;
  final String link;

  const ContactPromoBannerData({
    required this.imageUrl,
    this.borderRadius = 14.0,
    this.height = 180.0,
    this.link = '',
  });

  factory ContactPromoBannerData.fromContentJson(Map<String, dynamic> json) {
    String img = '2026/10/23/contact-us-780dd92c.webp';
    double radius = 14.0;
    double h = 180.0;
    String lnk = '';

    final banners = json['banners'];
    if (banners is List && banners.isNotEmpty) {
      final b = banners.first;
      if (b is Map<String, dynamic>) {
        final cfg = b['config'];
        if (cfg is Map<String, dynamic>) {
          radius =
              double.tryParse(cfg['border_radius']?.toString() ?? '14') ?? 14.0;
          h = double.tryParse(cfg['height']?.toString() ?? '180') ?? 180.0;
        }
        final items = b['items'];
        if (items is List && items.isNotEmpty) {
          final it = items.first;
          if (it is Map<String, dynamic>) {
            final linkObj = it['link'];
            if (linkObj is Map) {
              lnk = linkObj['value']?.toString() ?? '';
            } else if (linkObj != null) {
              lnk = linkObj.toString();
            }
            final feat = it['featured_image'];
            if (feat is Map<String, dynamic>) {
              img = feat['download_url'] ??
                  feat['filepath'] ??
                  feat['filePath'] ??
                  img;
            }
          }
        }
      }
    }

    return ContactPromoBannerData(
      imageUrl: _cleanUrl(img),
      borderRadius: radius,
      height: h,
      link: lnk,
    );
  }

  factory ContactPromoBannerData.canonical() => ContactPromoBannerData(
        imageUrl: _cleanUrl(_parentWebIllustrationBanner),
        borderRadius: 14.0,
        height: 180.0,
        link: 'contact-us',
      );
}

/// Section 4: Form Builder Section Specification
class ContactFormBuilderData {
  final String title;
  final String formSlug;
  final String formId;

  const ContactFormBuilderData({
    required this.title,
    required this.formSlug,
    required this.formId,
  });

  factory ContactFormBuilderData.fromContentJson(Map<String, dynamic> json) {
    String title = _s(json, 'title', 'Send Us a Message');
    String slug = 'contact-form';
    String id = '6a92de7e3c13c2a7e9940189';

    final fId = json['form_id'];
    if (fId is Map<String, dynamic>) {
      slug = _s(fId, 'slug', slug);
      id = _s(fId, 'value', id);
    } else if (fId is Map) {
      slug = fId['slug']?.toString().trim() ?? slug;
      id = fId['value']?.toString().trim() ?? id;
    } else if (fId != null) {
      id = fId.toString();
    }

    return ContactFormBuilderData(
      title: title,
      formSlug: slug,
      formId: id,
    );
  }

  factory ContactFormBuilderData.canonical() => const ContactFormBuilderData(
        title: 'Send Us a Message',
        formSlug: 'contact-form',
        formId: '6a92de7e3c13c2a7e9940189',
      );
}

/// Container for the Contact Us server-driven sections
class ContactBroadcastSectionsData {
  final ContactHeroSliderData heroSlider;
  final ContactInfoBadgesData infoBadges;
  final ContactPromoBannerData? promoBanner;
  final ContactFormBuilderData formBuilder;
  final String officeAddress;

  const ContactBroadcastSectionsData({
    required this.heroSlider,
    required this.infoBadges,
    this.promoBanner,
    required this.formBuilder,
    this.officeAddress =
        'Vision Infrastructure Solutions, 120 E Beaver Creek Rd, Richmond Hill, ON, Canada',
  });

  factory ContactBroadcastSectionsData.fromSections(List sections) {
    ContactHeroSliderData? slider;
    ContactInfoBadgesData? badges;
    ContactPromoBannerData? banner;
    ContactFormBuilderData? form;

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
          slider = ContactHeroSliderData.fromContentJson(contentMap);
          break;
        case 'trust_badges':
          badges = ContactInfoBadgesData.fromContentJson(contentMap);
          break;
        case 'banner':
          banner = ContactPromoBannerData.fromContentJson(contentMap);
          break;
        case 'formbuilder':
        case 'form_builder':
          form = ContactFormBuilderData.fromContentJson(contentMap);
          break;
      }
    }

    return ContactBroadcastSectionsData(
      heroSlider: slider ?? ContactHeroSliderData.canonical(),
      infoBadges: badges ?? ContactInfoBadgesData.canonical(),
      promoBanner: banner ?? ContactPromoBannerData.canonical(),
      formBuilder: form ?? ContactFormBuilderData.canonical(),
      officeAddress:
          'Vision Infrastructure Solutions, 120 E Beaver Creek Rd, Richmond Hill, ON, Canada',
    );
  }

  factory ContactBroadcastSectionsData.fromLegacyComponents(
      List<PageComponent> components) {
    String heading = 'Contact Us';
    String headerImg = _parentWebHeroBanner;
    String infoTitle = 'Contact Information';
    String infoDesc = '';
    final infoCards = <ContactInfoCard>[];
    String formTitle = 'Send Us a Message';
    String formSlug = 'contact-form';
    String addr =
        'Vision Infrastructure Solutions, 120 E Beaver Creek Rd, Richmond Hill, ON, Canada';

    for (final c in components) {
      final f = c.fields;
      if (c.type == 'services_page-header') {
        heading = _s(f, 'h1_services', heading);
        final rawH = _s(f, 'header_image');
        if (rawH.isNotEmpty &&
            !rawH.contains('contact-us-banner-c99b0d5f.webp')) {
          headerImg = rawH;
        }
      } else if (c.type == 'contact-us_contact-information') {
        infoTitle = _s(f, 'section_title', infoTitle);
        infoDesc = _s(f, 'section_description', infoDesc);
        final addressText = _s(f, 'address_text');
        if (addressText.isNotEmpty) addr = addressText;

        final email = _s(f, 'email_address', 'support@vbought.com');
        if (email.isNotEmpty) {
          infoCards.add(ContactInfoCard(
            image: '2026/10/23/mail-e965f363.webp',
            heading: _s(f, 'email_heading', 'E-mail Address'),
            text: email,
          ));
        }
        final phone = _s(f, 'phone_number', '+91 98765 43210');
        if (phone.isNotEmpty) {
          infoCards.add(ContactInfoCard(
            image: '2026/10/23/svgviewer-png-output-1-650a0ab8.webp',
            heading: _s(f, 'phone_heading', 'Phone Number'),
            text: phone,
          ));
        }
      } else if (c.type == 'contact-us_contact-form-section_form_banner') {
        formTitle = _s(f, 'section_title', formTitle);
        formSlug = _s(f, 'form_slug', formSlug);
      }
    }

    return ContactBroadcastSectionsData(
      heroSlider: ContactHeroSliderData(
        heading: heading,
        description: '',
        imageUrl: _cleanUrl(headerImg),
      ),
      infoBadges: ContactInfoBadgesData(
        eyebrow: 'GET IN TOUCH',
        title: infoTitle,
        subtitle: infoDesc.isNotEmpty
            ? infoDesc
            : 'Have questions about our fiber optic products or enterprise networking? Our technical team is here to assist.',
        noOfColumns: 2,
        cards: infoCards.isNotEmpty
            ? infoCards
            : ContactInfoBadgesData.canonical().cards,
      ),
      promoBanner: ContactPromoBannerData.canonical(),
      formBuilder: ContactFormBuilderData(
        title: formTitle,
        formSlug: formSlug,
        formId: '6a92de7e3c13c2a7e9940189',
      ),
      officeAddress: addr,
    );
  }

  factory ContactBroadcastSectionsData.canonical() =>
      ContactBroadcastSectionsData(
        heroSlider: ContactHeroSliderData.canonical(),
        infoBadges: ContactInfoBadgesData.canonical(),
        promoBanner: ContactPromoBannerData.canonical(),
        formBuilder: ContactFormBuilderData.canonical(),
        officeAddress:
            'Vision Infrastructure Solutions, 120 E Beaver Creek Rd, Richmond Hill, ON, Canada',
      );
}
