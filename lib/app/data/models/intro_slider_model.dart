import '../../../constants/constants.dart';

class IntroSliderResponse {
  final String? status;
  final IntroSliderData? data;

  IntroSliderResponse({this.status, this.data});

  factory IntroSliderResponse.fromJson(Map<dynamic, dynamic> json) {
    Map<dynamic, dynamic>? dataMap;
    if (json['data'] is Map) {
      dataMap = json['data'] as Map;
    } else if (json['content'] is List) {
      // BasicProvider automatically unwraps responseBody["data"]
      dataMap = json;
    }

    return IntroSliderResponse(
      status: json['status']?.toString() ?? 'success',
      data: dataMap != null ? IntroSliderData.fromJson(dataMap) : null,
    );
  }
}

class IntroSliderData {
  final String? id;
  final String? name;
  final String? slug;
  final String? view;
  final List<IntroSlideItem> content;

  IntroSliderData({
    this.id,
    this.name,
    this.slug,
    this.view,
    required this.content,
  });

  factory IntroSliderData.fromJson(Map<dynamic, dynamic> json) {
    List<IntroSlideItem> items = [];
    if (json['content'] is List) {
      items = (json['content'] as List)
          .whereType<Map>()
          .map((item) => IntroSlideItem.fromJson(item))
          .toList();
    }
    return IntroSliderData(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name']?.toString(),
      slug: json['slug']?.toString(),
      view: json['view']?.toString(),
      content: items,
    );
  }
}

class IntroSlideItem {
  final String heading;
  final String subHeading;
  final String description;
  final String link;
  final String buttonText;
  final int order;
  final String imageId;
  final String filePath;
  final int size;
  final String altText;
  final bool isAsset;

  IntroSlideItem({
    this.heading = '',
    this.subHeading = '',
    this.description = '',
    this.link = '',
    this.buttonText = '',
    this.order = 0,
    this.imageId = '',
    this.filePath = '',
    this.size = 0,
    this.altText = '',
    this.isAsset = false,
  });

  factory IntroSlideItem.fromJson(Map<dynamic, dynamic> json) {
    return IntroSlideItem(
      heading: json['heading']?.toString() ?? '',
      subHeading: json['sub_heading']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
      buttonText: json['button_text']?.toString() ?? '',
      order: json['order'] is int
          ? json['order'] as int
          : int.tryParse(json['order']?.toString() ?? '0') ?? 0,
      imageId: json['imageId']?.toString() ?? '',
      filePath: json['filePath']?.toString() ?? '',
      size: json['size'] is int
          ? json['size'] as int
          : int.tryParse(json['size']?.toString() ?? '0') ?? 0,
      altText: json['alt_text']?.toString() ?? '',
      isAsset: false,
    );
  }

  factory IntroSlideItem.fromAsset({
    required String assetPath,
    required String description,
    String heading = '',
    String buttonText = 'Skip',
    int order = 0,
  }) {
    return IntroSlideItem(
      filePath: assetPath,
      description: description,
      heading: heading,
      buttonText: buttonText,
      order: order,
      isAsset: true,
    );
  }

  /// Resolves the absolute image URL using `assetURL`
  String get fullImageUrl {
    if (isAsset || filePath.isEmpty) return filePath;
    if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
      return filePath;
    }
    final cleanPath = filePath.startsWith('/') ? filePath.substring(1) : filePath;
    return '$assetURL$cleanPath';
  }
}
