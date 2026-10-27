/// Block types representing the dynamic sections returned by:
/// `GET https://vision.foduu.store/api/mobile-app/terms-and-conditions`
enum TermsBlockType {
  heading,
  paragraph,
  contact,
  lastUpdated,
}

/// Individual content block directly driven by backend API `sections`.
class TermsContentBlock {
  final String id;
  final TermsBlockType type;
  final String text;
  final double size;
  final String weight;
  final String alignment;
  final String color;
  final String? url;

  const TermsContentBlock({
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

/// Pure server-driven model representing the Terms & Conditions page data.
class TermsPageData {
  final String pageTitle;
  final List<TermsContentBlock> blocks;

  const TermsPageData({
    this.pageTitle = 'Terms & Conditions',
    required this.blocks,
  });

  /// Parse the dynamic sequential CMS sections delivered by:
  /// `GET https://vision.foduu.store/api/mobile-app/terms-and-conditions`
  factory TermsPageData.fromSections(List sections) {
    final list = <TermsContentBlock>[];

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
        if (cleanText.isNotEmpty) {
          list.add(TermsContentBlock(
            id: id,
            type: TermsBlockType.heading,
            text: cleanText,
            weight: 'bold',
          ));
        }
      } else if (type == 'text_block') {
        final text = (contentJson['text'] ?? '').toString().trim();
        if (text.isEmpty) continue;

        final isLastUpdated = text.toLowerCase().startsWith('last updated') ||
            text
                .toLowerCase()
                .contains('vision reserves the right to update or modify');

        final isContact = id.toLowerCase().contains('contact') ||
            text.toLowerCase().contains('contact the vision support team') ||
            text.toLowerCase().contains('contact information provided on our website');

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

          final size = double.tryParse(contentJson['size']?.toString() ?? '') ?? 15.0;
          final weight = contentJson['weight']?.toString() ?? 'normal';
          final alignment = contentJson['alignment']?.toString() ?? 'left';
          final color = contentJson['color']?.toString() ?? '#000000';

          list.add(TermsContentBlock(
            id: id,
            type: TermsBlockType.contact,
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

          list.add(TermsContentBlock(
            id: id,
            type: isLastUpdated
                ? TermsBlockType.lastUpdated
                : TermsBlockType.paragraph,
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
      return TermsPageData.canonical();
    }

    return TermsPageData(blocks: list);
  }

  /// Canonical defaults strictly mirroring:
  /// `https://vision.foduu.store/terms-conditions`
  factory TermsPageData.canonical() {
    return const TermsPageData(
      pageTitle: 'Terms & Conditions',
      blocks: [
        TermsContentBlock(
          id: 'rich_text_intro',
          type: TermsBlockType.heading,
          text: 'Introduction',
        ),
        TermsContentBlock(
          id: 'text_block_intro',
          type: TermsBlockType.paragraph,
          text:
              'Welcome to Vision. These Terms & Conditions govern your access to and use of our website, products, services, and online store. By accessing or using the Vision website, you acknowledge that you have read, understood, and agree to comply with these terms.',
        ),
        TermsContentBlock(
          id: 'rich_text_website',
          type: TermsBlockType.heading,
          text: 'Use of Website',
        ),
        TermsContentBlock(
          id: 'text_block_website',
          type: TermsBlockType.paragraph,
          text:
              'You agree to use the Vision website only for lawful purposes. You must not use the website in any way that may damage, disrupt, or interfere with its operation, security, or availability. Unauthorized access, misuse of website features, fraudulent activities, or activities that violate applicable laws are prohibited.',
        ),
        TermsContentBlock(
          id: 'rich_text_account',
          type: TermsBlockType.heading,
          text: 'Account Registration',
        ),
        TermsContentBlock(
          id: 'text_block_account',
          type: TermsBlockType.paragraph,
          text:
              'Certain features and services may require you to create an account. You are responsible for providing accurate and up-to-date information and maintaining the confidentiality of your login credentials. You are responsible for all activities performed through your account and should notify Vision promptly if you suspect unauthorized access.',
        ),
        TermsContentBlock(
          id: 'rich_text_orders',
          type: TermsBlockType.heading,
          text: 'Orders and Payment',
        ),
        TermsContentBlock(
          id: 'text_block_orders',
          type: TermsBlockType.paragraph,
          text:
              'Orders placed through Vision are subject to product availability, pricing, confirmation, and acceptance. Vision reserves the right to accept, reject, cancel, or limit orders when necessary, including in cases of incorrect pricing or product information, availability issues, suspected fraudulent activity, or other legitimate business reasons. Payment must be completed using the available payment methods before an order is processed or shipped.',
        ),
        TermsContentBlock(
          id: 'rich_text_pricing',
          type: TermsBlockType.heading,
          text: 'Pricing and Product Information',
        ),
        TermsContentBlock(
          id: 'text_block_pricing',
          type: TermsBlockType.paragraph,
          text:
              'Vision makes reasonable efforts to provide accurate product descriptions, technical specifications, images, prices, and availability information. However, occasional errors or omissions may occur. Vision reserves the right to correct errors, update information, change prices, or modify product availability without prior notice.',
        ),
        TermsContentBlock(
          id: 'rich_text_shipping',
          type: TermsBlockType.heading,
          text: 'Shipping and Delivery',
        ),
        TermsContentBlock(
          id: 'text_block_shipping',
          type: TermsBlockType.paragraph,
          text:
              'Orders are processed and shipped according to the shipping options available at the time of purchase. Delivery times may vary based on product availability, destination, shipping provider, and other circumstances. Vision is not responsible for delays caused by shipping carriers, incorrect addresses, customs procedures, or events beyond our reasonable control.',
        ),
        TermsContentBlock(
          id: 'rich_text_returns',
          type: TermsBlockType.heading,
          text: 'Returns and Refunds',
        ),
        TermsContentBlock(
          id: 'text_block_returns',
          type: TermsBlockType.paragraph,
          text:
              'Returns, replacements, refunds, and order cancellations are subject to the applicable policies of Vision. Customers must follow the required return procedure and provide accurate order and delivery information. Products must meet the applicable eligibility conditions for returns or refunds.',
        ),
        TermsContentBlock(
          id: 'rich_text_specs',
          type: TermsBlockType.heading,
          text: 'Product Specifications and Compatibility',
        ),
        TermsContentBlock(
          id: 'text_block_specs',
          type: TermsBlockType.paragraph,
          text:
              'Vision offers networking and technology products that may have specific technical specifications and compatibility requirements. Customers are responsible for reviewing product specifications and confirming that selected products are suitable for their intended application before placing an order.',
        ),
        TermsContentBlock(
          id: 'rich_text_ip',
          type: TermsBlockType.heading,
          text: 'Intellectual Property',
        ),
        TermsContentBlock(
          id: 'text_block_ip',
          type: TermsBlockType.paragraph,
          text:
              'All content available on the Vision website, including text, product information, graphics, images, logos, icons, designs, software, and other materials, is owned by or licensed to Vision and is protected by applicable intellectual property laws. You may not copy, reproduce, modify, distribute, publish, or commercially use website content without prior written permission.',
        ),
        TermsContentBlock(
          id: 'rich_text_liability',
          type: TermsBlockType.heading,
          text: 'Limitation of Liability',
        ),
        TermsContentBlock(
          id: 'text_block_liability',
          type: TermsBlockType.paragraph,
          text:
              'To the fullest extent permitted by applicable law, Vision shall not be liable for indirect, incidental, special, consequential, or punitive damages arising from your use of the website, products, or services. Vision is also not responsible for service interruptions, delays, or failures caused by circumstances beyond our reasonable control.',
        ),
        TermsContentBlock(
          id: 'rich_text_changes',
          type: TermsBlockType.heading,
          text: 'Changes to these Terms',
        ),
        TermsContentBlock(
          id: 'text_block_changes',
          type: TermsBlockType.paragraph,
          text:
              'Vision may update or modify these Terms & Conditions from time to time to reflect changes in our products, services, website functionality, business practices, or applicable laws. Updated terms will be published on this page along with the revised Last Updated date. Continued use of the website after changes are posted constitutes acceptance of the updated terms.',
        ),
        TermsContentBlock(
          id: 'rich_text_contact',
          type: TermsBlockType.heading,
          text: 'Contact Us',
        ),
        TermsContentBlock(
          id: 'text_block_contact',
          type: TermsBlockType.contact,
          text:
              'If you have any questions or concerns regarding these Terms & Conditions, our products, orders, shipping, returns, or services, please contact the Vision support team through the contact information provided on our website.',
          url: 'https://vision.vbought.com',
        ),
        TermsContentBlock(
          id: 'text_block_last_updated',
          type: TermsBlockType.lastUpdated,
          text:
              'Last updated on September 2, 2026. Vision reserves the right to update or modify these Terms & Conditions at any time without prior notice.',
        ),
      ],
    );
  }
}
