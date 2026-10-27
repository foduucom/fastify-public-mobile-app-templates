/// Block types representing the dynamic sections returned by:
/// `GET https://vision.foduu.store/api/mobile-app/privacy-policy`
enum PrivacyBlockType {
  heading,
  paragraph,
  contact,
  lastUpdated,
}

/// Individual content block directly driven by backend API `sections`.
class PrivacyContentBlock {
  final String id;
  final PrivacyBlockType type;
  final String text;
  final double size;
  final String weight;
  final String alignment;
  final String color;
  final String? url;

  const PrivacyContentBlock({
    required this.id,
    required this.type,
    required this.text,
    this.size = 15.0,
    this.weight = 'normal',
    this.alignment = 'left',
    this.color = '#000000',
    this.url,
  });
}

/// Pure server-driven model representing the Privacy Policy page data.
class PrivacyPageData {
  final String pageTitle;
  final String subtitle;
  final List<PrivacyContentBlock> blocks;

  const PrivacyPageData({
    this.pageTitle = 'Privacy Policy',
    this.subtitle = 'Vision Infrastructure Solutions',
    required this.blocks,
  });

  /// Parse the dynamic sequential CMS sections delivered by:
  /// `GET https://vision.foduu.store/api/mobile-app/privacy-policy`
  factory PrivacyPageData.fromSections(List sections) {
    String pageTitle = 'Privacy Policy';
    String subtitle = 'Vision Infrastructure Solutions';
    final list = <PrivacyContentBlock>[];

    for (final raw in sections) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final visible = map['visible'] as bool? ?? true;
      if (!visible) continue;

      final type = map['type']?.toString() ?? '';
      final id = map['id']?.toString() ?? '';
      final contentJson = map['content_json'] is Map
          ? Map<String, dynamic>.from(map['content_json'])
          : <String, dynamic>{};

      if (type == 'rich_text') {
        String rawHtml =
            (contentJson['html_content'] ?? contentJson['text'] ?? '')
                .toString()
                .trim();
        final cleanText = rawHtml.replaceAll(RegExp(r'<[^>]*>'), '').trim();
        if (cleanText.isEmpty) continue;

        // Section 0 in log3.txt packs: "Privacy PolicyVision Infrastructure SolutionsIntroduction"
        if (cleanText.toLowerCase().contains('privacy policy') &&
            cleanText.toLowerCase().contains('vision infrastructure solutions')) {
          pageTitle = 'Privacy Policy';
          subtitle = 'Vision Infrastructure Solutions';

          // Extract any remaining section heading (e.g. "Introduction")
          String remaining = cleanText;
          final titleIdx = remaining.indexOf('Privacy Policy');
          if (titleIdx >= 0) {
            remaining = remaining.replaceFirst('Privacy Policy', '');
          }
          final subIdx = remaining.indexOf('Vision Infrastructure Solutions');
          if (subIdx >= 0) {
            remaining = remaining.replaceFirst('Vision Infrastructure Solutions', '');
          }
          remaining = remaining.trim();
          if (remaining.isNotEmpty) {
            list.add(PrivacyContentBlock(
              id: '${id}_intro',
              type: PrivacyBlockType.heading,
              text: remaining,
              weight: 'bold',
            ));
          }
        } else {
          list.add(PrivacyContentBlock(
            id: id,
            type: PrivacyBlockType.heading,
            text: cleanText,
            weight: 'bold',
          ));
        }
      } else if (type == 'text_block') {
        final text = (contentJson['text'] ?? '').toString().trim();
        if (text.isEmpty) continue;

        final isLastUpdated = text.toLowerCase().startsWith('last updated') ||
            text.toLowerCase().contains('all rights reserved') ||
            text
                .toLowerCase()
                .contains('vision reserves the right to update or modify');

        final isContact = id.toLowerCase().contains('contact') ||
            text.toLowerCase().contains('reach out to our team at') ||
            text.toLowerCase().contains('https://vision.vbought.com');

        if (isContact) {
          String cleanText = text;
          String? contactUrl;
          final urlMatch = RegExp(r'(https?:\/\/[^\s]+)').firstMatch(text);
          if (urlMatch != null) {
            contactUrl = urlMatch.group(0);
            cleanText = text.replaceAll(contactUrl!, '').trim();
          }
          cleanText = cleanText
              .replaceAll('\r\n', '\n')
              .replaceAll(RegExp(r'\n[ \t]+'), '\n')
              .replaceAll(RegExp(r'\n{2,}'), '\n\n')
              .trim();

          final size =
              double.tryParse(contentJson['size']?.toString() ?? '') ?? 15.0;
          final weight = contentJson['weight']?.toString() ?? 'normal';
          final alignment = contentJson['alignment']?.toString() ?? 'left';
          final color = contentJson['color']?.toString() ?? '#000000';

          list.add(PrivacyContentBlock(
            id: id,
            type: PrivacyBlockType.contact,
            text: cleanText,
            url: contactUrl ?? 'https://vision.vbought.com',
            size: size,
            weight: weight,
            alignment: alignment,
            color: color,
          ));
        } else {
          final cleanParagraph = text
              .replaceAll('\r\n', '\n')
              .replaceAll(RegExp(r'\n[ \t]+'), '\n')
              .replaceAll(RegExp(r'\n{3,}'), '\n\n')
              .trim();

          final size = double.tryParse(contentJson['size']?.toString() ?? '') ??
              (isLastUpdated ? 13.0 : 15.0);
          final weight = contentJson['weight']?.toString() ?? 'normal';
          final alignment = contentJson['alignment']?.toString() ?? 'left';
          final color = contentJson['color']?.toString() ?? '#000000';

          list.add(PrivacyContentBlock(
            id: id,
            type: isLastUpdated
                ? PrivacyBlockType.lastUpdated
                : PrivacyBlockType.paragraph,
            text: cleanParagraph,
            size: size,
            weight: weight,
            alignment: alignment,
            color: color,
          ));
        }
      }
    }

    if (list.isEmpty) {
      return PrivacyPageData.canonical();
    }

    return PrivacyPageData(
      pageTitle: pageTitle,
      subtitle: subtitle,
      blocks: list,
    );
  }

  /// Canonical defaults strictly mirroring:
  /// `https://vision.foduu.store/privacy-policy`
  factory PrivacyPageData.canonical() {
    return const PrivacyPageData(
      pageTitle: 'Privacy Policy',
      subtitle: 'Vision Infrastructure Solutions',
      blocks: [
        PrivacyContentBlock(
          id: 'rich_text_intro',
          type: PrivacyBlockType.heading,
          text: 'Introduction',
        ),
        PrivacyContentBlock(
          id: 'text_block_intro',
          type: PrivacyBlockType.paragraph,
          text:
              'At Vision, we value your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you visit our website, purchase networking equipment, or interact with our services. By accessing or using our platform, you consent to the practices described in this policy.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_info',
          type: PrivacyBlockType.heading,
          text: 'Information We Collect',
        ),
        PrivacyContentBlock(
          id: 'text_block_info',
          type: PrivacyBlockType.paragraph,
          text:
              'We collect information you provide directly to us when creating an account, placing an order, or contacting customer support. This includes personal information (Name, email address, phone number, company name), billing and shipping address, order details for networking products, and technical usage data (IP address, browser type, cookies, and system logs).',
        ),
        PrivacyContentBlock(
          id: 'rich_text_account',
          type: PrivacyBlockType.heading,
          text: 'Account & Profile Information',
        ),
        PrivacyContentBlock(
          id: 'text_block_account',
          type: PrivacyBlockType.paragraph,
          text:
              'When you register an account on the Vision store, we maintain your profile information, order history, and saved addresses to streamline your purchasing experience. You are responsible for keeping your credentials secure and should notify us immediately of any unauthorized access.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_orders',
          type: PrivacyBlockType.heading,
          text: 'Orders and Fulfillment',
        ),
        PrivacyContentBlock(
          id: 'text_block_orders',
          type: PrivacyBlockType.paragraph,
          text:
              'To process orders for switches, fiber cables, transceivers, and hardware accessories, we collect order specifications, delivery addresses, and payment confirmations. This information is used strictly to fulfill purchases, generate invoices, send shipping notifications, and provide post-purchase support.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_payment',
          type: PrivacyBlockType.heading,
          text: 'Payment Processing',
        ),
        PrivacyContentBlock(
          id: 'text_block_payment',
          type: PrivacyBlockType.paragraph,
          text:
              'All online transactions on Vision are processed securely through certified third-party payment gateways with PCI-DSS compliance. Vision does not store sensitive credit/debit card details on our local servers.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_usage',
          type: PrivacyBlockType.heading,
          text: 'How We Use Your Information',
        ),
        PrivacyContentBlock(
          id: 'text_block_usage',
          type: PrivacyBlockType.paragraph,
          text:
              'We use the collected information to fulfill orders, process payments, deliver support, send system updates and order status alerts, enhance site performance, prevent fraudulent activities, and maintain the legal and security integrity of our infrastructure.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_cookies',
          type: PrivacyBlockType.heading,
          text: 'Cookies and Analytics',
        ),
        PrivacyContentBlock(
          id: 'text_block_cookies',
          type: PrivacyBlockType.paragraph,
          text:
              'Vision utilizes cookies, web beacons, and site analytics to remember cart items, personalize your browsing experience, and analyze site performance. You may choose to disable cookies through your browser settings, though some features of our website may not function properly.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_sharing',
          type: PrivacyBlockType.heading,
          text: 'Information Sharing',
        ),
        PrivacyContentBlock(
          id: 'text_block_sharing',
          type: PrivacyBlockType.paragraph,
          text:
              'Vision does not sell, rent, or trade your personal information to third parties. We share data only with trusted partners, courier services, and technology providers necessary to operate our website, fulfill shipments, and deliver services under strict confidentiality agreements.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_security',
          type: PrivacyBlockType.heading,
          text: 'Data Security',
        ),
        PrivacyContentBlock(
          id: 'text_block_security',
          type: PrivacyBlockType.paragraph,
          text:
              'We implement industry-standard technical, SSL encryption, and physical security measures to protect your personal information against unauthorized access, loss, or misuse. However, no data transmission over the Internet can be guaranteed 100% secure.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_retention',
          type: PrivacyBlockType.heading,
          text: 'Data Retention',
        ),
        PrivacyContentBlock(
          id: 'text_block_retention',
          type: PrivacyBlockType.paragraph,
          text:
              'We retain your personal data only as long as necessary to fulfill business transactions, maintain accounting and tax records, resolve disputes, enforce legal contracts, and comply with regulatory requirements.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_third_party',
          type: PrivacyBlockType.heading,
          text: 'Third-Party Links & Services',
        ),
        PrivacyContentBlock(
          id: 'text_block_third_party',
          type: PrivacyBlockType.paragraph,
          text:
              'Our website may contain links to third-party tools or external sites. Vision is not responsible for the content, security, or privacy policies of third-party websites. We encourage you to read their privacy statements before sharing any personal data.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_rights',
          type: PrivacyBlockType.heading,
          text: 'Your Privacy Choices & Rights',
        ),
        PrivacyContentBlock(
          id: 'text_block_rights',
          type: PrivacyBlockType.paragraph,
          text:
              'You have the right to access, update, correct, or request deletion of your personal data stored with us. You can also unsubscribe from promotional emails at any time by contacting our support team.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_children',
          type: PrivacyBlockType.heading,
          text: 'Children’s Privacy',
        ),
        PrivacyContentBlock(
          id: 'text_block_children',
          type: PrivacyBlockType.paragraph,
          text:
              'Vision products and services are targeted toward businesses and adults. We do not knowingly collect personal information from children under 16 years of age.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_changes',
          type: PrivacyBlockType.heading,
          text: 'Changes to this Privacy Policy',
        ),
        PrivacyContentBlock(
          id: 'text_block_changes',
          type: PrivacyBlockType.paragraph,
          text:
              'Vision reserves the right to modify or update this Privacy Policy at any time. Any changes will be published directly on this page along with the updated Last Revised date.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_contact',
          type: PrivacyBlockType.heading,
          text: 'Contact Us',
        ),
        PrivacyContentBlock(
          id: 'text_block_contact',
          type: PrivacyBlockType.contact,
          text:
              'If you have any questions or concerns regarding this Privacy Policy or data protection at Vision, please reach out to our team at:\n\n                https://vision.vbought.com',
          url: 'https://vision.vbought.com',
        ),
        PrivacyContentBlock(
          id: 'text_block_last_updated',
          type: PrivacyBlockType.lastUpdated,
          text:
              'Last updated on September 2, 2026. Vision Infrastructure Solutions. All rights reserved.',
        ),
      ],
    );
  }
}
