import 'package:zouhi/app/data/models/page_model.dart';

String _s(Map<String, dynamic> f, String key, [String fallback = '']) {
  final v = f[key]?.toString().trim() ?? '';
  return v.isEmpty ? fallback : v;
}

class ContactInfoItem {
  const ContactInfoItem({
    required this.iconHtml,
    required this.heading,
    required this.value,
    required this.link,
  });

  final String iconHtml;
  final String heading;
  final String value;
  final String link;
}

class ContactInfoSection {
  const ContactInfoSection({
    required this.title,
    required this.description,
    required this.items,
  });

  final String title;
  final String description;
  final List<ContactInfoItem> items;

  factory ContactInfoSection.fromComponent(PageComponent c) {
    final f = c.fields;
    final items = <ContactInfoItem>[
      ContactInfoItem(
          iconHtml: _s(f, 'email_icon'),
          heading: _s(f, 'email_heading', 'E-mail Address'),
          value: _s(f, 'email_address'),
          link: _s(f, 'email_link')),
      ContactInfoItem(
          iconHtml: _s(f, 'phone_icon'),
          heading: _s(f, 'phone_heading', 'Phone Number'),
          value: _s(f, 'phone_number'),
          link: _s(f, 'phone_link')),
    ].where((i) => i.value.isNotEmpty).toList();
    return ContactInfoSection(
      title: _s(f, 'section_title', 'Contact Information'),
      description: _s(f, 'section_description'),
      items: items,
    );
  }
}

class FormBannerSection {
  const FormBannerSection({
    required this.title,
    required this.backgroundImage,
    required this.formSlug,
  });

  final String title;
  final String backgroundImage;
  final String formSlug;

  factory FormBannerSection.fromComponent(PageComponent c) => FormBannerSection(
        title: _s(c.fields, 'section_title', 'Send Us a Message'),
        backgroundImage: _s(c.fields, 'background_image'),
        formSlug: _s(c.fields, 'form_slug'),
      );
}

class NewsletterSection {
  const NewsletterSection({
    required this.iconHtml,
    required this.title,
    required this.description,
    required this.formSlug,
  });

  final String iconHtml;
  final String title;
  final String description;
  final String formSlug;

  factory NewsletterSection.fromComponent(PageComponent c) => NewsletterSection(
        iconHtml: _s(c.fields, 'icon_html'),
        title: _s(c.fields, 'section_title', 'Subscribe To Our Newsletter'),
        description: _s(c.fields, 'section_description'),
        formSlug: _s(c.fields, 'form_slug'),
      );
}
