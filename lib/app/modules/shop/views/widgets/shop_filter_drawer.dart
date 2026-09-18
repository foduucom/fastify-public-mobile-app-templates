import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/app/modules/shop/controllers/shop_controller.dart';
import '/components/buttons/outlinebutton.dart';

/// Right-sliding Filter drawer: Category / Material / Style / Brand / Price.
///
/// Ported from SOURCE (fastify-public-mobile-app-templates)
/// `shop/views/widgets/shop_filter_drawer.dart` as part of PORT_AUDIT.md /
/// plan Phase 4 — logic (open/close, expand-collapse sections, staged
/// apply/reset) kept as-is, visuals restyled to TARGET's `colorScheme`
/// (`constants/dynamic_theme.dart`) and `components/buttons/*`.
///
/// Selections are staged in local temp state and only committed to
/// [ShopController] when "Apply Filters" is tapped — closing the drawer
/// without applying discards any in-progress changes.
class ShopFilterDrawer extends StatefulWidget {
  final ShopController controller;

  const ShopFilterDrawer({Key? key, required this.controller})
      : super(key: key);

  @override
  State<ShopFilterDrawer> createState() => _ShopFilterDrawerState();
}

class _ShopFilterDrawerState extends State<ShopFilterDrawer> {
  late Set<String> _tempCategories;
  late Set<String> _tempMaterials;
  late Set<String> _tempStyles;
  late Set<String> _tempBrands;
  late RangeValues _tempPriceRange;

  ShopController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _seedTempStateFromController();
    // Loads regardless of how the drawer was opened — the trigger icon's
    // onTap also calls these, but Scaffold's endDrawer also opens via a
    // native edge-swipe gesture that bypasses onTap entirely.
    controller.ensureFilterDataLoaded();
    controller.ensureCategoryTreeLoaded();
  }

  void _seedTempStateFromController() {
    _tempCategories = Set.from(controller.selectedCategories);
    _tempMaterials = Set.from(controller.selectedAttributes['material'] ?? {});
    _tempStyles = Set.from(controller.selectedAttributes['style'] ?? {});
    _tempBrands = Set.from(controller.selectedBrands);
    _tempPriceRange = controller.currentPriceRange.value;
  }

  int get _totalSelectedCount {
    int count = _tempCategories.length +
        _tempMaterials.length +
        _tempStyles.length +
        _tempBrands.length;
    if (_tempPriceRange.start > 0 || _tempPriceRange.end < 10000) {
      count++;
    }
    return count;
  }

  void _clearAll() {
    setState(() {
      _tempCategories = {};
      _tempMaterials = {};
      _tempStyles = {};
      _tempBrands = {};
      _tempPriceRange = const RangeValues(0, 10000);
    });
    controller.clearAllFilters();
  }

  void _applyFilters() {
    controller.selectedCategories
      ..clear()
      ..addAll(_tempCategories);
    controller.selectedAttributes['material'] = _tempMaterials;
    controller.selectedAttributes['style'] = _tempStyles;
    controller.selectedAttributes.refresh();
    controller.selectedBrands
      ..clear()
      ..addAll(_tempBrands);
    controller.currentPriceRange.value = _tempPriceRange;
    controller.minPrice.value = _tempPriceRange.start;
    controller.maxPrice.value = _tempPriceRange.end;
    Navigator.pop(context);
    controller.applyFiltersAndRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(colorScheme, textTheme),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    _buildTreeFilterSection(
                      label: "Category",
                      attributeKey: "product",
                      tempSet: _tempCategories,
                      icon: Icons.category_outlined,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 12),
                    _buildPriceSectionCard(colorScheme, textTheme),
                    const SizedBox(height: 12),
                    _buildTreeFilterSection(
                      label: "Material",
                      attributeKey: "material",
                      tempSet: _tempMaterials,
                      icon: Icons.layers_outlined,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 12),
                    _buildTreeFilterSection(
                      label: "Style",
                      attributeKey: "style",
                      tempSet: _tempStyles,
                      icon: Icons.style_outlined,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 12),
                    _buildBrandsSectionCard(colorScheme, textTheme),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomActionBar(colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(ColorScheme colorScheme, TextTheme textTheme) {
    final activeCount = _totalSelectedCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Filters",
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                    if (activeCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "$activeCount",
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  "Refine products by options",
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Close Filters',
          ),
        ],
      ),
    );
  }

  Widget _buildTreeFilterSection({
    required String label,
    required String attributeKey,
    required Set<String> tempSet,
    required IconData icon,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Obx(() {
      final loading = controller.isCategoryTreeLoading.value;
      final hasError =
          controller.categoryTreeErrorByType[attributeKey] == true;
      final nodes = controller.categoryTreeByType[attributeKey] ?? [];

      final selectedCount = tempSet.length;

      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selectedCount > 0
                ? colorScheme.primary.withOpacity(0.3)
                : colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            leading: Icon(
              icon,
              size: 20,
              color: selectedCount > 0
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            title: Row(
              children: [
                Text(
                  label,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (selectedCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "$selectedCount",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            children: [
              if (loading && nodes.isEmpty && !hasError)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CupertinoActivityIndicator()),
                )
              else if (hasError)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Couldn't load $label",
                          style:
                              TextStyle(fontSize: 13, color: colorScheme.error),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            controller.retryCategoryTreeType(attributeKey),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              else if (nodes.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "No $label options available",
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: nodes.map((node) {
                      final isSelected = tempSet.contains(node.slug);
                      return FilterChip(
                        label: Text(node.name),
                        selected: isSelected,
                        onSelected: (checked) {
                          setState(() {
                            if (checked) {
                              tempSet.add(node.slug);
                            } else {
                              tempSet.remove(node.slug);
                            }
                          });
                        },
                        selectedColor: colorScheme.primaryContainer,
                        checkmarkColor: colorScheme.onPrimaryContainer,
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant.withOpacity(0.6),
                          ),
                        ),
                        showCheckmark: true,
                        backgroundColor:
                            colorScheme.surfaceVariant.withOpacity(0.3),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBrandsSectionCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Obx(() {
      final loading = controller.isBrandsLoading.value;
      final brands = controller.availableBrands;
      final selectedCount = _tempBrands.length;

      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selectedCount > 0
                ? colorScheme.primary.withOpacity(0.3)
                : colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            leading: Icon(
              Icons.branding_watermark_outlined,
              size: 20,
              color: selectedCount > 0
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            title: Row(
              children: [
                Text(
                  "Brands",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (selectedCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "$selectedCount",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            children: [
              if (loading && brands.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CupertinoActivityIndicator()),
                )
              else if (brands.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "No brands available",
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: brands.map((brand) {
                      final String slug = brand['slug']?.toString() ?? '';
                      final String name =
                          brand['name']?.toString() ?? 'Unknown';
                      final isSelected = _tempBrands.contains(slug);

                      return FilterChip(
                        label: Text(name),
                        selected: isSelected,
                        onSelected: (checked) {
                          setState(() {
                            if (checked) {
                              _tempBrands.add(slug);
                            } else {
                              _tempBrands.remove(slug);
                            }
                          });
                        },
                        selectedColor: colorScheme.primaryContainer,
                        checkmarkColor: colorScheme.onPrimaryContainer,
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant.withOpacity(0.6),
                          ),
                        ),
                        showCheckmark: true,
                        backgroundColor:
                            colorScheme.surfaceVariant.withOpacity(0.3),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPriceSectionCard(ColorScheme colorScheme, TextTheme textTheme) {
    final isPriceFiltered =
        _tempPriceRange.start > 0 || _tempPriceRange.end < 10000;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPriceFiltered
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Icon(
            Icons.payments_outlined,
            size: 20,
            color: isPriceFiltered
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          title: Text(
            "Price Range",
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            "₹${_tempPriceRange.start.round()} - ₹${_tempPriceRange.end.round()}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isPriceFiltered
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: colorScheme.outlineVariant.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Min Price",
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "₹${_tempPriceRange.start.round()}",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("-",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: colorScheme.outlineVariant.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Max Price",
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "₹${_tempPriceRange.end.round()}",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _pricePresetChip("Under ₹1k", 0, 1000, colorScheme),
                _pricePresetChip("₹1k - ₹5k", 1000, 5000, colorScheme),
                _pricePresetChip("₹5k - ₹10k", 5000, 10000, colorScheme),
                _pricePresetChip("Reset", 0, 10000, colorScheme),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                rangeThumbShape: const RoundRangeSliderThumbShape(
                    enabledThumbRadius: 9, elevation: 3),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                activeTrackColor: colorScheme.primary,
                inactiveTrackColor:
                    colorScheme.primaryContainer.withOpacity(0.4),
                thumbColor: colorScheme.primary,
              ),
              child: RangeSlider(
                values: _tempPriceRange,
                min: 0,
                max: 10000,
                divisions: 100,
                labels: RangeLabels(
                  "₹${_tempPriceRange.start.round()}",
                  "₹${_tempPriceRange.end.round()}",
                ),
                onChanged: (values) => setState(() => _tempPriceRange = values),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pricePresetChip(
    String label,
    double start,
    double end,
    ColorScheme colorScheme,
  ) {
    final isSelected =
        _tempPriceRange.start == start && _tempPriceRange.end == end;

    return InkWell(
      onTap: () {
        setState(() {
          _tempPriceRange = RangeValues(start, end);
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  /// Bottom action bar restyled with TARGET's `outLineButton` (Clear All)
  /// and a themed `ElevatedButton` (Apply) rather than SOURCE's
  /// hardcoded OutlinedButton/ElevatedButton pair — Apply keeps an
  /// ElevatedButton (not `AppButton`) because it needs a leading icon and
  /// a dynamic "(N)" count label that `AppButton` doesn't support.
  Widget _buildBottomActionBar(ColorScheme colorScheme, TextTheme textTheme) {
    final activeCount = _totalSelectedCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: outLineButton(
              buttonText: "Clear All",
              backgroundColor: colorScheme.error,
              pressEvent: _clearAll,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 42,
              child: ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(
                  activeCount > 0
                      ? "Apply Filters ($activeCount)"
                      : "Apply Filters",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
