import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/data/models/blog_sections.dart';
import 'package:foduu_ecommerce/app/modules/blog/controller/blog_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/foduuCachedImageNetwork.dart';
import 'package:foduu_ecommerce/models/blog_model.dart';
import 'package:get/get.dart';

class BlogFeedSection extends StatefulWidget {
  final Map<String, dynamic>? contentJson;

  const BlogFeedSection({Key? key, this.contentJson}) : super(key: key);

  factory BlogFeedSection.fromMap(Map<String, dynamic>? json) {
    return BlogFeedSection(contentJson: json);
  }

  @override
  State<BlogFeedSection> createState() => _BlogFeedSectionState();
}

class _BlogFeedSectionState extends State<BlogFeedSection> {
  late final BlogFeedSectionData _staticData;

  @override
  void initState() {
    super.initState();
    _staticData = BlogFeedSectionData.fromMap(widget.contentJson);
  }

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<BlogController>()) {
      return const _ReactiveBlogFeed();
    }
    return _StaticBlogFeed(data: _staticData);
  }
}

/// Reactive feed connected directly to BlogController
class _ReactiveBlogFeed extends StatelessWidget {
  const _ReactiveBlogFeed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BlogController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final categories = controller.categories;
      final selectedCategory = controller.selectedCategory.value;
      final blogs = controller.filteredBlogs;
      final isGridView = controller.isGridView.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Category Pills
          if (categories.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = (cat == selectedCategory) ||
                        (selectedCategory.isEmpty && cat == 'All');
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          cat == 'All' ? 'All Articles' : cat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: isDark
                            ? colorScheme.primary
                            : colorScheme.primary,
                        backgroundColor: isDark
                            ? colorScheme.surface
                            : colorScheme.surfaceVariant.withValues(alpha: 0.5),
                        elevation: isSelected ? 2 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        onSelected: (_) => controller.onCategorySelected(cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 2. Section Header: "Latest Articles" & View Mode Switcher
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Latest Articles',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        (selectedCategory == 'All' &&
                                controller.searchQuery.value.isEmpty &&
                                controller.totalArticles.value > 0)
                            ? '${controller.totalArticles.value}'
                            : '${blogs.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  tooltip: isGridView ? 'Switch to List' : 'Switch to Grid',
                  icon: Icon(
                    isGridView ? Icons.view_agenda_outlined : Icons.grid_view_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: controller.toggleViewMode,
                ),
              ],
            ),
          ),

          // 3. Blog List / Grid
          if (blogs.isEmpty) ...[
            _buildEmptyState(context, controller),
          ] else if (isGridView) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: blogs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  return _BlogGridCard(blog: blogs[index]);
                },
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: blogs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _BlogListCard(blog: blogs[index]);
              },
            ),
          ],
          if (controller.isMoreLoading.value) ...[
            const SizedBox(height: 18),
            Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 28),
        ],
      );
    });
  }

  Widget _buildEmptyState(BuildContext context, BlogController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasSearch = controller.searchQuery.value.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.article_outlined,
              size: 40,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            hasSearch
                ? 'No articles match "${controller.searchQuery.value}"'
                : 'No articles found in this category',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasSearch
                ? 'Try searching with different keywords.'
                : 'Check back later for new updates.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (hasSearch) ...[
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: controller.clearSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Static feed fallback
class _StaticBlogFeed extends StatelessWidget {
  final BlogFeedSectionData data;

  const _StaticBlogFeed({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.categories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      label: const Text('All Articles'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                  ...data.categories.map((c) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(label: Text(c.name)),
                      )),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.blogs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _BlogListCard(blog: data.blogs[index]),
          ),
        ),
      ],
    );
  }
}

/// Grid Card Widget matching parent website card styling
class _BlogGridCard extends StatelessWidget {
  final BlogModel blog;

  const _BlogGridCard({Key? key, required this.blog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final categoryLabel = blog.categories.isNotEmpty
        ? blog.categories.first
        : (blog.tags.isNotEmpty ? blog.tags.first : 'General');

    return InkWell(
      onTap: () {
        Get.toNamed(Routes.BLOG_DETAILS, arguments: {'blog': blog});
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Category Badge overlay
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: blog.imageUrl != null && blog.imageUrl!.isNotEmpty
                      ? FoduuCachedNetworkImage(
                          image: blog.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: colorScheme.surfaceVariant,
                          child: Icon(
                            Icons.image_outlined,
                            size: 32,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      categoryLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blog.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        height: 1.25,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        blog.cleanExcerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          blog.shortDate.isNotEmpty ? blog.shortDate : 'Recent',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          blog.readingTime,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.primary,
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
  }
}

/// List Card Widget matching parent website article layout
class _BlogListCard extends StatelessWidget {
  final BlogModel blog;

  const _BlogListCard({Key? key, required this.blog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final categoryLabel = blog.categories.isNotEmpty
        ? blog.categories.first
        : (blog.tags.isNotEmpty ? blog.tags.first : 'General');

    return InkWell(
      onTap: () {
        Get.toNamed(Routes.BLOG_DETAILS, arguments: {'blog': blog});
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: blog.imageUrl != null && blog.imageUrl!.isNotEmpty
                      ? FoduuCachedNetworkImage(
                          image: blog.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: colorScheme.surfaceVariant,
                          child: Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      categoryLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1.3,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    blog.cleanExcerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12.5,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        blog.formattedDate.isNotEmpty
                            ? blog.formattedDate
                            : 'Recent',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.schedule_outlined,
                        size: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        blog.readingTime,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (blog.author != null &&
                          blog.author!.fullName.isNotEmpty) ...[
                        const Spacer(),
                        Text(
                          blog.author!.fullName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
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
