import 'package:zouhi/constants/constants.dart';

String _cleanUrl(dynamic val) {
  if (val == null) return '';
  final str = val.toString().trim();
  if (str.isEmpty) return '';
  if (str.startsWith('http://') || str.startsWith('https://')) {
    // Rewrite internal hex subdomains to live CDN host if needed
    if (str.contains('.foduu.store/images/')) {
      return str.replaceFirst(
          RegExp(r'https?://[a-f0-9]+\.foduu\.store/images/'),
          'https://vision.foduu.store/images/');
    }
    return str;
  }
  if (str.startsWith('//')) return 'https:$str';
  final normalized = str.startsWith('/') ? str.substring(1) : str;
  if (normalized.startsWith('images/')) {
    return '$url$normalized';
  }
  return '$assetURL$normalized';
}

/// Section 1: Top Engineering Schematic Banner
class MtpSolutionBannerData {
  final String imageUrl;
  final String altText;
  final double borderRadius;
  final double height;
  final String linkSlug;

  const MtpSolutionBannerData({
    required this.imageUrl,
    this.altText = 'MTP Solution Schematic Banner',
    this.borderRadius = 8,
    this.height = 200,
    this.linkSlug = 'mtp-solution',
  });

  factory MtpSolutionBannerData.fromContentJson(Map<String, dynamic> json) {
    String img = '';
    String alt = 'MTP Solution Schematic Banner';
    double radius = 8.0;
    double h = 200.0;
    String slug = 'mtp-solution';

    final banners = json['banners'];
    if (banners is List && banners.isNotEmpty) {
      final b0 = banners.first;
      if (b0 is Map<String, dynamic>) {
        final config = b0['config'];
        if (config is Map) {
          if (config['border_radius'] != null) {
            radius =
                double.tryParse(config['border_radius'].toString()) ?? 8.0;
          }
          if (config['height'] != null) {
            h = double.tryParse(config['height'].toString()) ?? 200.0;
          }
        }

        final items = b0['items'];
        if (items is List && items.isNotEmpty) {
          final item0 = items.first;
          if (item0 is Map<String, dynamic>) {
            final link = item0['link'];
            if (link is Map && link['value'] != null) {
              slug = link['value'].toString().trim();
            }

            final featuredImage = item0['featured_image'];
            if (featuredImage is Map) {
              final rawUrl = featuredImage['download_url'] ??
                  featuredImage['filepath'] ??
                  featuredImage['filename'];
              if (rawUrl != null && rawUrl.toString().trim().isNotEmpty) {
                img = _cleanUrl(rawUrl);
              }
              if (featuredImage['alt_text'] != null) {
                alt = featuredImage['alt_text'].toString().trim();
              }
            }
          }
        }
      }
    }

    return MtpSolutionBannerData(
      imageUrl: img.isNotEmpty ? img : 'assets/images/mtp-lead.webp',
      altText: alt,
      borderRadius: radius,
      height: h,
      linkSlug: slug,
    );
  }

  factory MtpSolutionBannerData.canonical() => const MtpSolutionBannerData(
        imageUrl: 'assets/images/mtp-lead.webp',
        altText: 'MTP Solution Schematic Banner',
        borderRadius: 8,
        height: 200,
        linkSlug: 'mtp-solution',
      );
}

/// Section 2: Inspection Prompt Text Block
class MtpSolutionTextBlockData {
  final String text;
  final double size;
  final String weight;
  final String alignment;
  final String color;

  const MtpSolutionTextBlockData({
    required this.text,
    this.size = 14,
    this.weight = 'normal',
    this.alignment = 'left',
    this.color = '#000000',
  });

  factory MtpSolutionTextBlockData.fromContentJson(Map<String, dynamic> json) {
    return MtpSolutionTextBlockData(
      text: json['text']?.toString().trim() ??
          'Tap schematic to inspect detailed MTP pinout, polarity & specifications',
      size: double.tryParse(json['size']?.toString() ?? '14') ?? 14,
      weight: json['weight']?.toString().trim() ?? 'normal',
      alignment: json['alignment']?.toString().trim() ?? 'left',
      color: json['color']?.toString().trim() ?? '#000000',
    );
  }

  factory MtpSolutionTextBlockData.canonical() =>
      const MtpSolutionTextBlockData(
        text:
            'Tap schematic to inspect detailed MTP pinout, polarity & specifications',
        size: 14,
        weight: 'normal',
        alignment: 'left',
        color: '#000000',
      );
}

/// Section 3: FormBuilder Descriptor
class MtpSolutionFormBuilderData {
  final String formId;
  final String formSlug;
  final String formLabel;
  final String title;

  const MtpSolutionFormBuilderData({
    required this.formId,
    required this.formSlug,
    required this.formLabel,
    required this.title,
  });

  factory MtpSolutionFormBuilderData.fromContentJson(Map<String, dynamic> json) {
    String id = 'mtp-solution';
    String slug = 'mtp-solution';
    String label = 'MTP Solution Form';

    final formIdObj = json['form_id'];
    if (formIdObj is Map) {
      id = formIdObj['value']?.toString().trim() ?? id;
      slug = formIdObj['slug']?.toString().trim() ?? slug;
      label = formIdObj['label']?.toString().trim() ?? label;
    }

    final title = json['title']?.toString().trim() ?? 'MTP Solution Configurator';

    return MtpSolutionFormBuilderData(
      formId: id,
      formSlug: slug.isNotEmpty ? slug : 'mtp-solution',
      formLabel: label,
      title: title,
    );
  }

  factory MtpSolutionFormBuilderData.canonical() =>
      const MtpSolutionFormBuilderData(
        formId: 'mtp-solution',
        formSlug: 'mtp-solution',
        formLabel: 'MTP Solution Form',
        title: 'MTP Solution Configurator',
      );
}

/// Section 4: Rich Text Specifications & Standards Note
class MtpSolutionRichTextData {
  final String htmlContent;

  const MtpSolutionRichTextData({required this.htmlContent});

  factory MtpSolutionRichTextData.fromContentJson(Map<String, dynamic> json) {
    return MtpSolutionRichTextData(
      htmlContent: json['html_content']?.toString().trim() ??
          _defaultTechnicalNotes,
    );
  }

  factory MtpSolutionRichTextData.canonical() =>
      const MtpSolutionRichTextData(
        htmlContent: _defaultTechnicalNotes,
      );

  static const String _defaultTechnicalNotes =
      'Note:MTP Polarity Specifications:- Polarity A (Key Up to Key Down): Straight through Pin 1 to Pin 1- Polarity B (Key Up to Key Up): Cross over Pin 1 to Pin 12- Polarity C (Key Up to Key Down): Cross pair Pin 1 to Pin 2Jacket Standard Colours:- OM1: Orange- OM3: Aqua- OM4: Erika Violet / Magenta- OM5: Lime Green- OS2: YellowTechnical Criteria:- Drum recommended for lengths in excess of 40m- Connectors available in US Conec MTP Elite low-loss formats (Male with guide pins, Female without pins)';

  List<String> get bulletPoints {
    if (htmlContent.isEmpty) return [];

    final clean = htmlContent
        .replaceAll('Note:', '')
        .replaceAll('MTP Polarity Specifications:', 'MTP Polarity Specifications:\n')
        .replaceAll('Jacket Standard Colours:', '\nJacket Standard Colours:\n')
        .replaceAll('Technical Criteria:', '\nTechnical Criteria:\n');

    final parts = clean
        .split('- ')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return parts;
  }
}

/// Master Container for MTP Solution Dynamic Sections
class MtpSolutionSectionsData {
  final MtpSolutionBannerData banner;
  final MtpSolutionTextBlockData textBlock;
  final MtpSolutionFormBuilderData formBuilder;
  final MtpSolutionRichTextData richText;

  const MtpSolutionSectionsData({
    required this.banner,
    required this.textBlock,
    required this.formBuilder,
    required this.richText,
  });

  factory MtpSolutionSectionsData.fromSections(List sections) {
    MtpSolutionBannerData? banner;
    MtpSolutionTextBlockData? textBlock;
    MtpSolutionFormBuilderData? formBuilder;
    MtpSolutionRichTextData? richText;

    for (final raw in sections) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final type = map['type']?.toString().trim().toLowerCase() ?? '';
      final content = map['content_json'];
      final contentJson =
          content is Map ? Map<String, dynamic>.from(content) : <String, dynamic>{};

      switch (type) {
        case 'banner':
          banner = MtpSolutionBannerData.fromContentJson(contentJson);
          break;
        case 'text_block':
          textBlock = MtpSolutionTextBlockData.fromContentJson(contentJson);
          break;
        case 'formbuilder':
          formBuilder =
              MtpSolutionFormBuilderData.fromContentJson(contentJson);
          break;
        case 'rich_text':
          richText = MtpSolutionRichTextData.fromContentJson(contentJson);
          break;
      }
    }

    return MtpSolutionSectionsData(
      banner: banner ?? MtpSolutionBannerData.canonical(),
      textBlock: textBlock ?? MtpSolutionTextBlockData.canonical(),
      formBuilder: formBuilder ?? MtpSolutionFormBuilderData.canonical(),
      richText: richText ?? MtpSolutionRichTextData.canonical(),
    );
  }

  factory MtpSolutionSectionsData.canonical() => MtpSolutionSectionsData(
        banner: MtpSolutionBannerData.canonical(),
        textBlock: MtpSolutionTextBlockData.canonical(),
        formBuilder: MtpSolutionFormBuilderData.canonical(),
        richText: MtpSolutionRichTextData.canonical(),
      );
}
