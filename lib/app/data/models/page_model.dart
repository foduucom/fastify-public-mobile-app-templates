import 'dart:convert';

class PageResponse {
  final String? status;
  final PageData? data;

  PageResponse({this.status, this.data});

  factory PageResponse.fromJson(Map<String, dynamic> json) {
    return PageResponse(
      status: json['status'] as String?,
      data: json['data'] != null ? PageData.fromJson(Map<String, dynamic>.from(json['data'])) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.toJson(),
    };
  }
}

class PageData {
  final String? id;
  final String? name;
  final String? slug;
  final List<PageComponent> content;
  final String? pageType;
  final String? publishedAt;
  final String? template;
  final String? createdAt;
  final String? updatedAt;

  PageData({
    this.id,
    this.name,
    this.slug,
    required this.content,
    this.pageType,
    this.publishedAt,
    this.template,
    this.createdAt,
    this.updatedAt,
  });

  factory PageData.fromJson(Map<String, dynamic> json) {
    List<PageComponent> parsedContent = [];
    if (json['content'] != null) {
      try {
        dynamic contentRaw = json['content'];
        List<dynamic> contentList = [];
        if (contentRaw is String) {
          contentList = jsonDecode(contentRaw) as List<dynamic>;
        } else if (contentRaw is List) {
          contentList = contentRaw;
        }
        parsedContent = contentList
            .map((e) => PageComponent.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (e) {
        print("Error parsing PageData content field: $e");
      }
    }

    return PageData(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      content: parsedContent,
      pageType: json['page_type'] as String?,
      publishedAt: json['published_at'] as String?,
      template: json['template'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'content': content.map((e) => e.toJson()).toList(),
      'page_type': pageType,
      'published_at': publishedAt,
      'template': template,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class PageComponent {
  final String? id;
  final String? type;
  final Map<String, dynamic> fields;
  final Map<String, dynamic> rawJson;

  PageComponent({
    this.id,
    this.type,
    required this.fields,
    required this.rawJson,
  });

  factory PageComponent.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> extractedFields = {};
    if (json['fields'] != null && json['fields'] is Map) {
      extractedFields = Map<String, dynamic>.from(json['fields']);
    } else if (json['data'] != null && json['data'] is Map) {
      extractedFields = Map<String, dynamic>.from(json['data']);
    } else {
      // Fallback: put everything except id and type in fields
      json.forEach((key, value) {
        if (key != 'id' && key != '_id' && key != 'type') {
          extractedFields[key] = value;
        }
      });
    }

    return PageComponent(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      type: json['type'] as String?,
      fields: extractedFields,
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() {
    return rawJson;
  }
}
