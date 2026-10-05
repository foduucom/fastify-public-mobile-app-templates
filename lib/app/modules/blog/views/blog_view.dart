import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:foduu_ecommerce/app/modules/blog/controller/blog_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/models/blog_model.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class BlogView extends GetView<BlogController> {
  const BlogView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BlogController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Blog Standard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          // View Mode Switcher (Grid vs List View matching parent website tabs)
          Obx(() => IconButton(
                tooltip: controller.isGridView.value
                    ? 'Switch to List View'
                    : 'Switch to Grid View',
                icon: Icon(
                  controller.isGridView.value
                      ? Icons.view_agenda_outlined
                      : Icons.grid_view_rounded,
                  color: colorScheme.onSurface,
                ),
                onPressed: controller.toggleViewMode,
              )),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: colorScheme.primary,
        onRefresh: controller.onRefresh,
        child: SingleChildScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Banner Heading (Faithfully replicates parent website header)
              _buildTopHeader(context),

              // Search Bar
              _buildSearchBar(context, controller),

              // Category Filter Pills (if any exist)
              _buildCategoryBar(context, controller),

              const SizedBox(height: 12),

              // Main Blog Content Area
              Obx(() {
                if (controller.isLoading.value) {
                  return _buildShimmerLoading(context, controller.isGridView.value);
                }

                if (controller.hasError.value && controller.allBlogs.isEmpty) {
                  return _buildErrorState(context, controller);
                }

                if (controller.filteredBlogs.isEmpty) {
                  return _buildEmptyState(context, controller);
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      controller.isGridView.value
                          ? _buildGridView(context, controller.filteredBlogs)
                          : _buildListView(context, controller.filteredBlogs),
                      if (controller.isMoreLoading.value)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: colorScheme.primary,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      const SizedBox(height: 36),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// Top Heading Section matching parent website:
  /// Subtitle: "Blog Standard"
  /// Title: "Insight & advice From our Expert team."
  Widget _buildTopHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'INSIGHT & ADVICE',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'From our Expert team.',
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  /// Live Search Bar
  Widget _buildSearchBar(BuildContext context, BlogController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Search articles, topics, author...',
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox.shrink()),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  /// Horizontal category filter chips
  Widget _buildCategoryBar(BuildContext context, BlogController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      if (controller.categories.length <= 1) return const SizedBox.shrink();

      return Container(
        height: 44,
        margin: const EdgeInsets.only(top: 8),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final isSelected = controller.selectedCategory.value == category;

            return ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => controller.selectCategory(category),
              selectedColor: colorScheme.primary,
              backgroundColor: colorScheme.surfaceVariant,
              labelStyle: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.15),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  /// Grid Presentation (2 Columns)
  Widget _buildGridView(BuildContext context, List<BlogModel> blogs) {
    return AlignedGridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: blogs.length,
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 14,
      itemBuilder: (context, index) {
        return _buildGridCard(context, blogs[index]);
      },
    );
  }

  /// Grid Card (Aspect ratio 16:9 thumbnail, date, comments, title, excerpt, Read More)
  Widget _buildGridCard(BuildContext context, BlogModel blog) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: () => Get.toNamed(Routes.BLOG_DETAILS, arguments: {'blog': blog}),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: blog.imageUrl != null && blog.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: blog.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: colorScheme.surfaceVariant,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: colorScheme.surfaceVariant,
                          child: Icon(Icons.article_outlined,
                              color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    : Container(
                        color: colorScheme.surfaceVariant,
                        child: Icon(Icons.article_outlined,
                            color: colorScheme.onSurfaceVariant),
                      ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Row: Clock + Date, Comments (matches website)
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 12, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          blog.shortDate.isNotEmpty
                              ? blog.shortDate
                              : 'Recent',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    blog.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Excerpt
                  Text(
                    blog.cleanExcerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // "Read More" button
                  Row(
                    children: [
                      Text(
                        'Read More',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 13,
                        color: colorScheme.primary,
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

  /// List Presentation (Full-Width cards matching parent website `#profile-tab-pane`)
  Widget _buildListView(BuildContext context, List<BlogModel> blogs) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: blogs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildListCard(context, blogs[index]);
      },
    );
  }

  /// List Card
  Widget _buildListCard(BuildContext context, BlogModel blog) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: () => Get.toNamed(Routes.BLOG_DETAILS, arguments: {'blog': blog}),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Large Thumbnail
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: blog.imageUrl != null && blog.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: blog.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: colorScheme.surfaceVariant,
                          child: Icon(Icons.article_outlined,
                              size: 40, color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    : Container(
                        color: colorScheme.surfaceVariant,
                        child: Icon(Icons.article_outlined,
                            size: 40, color: colorScheme.onSurfaceVariant),
                      ),
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Row: Clock + Date and Comments
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 5),
                      Text(
                        blog.shortDate.isNotEmpty
                            ? blog.shortDate
                            : 'Recent',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 13, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 5),
                      Text(
                        'Comments (${blog.commentsCount})',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        blog.readingTime,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    blog.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Excerpt
                  Text(
                    blog.cleanExcerpt,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Read More Button
                  Row(
                    children: [
                      Text(
                        'Read More',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: colorScheme.primary,
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

  /// Shimmer skeleton loader conforming to light/dark themes
  Widget _buildShimmerLoading(BuildContext context, bool isGrid) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor =
        isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: isGrid
            ? AlignedGridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 6,
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 14,
                itemBuilder: (_, __) => Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            : ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, __) => Container(
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
      ),
    );
  }

  /// Empty State
  Widget _buildEmptyState(BuildContext context, BlogController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined,
                size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No Articles Found',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.searchQuery.value.isNotEmpty
                  ? 'No results matching "${controller.searchQuery.value}"'
                  : 'Check back soon for new articles & insights.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (controller.searchQuery.value.isNotEmpty) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: controller.clearSearch,
                child: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Error State
  Widget _buildErrorState(BuildContext context, BlogController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 56, color: colorScheme.error.withOpacity(0.8)),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.fetchBlogs(isRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
