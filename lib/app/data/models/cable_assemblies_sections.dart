import 'package:zouhi/constants/constants.dart';

String _cleanUrl(dynamic val) {
  if (val == null) return '';
  final str = val.toString().trim();
  if (str.isEmpty) return '';
  if (str.startsWith('http://') || str.startsWith('https://')) return str;
  if (str.startsWith('//')) return 'https:$str';
  final normalized = str.startsWith('/') ? str.substring(1) : str;
  if (normalized.startsWith('images/')) {
    return '$url$normalized';
  }
  return '$assetURL$normalized';
}

/// Section 1: Top Engineering Schematic Banner
class CableAssembliesBannerData {
  final String imageUrl;
  final String altText;
  final double borderRadius;
  final double height;
  final String linkSlug;

  const CableAssembliesBannerData({
    required this.imageUrl,
    this.altText = 'Cable Assembler Banner Image',
    this.borderRadius = 12,
    this.height = 200,
    this.linkSlug = 'cable-assemblies',
  });

  factory CableAssembliesBannerData.fromContentJson(Map<String, dynamic> json) {
    String img =
        'https://6a92a52778a2a51e604f819d.foduu.store/images/2026/10/23/cable-assembler-banner-image-361c9f57.webp';
    String alt = 'Cable Assembler Banner Image';
    double radius = 12.0;
    double h = 200.0;
    String slug = 'cable-assemblies';

    final banners = json['banners'];
    if (banners is List && banners.isNotEmpty) {
      final b0 = banners.first;
      if (b0 is Map<String, dynamic>) {
        final config = b0['config'];
        if (config is Map) {
          if (config['border_radius'] != null) {
            radius = double.tryParse(config['border_radius'].toString()) ?? 12.0;
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

    return CableAssembliesBannerData(
      imageUrl: img,
      altText: alt,
      borderRadius: radius,
      height: h,
      linkSlug: slug,
    );
  }

  factory CableAssembliesBannerData.canonical() => const CableAssembliesBannerData(
        imageUrl:
            'https://6a92a52778a2a51e604f819d.foduu.store/images/2026/10/23/cable-assembler-banner-image-361c9f57.webp',
        altText: 'Cable Assembler Banner Image',
        borderRadius: 12,
        height: 200,
        linkSlug: 'cable-assemblies',
      );
}

/// Section 2: Inspection Text Block
class CableAssembliesTextBlockData {
  final String text;
  final double size;
  final String weight;
  final String alignment;
  final String color;

  const CableAssembliesTextBlockData({
    required this.text,
    this.size = 16,
    this.weight = 'normal',
    this.alignment = 'left',
    this.color = '#000000',
  });

  factory CableAssembliesTextBlockData.fromContentJson(
      Map<String, dynamic> json) {
    return CableAssembliesTextBlockData(
      text: json['text']?.toString().trim() ??
          'Tap to inspect detailed pinout & schematic',
      size: double.tryParse(json['size']?.toString() ?? '16') ?? 16,
      weight: json['weight']?.toString().trim() ?? 'normal',
      alignment: json['alignment']?.toString().trim() ?? 'left',
      color: json['color']?.toString().trim() ?? '#000000',
    );
  }

  factory CableAssembliesTextBlockData.canonical() =>
      const CableAssembliesTextBlockData(
        text: 'Tap to inspect detailed pinout & schematic',
        size: 16,
        weight: 'normal',
        alignment: 'left',
        color: '#000000',
      );
}

/// Section 3: FormBuilder Descriptor
class CableAssembliesFormBuilderData {
  final String formId;
  final String formSlug;
  final String formLabel;
  final String title;

  const CableAssembliesFormBuilderData({
    required this.formId,
    required this.formSlug,
    required this.formLabel,
    required this.title,
  });

  factory CableAssembliesFormBuilderData.fromContentJson(
      Map<String, dynamic> json) {
    String id = '6ad31adad6faba0e1ea233a8';
    String slug = 'cable-form';
    String label = 'Cable Form';

    final formIdObj = json['form_id'];
    if (formIdObj is Map) {
      id = formIdObj['value']?.toString().trim() ?? id;
      slug = formIdObj['slug']?.toString().trim() ?? slug;
      label = formIdObj['label']?.toString().trim() ?? label;
    }

    final title = json['title']?.toString().trim() ?? 'Cable Assemblies Form';

    return CableAssembliesFormBuilderData(
      formId: id,
      formSlug: slug.isNotEmpty ? slug : 'cable-form',
      formLabel: label,
      title: title,
    );
  }

  factory CableAssembliesFormBuilderData.canonical() =>
      const CableAssembliesFormBuilderData(
        formId: '6ad31adad6faba0e1ea233a8',
        formSlug: 'cable-form',
        formLabel: 'Cable Form',
        title: 'Cable Assemblies Form',
      );
}

/// Section 4: Rich Text Specifications & Standards Note
class CableAssembliesRichTextData {
  final String htmlContent;

  const CableAssembliesRichTextData({required this.htmlContent});

  factory CableAssembliesRichTextData.fromContentJson(
      Map<String, dynamic> json) {
    return CableAssembliesRichTextData(
      htmlContent: json['html_content']?.toString().trim() ??
          _defaultTechnicalNotes,
    );
  }

  factory CableAssembliesRichTextData.canonical() =>
      const CableAssembliesRichTextData(
        htmlContent: _defaultTechnicalNotes,
      );

  static const String _defaultTechnicalNotes =
      'Note:Oversheath Standard Colours:- OM1: Orange- OM3/4/5: Aqua- OS2: YellowCable Standard Colours:- Fire Rated: Red- Staggered connectors are paired and spaced 40mm apart- Cable Length: Measured from end of connector A End to end of connector B End- Drum recommended for lengths in excess of 40m- Breakout length is measured from breakout point to longest staggered connector';

  List<String> get bulletPoints {
    if (htmlContent.isEmpty) return [];

    // Format clean readable bullet points from backend string
    // e.g. "Note:Oversheath Standard Colours:- OM1: Orange- OM3/4/5: Aqua- OS2: YellowCable Standard Colours:- Fire Rated: Red- Staggered connectors are paired and spaced 40mm apart- Cable Length: Measured from end of connector A End to end of connector B End- Drum recommended for lengths in excess of 40m- Breakout length is measured from breakout point to longest staggered connector"
    final clean = htmlContent
        .replaceAll('Note:', '')
        .replaceAll('Oversheath Standard Colours:', 'Oversheath Standard Colours:\n')
        .replaceAll('Cable Standard Colours:', '\nCable Standard Colours:\n');

    final parts = clean
        .split('- ')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return parts;
  }
}

/// Master Container for Cable Assemblies Dynamic Sections
class CableAssembliesSectionsData {
  final CableAssembliesBannerData banner;
  final CableAssembliesTextBlockData textBlock;
  final CableAssembliesFormBuilderData formBuilder;
  final CableAssembliesRichTextData richText;

  const CableAssembliesSectionsData({
    required this.banner,
    required this.textBlock,
    required this.formBuilder,
    required this.richText,
  });

  factory CableAssembliesSectionsData.fromSections(List sections) {
    CableAssembliesBannerData? banner;
    CableAssembliesTextBlockData? textBlock;
    CableAssembliesFormBuilderData? formBuilder;
    CableAssembliesRichTextData? richText;

    for (final raw in sections) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final type = map['type']?.toString().trim().toLowerCase() ?? '';
      final content = map['content_json'];
      final contentJson =
          content is Map ? Map<String, dynamic>.from(content) : <String, dynamic>{};

      switch (type) {
        case 'banner':
          banner = CableAssembliesBannerData.fromContentJson(contentJson);
          break;
        case 'text_block':
          textBlock = CableAssembliesTextBlockData.fromContentJson(contentJson);
          break;
        case 'formbuilder':
          formBuilder =
              CableAssembliesFormBuilderData.fromContentJson(contentJson);
          break;
        case 'rich_text':
          richText = CableAssembliesRichTextData.fromContentJson(contentJson);
          break;
      }
    }

    return CableAssembliesSectionsData(
      banner: banner ?? CableAssembliesBannerData.canonical(),
      textBlock: textBlock ?? CableAssembliesTextBlockData.canonical(),
      formBuilder: formBuilder ?? CableAssembliesFormBuilderData.canonical(),
      richText: richText ?? CableAssembliesRichTextData.canonical(),
    );
  }

  factory CableAssembliesSectionsData.canonical() => CableAssembliesSectionsData(
        banner: CableAssembliesBannerData.canonical(),
        textBlock: CableAssembliesTextBlockData.canonical(),
        formBuilder: CableAssembliesFormBuilderData.canonical(),
        richText: CableAssembliesRichTextData.canonical(),
      );
}
