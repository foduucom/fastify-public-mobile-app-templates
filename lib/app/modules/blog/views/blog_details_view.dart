import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:foduu_ecommerce/app/modules/blog/controller/blog_detail_controller.dart';
import 'package:foduu_ecommerce/models/blog_model.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class BlogDetailsView extends GetView<BlogDetailsController> {
  const BlogDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BlogDetailsController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Article Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Share Article',
            icon: Icon(Icons.share_outlined, color: colorScheme.onSurface),
            onPressed: controller.shareBlog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        if (controller.hasError.value && controller.currentBlog.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 54, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final blog = controller.currentBlog.value;
        if (blog == null) {
          return const Center(child: Text('No article found.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Heading & Metadata Section (Faithfully replicating parent website)
              _buildTopHeading(context, blog),

              const SizedBox(height: 16),

              // Featured Banner Image
              _buildBannerImage(context, blog),

              const SizedBox(height: 20),

              // Article HTML Content
              _buildArticleContent(context, blog),

              const SizedBox(height: 24),

              // Tag Cloud (if tags exist)
              if (blog.tags.isNotEmpty) ...[
                _buildTagCloud(context, blog.tags),
                const SizedBox(height: 24),
              ],

              // Previous / Next Post Navigation (matches parent website)
              _buildPostNavigation(context, controller),

              const SizedBox(height: 24),

              // Author Box (matches parent website)
              _buildAuthorBox(context, blog),

              const SizedBox(height: 32),

              // Latest Posts Section (matches parent website sidebar widget)
              if (controller.latestBlogs.isNotEmpty) ...[
                _buildLatestPostsSection(context, controller),
                const SizedBox(height: 40),
              ],
            ],
          ),
        );
      }),
    );
  }

  /// Top Article Heading matching parent website:
  /// Title + Meta Row (By Admin + Date + Comments count)
  Widget _buildTopHeading(BuildContext context, BlogModel blog) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (blog.categories.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              blog.categories.first.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
        Text(
          blog.title,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 14),

        // Meta Row: By Admin | Date | Comments (matches aq-blog-details-top-meta)
        Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline_rounded,
                    size: 15, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'By ${blog.authorName}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time_rounded,
                    size: 15, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  blog.formattedDate.isNotEmpty
                      ? blog.formattedDate
                      : 'Recent',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'Comments (${blog.commentsCount})',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded,
                    size: 14, color: colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  blog.readingTime,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Banner image
  Widget _buildBannerImage(BuildContext context, BlogModel blog) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (blog.imageUrl == null || blog.imageUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: blog.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            color: colorScheme.surfaceVariant,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            color: colorScheme.surfaceVariant,
            child: Icon(Icons.broken_image_outlined,
                size: 48, color: colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  /// Rich HTML content renderer
  Widget _buildArticleContent(BuildContext context, BlogModel blog) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      child: HtmlWidget(
        blog.content.isNotEmpty ? blog.content : '<p>${blog.excerpt}</p>',
        textStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          height: 1.7,
          fontSize: 15,
        ),
        customStylesBuilder: (element) {
          if (element.localName == 'blockquote') {
            return {
              'background-color':
                  '#${colorScheme.surfaceVariant.value.toRadixString(16).substring(2)}',
              'padding': '14px 18px',
              'border-left':
                  '4px solid #${colorScheme.primary.value.toRadixString(16).substring(2)}',
              'font-style': 'italic',
              'margin': '16px 0',
              'border-radius': '6px',
            };
          }
          if (element.localName == 'h1' ||
              element.localName == 'h2' ||
              element.localName == 'h3') {
            return {
              'font-weight': 'bold',
              'margin': '14px 0 8px 0',
              'color':
                  '#${colorScheme.onSurface.value.toRadixString(16).substring(2)}',
            };
          }
          return null;
        },
        onTapUrl: (url) async {
          final uri = Uri.tryParse(url);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return true;
          }
          return false;
        },
      ),
    );
  }

  /// Tag cloud
  Widget _buildTagCloud(BuildContext context, List<String> tags) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Tags: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Previous and Next Post navigation cards (matching parent website)
  Widget _buildPostNavigation(
      BuildContext context, BlogDetailsController controller) {
    final prev = controller.previousBlog.value;
    final next = controller.nextBlog.value;

    if (prev == null && next == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          if (prev != null)
            InkWell(
              onTap: () => controller.openBlog(prev),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 16, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PREVIOUS POST',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            prev.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (prev != null && next != null)
            Divider(color: colorScheme.outline.withOpacity(0.12), height: 16),
          if (next != null)
            InkWell(
              onTap: () => controller.openBlog(next),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'NEXT POST',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            next.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 16, color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Author Box (matching postbox-details-author on parent website)
  Widget _buildAuthorBox(BuildContext context, BlogModel blog) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colorScheme.primary.withOpacity(0.2),
            child: Text(
              blog.authorName.isNotEmpty ? blog.authorName[0].toUpperCase() : 'A',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Written by',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  blog.authorName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Content creator and editor sharing insights and research on latest trends.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Latest Posts Section (matches parent website sidebar widget)
  Widget _buildLatestPostsSection(
      BuildContext context, BlogDetailsController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3.5,
              height: 18,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Latest Posts',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: controller.latestBlogs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = controller.latestBlogs[index];
            return InkWell(
              onTap: () => controller.openBlog(item),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: colorScheme.outline.withOpacity(0.12)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 72,
                        height: 54,
                        child: item.imageUrl != null &&
                                item.imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: item.imageUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  color: colorScheme.surfaceVariant,
                                  child: Icon(Icons.article_outlined,
                                      size: 20,
                                      color: colorScheme.onSurfaceVariant),
                                ),
                              )
                            : Container(
                                color: colorScheme.surfaceVariant,
                                child: Icon(Icons.article_outlined,
                                    size: 20,
                                    color: colorScheme.onSurfaceVariant),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.shortDate,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 10.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
