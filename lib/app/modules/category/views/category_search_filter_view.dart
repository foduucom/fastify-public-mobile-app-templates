import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../components/studio_widget/studio_category.dart';
import '../../../../components/studio_widget/studio_search_bar_rounded.dart';
import '../controllers/category_search_filter_controller.dart';

class CategorySearchFilterView extends GetView<CategorySearchFilterController> {
  const CategorySearchFilterView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Categories',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'lato',
              ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        // Search/filter results take over the body; otherwise render
        // whatever the CMS `category` layout actually sends — including
        // nothing, if that's all it authored.
        return Column(
          children: [
            if (controller.sectionTypes.contains('search'))
              _SearchBar(controller: controller, colorScheme: colorScheme),
            Expanded(
              child: controller.hasActiveFilters
                  ? Column(
                      children: [
                        ...controller
                            .buildWidgetsExcluding(['search', 'categories']),
                        _ResultHeader(
                            controller: controller, colorScheme: colorScheme),
                        Expanded(child: _CategoryGrid(controller: controller)),
                      ],
                    )
                  : _CategoryLayout(controller: controller),
            ),
          ],
        );
      }),
    );
  }
}

// ─── Browse Mode (CMS/socket-driven layout) ────────────────────────────────

class _CategoryLayout extends StatelessWidget {
  final CategorySearchFilterController controller;

  const _CategoryLayout({required this.controller});

  @override
  Widget build(BuildContext context) {
    return FoduuStudioLayoutView(
      onRefresh: () =>
          controller.fetchLayout(CategorySearchFilterController.pageSlug),
      widgetList: controller.widgetList,
      isLoading: controller.isLayoutLoading,
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final CategorySearchFilterController controller;
  final ColorScheme colorScheme;

  const _SearchBar({required this.controller, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: SearchBarRounded(
        searchHintText: controller.searchPlaceholder,
        SearchsController: controller.searchController,
        onChanged: controller.onSearchChanged,
      ),
    );
  }
}

// ─── Result Header ────────────────────────────────────────────────────────────

class _ResultHeader extends StatelessWidget {
  final CategorySearchFilterController controller;
  final ColorScheme colorScheme;

  const _ResultHeader({required this.controller, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Text(
              '${controller.totalCount.value} categories found',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Category Grid ────────────────────────────────────────────────────────────

class _CategoryGrid extends StatefulWidget {
  final CategorySearchFilterController controller;

  const _CategoryGrid({required this.controller});

  @override
  State<_CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<_CategoryGrid> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.controller.categoriesInfiniteScroll) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.controller.fetchCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.controller.isLoading.value) {
        return _CategoryGridShimmer();
      }

      if (widget.controller.categories.isEmpty) {
        return _EmptyState(hasFilters: widget.controller.hasActiveFilters);
      }

      return RefreshIndicator(
        onRefresh: () => widget.controller.fetchCategories(reset: true),
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: widget.controller.categories.length +
              (widget.controller.hasNextPage.value ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= widget.controller.categories.length) {
              return _CategoryCardShimmer();
            }
            final category = widget.controller.categories[index];
            return CategoryGridItem(
              category: category,
              style: 'rectangular',
              onTap: (cat) => widget.controller.onCategoryTap(cat),
            );
          },
        ),
      );
    });
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasFilters;

  const _EmptyState({required this.hasFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.category_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters
                  ? 'No categories match your filters'
                  : 'No categories found',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 8),
              Text(
                'Try adjusting or clearing your filters',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Shimmer Loading ──────────────────────────────────────────────────────────

class _CategoryGridShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => _CategoryCardShimmer(),
    );
  }
}

class _CategoryCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 12,
                      width: double.infinity,
                      color: Colors.grey.shade300),
                  const SizedBox(height: 6),
                  Container(height: 10, width: 60, color: Colors.grey.shade300),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
