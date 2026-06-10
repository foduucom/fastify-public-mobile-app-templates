import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/category_search_filter_controller.dart';

class CategorySearchFilterView extends GetView<CategorySearchFilterController> {
  const CategorySearchFilterView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Browse Categories',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'lato',
              ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _SearchBar(controller: controller, colorScheme: colorScheme),
          //_FilterChips(controller: controller, colorScheme: colorScheme),
          _ResultHeader(controller: controller, colorScheme: colorScheme),
          Expanded(
            child: _CategoryGrid(controller: controller),
          ),
        ],
      ),
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
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search categories...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() => controller.searchText.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.searchController.clear();
                    controller.onSearchChanged('');
                  },
                )
              : const SizedBox.shrink()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide:
                BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide:
                BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

// ─── Filter Chips ─────────────────────────────────────────────────────────────

// class _FilterChips extends StatelessWidget {
//   final CategorySearchFilterController controller;
//   final ColorScheme colorScheme;

//   const _FilterChips(
//       {required this.controller, required this.colorScheme});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//           child: Row(
//             children: [
//               // Parent only toggle
//               _FilterToggleChip(
//                 label: 'Parents Only',
//                 isSelected: controller.showOnlyParents.value,
//                 onSelected: (v) => controller.toggleShowOnlyParents(v),
//                 colorScheme: colorScheme,
//               ),
//               const SizedBox(width: 8),

//               // Children only toggle
//               _FilterToggleChip(
//                 label: 'Children Only',
//                 isSelected: controller.showOnlyChildren.value,
//                 onSelected: (v) => controller.toggleShowOnlyChildren(v),
//                 colorScheme: colorScheme,
//               ),
//               const SizedBox(width: 8),

//               // Type filter
//               _TypeDropdownChip(
//                 controller: controller,
//                 colorScheme: colorScheme,
//               ),
//               const SizedBox(width: 8),

//               // Parent category dropdown
//               if (controller.parentCategories.isNotEmpty) ...[
//                 _ParentDropdownChip(
//                   controller: controller,
//                   colorScheme: colorScheme,
//                 ),
//                 const SizedBox(width: 8),
//               ],

//               // Clear all
//               if (controller.hasActiveFilters)
//                 ActionChip(
//                   label: const Text('Clear All'),
//                   avatar: const Icon(Icons.close, size: 16),
//                   onPressed: controller.clearAllFilters,
//                   backgroundColor:
//                       colorScheme.errorContainer.withValues(alpha: 0.8),
//                   labelStyle:
//                       TextStyle(color: colorScheme.onErrorContainer),
//                 ),
//             ],
//           ),
//         ));
//   }
// }

class _FilterToggleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool?> onSelected;
  final ColorScheme colorScheme;

  const _FilterToggleChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color:
            isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
        fontSize: 13,
      ),
    );
  }
}

class _TypeDropdownChip extends StatelessWidget {
  final CategorySearchFilterController controller;
  final ColorScheme colorScheme;

  const _TypeDropdownChip(
      {required this.controller, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = controller.selectedType.value != 'all';
      return PopupMenuButton<String>(
        initialValue: controller.selectedType.value,
        onSelected: controller.onTypeChanged,
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'all', child: Text('All Types')),
          const PopupMenuItem(value: 'product', child: Text('Product')),
          const PopupMenuItem(
              value: 'home_category', child: Text('Home Category')),
        ],
        child: Chip(
          label: Text(
            controller.selectedType.value == 'all'
                ? 'Type'
                : controller.selectedType.value == 'home_category'
                    ? 'Home Category'
                    : 'Product',
          ),
          avatar: Icon(
            Icons.arrow_drop_down,
            size: 18,
            color: isActive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
          ),
          backgroundColor: isActive
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          labelStyle: TextStyle(
            color: isActive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
            fontSize: 13,
          ),
        ),
      );
    });
  }
}

class _ParentDropdownChip extends StatelessWidget {
  final CategorySearchFilterController controller;
  final ColorScheme colorScheme;

  const _ParentDropdownChip(
      {required this.controller, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = controller.selectedParentSlug.value.isNotEmpty;
      final selectedParent = isActive
          ? controller.parentCategories.firstWhereOrNull(
              (c) => c['slug'] == controller.selectedParentSlug.value)
          : null;

      return PopupMenuButton<String>(
        initialValue: controller.selectedParentSlug.value.isEmpty
            ? ''
            : controller.selectedParentSlug.value,
        onSelected: (val) =>
            controller.onParentFilterChanged(val.isEmpty ? null : val),
        itemBuilder: (_) => [
          const PopupMenuItem(value: '', child: Text('All Parents')),
          ...controller.parentCategories
              .map<PopupMenuEntry<String>>((cat) => PopupMenuItem(
                    value: cat['slug']?.toString() ?? '',
                    child: Text(cat['name']?.toString() ?? ''),
                  )),
        ],
        child: Chip(
          label: Text(
            isActive && selectedParent != null
                ? selectedParent['name'].toString()
                : 'Parent',
          ),
          avatar: Icon(
            Icons.arrow_drop_down,
            size: 18,
            color: isActive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
          ),
          backgroundColor: isActive
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          labelStyle: TextStyle(
            color: isActive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
            fontSize: 13,
          ),
        ),
      );
    });
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
            return _CategoryCard(
              category: category,
              onTap: () => widget.controller.onCategoryTap(category),
            );
          },
        ),
      );
    });
  }
}

// ─── Category Card ────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final dynamic category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List children = category['children'] ?? [];
    final String? type = category['type']?.toString();
    final String? parentName = category['parentCategory']?.toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl:
                      HelperFunctions().getImage(category['featured_image']),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.category_outlined,
                        size: 40, color: colorScheme.onSurfaceVariant),
                  ),
                  progressIndicatorBuilder: (_, __, ___) => Container(
                    color: colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['name']?.toString() ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (type != null)
                        _TypeBadge(type: type, colorScheme: colorScheme),
                      const Spacer(),
                      if (children.isNotEmpty)
                        Text(
                          '${children.length} sub',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                        ),
                    ],
                  ),
                  if (parentName != null && parentName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'in $parentName',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  final ColorScheme colorScheme;

  const _TypeBadge({required this.type, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final isProduct = type == 'product';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isProduct
            ? colorScheme.primaryContainer
            : colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isProduct ? 'Product' : 'Home',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: isProduct
              ? colorScheme.onPrimaryContainer
              : colorScheme.onTertiaryContainer,
        ),
      ),
    );
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
