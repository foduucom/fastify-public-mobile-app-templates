import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/modules/shop/controllers/shop_controller.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

/// Hero area shown above the shop grid: search bar, category strip with
/// breadcrumb and a static trust row. Fully local, no CMS content.
class ShopHeroHeader extends GetView<ShopController> {
  const ShopHeroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ShopSearchBar(),
        //const _CategoryStrip(),
        const _TrustRow(),
        const ShopActiveFilterChips(),
      ],
    );
  }
}

class _ShopSearchBar extends GetView<ShopController> {
  const _ShopSearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Container(
        decoration: BoxDecoration(
          color: context.themegreyColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.themeBorderColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(Icons.search, size: 20, color: context.themeSecondrytext),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller.productSearchController,
                textInputAction: TextInputAction.search,
                style: TextStyle(fontSize: 14, color: context.themeTextColor),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle:
                      TextStyle(fontSize: 14, color: context.themeSecondrytext),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: controller.onProductSearchChanged,
                onSubmitted: controller.onProductSearchChanged,
              ),
            ),
            Obx(() => controller.searchQuery.value.isEmpty
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: controller.clearProductSearch,
                    child:
                        const Icon(Icons.close, size: 18, color: Colors.grey),
                  )),
          ],
        ),
      ),
    );
  }
}

class _CategoryStrip extends GetView<ShopController> {
  const _CategoryStrip();

  void _onTap(Map<String, dynamic> cat) {
    final slug = cat['slug']?.toString() ?? '';
    if (slug.isEmpty) return;
    final children = cat['children'];
    final isParent = children is List && children.isNotEmpty;
    if (isParent) {
      if (!controller.selectedCategories.contains(slug)) {
        controller.toggleCategory(slug);
      }
      controller.drillIntoCategory(cat);
    } else {
      controller.toggleCategory(slug);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cats = controller.filterCurrentCategories.toList();
      final stack = controller.filterCategoryStack.toList();
      if (cats.isEmpty && stack.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (stack.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: GestureDetector(
                onTap: controller.goUpFilterCategory,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_ios_new,
                        size: 14, color: themeRedColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        [
                          'All',
                          ...stack.map((e) =>
                              (e['cat'] as Map)['name']?.toString() ?? '')
                        ].join(' › '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: themeRedColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final cat = cats[i];
                final slug = cat['slug']?.toString() ?? '';
                final selected = controller.selectedCategories.contains(slug);
                final imageUrl = cat['featured_image'] != null
                    ? HelperFunctions().getImage(cat['featured_image'])
                    : null;
                return GestureDetector(
                  onTap: () => _onTap(cat),
                  child: SizedBox(
                    width: 64,
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.themegreyColor,
                            border: Border.all(
                              color: selected
                                  ? themeRedColor
                                  : context.themeBorderColor,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: ClipOval(
                            child: imageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => const Icon(
                                        Icons.category,
                                        size: 22,
                                        color: Colors.grey),
                                  )
                                : const Icon(Icons.category,
                                    size: 22, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat['name']?.toString() ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected
                                ? themeRedColor
                                : context.themeTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.lock_outline, 'Secure payment'),
      (Icons.local_shipping_outlined, 'Fast delivery'),
      (Icons.replay, 'Easy returns'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: context.themePrimaryColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final item in items)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.$1, size: 16, color: context.themePrimaryColor),
                  const SizedBox(width: 4),
                  Text(
                    item.$2,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: context.themeTextColor,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal strip of removable chips for every active filter.
class ShopActiveFilterChips extends GetView<ShopController> {
  const ShopActiveFilterChips({super.key});

  String _categoryName(String slug) {
    final treeName = controller.treeNodeName('product', slug);
    if (treeName != slug) return treeName;
    String? find(List<dynamic> list) {
      for (final item in list) {
        if (item is! Map) continue;
        if (item['slug'] == slug) return item['name']?.toString();
        final children = item['children'];
        if (children is List && children.isNotEmpty) {
          final res = find(children);
          if (res != null) return res;
        }
      }
      return null;
    }

    final source = controller.allCategories.isNotEmpty
        ? controller.allCategories
        : controller.availableCategories;
    return find(source) ?? slug;
  }

  String _brandName(String slug) {
    final brand =
        controller.availableBrands.firstWhereOrNull((b) => b['slug'] == slug);
    return brand?['name']?.toString() ?? slug;
  }

  Widget _chip(BuildContext context, String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: themeRedColor.withOpacity(0.08),
      side: BorderSide(color: themeRedColor.withOpacity(0.4)),
      deleteIcon: const Icon(Icons.close, size: 14),
      onDeleted: onDeleted,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Touch every observable the chips depend on.
      final search = controller.searchQuery.value;
      final bts = controller.isBackToSchool.value;
      final seasonal = controller.isSeasonalItems.value;
      final weekly = controller.isWeeklyTopHighlights.value;
      final pick = controller.isTodaysTopPick.value;
      final rec = controller.isRecommended.value;
      final cats = controller.selectedCategories.toList();
      final brands = controller.selectedBrands.toList();
      final attrs = controller.selectedAttributes.entries
          .expand((e) => e.value.map((v) => MapEntry(e.key, v)))
          .toList();
      final priceActive =
          controller.minPrice.value > controller.absoluteMinPrice.value ||
              controller.maxPrice.value < controller.absoluteMaxPrice.value;

      if (!controller.hasActiveFilters) return const SizedBox.shrink();

      final chips = <Widget>[
        if (search.isNotEmpty)
          _chip(context, '"$search"', controller.clearProductSearch),
        if (weekly)
          _chip(context, 'Weekly Highlights',
              controller.toggleWeeklyTopHighlights),
        if (pick)
          _chip(context, "Top Picks", controller.toggleTodaysTopPick),
        if (rec) _chip(context, 'Recommended', controller.toggleRecommended),
        for (final slug in cats)
          _chip(context, _categoryName(slug),
              () => controller.toggleCategory(slug)),
        for (final slug in brands)
          _chip(context, _brandName(slug), () => controller.toggleBrand(slug)),
        for (final a in attrs)
          _chip(
              context,
              controller.treeNodeName(a.key, a.value) == a.value
                  ? '${a.key}: ${a.value}'
                  : controller.treeNodeName(a.key, a.value),
              () => controller.toggleAttribute(a.key, a.value)),
        if (priceActive)
          _chip(
            context,
            '${controller.formatPriceForInput(controller.minPrice.value)} - ${controller.formatPriceForInput(controller.maxPrice.value)}',
            () => controller.updatePriceRange(RangeValues(
                controller.absoluteMinPrice.value,
                controller.absoluteMaxPrice.value)),
          ),
      ];

      return SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          children: [
            ActionChip(
              label: const Text('Clear All',
                  style: TextStyle(fontSize: 12, color: Colors.white)),
              backgroundColor: themeRedColor,
              onPressed: controller.clearAllFilters,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            for (final c in chips)
              Padding(padding: const EdgeInsets.only(left: 8), child: c),
          ],
        ),
      );
    });
  }
}
