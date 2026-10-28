/// Block types representing the dynamic sections returned by:
/// `GET https://vision.foduu.store/api/mobile-app/privacy-policy`
enum PrivacyBlockType {
  heading,
  paragraph,
  bulletList,
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
  final List<String> listItems;
  final String? introText;
  final String? outroText;
  final String? email;
  final String? website;
  final String? companyName;
  final String? effectiveDate;
  final String? regulatoryNotice;

  const PrivacyContentBlock({
    required this.id,
    required this.type,
    required this.text,
    this.size = 15.0,
    this.weight = 'normal',
    this.alignment = 'left',
    this.color = '#000000',
    this.url,
    this.listItems = const [],
    this.introText,
    this.outroText,
    this.email,
    this.website,
    this.companyName,
    this.effectiveDate,
    this.regulatoryNotice,
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
        final cleanText = _stripHtml(rawHtml).trim();
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
        final rawText = (contentJson['text'] ?? '').toString();
        if (rawText.trim().isEmpty) continue;

        final isLastUpdated = rawText.toLowerCase().startsWith('last updated') ||
            rawText.toLowerCase().contains('all rights reserved') ||
            rawText
                .toLowerCase()
                .contains('vision reserves the right to update or modify');

        final isContactHeading = list.isNotEmpty &&
            list.last.type == PrivacyBlockType.heading &&
            list.last.text.toLowerCase().trim() == 'contact us';

        final isContact = id.toLowerCase().contains('contact') ||
            isContactHeading ||
            (rawText.toLowerCase().contains('sales@visioninfrastructurecanada.com') &&
                (rawText.toLowerCase().contains('website:') ||
                    rawText.toLowerCase().contains('webiste:')));

        final size = double.tryParse(contentJson['size']?.toString() ?? '') ??
            (isLastUpdated ? 13.0 : 15.0);
        final weight = contentJson['weight']?.toString() ?? 'normal';
        final alignment = contentJson['alignment']?.toString() ?? 'left';
        final color = contentJson['color']?.toString() ?? '#000000';

        if (isContact) {
          list.add(_parseContactBlock(
            id: id,
            rawText: rawText,
            size: size,
            weight: weight,
            alignment: alignment,
            color: color,
          ));
        } else if (isLastUpdated) {
          final cleanParagraph = rawText
              .replaceAll('\r\n', '\n')
              .replaceAll(RegExp(r'\n[ \t]+'), '\n')
              .replaceAll(RegExp(r'\n{3,}'), '\n\n')
              .trim();

          list.add(PrivacyContentBlock(
            id: id,
            type: PrivacyBlockType.lastUpdated,
            text: cleanParagraph,
            size: size,
            weight: weight,
            alignment: alignment,
            color: color,
          ));
        } else {
          // Check if this text block contains a structured <ul><li> HTML list
          // or an indented/bulleted list
          final parsedListBlock = _tryParseListBlock(
            id: id,
            rawText: rawText,
            size: size,
            weight: weight,
            alignment: alignment,
            color: color,
          );

          if (parsedListBlock != null) {
            list.add(parsedListBlock);
          } else {
            final cleanParagraph = rawText
                .replaceAll('\r\n', '\n')
                .replaceAll(RegExp(r'\n[ \t]+'), '\n')
                .replaceAll(RegExp(r'\n{3,}'), '\n\n')
                .trim();

            list.add(PrivacyContentBlock(
              id: id,
              type: PrivacyBlockType.paragraph,
              text: cleanParagraph,
              size: size,
              weight: weight,
              alignment: alignment,
              color: color,
            ));
          }
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

  /// Attempts to parse raw text into a `bulletList` block.
  /// Handles:
  /// 1. HTML unordered lists `<ul><li>...</li></ul>` (including escaped entities `&lt;ul&gt;`)
  /// 2. Indented text lines (e.g. lines with 2+ leading spaces or bullet markers)
  static PrivacyContentBlock? _tryParseListBlock({
    required String id,
    required String rawText,
    required double size,
    required String weight,
    required String alignment,
    required String color,
  }) {
    // 1. Unescape HTML entities if any
    final unescaped = rawText
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&#x27;', "'")
        .replaceAll('&quot;', '"');

    // 2. Check for HTML <ul> ... <li> ... </ul> pattern
    if (unescaped.contains('<ul') && unescaped.contains('<li')) {
      final ulStart = unescaped.indexOf('<ul');
      final ulEnd = unescaped.indexOf('</ul>');

      String intro = '';
      if (ulStart > 0) {
        intro = _stripHtml(unescaped.substring(0, ulStart)).trim();
      }

      String listSegment = ulEnd > ulStart
          ? unescaped.substring(ulStart, ulEnd + 5)
          : unescaped.substring(ulStart);

      String outro = '';
      if (ulEnd > 0 && ulEnd + 5 < unescaped.length) {
        outro = _stripHtml(unescaped.substring(ulEnd + 5)).trim();
      }

      final liRegex = RegExp(r'<li[^>]*>(.*?)<\/li>', dotAll: true);
      final items = <String>[];
      for (final match in liRegex.allMatches(listSegment)) {
        final itemText = _stripHtml(match.group(1) ?? '').trim();
        if (itemText.isNotEmpty) {
          items.add(itemText);
        }
      }

      if (items.isNotEmpty) {
        return PrivacyContentBlock(
          id: id,
          type: PrivacyBlockType.bulletList,
          text: _stripHtml(unescaped).trim(),
          size: size,
          weight: weight,
          alignment: alignment,
          color: color,
          listItems: items,
          introText: intro.isNotEmpty ? intro : null,
          outroText: outro.isNotEmpty ? outro : null,
        );
      }
    }

    // 3. Check for indented text lines (e.g. \n  Identity and business...)
    final lines = rawText.replaceAll('\r\n', '\n').split('\n');
    final introLines = <String>[];
    final itemLines = <String>[];
    final outroLines = <String>[];

    bool inList = false;
    bool afterList = false;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        if (inList && itemLines.isNotEmpty) {
          // Empty line encountered after items might mark end of list
          inList = false;
          afterList = true;
        }
        continue;
      }

      // Check if line is indented with 2+ spaces or has bullet marker
      final isIndented = (line.startsWith('  ') ||
              line.startsWith('\t') ||
              line.startsWith('- ') ||
              line.startsWith('• ') ||
              line.startsWith('* ')) &&
          trimmed.length > 5;

      if (!afterList) {
        if (isIndented) {
          inList = true;
          // Strip leading bullet marker or whitespace
          String cleanItem = trimmed;
          if (cleanItem.startsWith('- ') ||
              cleanItem.startsWith('• ') ||
              cleanItem.startsWith('* ')) {
            cleanItem = cleanItem.substring(2).trim();
          }
          itemLines.add(cleanItem);
        } else if (inList) {
          // If we were in list and encounter an unindented line, transition to outro
          inList = false;
          afterList = true;
          outroLines.add(trimmed);
        } else {
          introLines.add(trimmed);
        }
      } else {
        outroLines.add(trimmed);
      }
    }

    // Must have at least 2 distinct list items to classify as a bullet list
    if (itemLines.length >= 2) {
      return PrivacyContentBlock(
        id: id,
        type: PrivacyBlockType.bulletList,
        text: _stripHtml(rawText).trim(),
        size: size,
        weight: weight,
        alignment: alignment,
        color: color,
        listItems: itemLines,
        introText: introLines.isNotEmpty ? introLines.join(' ') : null,
        outroText: outroLines.isNotEmpty ? outroLines.join(' ') : null,
      );
    }

    return null;
  }

  static String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Parses contact section text into a strongly typed PrivacyContentBlock
  /// with extracted email, website, company name, date, and regulatory notice.
  static PrivacyContentBlock _parseContactBlock({
    required String id,
    required String rawText,
    required double size,
    required String weight,
    required String alignment,
    required String color,
  }) {
    // 1. Sanitize typos and filter out internal pre-publication template disclaimers
    String cleaned = rawText
        .replaceAll(RegExp(r'Webiste:', caseSensitive: false), 'Website:')
        .replaceAll('\r\n', '\n');

    cleaned = cleaned
        .replaceAll(
          RegExp(
            r'Important:\s*This policy is a general template and should be reviewed against[^\n]*before publication\.?',
            caseSensitive: false,
          ),
          '',
        )
        .trim();

    // 2. Extract email address
    String? email;
    final emailMatch = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}').firstMatch(cleaned);
    if (emailMatch != null) {
      email = emailMatch.group(0);
    } else {
      email = 'sales@visioninfrastructurecanada.com';
    }

    // 3. Extract website
    String? website;
    final websiteMatch = RegExp(r'(?:https?:\/\/|www\.)[a-zA-Z0-9.\-_]+(?:\/[^\s]*)?').firstMatch(cleaned);
    if (websiteMatch != null) {
      website = websiteMatch.group(0);
    } else {
      website = 'www.visioninfrastructurecanada.com';
    }

    // 4. Extract company name
    String companyName = 'Vision Infrastructure Canada';
    if (cleaned.contains('Vision Infrastructure Canada')) {
      companyName = 'Vision Infrastructure Canada';
    } else if (cleaned.contains('Vision Infrastructure Solutions')) {
      companyName = 'Vision Infrastructure Solutions';
    }

    // 5. Extract effective date (e.g. "September 2, 2026")
    String? effectiveDate;
    final dateMatch = RegExp(
      r'(?:January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{1,2},\s+\d{4}',
      caseSensitive: false,
    ).firstMatch(cleaned);
    if (dateMatch != null) {
      effectiveDate = dateMatch.group(0);
    }

    // 6. Extract regulatory & complaints notice
    String? regulatoryNotice;
    final regMatch = RegExp(
      r'We will review privacy enquiries and complaints and respond within a reasonable period[\s\S]*?(?:jurisdiction\.|applicable law\.)',
      caseSensitive: false,
    ).firstMatch(cleaned);
    if (regMatch != null) {
      regulatoryNotice = regMatch.group(0)?.trim();
    }

    // 7. Extract intro text (e.g. "If you have questions about this Privacy Policy...")
    String intro = '';
    final introMatch = RegExp(
      r'^([\s\S]*?)(?:Vision Infrastructure Canada|Email:|Website:|sales@)',
      caseSensitive: false,
    ).firstMatch(cleaned);
    if (introMatch != null) {
      intro = introMatch.group(1)!.trim();
    }
    if (intro.isEmpty) {
      intro =
          'If you have questions about this Privacy Policy, wish to make a privacy request, or want to raise a concern about how personal information is handled, please contact:';
    }

    final webUrl = website != null
        ? (website.startsWith('http') ? website : 'https://$website')
        : 'https://www.visioninfrastructurecanada.com';

    return PrivacyContentBlock(
      id: id,
      type: PrivacyBlockType.contact,
      text: intro,
      size: size,
      weight: weight,
      alignment: alignment,
      color: color,
      email: email,
      website: website,
      companyName: companyName,
      effectiveDate: effectiveDate,
      regulatoryNotice: regulatoryNotice,
      url: webUrl,
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
          id: 'text_block_intro',
          type: PrivacyBlockType.paragraph,
          text:
              'Vision Infrastructure Canada (“Vision Infrastructure Canada”, “we”, “us” or “our”) respects your privacy and is committed to handling personal information responsibly. This Privacy Policy explains how we collect, use, store, disclose and protect personal information when you visit our website, contact us, request a quotation, purchase products, or otherwise interact with our business. We handle personal information in accordance with applicable privacy and data-protection laws.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_1',
          type: PrivacyBlockType.heading,
          text: '1. About Vision Infrastructure Canada',
        ),
        PrivacyContentBlock(
          id: 'text_block_1',
          type: PrivacyBlockType.paragraph,
          text:
              'Vision Infrastructure Canada supplies fibre optic products, networking equipment, infrastructure solutions and network architectural designs to business customers and other organisations. In providing these products and services, we may handle information about customers, prospective customers, suppliers, business contacts and website visitors. The organisation responsible for personal information will generally be the Vision Infrastructure Canada legal entity that interacts with you or determines how and why the information is used. Please contact us using the details in the Contact Us section if you would like clarification about the entity responsible for your information.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_2',
          type: PrivacyBlockType.heading,
          text: '2. Personal Information We May Collect',
        ),
        PrivacyContentBlock(
          id: 'text_block_2',
          type: PrivacyBlockType.bulletList,
          text: 'Personal Information We May Collect',
          introText: 'Depending on how you interact with us, we may collect:',
          listItems: [
            'Identity and business contact details, such as your name, business name, job title, email address, telephone number and business address.',
            'Transaction and account information, including quotation requests, purchase orders, order history, delivery details, billing information and relevant correspondence.',
            'Project and technical information you choose to provide, such as product specifications, network requirements, project details and support requests.',
            'Communications and enquiry records, including information you provide when contacting us by email, telephone, website forms or other channels.',
            'Website and device information, such as IP address, browser type, device information, pages viewed, referring pages and interactions with our website.',
            'Cookie and analytics information, where applicable and subject to any consent required by law.',
          ],
          outroText:
              'We do not seek to collect sensitive information unless it is necessary for a legitimate business purpose and collection is permitted by applicable law.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_3',
          type: PrivacyBlockType.heading,
          text: '3. How We Collect Information',
        ),
        PrivacyContentBlock(
          id: 'text_block_3',
          type: PrivacyBlockType.paragraph,
          text:
              'We may collect information directly from you when you submit an enquiry, request a quotation, place an order, communicate with our team, attend a meeting or event, subscribe to updates, or otherwise do business with us. We may also receive relevant business contact information from your employer or organisation, authorised representatives, business partners, publicly available sources or service providers, where lawful. If you provide personal information about another person, please ensure you are authorised to do so and that the person is aware of this Privacy Policy where appropriate.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_4',
          type: PrivacyBlockType.heading,
          text: '4. How We Use Personal Information',
        ),
        PrivacyContentBlock(
          id: 'text_block_4',
          type: PrivacyBlockType.bulletList,
          text: 'How We Use Personal Information',
          introText: 'We may use personal information to:',
          listItems: [
            'Respond to enquiries and provide product, pricing and technical information.',
            'Prepare quotations, process and fulfil orders, arrange delivery and provide order updates.',
            'Supply products and services and manage customer, supplier and business relationships.',
            'Provide customer service, troubleshoot issues and manage product claims or warranty matters.',
            'Maintain business, accounting, tax and transaction records.',
            'Send relevant product information, company updates and marketing communications where permitted by law.',
            'Operate, maintain, protect and improve our website, systems, products and services.',
            'Detect and prevent fraud, security incidents, misuse or other unlawful activity.',
            'Meet legal, regulatory and contractual obligations and establish, exercise or defend legal claims.',
          ],
          outroText:
              'Where required by law, we will obtain consent before using personal information for a particular purpose. We will not use information for a materially different purpose unless permitted by law or we have obtained any required consent.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_5',
          type: PrivacyBlockType.heading,
          text: '5. Legal Grounds for Handling Information',
        ),
        PrivacyContentBlock(
          id: 'text_block_5',
          type: PrivacyBlockType.paragraph,
          text:
              'Depending on the circumstances and applicable law, we may handle personal information because it is necessary to perform a contract or take steps at your request before entering into a contract, to comply with a legal obligation, based on your consent, or for a legitimate business purpose that does not override your applicable privacy rights. Where consent is the basis for handling information, you may withdraw it as described in this Policy, subject to legal or contractual limitations.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_6',
          type: PrivacyBlockType.heading,
          text: '6. Disclosure to Other Parties',
        ),
        PrivacyContentBlock(
          id: 'text_block_6',
          type: PrivacyBlockType.bulletList,
          text: 'Disclosure to Other Parties',
          introText: 'We do not sell personal information. We may disclose relevant information, on a need-to-know basis, to:',
          listItems: [
            'Manufacturers, distributors, suppliers and logistics providers involved in fulfilling an order or providing a service.',
            'Website hosting, cloud storage, IT support, communications, analytics and other technology providers.',
            'Payment processors, banks, insurers and professional advisers, where relevant.',
            'Our employees, contractors and authorised representatives who need the information for their work.',
            'Government agencies, regulators, courts, law enforcement or other parties where disclosure is required or permitted by law.',
            'A prospective or actual purchaser, investor or successor in connection with a merger, restructuring, sale or transfer of all or part of our business, subject to appropriate safeguards.',
          ],
          outroText:
              'Third parties that process information on our behalf are expected to handle it securely and only for authorised purposes, subject to their role and applicable agreements and laws.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_7',
          type: PrivacyBlockType.heading,
          text: '7. International Disclosure and Storage',
        ),
        PrivacyContentBlock(
          id: 'text_block_7',
          type: PrivacyBlockType.paragraph,
          text:
              'Some of our service providers, suppliers or business partners may be located outside the country in which you are based. As a result, personal information may be stored or processed in another country, subject to applicable law. Where required, we take reasonable steps to ensure that appropriate safeguards are in place for cross-border disclosures and that information receives the protection required by applicable privacy laws. If you would like more information about overseas handling of personal information, please contact us using the details below.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_8',
          type: PrivacyBlockType.heading,
          text: '8. Cookies and Analytics',
        ),
        PrivacyContentBlock(
          id: 'text_block_8',
          type: PrivacyBlockType.paragraph,
          text:
              'Our website may use cookies and similar technologies to support essential website functions, remember preferences, understand website traffic and improve the user experience. These technologies may collect technical and usage information, such as pages viewed, browser details and interactions with the site. You can manage cookies through your browser settings. Some website features may not function properly if certain cookies are disabled. Where required by law, we will ask for consent before using non-essential cookies or tracking technologies. If our website uses third-party analytics or advertising tools, those providers may process information in accordance with their own privacy terms. Please review any separate Cookie Policy published on our website, if available.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_9',
          type: PrivacyBlockType.heading,
          text: '9. Marketing Communications',
        ),
        PrivacyContentBlock(
          id: 'text_block_9',
          type: PrivacyBlockType.paragraph,
          text:
              'Where permitted by law, we may use your business contact details to send information about products, services, industry updates or other material that may be relevant to your work. You can opt out of marketing messages at any time by following the unsubscribe instructions in the message or contacting us directly. Opting out of marketing will not prevent us from sending essential non-marketing communications, such as information about an existing quotation, order, delivery, warranty or business relationship.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_10',
          type: PrivacyBlockType.heading,
          text: '10. Retention of Information',
        ),
        PrivacyContentBlock(
          id: 'text_block_10',
          type: PrivacyBlockType.paragraph,
          text:
              'We retain personal information only for as long as reasonably necessary for the purposes for which it was collected, including fulfilling orders, maintaining business relationships, handling claims, meeting record-keeping requirements and resolving disputes. The appropriate retention period depends on the type of information and the circumstances. When information is no longer required, we take reasonable steps to securely delete, destroy or de-identify it, unless we are required or permitted by law to retain it for longer.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_11',
          type: PrivacyBlockType.heading,
          text: '11. Security',
        ),
        PrivacyContentBlock(
          id: 'text_block_11',
          type: PrivacyBlockType.paragraph,
          text:
              'We use reasonable technical, organisational and administrative safeguards designed to protect personal information against loss, misuse, unauthorised access, disclosure, alteration or destruction. No method of electronic storage or transmission is completely secure, and we cannot guarantee absolute security. If a data breach occurs, we will respond and provide notifications as required by applicable law.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_12',
          type: PrivacyBlockType.heading,
          text: '12. Access, Correction and Privacy Requests',
        ),
        PrivacyContentBlock(
          id: 'text_block_12',
          type: PrivacyBlockType.paragraph,
          text:
              'Subject to applicable law, you may request access to personal information we hold about you and ask us to correct information that is inaccurate, incomplete or out of date. Depending on your location and the laws that apply, you may also have rights to request deletion, object to or restrict certain handling, receive a copy of information in a portable format, or withdraw consent. To make a request, contact us using the details below. We may need to verify your identity before responding. Some requests may be limited by legal, contractual, security or record-keeping requirements. If we cannot fulfil a request, we will explain our decision where required by law.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_13',
          type: PrivacyBlockType.heading,
          text: '13. Third-Party Websites',
        ),
        PrivacyContentBlock(
          id: 'text_block_13',
          type: PrivacyBlockType.paragraph,
          text:
              'Our website may link to websites or services operated by third parties, including manufacturers, suppliers and other business partners. Those websites have their own privacy practices and policies. We do not control their privacy practices and encourage you to read the relevant policy before submitting personal information to them.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_14',
          type: PrivacyBlockType.heading,
          text: '14. Children\'s Privacy',
        ),
        PrivacyContentBlock(
          id: 'text_block_14',
          type: PrivacyBlockType.paragraph,
          text:
              'Our website and services are intended primarily for businesses and professional users and are not directed at children. We do not knowingly collect personal information from children in circumstances where doing so would be inappropriate or unlawful. If you believe a child has provided personal information to us, please contact us so we can assess and address the matter.',
        ),
        PrivacyContentBlock(
          id: 'rich_text_15',
          type: PrivacyBlockType.heading,
          text: '15. Changes to This Policy',
        ),
        PrivacyContentBlock(
          id: 'text_block_15',
          type: PrivacyBlockType.paragraph,
          text:
              'We may update this Privacy Policy from time to time to reflect changes to our business, website, service providers or legal requirements. The latest version will be published on our website with its updated revision date. We encourage you to review this page periodically.',
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
              'If you have questions about this Privacy Policy, wish to make a privacy request, or want to raise a concern about how personal information is handled, please contact:',
          companyName: 'Vision Infrastructure Canada',
          email: 'sales@visioninfrastructurecanada.com',
          website: 'www.visioninfrastructurecanada.com',
          url: 'https://www.visioninfrastructurecanada.com',
          effectiveDate: 'September 2, 2026',
          regulatoryNotice:
              'We will review privacy enquiries and complaints and respond within a reasonable period, in accordance with applicable law. You may also have the right to lodge a complaint with the relevant privacy regulator in your jurisdiction.',
        ),
        PrivacyContentBlock(
          id: 'text_block_last_updated',
          type: PrivacyBlockType.lastUpdated,
          text:
              'Last updated on September 2, 2026. Vision Infrastructure Canada. All rights reserved.',
        ),
      ],
    );
  }
}
