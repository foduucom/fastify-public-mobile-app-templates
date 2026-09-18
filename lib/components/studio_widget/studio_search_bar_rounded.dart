import 'package:flutter/material.dart';

class SearchBarRounded extends StatelessWidget {
  const SearchBarRounded({
    Key? key,
    required this.searchHintText,
    required this.SearchsController,
    this.icon,
    required this.onChanged,
    this.onFilterTap,
  }) : super(key: key);

  final String searchHintText;
  final TextEditingController SearchsController;
  final IconData? icon;
  final Function(String) onChanged;

  /// PORT_AUDIT.md Phase 4 — the trailing "tune" icon was previously
  /// decorative only. Optional so existing call sites (CMS `search`
  /// section registration) keep working unchanged; screens that need a
  /// filter entry point (e.g. Shop) can now pass a callback.
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        // You can add navigation here if needed, or let the TextField handle focus
        // For now, just focus the TextField when tapped
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              icon ?? Icons.search,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: SearchsController,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: searchHintText,
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: colorScheme.onInverseSurface,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.tune,
                  color: colorScheme.onSurfaceVariant,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
