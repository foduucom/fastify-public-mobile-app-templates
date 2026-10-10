import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/data/models/region_model.dart';

typedef RegionLoader = Future<RegionPage> Function(int page, String search);

/// Searchable, infinitely scrolling picker for countries / states.
Future<Region?> showRegionPicker(
  BuildContext context, {
  required String title,
  required String searchHint,
  required RegionLoader loader,
  String? selectedId,
}) {
  return showModalBottomSheet<Region>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _RegionPickerSheet(
        title: title,
        searchHint: searchHint,
        loader: loader,
        selectedId: selectedId,
      ),
    ),
  );
}

class _RegionPickerSheet extends StatefulWidget {
  final String title;
  final String searchHint;
  final RegionLoader loader;
  final String? selectedId;

  const _RegionPickerSheet({
    required this.title,
    required this.searchHint,
    required this.loader,
    this.selectedId,
  });

  @override
  State<_RegionPickerSheet> createState() => _RegionPickerSheetState();
}

class _RegionPickerSheetState extends State<_RegionPickerSheet> {
  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  final List<Region> _items = [];
  bool _loading = false;
  bool _hasNext = false;
  bool _error = false;
  int _nextPage = 1;
  // Guards against a slow earlier request overwriting a newer search.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 100) {
        _load();
      }
    });
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      _generation++;
      _items.clear();
      _nextPage = 1;
      _hasNext = false;
      _loading = false;
    }
    if (_loading || (!reset && !_hasNext && _items.isNotEmpty)) return;
    final gen = _generation;
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final result = await widget.loader(_nextPage, _searchCtrl.text);
      if (!mounted || gen != _generation) return;
      setState(() {
        _items.addAll(result.items);
        _hasNext = result.hasNext;
        _nextPage = result.nextPage;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || gen != _generation) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _load(reset: true));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(widget.title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface)),
          const SizedBox(height: 12),
          TextField(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            style: TextStyle(color: cs.onSurface, fontSize: 14),
            decoration: InputDecoration(
              hintText: widget.searchHint,
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: cs.outline),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(child: _buildList(context)),
        ],
      ),
    ),
  );
}

  Widget _buildList(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (_items.isEmpty) {
      if (_loading) {
        return const SizedBox(
            height: 160, child: Center(child: CircularProgressIndicator()));
      }
      return SizedBox(
        height: 160,
        child: Center(
          child: _error
              ? TextButton.icon(
                  onPressed: () => _load(reset: true),
                  icon: const Icon(Icons.refresh),
                  label: Text('Retry'.tr))
              : Text('No results'.tr,
                  style: TextStyle(color: cs.onSurface)),
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      shrinkWrap: true,
      itemCount: _items.length + ((_loading || _error) ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= _items.length) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: _error
                  ? TextButton(
                      onPressed: () => _load(), child: Text('Retry'.tr))
                  : const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }
        final r = _items[i];
        final selected = r.id == widget.selectedId;
        return ListTile(
          dense: true,
          title: Text(r.name,
              style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
          trailing: selected
              ? Icon(Icons.check, color: cs.primary)
              : null,
          onTap: () => Navigator.of(context).pop(r),
        );
      },
    );
  }
}
