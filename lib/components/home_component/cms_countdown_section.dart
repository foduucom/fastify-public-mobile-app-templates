import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/app/modules/shop/shop_navigation.dart';
import '/app/routes/app_pages.dart';
import '/constants/constants.dart';

/// Renders a CMS countdown using its configured end date and copy.
/// Expired or missing dates are shown honestly; the timer never resets itself.
class CmsCountdownSection extends StatefulWidget {
  const CmsCountdownSection({super.key, required this.content});

  final Map<String, dynamic> content;

  @override
  State<CmsCountdownSection> createState() => _CmsCountdownSectionState();
}

class _CmsCountdownSectionState extends State<CmsCountdownSection> {
  Timer? _ticker;
  DateTime? _endAt;
  Duration _remaining = Duration.zero;

  Map<String, dynamic> get _item {
    final slider = widget.content['slider'];
    if (slider is Map) {
      final entries = slider['content'];
      if (entries is List && entries.isNotEmpty && entries.first is Map) {
        return Map<String, dynamic>.from(entries.first as Map);
      }
    }
    return widget.content;
  }

  @override
  void initState() {
    super.initState();
    _readEndDate();
  }

  @override
  void didUpdateWidget(covariant CmsCountdownSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) _readEndDate();
  }

  void _readEndDate() {
    _ticker?.cancel();
    final item = _item;
    final rawDate = item['expiry_date'] ?? item['end_date'] ?? item['expiry'];
    _endAt = rawDate == null ? null : DateTime.tryParse(rawDate.toString());
    _tick();
    if (_endAt != null && _remaining > Duration.zero) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      final endAt = _endAt;
      _remaining =
          endAt == null ? Duration.zero : endAt.difference(DateTime.now());
      if (_remaining.isNegative) _remaining = Duration.zero;
      if (_remaining == Duration.zero) {
        _ticker?.cancel();
        _ticker = null;
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  void _openOffer() {
    final link = (_item['link'] ?? _item['product_id'] ?? '').toString().trim();
    if (link.isEmpty) return;
    if (link.startsWith('http://') || link.startsWith('https://')) {
      Get.toNamed(Routes.PRODUCTDETAILS, arguments: {'productId': link});
    } else {
      openShop({'name': _title, 'source': 'countdown', 'productId': link});
    }
  }

  String get _title {
    final item = _item;
    final value = (item['heading'] ??
            item['title'] ??
            item['sub_heading'] ??
            'Limited time offer')
        .toString()
        .trim();
    return value.isEmpty ? 'Limited time offer' : value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final item = _item;
    final description =
        (item['description'] ?? item['subtitle'] ?? '').toString().trim();
    final hasEndDate = _endAt != null;
    final expired = hasEndDate && _remaining == Duration.zero;
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return Padding(
      padding: pageSurroundingPadding,
      child: Card(
        elevation: 0,
        color: colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.timer_outlined, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_title, style: theme.textTheme.titleMedium),
                  ),
                ],
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(description, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: 14),
              if (!hasEndDate)
                Text('Offer timing unavailable',
                    style: theme.textTheme.bodySmall),
              if (hasEndDate)
                Row(
                  children: [
                    Expanded(
                        child: _timePart(
                            context, expired ? 'Ended' : '${days}d', 'DAYS')),
                    Expanded(
                        child: _timePart(context, _twoDigits(hours), 'HRS')),
                    Expanded(
                        child: _timePart(context, _twoDigits(minutes), 'MINS')),
                    Expanded(
                        child: _timePart(context, _twoDigits(seconds), 'SECS')),
                  ],
                ),
              if ((_item['link'] ?? _item['product_id']) != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: expired ? null : _openOffer,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label:
                        Text((item['button_text'] ?? 'View offer').toString()),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _timePart(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
