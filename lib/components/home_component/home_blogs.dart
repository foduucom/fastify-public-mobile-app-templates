import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'home_common_widgets.dart';

class BlogSection extends StatefulWidget {
  final dynamic blogData;

  const BlogSection({Key? key, required this.blogData}) : super(key: key);

  @override
  State<BlogSection> createState() => _BlogSectionState();
}

class _BlogSectionState extends State<BlogSection>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> _blogs = [];
  bool _isLoading = false;
  bool _fetched = false;

  @override
  void initState() {
    super.initState();
    _initBlogsFromData();
    _fetchLiveBlogs();
  }

  @override
  void didUpdateWidget(covariant BlogSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.blogData != widget.blogData) {
      _initBlogsFromData();
    }
  }

  void _initBlogsFromData() {
    if (widget.blogData is Map) {
      final raw = widget.blogData['blogs'];
      if (raw is List && raw.isNotEmpty) {
        _blogs = List.from(raw);
      }
    }
  }

  Future<void> _fetchLiveBlogs() async {
    if (_fetched) return;
    _fetched = true;
    try {
      final response = await BasicProvider('blogs?count=6').getRequest();
      List? fetched;
      if (response is Map) {
        final inner = response['data'];
        if (inner is List) {
          fetched = inner;
        } else if (inner is Map && inner['data'] is List) {
          fetched = inner['data'];
        }
      } else if (response is List) {
        fetched = response;
      }

      if (mounted && fetched != null && fetched.isNotEmpty) {
        setState(() {
          _blogs = fetched!;
        });
      }
    } catch (_) {
      // Retain already loaded blogs from CMS payload
    }
  }

  String _resolveBlogImage(dynamic blog) {
    if (blog is! Map) return '';

    String? tryParseUrl(dynamic value) {
      if (value == null) return null;
      if (value is Map) {
        // 1. Direct download_url / url / src
        for (final key in ['download_url', 'downloadUrl', 'url', 'src']) {
          final val = value[key]?.toString();
          if (val != null && val.isNotEmpty) {
            if (val.startsWith('http://') || val.startsWith('https://')) {
              return _fixDomain(val);
            }
            if (val.startsWith('/')) return '${url}${val.substring(1)}';
            return '${url}$val';
          }
        }
        // 2. filePath / filepath / filename / path
        for (final key in [
          'filePath',
          'filepath',
          'filename',
          'path',
          'file_path'
        ]) {
          final val = value[key]?.toString();
          if (val != null && val.isNotEmpty) {
            if (val.startsWith('http://') || val.startsWith('https://')) {
              return _fixDomain(val);
            }
            if (val.startsWith('/')) return '${url}${val.substring(1)}';
            if (val.startsWith('uploads/') || val.startsWith('images/')) {
              return '${url}$val';
            }
            return '${url}images/$val';
          }
        }
        // HelperFunctions fallback
        final helperImg = HelperFunctions().getImage(value);
        if (helperImg.isNotEmpty && helperImg != HelperFunctions.getNoImage()) {
          return helperImg;
        }
      } else if (value is String && value.isNotEmpty) {
        final str = value.trim();
        if (str.startsWith('http://') || str.startsWith('https://')) {
          return _fixDomain(str);
        }
        // Skip raw mongo IDs
        if (RegExp(r'^[a-f0-9]{24}$').hasMatch(str)) return null;
        if (str.startsWith('/')) return '${url}${str.substring(1)}';
        if (str.startsWith('uploads/') || str.startsWith('images/')) {
          return '${url}$str';
        }
        return '${url}images/$str';
      }
      return null;
    }

    for (final key in [
      'featured_image',
      'featured_image_url',
      'image',
      'image_url',
      'cover_image',
      'thumbnail',
      'banner',
      'banner_image',
    ]) {
      final parsed = tryParseUrl(blog[key]);
      if (parsed != null && parsed.isNotEmpty) {
        return parsed;
      }
    }
    return '';
  }

  String _fixDomain(String imageUrl) {
    if (imageUrl.isEmpty) return imageUrl;
    final uri = Uri.tryParse(imageUrl);
    if (uri == null) return imageUrl;
    if (uri.host.endsWith('.vbought.com') && uri.host != websiteDomain) {
      return imageUrl.replaceFirst(uri.host, websiteDomain);
    }
    return imageUrl;
  }

  String _cleanContent(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    return raw
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '10 Nov 2026';
    try {
      DateTime? dt;
      if (raw is DateTime) {
        dt = raw;
      } else {
        dt = DateTime.tryParse(raw.toString());
      }
      if (dt != null) {
        return DateFormat('d MMM yyyy').format(dt);
      }
    } catch (_) {}
    return '10 Nov 2026';
  }

  Widget _buildEditorialFallback(String blogTitle, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 145,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.85),
            colorScheme.primary,
            const Color(0xFF1E293B),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.article_rounded,
              size: 80,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ARTICLE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Icon(
                  Icons.auto_stories_rounded,
                  size: 24,
                  color: Colors.white.withOpacity(0.9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_blogs.isEmpty) return const SizedBox.shrink();

    final heading = (widget.blogData is Map &&
            (widget.blogData['heading'] ?? '').toString().isNotEmpty)
        ? widget.blogData['heading'].toString()
        : 'Stories Powered by Tech';

    final subheading = (widget.blogData is Map &&
            (widget.blogData['subheading'] ?? '').toString().isNotEmpty)
        ? widget.blogData['subheading'].toString()
        : 'Discover the latest gadgets, smart home trends, and expert reviews designed to upgrade every corner of your digital life.';

    final cardWidth =
        (MediaQuery.of(context).size.width * 0.78).clamp(280.0, 320.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading matching parent website
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: StudioSectionHeader(
              title: heading,
              subtitle: subheading,
              onSeeAll: () {
                Get.toNamed(Routes.BLOG);
              },
            ),
          ),
          const SizedBox(height: 14),

          // Horizontal Snapping Carousel
          SizedBox(
            height: 335,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _blogs.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final blog = _blogs[index];
                if (blog is! Map) return const SizedBox.shrink();

                final blogId = blog['_id'] ?? blog['id'];
                final title = blog['name']?.toString() ??
                    blog['title']?.toString() ??
                    '';
                final rawExcerpt = blog['excerpt']?.toString() ??
                    blog['content']?.toString() ??
                    '';
                final cleanDesc = _cleanContent(rawExcerpt);
                final imageUrl = _resolveBlogImage(blog);
                final dateStr = _formatDate(blog['created_at']);

                return Container(
                  width: cardWidth,
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.12),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (blogId != null) {
                        Get.toNamed(Routes.BLOG_DETAILS,
                            arguments: {'id': blogId, 'blog': blog});
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Article Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15)),
                          child: SizedBox(
                            height: 145,
                            width: double.infinity,
                            child: imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    height: 145,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) =>
                                        _buildEditorialFallback(title, context),
                                    progressIndicatorBuilder: (_, __, ___) =>
                                        HelperFunctions().loadingIndicator(),
                                  )
                                : _buildEditorialFallback(title, context),
                          ),
                        ),

                        // Article Details & Meta
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onSurface,
                                        height: 1.25,
                                      ),
                                    ),
                                    if (cleanDesc.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        cleanDesc,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorScheme.onSurfaceVariant,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),

                                // Footer: Date + "Read more >" dark pill button
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 13,
                                          color: colorScheme.onSurfaceVariant
                                              .withOpacity(0.7),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          dateStr,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text(
                                            'Read more',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(width: 3),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // "EXPLORE MORE BLOG" Blue Pill CTA Button matching parent website
          Center(
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.BLOG);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                'EXPLORE MORE BLOG',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
