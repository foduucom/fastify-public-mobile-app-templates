import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zouhi/app/modules/blog/controller/blog_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

class BlogView extends GetView<BlogController> {
  BlogView({Key? key}) : super(key: key);
  @override
  final BlogController controller = Get.put(BlogController());

  String _cleanContent(dynamic content) {
    if (content == null) return '';
    String str = content.toString();
    str = str.replaceAll(RegExp(r'<[^>]*>'), ' ');
    str = str
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ');
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

  String _calculateReadTime(dynamic content) {
    final clean = _cleanContent(content);
    if (clean.isEmpty) return '2 min read';
    final words = clean.split(RegExp(r'\s+')).length;
    final minutes = (words / 200).ceil();
    return '$minutes min read';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeBackground,
      appBar: AppBar(
        title: Text(
          'Blogs',
          style: TextStyle(
            color: context.themeTextColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        elevation: 0,
        backgroundColor: context.themeWhiteColor,
        iconTheme: IconThemeData(color: context.themeTextColor),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.onRefresh();
        },
        child: Column(
          children: [
            // Search Input Bar
            Container(
              color: context.themeWhiteColor,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: context.themeBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.themeBorderColor.withOpacity(0.5),
                  ),
                ),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.updateSearch,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: context.themeTextColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search blogs & insights...',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: context.themeSecondrytext,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: context.themePrimaryColor,
                      size: 20,
                    ),
                    suffixIcon: Obx(
                      () => controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: controller.clearSearch,
                            )
                          : const SizedBox.shrink(),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                  ),
                ),
              ),
            ),

            // Blog List View
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: controller.scrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Obx(() {
                    if (controller.allnews.isEmpty && controller.isLoading.isTrue) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (_, __) => const AllNewsShimmer(),
                      );
                    }

                    final blogs = controller.displayedBlogs;

                    if (blogs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: context.themePrimaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.article_outlined,
                                size: 48,
                                color: context.themePrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.searchQuery.value.isEmpty
                                  ? 'No Blogs Available'
                                  : 'No articles match "${controller.searchQuery.value}"',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: context.themeTextColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.searchQuery.value.isEmpty
                                  ? 'Please check back later for new updates.'
                                  : 'Try searching with different keywords.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: context.themeSecondrytext,
                              ),
                            ),
                            if (controller.searchQuery.value.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: controller.clearSearch,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.themePrimaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Clear Search',
                                  style: TextStyle(fontFamily: 'Poppins'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Article count banner
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            controller.searchQuery.value.isEmpty
                                ? 'Latest Articles (${blogs.length})'
                                : 'Found ${blogs.length} result${blogs.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.themeSecondrytext,
                            ),
                          ),
                        ),

                        // Blog cards list
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: blogs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final blog = blogs[index];
                            final String title = blog['name']?.toString() ?? '';
                            final String snippet = _cleanContent(blog['content']);
                            final String date = _formatDate(blog);
                            final String readTime = _calculateReadTime(blog['content']);
                            final String imageUrl = HelperFunctions().getImage(
                              blog['featured_image'],
                            );
                            final String blogId = blog['_id']?.toString() ?? '';

                            return Container(
                              decoration: BoxDecoration(
                                color: context.themeWhiteColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: context.themeBorderColor.withOpacity(0.6),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    if (blogId.isNotEmpty) {
                                      Get.toNamed(
                                        Routes.BLOGDETAILS,
                                        arguments: {'id': blogId},
                                      );
                                    }
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Image with Date Badge Overlay
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              height: 190,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorWidget: (context, url, error) =>
                                                  Container(
                                                height: 190,
                                                color: context.themegreyColor,
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.image_not_supported_outlined,
                                                    color: Colors.grey,
                                                    size: 36,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  Container(
                                                height: 190,
                                                color: context.themegreyColor,
                                                child: HelperFunctions()
                                                    .loadingIndicator(),
                                              ),
                                            ),
                                          ),
                                          if (date.isNotEmpty)
                                            Positioned(
                                              top: 12,
                                              left: 12,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.95),
                                                  borderRadius: BorderRadius.circular(20),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.12),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today_outlined,
                                                      size: 12,
                                                      color: context.themePrimaryColor,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      date,
                                                      style: TextStyle(
                                                        fontSize: 11,
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

                                      // Content Container
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Meta tag (Read time)
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time_rounded,
                                                  size: 13,
                                                  color: context.themeSecondrytext,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  readTime,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'Poppins',
                                                    color: context.themeSecondrytext,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  "Vision Infrastructure",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Poppins',
                                                    color: context.themePrimaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 10),

                                            // Title (2 lines without cutting off words awkwardly)
                                            Text(
                                              title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Poppins',
                                                color: context.themeTextColor,
                                                height: 1.35,
                                              ),
                                            ),

                                            if (snippet.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                snippet,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontFamily: 'Poppins',
                                                  color: context.themeSecondrytext,
                                                  height: 1.45,
                                                ),
                                              ),
                                            ],

                                            const SizedBox(height: 14),

                                            // Action Link / Button
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Read More",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w700,
                                                        fontFamily: 'Poppins',
                                                        color: context.themePrimaryColor,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Icon(
                                                      Icons.arrow_forward_rounded,
                                                      size: 15,
                                                      color: context.themePrimaryColor,
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: context.themePrimaryLight,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    "Article",
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                      fontFamily: 'Poppins',
                                                      color: context.themePrimaryDark,
                                                    ),
                                                  ),
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
                            );
                          },
                        ),

                        // Pagination Loader
                        if (controller.isLoading.isTrue && controller.allnews.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: HelperFunctions().loadingIndicator(),
                            ),
                          ),

                        const SizedBox(height: 24),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AllNewsShimmer extends StatelessWidget {
  const AllNewsShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 190,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 14,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Container(
                        height: 20,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
