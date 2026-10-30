import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/filter_model.dart';

/// Opens the filter bottom sheet and returns the applied [FilterModel],
/// or `null` if dismissed without applying.
Future<FilterModel?> showFilterBottomSheet(
  BuildContext context,
  FilterModel currentFilter,
) {
  return showModalBottomSheet<FilterModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FilterSheet(initial: currentFilter),
  );
}

// ── Sort option helper ──────────────────────────────────────────────────────
class _SortOption {
  final String label;
  final String? sortBy;
  final String? sortOrder;

  const _SortOption(this.label, this.sortBy, this.sortOrder);
}

const _sortOptions = [
  _SortOption('Relevance', null, null),
  _SortOption('Price: Low → High', 'price', 'asc'),
  _SortOption('Price: High → Low', 'price', 'desc'),
  _SortOption('Newest First', 'created_at', 'desc'),
];

// ── Filter Sheet ────────────────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  final FilterModel initial;
  const _FilterSheet({required this.initial});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  // ── Local state mirrors FilterModel fields ──
  late RangeValues _priceRange;
  late bool _priceRangeActive;
  late bool _featured;
  late bool _hot;
  late bool _trending;
  late bool _recommended;
  late List<String> _categories;
  late List<String> _parentCategories;
  late List<String> _specific;
  late List<String> _brands;
  late int _sortIndex;

  // Price bounds
  static const double _priceMin = 0;
  static const double _priceMax = 10000;

  @override
  void initState() {
    super.initState();
    _initFromModel(widget.initial);
  }

  void _initFromModel(FilterModel m) {
    final hasPrice = m.minPrice != null || m.maxPrice != null;
    _priceRangeActive = hasPrice;
    _priceRange = RangeValues(
      m.minPrice ?? _priceMin,
      m.maxPrice ?? _priceMax,
    );
    _featured = m.featured;
    _hot = m.hot;
    _trending = m.trending;
    _recommended = m.recommended;
    _categories = List.from(m.categories);
    _parentCategories = List.from(m.parentCategories);
    _specific = List.from(m.specific);
    _brands = List.from(m.brands);
    _sortIndex = _sortOptions.indexWhere(
      (o) => o.sortBy == m.sortBy && o.sortOrder == m.sortOrder,
    );
    if (_sortIndex < 0) _sortIndex = 0;
  }

  void _reset() {
    setState(() => _initFromModel(const FilterModel.empty()));
  }

  FilterModel _buildModel() {
    return FilterModel(
      minPrice: _priceRangeActive && _priceRange.start > _priceMin
          ? _priceRange.start
          : null,
      maxPrice: _priceRangeActive && _priceRange.end < _priceMax
          ? _priceRange.end
          : null,
      featured: _featured,
      hot: _hot,
      trending: _trending,
      recommended: _recommended,
      categories: _categories,
      parentCategories: _parentCategories,
      specific: _specific,
      brands: _brands,
      sortBy: _sortOptions[_sortIndex].sortBy,
      sortOrder: _sortOptions[_sortIndex].sortOrder,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(colorScheme, textTheme),

            // ── Scrollable content ──
            Expanded(
              child: ListView(
                controller: scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  _buildSortSection(colorScheme, textTheme),
                  const SizedBox(height: 20),
                  _buildPriceSection(colorScheme, textTheme),
                  const SizedBox(height: 20),
                  _buildFlagsSection(colorScheme, textTheme),
                  const SizedBox(height: 20),
                  _buildListSection(
                    'Categories',
                    _categories,
                    [], // available options — populate when API provides them
                    (updated) => setState(() => _categories = updated),
                    colorScheme,
                    textTheme,
                  ),
                  _buildListSection(
                    'Parent Categories',
                    _parentCategories,
                    [],
                    (updated) => setState(() => _parentCategories = updated),
                    colorScheme,
                    textTheme,
                  ),
                  _buildListSection(
                    'Specific',
                    _specific,
                    [],
                    (updated) => setState(() => _specific = updated),
                    colorScheme,
                    textTheme,
                  ),
                  _buildListSection(
                    'Brands',
                    _brands,
                    [],
                    (updated) => setState(() => _brands = updated),
                    colorScheme,
                    textTheme,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ── Bottom bar ──
            _buildBottomBar(colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: colorScheme.onSurfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: colorScheme.outline.withOpacity(0.15)),
      ],
    );
  }

  // ── Sort Section ──────────────────────────────────────────────────────────
  Widget _buildSortSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sort By',
            style: textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_sortOptions.length, (i) {
            final selected = i == _sortIndex;
            return ChoiceChip(
              label: Text(_sortOptions[i].label),
              selected: selected,
              onSelected: (_) => setState(() => _sortIndex = i),
              selectedColor: colorScheme.primary.withOpacity(0.15),
              labelStyle: textTheme.bodySmall?.copyWith(
                color: selected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Price Range Section ───────────────────────────────────────────────────
  Widget _buildPriceSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Price Range',
                style: textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            Switch(
              value: _priceRangeActive,
              onChanged: (v) => setState(() => _priceRangeActive = v),
              activeColor: colorScheme.primary,
            ),
          ],
        ),
        if (_priceRangeActive) ...[
          RangeSlider(
            values: _priceRange,
            min: _priceMin,
            max: _priceMax,
            divisions: 100,
            activeColor: colorScheme.primary,
            inactiveColor: colorScheme.primary.withOpacity(0.15),
            labels: RangeLabels(
              '₹${_priceRange.start.round()}',
              '₹${_priceRange.end.round()}',
            ),
            onChanged: (v) => setState(() => _priceRange = v),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PriceField(
                  label: 'Min',
                  value: _priceRange.start,
                  onChanged: (v) {
                    if (v >= _priceMin && v <= _priceRange.end) {
                      setState(() =>
                          _priceRange = RangeValues(v, _priceRange.end));
                    }
                  },
                ),
                Container(
                  width: 24,
                  height: 1,
                  color: colorScheme.outline.withOpacity(0.3),
                ),
                _PriceField(
                  label: 'Max',
                  value: _priceRange.end,
                  onChanged: (v) {
                    if (v >= _priceRange.start && v <= _priceMax) {
                      setState(() =>
                          _priceRange = RangeValues(_priceRange.start, v));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Product Flags Section ─────────────────────────────────────────────────
  Widget _buildFlagsSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product Type',
            style:
                textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _flagTile('Featured', _featured, (v) => setState(() => _featured = v),
            Icons.star, Colors.amber.shade700, colorScheme),
        _flagTile('Hot', _hot, (v) => setState(() => _hot = v),
            Icons.local_fire_department, Colors.red.shade600, colorScheme),
        _flagTile('Trending', _trending, (v) => setState(() => _trending = v),
            Icons.trending_up, Colors.purple.shade600, colorScheme),
        _flagTile(
            'Recommended',
            _recommended,
            (v) => setState(() => _recommended = v),
            Icons.thumb_up,
            Colors.green.shade600,
            colorScheme),
      ],
    );
  }

  Widget _flagTile(String label, bool value, ValueChanged<bool> onChanged,
      IconData icon, Color iconColor, ColorScheme colorScheme) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
      value: value,
      onChanged: onChanged,
      activeColor: colorScheme.primary,
      dense: true,
    );
  }

  // ── Multi-select list section (future-proof) ──────────────────────────────
  Widget _buildListSection(
    String title,
    List<String> selected,
    List<String> available,
    ValueChanged<List<String>> onChanged,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (available.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: available.map((item) {
            final isSelected = selected.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (sel) {
                final updated = List<String>.from(selected);
                sel ? updated.add(item) : updated.remove(item);
                onChanged(updated);
              },
              selectedColor: colorScheme.primary.withOpacity(0.15),
              checkmarkColor: colorScheme.primary,
              labelStyle: TextStyle(
                color:
                    isSelected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.3),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── Bottom Bar (Reset + Apply) ────────────────────────────────────────────
  Widget _buildBottomBar(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withOpacity(0.15)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Reset',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => Get.back(result: _buildModel()),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Apply Filters',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Price text-field helper ─────────────────────────────────────────────────
class _PriceField extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _PriceField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 120,
      child: TextFormField(
        initialValue: value.round().toString(),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixText: '₹ ',
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: colorScheme.outline.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: colorScheme.outline.withOpacity(0.3)),
          ),
        ),
        onChanged: (text) {
          final parsed = double.tryParse(text);
          if (parsed != null) onChanged(parsed);
        },
      ),
    );
  }
}
