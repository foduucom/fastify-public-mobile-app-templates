import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/components/home_component/home_category.dart';
import '/constants/helper_functions.dart';
import '../controllers/category_search_controller.dart';

class CategorySearchView extends GetView<CategorySearchController> {
  const CategorySearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchBar(controller: controller),
          _FilterChips(controller: controller),
          _ParentDropdown(controller: controller),
          _ActiveFilterBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const CategoryPageShimmer();
              }
              if (controller.categories.isEmpty) {
                return const Center(
                  child: Text('No categories found'),
                );
              }
              return _CategoryGrid(
                  controller: controller, colorScheme: colorScheme);
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final CategorySearchController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: controller.searchTextController,
        onChanged: controller.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search categories...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: Obx(() => controller.searchTxt.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    controller.searchTextController.clear();
                    controller.onSearchChanged('');
                  },
                )
              : const SizedBox.shrink()),
        ),
      ),
    );
  }
}

// ─── Filter Chips ─────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final CategorySearchController controller;
  const _FilterChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              _ToggleChip(
                label: 'Main Categories',
                selected: controller.showOnlyParents.value,
                onSelected: controller.toggleParentOnly,
              ),
              const SizedBox(width: 8),
              _ToggleChip(
                label: 'Sub-categories',
                selected: controller.showOnlyChildren.value,
                onSelected: controller.toggleChildrenOnly,
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: 'All',
                value: 'all',
                controller: controller,
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: 'Shop',
                value: 'product',
                controller: controller,
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: 'Featured',
                value: 'home_category',
                controller: controller,
              ),
            ],
          ),
        ));
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  const _ToggleChip(
      {required this.label, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: true,
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String value;
  final CategorySearchController controller;
  const _TypeChip(
      {required this.label, required this.value, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: controller.selectedType.value == value,
      onSelected: (_) => controller.setType(value),
    );
  }
}

// ─── Parent Dropdown ──────────────────────────────────────────────────────────

class _ParentDropdown extends StatelessWidget {
  final CategorySearchController controller;
  const _ParentDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.showOnlyParents.value) return const SizedBox.shrink();
      if (controller.parentCategories.isEmpty) return const SizedBox.shrink();

      final items = [
        const DropdownMenuItem(value: '', child: Text('All main categories')),
        ...controller.parentCategories.map((cat) => DropdownMenuItem(
              value: cat['slug']?.toString() ?? '',
              child: Text(cat['name']?.toString() ?? ''),
            )),
      ];

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonFormField<String>(
          value: controller.selectedParentSlug.value,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Show sub-categories of...',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: items,
          onChanged: (val) => controller.setParentFilter(val ?? ''),
        ),
      );
    });
  }
}

// ─── Active Filter Bar ────────────────────────────────────────────────────────

class _ActiveFilterBar extends StatelessWidget {
  final CategorySearchController controller;
  const _ActiveFilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.totalCount.value;
      final hasFilters = controller.hasActiveFilters;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Row(
          children: [
            Text(
              '$count ${count == 1 ? 'category' : 'categories'} found',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            if (hasFilters)
              TextButton.icon(
                onPressed: controller.clearAllFilters,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
      );
    });
  }
}

// ─── Category Grid ────────────────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  final CategorySearchController controller;
  final ColorScheme colorScheme;
  const _CategoryGrid({required this.controller, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomScrollView(
          controller: controller.scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _CategoryCard(
                    category: controller.categories[index],
                    colorScheme: colorScheme,
                    onTap: () => controller
                        .navigateToCategory(controller.categories[index]),
                  ),
                  childCount: controller.categories.length,
                ),
              ),
            ),
            if (controller.isFetchingMore.value)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ));
  }
}

// ─── Category Card ────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final dynamic category;
  final ColorScheme colorScheme;
  final VoidCallback onTap;
  const _CategoryCard(
      {required this.category, required this.colorScheme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = category['name']?.toString() ?? '';
    final type = category['type']?.toString() ?? '';
    final parentName = category['parentCategoryName']?.toString();
    final hasChildren = (category['children'] as List?)?.isNotEmpty ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.05),
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: HelperFunctions()
                          .getImage(category['featured_image']),
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: colorScheme.surfaceVariant,
                        child: Icon(Icons.category_outlined,
                            size: 40, color: colorScheme.onSurfaceVariant),
                      ),
                      progressIndicatorBuilder: (_, __, ___) => Container(
                        color: colorScheme.surfaceVariant,
                      ),
                    ),
                    if (hasChildren)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Has sub-categories',
                            style: TextStyle(color: Colors.white, fontSize: 9),
                          ),
                        ),
                      ),
                  ],
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
                    name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _TypeBadge(type: type, colorScheme: colorScheme),
                      if (parentName != null && parentName.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '↳ $parentName',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
            : colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isProduct ? 'Shop' : 'Featured',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isProduct
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
