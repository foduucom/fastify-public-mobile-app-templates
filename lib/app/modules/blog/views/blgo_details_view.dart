import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zouhi/app/modules/blog/controller/blog_details_controller.dart';
import 'package:zouhi/components/product_image_placeholder.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

class BlogDetailsView extends StatefulWidget {
  const BlogDetailsView({Key? key}) : super(key: key);

  @override
  State<BlogDetailsView> createState() => _BlogDetailsViewState();
}

class _BlogDetailsViewState extends State<BlogDetailsView> {
  final BlogDetailsController controller = Get.put(BlogDetailsController());
  final ScrollController _scrollController = ScrollController();

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

  String _formatDate(dynamic dateRaw) {
    if (dateRaw == null) return '';
    try {
      final dt = DateTime.parse(dateRaw.toString());
      return DateFormat('dd MMMM yyyy').format(dt);
    } catch (_) {
      return dateRaw.toString();
    }
  }

  String _calculateReadTime(dynamic content) {
    final clean = _cleanContent(content);
    if (clean.isEmpty) return '2 min read';
    final words = clean.split(RegExp(r'\s+')).length;
    final minutes = (words / 200).ceil();
    return '$minutes min read';
  }

  void _shareArticle(String? title, String? id, String? slug) {
    final blogSlug = slug != null && slug.isNotEmpty ? slug : (id ?? '');
    final fullUrl = "https://vision.vbought.com/blog/$blogSlug";
    Clipboard.setData(ClipboardData(text: fullUrl));
    Fluttertoast.showToast(
      msg: "Blog link copied to clipboard!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeBackground,
      appBar: AppBar(
        title: Text(
          'Blog Details',
          style: TextStyle(
            color: context.themeTextColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        elevation: 0,
        backgroundColor: context.themeWhiteColor,
        iconTheme: IconThemeData(color: context.themeTextColor),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.share_outlined),
        //     tooltip: 'Share Blog',
        //     onPressed: () {
        //       if (controller.blogDetails.isNotEmpty) {
        //         _shareArticle(
        //           controller.blogDetails['name']?.toString(),
        //           controller.blogDetails['_id']?.toString(),
        //           controller.blogDetails['slug']?.toString(),
        //         );
        //       }
        //     },
        //   ),
        // ],
      ),
      body: Obx(() {
        if (controller.isLoading.isTrue && controller.blogDetails.isEmpty) {
          return Center(child: HelperFunctions().loadingIndicator());
        }

        if (controller.blogDetails.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 54,
                  color: context.themeSecondrytext,
                ),
                const SizedBox(height: 16),
                Text(
                  'Blog not found',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.themeTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.themePrimaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        final blog = controller.blogDetails;
        final String title = blog['name']?.toString() ?? '';
        final String content = blog['content']?.toString() ?? '';
        final dynamic dateRaw = blog['createdAt'] ??
            blog['created_at'] ??
            blog['date'] ??
            blog['published_at'] ??
            blog['updatedAt'];
        final String formattedDate = _formatDate(dateRaw);
        final String readTime = _calculateReadTime(content);
        final String imageUrl =
            HelperFunctions().getImage(blog['featured_image']);

        return SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Article Card
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.themeWhiteColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.themeBorderColor.withOpacity(0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Featured Image
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const SizedBox(
                            height: 220,
                            width: double.infinity,
                            child: ProductImagePlaceholder(radius: 16),
                          ),
                          placeholder: (context, url) => Container(
                            height: 220,
                            color: context.themegreyColor,
                            child: HelperFunctions().loadingIndicator(),
                          ),
                        ),
                      )
                    else
                      const SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: ProductImagePlaceholder(radius: 16),
                      ),

                    // Article Header & Content
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Meta Row (Date, Read Time, Category)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (formattedDate.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.themePrimaryLight,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 13,
                                        color: context.themePrimaryDark,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: context.themePrimaryDark,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 13,
                                      color: context.themeSecondrytext,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      readTime,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: context.themeSecondrytext,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Article Title
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              fontFamily: 'Poppins',
                              color: context.themeTextColor,
                              height: 1.35,
                            ),
                          ),

                          const SizedBox(height: 12),
                          Divider(
                              color: context.themeBorderColor.withOpacity(0.5)),
                          const SizedBox(height: 8),

                          // Formatted HTML Content
                          Html(
                            data: content,
                            style: {
                              "body": Style(
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                                fontSize: FontSize(15),
                                lineHeight: const LineHeight(1.65),
                                fontFamily: 'Poppins',
                                color: context.themeTextColor,
                              ),
                              "p": Style(
                                margin: Margins.only(bottom: 14),
                                fontSize: FontSize(15),
                                lineHeight: const LineHeight(1.65),
                                fontFamily: 'Poppins',
                                color: context.themeTextColor,
                              ),
                              "h1": Style(
                                fontSize: FontSize(20),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                margin: Margins.only(top: 16, bottom: 8),
                                color: context.themeTextColor,
                              ),
                              "h2": Style(
                                fontSize: FontSize(18),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                margin: Margins.only(top: 16, bottom: 8),
                                color: context.themeTextColor,
                              ),
                              "h3": Style(
                                fontSize: FontSize(17),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                margin: Margins.only(top: 14, bottom: 8),
                                color: context.themeTextColor,
                              ),
                              "h4": Style(
                                fontSize: FontSize(16),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                margin: Margins.only(top: 12, bottom: 6),
                                color: context.themeTextColor,
                              ),
                              "ul": Style(
                                margin: Margins.only(left: 4, bottom: 12),
                                padding: HtmlPaddings.only(left: 16),
                              ),
                              "li": Style(
                                margin: Margins.only(bottom: 6),
                                fontSize: FontSize(14.5),
                                lineHeight: const LineHeight(1.55),
                                fontFamily: 'Poppins',
                              ),
                              "a": Style(
                                color: context.themePrimaryColor,
                                textDecoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                              ),
                              "img": Style(
                                width: Width(double.infinity),
                                margin: Margins.symmetric(vertical: 8),
                              ),
                              "blockquote": Style(
                                margin: Margins.symmetric(vertical: 12),
                                padding: HtmlPaddings.all(12),
                                backgroundColor: context.themePrimaryLight,
                                border: Border(
                                  left: BorderSide(
                                    color: context.themePrimaryColor,
                                    width: 4,
                                  ),
                                ),
                              ),
                            },
                            onLinkTap: (url, attributes, element) async {
                              if (url != null) {
                                final uri = Uri.tryParse(url);
                                if (uri != null && await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Recent Posts Section (Website parity)
              Obx(() {
                final recent = controller.recentBlogs;
                if (recent.isEmpty) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.themeWhiteColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.themeBorderColor.withOpacity(0.6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: context.themePrimaryColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Recent Posts",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: context.themeTextColor,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Text(
                              "View All",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.themePrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recent.length > 3 ? 3 : recent.length,
                        separatorBuilder: (_, __) => Divider(
                          color: context.themeBorderColor.withOpacity(0.4),
                          height: 20,
                        ),
                        itemBuilder: (context, index) {
                          final item = recent[index];
                          final itemTitle = item['name']?.toString() ?? '';
                          final itemDate = _formatDate(
                            item['createdAt'] ??
                                item['created_at'] ??
                                item['date'],
                          );
                          final itemImage = HelperFunctions().getImage(
                            item['featured_image'],
                          );
                          final itemId = item['_id']?.toString() ?? '';

                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              if (itemId.isNotEmpty) {
                                controller.loadBlogAndRecent(itemId);
                                _scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: itemImage.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: itemImage,
                                            width: 72,
                                            height: 56,
                                            fit: BoxFit.cover,
                                            errorWidget: (_, __, ___) =>
                                                Container(
                                              width: 72,
                                              height: 56,
                                              color: context.themegreyColor,
                                              child: const Icon(
                                                Icons
                                                    .image_not_supported_outlined,
                                                size: 20,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: 72,
                                            height: 56,
                                            color: context.themegreyColor,
                                            child: const Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (itemDate.isNotEmpty)
                                          Text(
                                            itemDate,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                              color: context.themeSecondrytext,
                                            ),
                                          ),
                                        const SizedBox(height: 2),
                                        Text(
                                          itemTitle,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            color: context.themeTextColor,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 20,
                                    color: context.themeSecondrytext,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}
