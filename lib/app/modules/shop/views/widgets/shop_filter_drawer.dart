import 'package:zouhi/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';
import 'package:zouhi/app/data/category_filter_service.dart';
import 'package:zouhi/app/modules/shop/controllers/shop_controller.dart';

/// Sliding Filter drawer: Category / Price / Material / Style / Brands.
/// Selections are staged in local state and only committed to
/// [ShopController] when "Apply Filters" is tapped — closing the drawer
/// without applying discards in-progress changes. Fully local, no CMS.
class ShopFilterDrawer extends StatefulWidget {
  final ShopController controller;

  const ShopFilterDrawer({super.key, required this.controller});

  @override
  State<ShopFilterDrawer> createState() => _ShopFilterDrawerState();
}

class _ShopFilterDrawerState extends State<ShopFilterDrawer> {
  Set<String> _tempCategories = {};
  Set<String> _tempMaterials = {};
  Set<String> _tempStyles = {};
  Set<String> _tempBrands = {};
  late RangeValues _tempPriceRange;
  Worker? _openWorker;

  ShopController get controller => widget.controller;

  String get _currencySymbol {
    if (Get.isRegistered<CurrencyController>()) {
      return Get.find<CurrencyController>()
              .selectedCurrency['symbol']
              ?.toString() ??
          currency;
    }
    return currency;
  }

  double get _absMin => controller.absoluteMinPrice.value;
  double get _absMax {
    final max = controller.absoluteMaxPrice.value;
    return max <= _absMin ? _absMin + 1.0 : max;
  }

  @override
  void initState() {
    super.initState();
    _seedTempStateFromController();
    controller.ensureFilterDataLoaded();
    controller.ensureCategoryTreeLoaded();
    // Re-seed every time the drawer is opened (set by ShopView).
    _openWorker = ever(controller.filterDrawerOpenTick, (_) {
      if (!mounted) return;
      setState(_seedTempStateFromController);
    });
  }

  @override
  void dispose() {
    _openWorker?.dispose();
    super.dispose();
  }

  void _seedTempStateFromController() {
    _tempCategories = Set.from(controller.selectedCategories);
    if (controller.parentCategoryFilter.value.isNotEmpty) {
      _tempCategories.add(controller.parentCategoryFilter.value);
    }
    _tempMaterials = Set.from(controller.selectedAttributes['material'] ?? {});
    _tempStyles = Set.from(controller.selectedAttributes['style'] ?? {});
    _tempBrands = Set.from(controller.selectedBrands);
    _tempPriceRange = _clampRange(controller.currentPriceRange.value);
  }

  RangeValues _clampRange(RangeValues r) {
    final start = r.start.clamp(_absMin, _absMax).toDouble();
    final end = r.end.clamp(start, _absMax).toDouble();
    return RangeValues(start, end);
  }

  bool get _isPriceFiltered =>
      _tempPriceRange.start > _absMin || _tempPriceRange.end < _absMax;

  int get _totalSelectedCount {
    int count = _tempCategories.length +
        _tempMaterials.length +
        _tempStyles.length +
        _tempBrands.length;
    if (_isPriceFiltered) count++;
    return count;
  }

  String _price(double v) =>
      '$_currencySymbol${controller.formatPriceForInput(v)}';

  void _clearAll() {
    setState(() {
      _tempCategories = {};
      _tempMaterials = {};
      _tempStyles = {};
      _tempBrands = {};
      _tempPriceRange = RangeValues(_absMin, _absMax);
    });
    controller.clearAllFilters();
    Navigator.pop(context);
  }

  void _applyFilters() {
    Navigator.pop(context);
    controller.applyStagedFilters(
      categories: _tempCategories,
      // materials: _tempMaterials,
      // styles: _tempStyles,
      // brands: _tempBrands,
      priceRange: _tempPriceRange,
    );
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
                      label: 'Category',
                      attributeKey: 'product',
                      tempSet: _tempCategories,
                      icon: Icons.category_outlined,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 12),
                    _buildPriceSectionCard(colorScheme, textTheme),
                    // const SizedBox(height: 12),
                    // _buildTreeFilterSection(
                    //   label: 'Material',
                    //   attributeKey: 'material',
                    //   tempSet: _tempMaterials,
                    //   icon: Icons.layers_outlined,
                    //   colorScheme: colorScheme,
                    //   textTheme: textTheme,
                    // ),
                    // const SizedBox(height: 12),
                    // _buildTreeFilterSection(
                    //   label: 'Style',
                    //   attributeKey: 'style',
                    //   tempSet: _tempStyles,
                    //   icon: Icons.style_outlined,
                    //   colorScheme: colorScheme,
                    //   textTheme: textTheme,
                    // ),
                    // const SizedBox(height: 12),
                    // _buildBrandsSectionCard(colorScheme, textTheme),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomActionBar(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(ColorScheme colorScheme, TextTheme textTheme) {
    final activeCount = _totalSelectedCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 14),
      color: colorScheme.surface,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(Icons.tune_rounded, color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Filters',
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
                          '$activeCount',
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
                  'Refine products by options',
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

  /// Nodes for a tree type; Category falls back to the already-loaded
  /// category list if the tree endpoint returns nothing.
  List<CategoryTreeNode> _nodesFor(String type) {
    final nodes = controller.categoryTreeByType[type] ?? const [];
    if (nodes.isNotEmpty || type != 'product') return nodes;
    final source = controller.allCategories.isNotEmpty
        ? controller.allCategories
        : controller.availableCategories;
    return source
        .whereType<Map>()
        .map((e) => CategoryTreeNode.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Widget _sectionCard({
    required ColorScheme colorScheme,
    required bool highlighted,
    required IconData icon,
    required Widget title,
    Widget? subtitle,
    required List<Widget> children,
  }) {
    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: highlighted
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Icon(
            icon,
            size: 20,
            color: highlighted
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          title: title,
          subtitle: subtitle,
          children: children,
        ),
      ),
    );
  }

  Widget _sectionTitle(
      String label, int selectedCount, ColorScheme colorScheme, TextTheme t) {
    return Row(
      children: [
        Text(
          label,
          style: t.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        if (selectedCount > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$selectedCount',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _chip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
    required ColorScheme colorScheme,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: colorScheme.primary.withOpacity(0.15),
      checkmarkColor: colorScheme.primary,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outlineVariant.withOpacity(0.6),
        ),
      ),
      showCheckmark: true,
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
    );
  }

  Widget _treeFilterSectionBody(String label, String attributeKey,
      Set<String> tempSet, ColorScheme colorScheme) {
    final loading = controller.isCategoryTreeLoading.value;
    final hasError = controller.categoryTreeErrorByType[attributeKey] == true;
    final nodes = _nodesFor(attributeKey);

    if (loading && nodes.isEmpty && !hasError) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    if (hasError && nodes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Couldn't load $label",
                style: TextStyle(fontSize: 13, color: colorScheme.error),
              ),
            ),
            TextButton.icon(
              onPressed: () => controller.retryCategoryTreeType(attributeKey),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (nodes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'No $label options available',
          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: nodes.map((node) {
          return _chip(
            label: node.name,
            isSelected: tempSet.contains(node.slug),
            colorScheme: colorScheme,
            onSelected: (checked) => setState(() {
              checked ? tempSet.add(node.slug) : tempSet.remove(node.slug);
            }),
          );
        }).toList(),
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
      return _sectionCard(
        colorScheme: colorScheme,
        highlighted: tempSet.isNotEmpty,
        icon: icon,
        title: _sectionTitle(label, tempSet.length, colorScheme, textTheme),
        children: [
          _treeFilterSectionBody(label, attributeKey, tempSet, colorScheme)
        ],
      );
    });
  }

  Widget _buildBrandsSectionCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Obx(() {
      final loading = controller.isBrandsLoading.value;
      final brands = controller.availableBrands.toList();

      Widget body;
      if (loading && brands.isEmpty) {
        body = const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CupertinoActivityIndicator()),
        );
      } else if (brands.isEmpty) {
        body = Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'No brands available',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
        );
      } else {
        body = Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: brands.map((brand) {
              final slug = brand['slug']?.toString() ?? '';
              final name = brand['name']?.toString() ?? 'Unknown';
              return _chip(
                label: name,
                isSelected: _tempBrands.contains(slug),
                colorScheme: colorScheme,
                onSelected: (checked) => setState(() {
                  checked ? _tempBrands.add(slug) : _tempBrands.remove(slug);
                }),
              );
            }).toList(),
          ),
        );
      }

      return _sectionCard(
        colorScheme: colorScheme,
        highlighted: _tempBrands.isNotEmpty,
        icon: Icons.branding_watermark_outlined,
        title:
            _sectionTitle('Brands', _tempBrands.length, colorScheme, textTheme),
        children: [body],
      );
    });
  }

  Widget _priceBox(String label, double value, ColorScheme colorScheme,
      TextTheme textTheme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _price(value),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSectionCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Obx(() {
      final min = _absMin;
      final max = _absMax;
      final range = _clampRange(_tempPriceRange);
      final third = (max - min) / 3;

      return _sectionCard(
        colorScheme: colorScheme,
        highlighted: _isPriceFiltered,
        icon: Icons.payments_outlined,
        title: Text(
          'Price Range',
          style: textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          '${_price(range.start)} - ${_price(range.end)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _isPriceFiltered
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          const SizedBox(height: 6),
          Row(
            children: [
              _priceBox('Min Price', range.start, colorScheme, textTheme),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('-',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              _priceBox('Max Price', range.end, colorScheme, textTheme),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _pricePresetChip('Low', min, min + third, colorScheme),
              _pricePresetChip(
                  'Mid', min + third, min + 2 * third, colorScheme),
              _pricePresetChip('High', min + 2 * third, max, colorScheme),
              _pricePresetChip('Reset', min, max, colorScheme),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              rangeThumbShape: const RoundRangeSliderThumbShape(
                  enabledThumbRadius: 9, elevation: 3),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.primary.withOpacity(0.2),
              thumbColor: colorScheme.primary,
            ),
            child: RangeSlider(
              values: range,
              min: min,
              max: max,
              divisions: 100,
              labels: RangeLabels(_price(range.start), _price(range.end)),
              onChanged: (values) => setState(() => _tempPriceRange = values),
            ),
          ),
        ],
      );
    });
  }

  Widget _pricePresetChip(
      String label, double start, double end, ColorScheme colorScheme) {
    final isSelected = (_tempPriceRange.start - start).abs() < 0.01 &&
        (_tempPriceRange.end - end).abs() < 0.01;

    return InkWell(
      onTap: () => setState(() => _tempPriceRange = RangeValues(start, end)),
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

  Widget _buildBottomActionBar(ColorScheme colorScheme) {
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
            child: OutlinedButton.icon(
              onPressed: _clearAll,
              icon: const Icon(Icons.restart_alt_rounded, size: 18),
              label: const Text('Clear All'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.8)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _applyFilters,
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: Text(
                activeCount > 0
                    ? 'Apply Filters ($activeCount)'
                    : 'Apply Filters',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
