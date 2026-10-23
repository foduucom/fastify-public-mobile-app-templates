import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

class BlogCard extends StatelessWidget {
  final dynamic blog;
  final VoidCallback? onTap;

  const BlogCard({
    Key? key,
    required this.blog,
    this.onTap,
  }) : super(key: key);

  String _cleanContent(dynamic content) {
    if (content == null) return '';
    String str = content.toString();
    str = str.replaceAll(RegExp(r'<[^>]*>'), '');
    str = str
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"');
    return str.trim();
  }

  String _formatDate(dynamic blog) {
    if (blog is! Map) return '';
    final rawDate = blog['createdAt'] ??
        blog['created_at'] ??
        blog['date'] ??
        blog['published_at'] ??
        blog['updatedAt'];
    if (rawDate == null) return '';
    try {
      final dt = DateTime.parse(rawDate.toString());
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (blog == null || blog is! Map) return const SizedBox.shrink();

    final String title = blog['name']?.toString() ?? '';
    final String contentExcerpt = _cleanContent(blog['content']);
    final String imageUrl = HelperFunctions().getImage(blog['featured_image']);
    final String blogId = blog['_id']?.toString() ?? '';
    final String date = _formatDate(blog);

    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      child: Container(
        decoration: BoxDecoration(
          color: context.themeWhiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.themeBorderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap ??
                () {
                  if (blogId.isNotEmpty) {
                    Get.toNamed(Routes.BLOGDETAILS, arguments: {'id': blogId});
                  }
                },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: 145,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        memCacheWidth:
                            (240 * MediaQuery.of(context).devicePixelRatio).round(),
                        memCacheHeight:
                            (145 * MediaQuery.of(context).devicePixelRatio).round(),
                        placeholder: (context, url) => Container(
                          height: 145,
                          color: context.themegreyColor,
                          child: HelperFunctions().loadingIndicator(),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 145,
                          color: context.themegreyColor,
                          child: const Center(
                            child: Icon(Icons.image_not_supported_outlined,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    if (date.isNotEmpty)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 10,
                                color: context.themePrimaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: context.themePrimaryDark,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: context.themeTextColor,
                          height: 1.25,
                        ),
                      ),
                      if (contentExcerpt.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          contentExcerpt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            color: context.themeSecondrytext,
                            height: 1.3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Read Story",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: context.themePrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: context.themePrimaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
