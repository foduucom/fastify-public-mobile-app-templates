import 'package:foduu_ecommerce/models/blog_model.dart';

String _str(dynamic v) => (v ?? '').toString().trim();

/// Normalizes raw CMS blog category/tag names (e.g. "others" -> "Tech Guides").
String normalizeBlogCategory(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  final lower = trimmed.toLowerCase();
  if (lower == 'others' || lower == 'other') return 'Tech Guides';
  return trimmed;
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 1. Blog Hero Header (Top Slider: slug "blog-slider", heading "Blog")
/// ─────────────────────────────────────────────────────────────────────────────
class BlogHeroHeaderData {
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;
  final double height;

  const BlogHeroHeaderData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
    this.height = 200,
  });

  static const String defaultTitle = 'Blog';
  static const String defaultSubtitle = 'Stories Powered by Tech';
  static const String defaultDescription =
      'Discover the latest gadgets, smart home trends, and expert reviews designed to upgrade every corner of your digital life.';
  static const String defaultImage = '2026/11/17/appliance-lineup-5343cd2f.webp';

  factory BlogHeroHeaderData.fallback() {
    return const BlogHeroHeaderData(
      title: defaultTitle,
      subtitle: defaultSubtitle,
      description: defaultDescription,
      imagePath: defaultImage,
      height: 200,
    );
  }

  factory BlogHeroHeaderData.fromMap(Map<String, dynamic>? json) {
    if (json == null) return BlogHeroHeaderData.fallback();
    final slider = json['slider'] is Map ? json['slider'] as Map : json;
    final content = slider['content'];
    final heightVal = (json['height'] as num?)?.toDouble() ?? 200.0;

    if (content is List && content.isNotEmpty && content.first is Map) {
      final first = content.first as Map;
      return BlogHeroHeaderData(
        title: _str(first['heading']).isNotEmpty
            ? _str(first['heading'])
            : defaultTitle,
        subtitle: _str(first['sub_heading']).isNotEmpty
            ? _str(first['sub_heading'])
            : defaultSubtitle,
        description: _str(first['description']).isNotEmpty
            ? _str(first['description'])
            : defaultDescription,
        imagePath: _str(first['filePath'] ??
                    first['download_url'] ??
                    first['filepath'] ??
                    first['url'])
                .isNotEmpty
            ? _str(first['filePath'] ??
                first['download_url'] ??
                first['filepath'] ??
                first['url'])
            : defaultImage,
        height: heightVal,
      );
    }
    return BlogHeroHeaderData.fallback();
  }

  factory BlogHeroHeaderData.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'slider' || s['id'] == 'slider') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        final slider = cj['slider'] is Map ? cj['slider'] as Map : cj;
        final slug = _str(slider['slug'] ?? slider['name']).toLowerCase();
        if (slug == 'blog-slider' ||
            slug == 'blog' ||
            slug.contains('blog-hero')) {
          return BlogHeroHeaderData.fromMap(cj);
        }
      }
    }
    return BlogHeroHeaderData.fallback();
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 2. Blog Search Bar Data
/// ─────────────────────────────────────────────────────────────────────────────
class BlogSearchSectionData {
  final String name;
  final String placeholder;

  const BlogSearchSectionData({
    required this.name,
    required this.placeholder,
  });

  static const String defaultPlaceholder =
      'Search articles, guides and reviews';

  factory BlogSearchSectionData.fallback() {
    return const BlogSearchSectionData(
      name: 'Search',
      placeholder: defaultPlaceholder,
    );
  }

  factory BlogSearchSectionData.fromMap(Map<String, dynamic>? json) {
    if (json == null) return BlogSearchSectionData.fallback();
    return BlogSearchSectionData(
      name: _str(json['name']).isNotEmpty ? _str(json['name']) : 'Search',
      placeholder: _str(json['placeholder']).isNotEmpty
          ? _str(json['placeholder'])
          : defaultPlaceholder,
    );
  }

  factory BlogSearchSectionData.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'search' || s['id'] == 'search') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        return BlogSearchSectionData.fromMap(cj);
      }
    }
    return BlogSearchSectionData.fallback();
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 3. Blog Category Item
/// ─────────────────────────────────────────────────────────────────────────────
class BlogCategoryItem {
  final String id;
  final String name;
  final String slug;

  const BlogCategoryItem({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory BlogCategoryItem.fromJson(Map<String, dynamic> json) {
    return BlogCategoryItem(
      id: _str(json['_id'] ?? json['id']),
      name: normalizeBlogCategory(_str(json['name'])),
      slug: _str(json['slug']),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 4. Blog Feed Section Data (Categories + Articles)
/// ─────────────────────────────────────────────────────────────────────────────
class BlogFeedSectionData {
  final String title;
  final String subtitle;
  final String blogType;
  final int noOfBlog;
  final List<BlogCategoryItem> categories;
  final List<BlogModel> blogs;

  const BlogFeedSectionData({
    this.title = 'Our Latest Blog Posts',
    this.subtitle =
        'Explore in-depth articles, buying guides, and technical breakdowns.',
    required this.blogType,
    required this.noOfBlog,
    required this.categories,
    required this.blogs,
  });

  static List<BlogCategoryItem> get defaultCategories => const [
        BlogCategoryItem(
            id: '6af2a6985378860472ebf280', name: 'Gaming', slug: 'gaming-1'),
        BlogCategoryItem(
            id: '6af2a6985378860472ebf27e',
            name: 'Audio Tech',
            slug: 'audio-tech'),
        BlogCategoryItem(
            id: '6af2a6985378860472ebf27c',
            name: 'Smart Living',
            slug: 'smart-living'),
      ];

  factory BlogFeedSectionData.fallback() {
    return BlogFeedSectionData(
      title: 'Our Latest Blog Posts',
      subtitle:
          'Explore in-depth articles, buying guides, and technical breakdowns.',
      blogType: 'blog_category',
      noOfBlog: 100,
      categories: defaultCategories,
      blogs: const [],
    );
  }

  factory BlogFeedSectionData.fromMap(Map<String, dynamic>? json) {
    if (json == null) return BlogFeedSectionData.fallback();

    final catsRaw = json['category_ids'];
    final cats = <BlogCategoryItem>[];
    if (catsRaw is List) {
      for (final c in catsRaw) {
        if (c is Map) {
          cats.add(BlogCategoryItem.fromJson(Map<String, dynamic>.from(c)));
        }
      }
    }

    final blogsRaw = json['blogs'];
    final blogsList = <BlogModel>[];
    if (blogsRaw is List) {
      for (final b in blogsRaw) {
        if (b is Map) {
          try {
            blogsList.add(BlogModel.fromJson(Map<String, dynamic>.from(b)));
          } catch (_) {}
        }
      }
    }

    final title = _str(json['title'] ?? json['heading']);
    final subtitle = _str(json['subtitle'] ?? json['subheading']);

    return BlogFeedSectionData(
      title: title.isNotEmpty ? title : 'Our Latest Blog Posts',
      subtitle: subtitle.isNotEmpty
          ? subtitle
          : 'Explore in-depth articles, buying guides, and technical breakdowns.',
      blogType: _str(json['blog_type']).isNotEmpty
          ? _str(json['blog_type'])
          : 'blog_category',
      noOfBlog: (json['no_of_blog'] as num?)?.toInt() ?? 100,
      categories: cats.isNotEmpty ? cats : defaultCategories,
      blogs: blogsList,
    );
  }

  factory BlogFeedSectionData.fromSections(List sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      if (s['type'] == 'blog' || s['id'] == 'blog') {
        final cj = s['content_json'] is Map
            ? Map<String, dynamic>.from(s['content_json'])
            : <String, dynamic>{};
        return BlogFeedSectionData.fromMap(cj);
      }
    }
    return BlogFeedSectionData.fallback();
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 5. Root Blog Broadcast Sections Data (Complete Canonical Layout)
/// ─────────────────────────────────────────────────────────────────────────────
class BlogBroadcastSectionsData {
  final BlogHeroHeaderData heroHeader;
  final BlogSearchSectionData search;
  final String categoryTitle;
  final BlogFeedSectionData feed;

  const BlogBroadcastSectionsData({
    required this.heroHeader,
    required this.search,
    required this.categoryTitle,
    required this.feed,
  });

  factory BlogBroadcastSectionsData.canonical() {
    return BlogBroadcastSectionsData(
      heroHeader: BlogHeroHeaderData.fallback(),
      search: BlogSearchSectionData.fallback(),
      categoryTitle: 'Browse Categories',
      feed: BlogFeedSectionData.fallback(),
    );
  }

  factory BlogBroadcastSectionsData.fromSections(List sections) {
    var hero = BlogHeroHeaderData.fallback();
    var search = BlogSearchSectionData.fallback();
    var categoryTitle = 'Browse Categories';
    var feed = BlogFeedSectionData.fallback();

    for (final s in sections) {
      if (s is! Map) continue;
      final type = _str(s['type']);
      final id = _str(s['id']);
      final cj = s['content_json'] is Map
          ? Map<String, dynamic>.from(s['content_json'])
          : <String, dynamic>{};

      if (type == 'slider' || id == 'slider') {
        hero = BlogHeroHeaderData.fromMap(cj);
      } else if (type == 'search' || id == 'search') {
        search = BlogSearchSectionData.fromMap(cj);
      } else if (type == 'text_block' || id == 'text_block') {
        final t = _str(cj['text'] ?? cj['title']);
        if (t.isNotEmpty) categoryTitle = t;
      } else if (type == 'blog' || id == 'blog') {
        feed = BlogFeedSectionData.fromMap(cj);
      }
    }

    return BlogBroadcastSectionsData(
      heroHeader: hero,
      search: search,
      categoryTitle: categoryTitle,
      feed: feed,
    );
  }
}
