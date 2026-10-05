import 'package:intl/intl.dart';
import '../constants/helper_functions.dart';

class BlogModel {
  final String id;
  final String title;
  final String slug;
  final String content;
  final String excerpt;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isFeatured;
  final BlogAuthor? author;
  final List<String> categories;
  final List<String> tags;
  final int commentsCount;

  BlogModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.excerpt,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.isFeatured = false,
    this.author,
    this.categories = const [],
    this.tags = const [],
    this.commentsCount = 0,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    // Extract Image URL safely from either featured_image_url or nested featured_image object
    // Resolve through HelperFunctions so relative paths get the app's image
    // base URL and *.vbought.com hosts are rewritten to websiteDomain.
    final noImage = HelperFunctions.getNoImage();
    String? resolvedImageUrl;
    for (final source in [json['featured_image'], json['featured_image_url']]) {
      if (source == null) continue;
      final resolved = HelperFunctions().getImage(source);
      if (resolved.isNotEmpty && resolved != noImage) {
        resolvedImageUrl = resolved;
        break;
      }
    }

    // Parse author
    BlogAuthor? resolvedAuthor;
    if (json['owner_id'] is Map) {
      resolvedAuthor =
          BlogAuthor.fromJson(Map<String, dynamic>.from(json['owner_id']));
    }

    // Parse created date
    DateTime? parsedDate;
    if (json['created_at'] != null) {
      parsedDate = DateTime.tryParse(json['created_at'].toString());
    }

    // Parse updated date
    DateTime? parsedUpdatedDate;
    if (json['updated_at'] != null) {
      parsedUpdatedDate = DateTime.tryParse(json['updated_at'].toString());
    }

    // Parse tags & categories
    final rawTags = json['tags'];
    List<String> tagsList = [];
    if (rawTags is List) {
      tagsList = rawTags
          .map((e) => e is Map ? (e['name'] ?? '').toString() : e.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    final rawCategories = json['categories'];
    List<String> categoriesList = [];
    if (rawCategories is List) {
      categoriesList = rawCategories
          .map((e) => e is Map ? (e['name'] ?? '').toString() : e.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return BlogModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['name'] ?? json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      excerpt: (json['excerpt'] ?? '').toString(),
      imageUrl: resolvedImageUrl,
      createdAt: parsedDate,
      updatedAt: parsedUpdatedDate,
      isFeatured: json['featured'] == true,
      author: resolvedAuthor,
      categories: categoriesList,
      tags: tagsList,
      commentsCount: 0,
    );
  }

  /// Formatted long date matching parent website detail page: e.g. "03 August 2026"
  String get formattedDate {
    if (createdAt == null) return '';
    try {
      return DateFormat('dd MMMM yyyy').format(createdAt!);
    } catch (_) {
      return '';
    }
  }

  /// Formatted short date matching parent website card: e.g. "Aug 3, 2026"
  String get shortDate {
    if (createdAt == null) return '';
    try {
      return DateFormat('MMM d, yyyy').format(createdAt!);
    } catch (_) {
      return '';
    }
  }

  /// Plain text summary stripped of HTML tags
  String get cleanExcerpt {
    final raw = excerpt.isNotEmpty ? excerpt : content;
    final clean = raw.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
    return clean.replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Estimated reading time in minutes (assuming 200 wpm)
  String get readingTime {
    final raw = cleanExcerpt;
    final words = raw.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final minutes = (words / 200).ceil();
    return '${minutes > 0 ? minutes : 1} min read';
  }

  /// Author display name fallback
  String get authorName {
    if (author != null && author!.fullName.isNotEmpty) {
      return author!.fullName;
    }
    return 'Admin';
  }
}

class BlogAuthor {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  BlogAuthor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory BlogAuthor.fromJson(Map<String, dynamic> json) {
    return BlogAuthor(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : 'Admin';
  }
}

class BlogPagination {
  final int total;
  final int perPage;
  final int lastPage;
  final int currentPage;
  final bool hasNextPage;
  final bool hasPrevPage;

  BlogPagination({
    required this.total,
    required this.perPage,
    required this.lastPage,
    required this.currentPage,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory BlogPagination.fromJson(Map<String, dynamic> json) {
    return BlogPagination(
      total: (json['total'] as num?)?.toInt() ?? 0,
      perPage: (json['per_page'] as num?)?.toInt() ?? 20,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      hasNextPage: json['hasNextPage'] == true,
      hasPrevPage: json['hasPrevPage'] == true,
    );
  }
}
