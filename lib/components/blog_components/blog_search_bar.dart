import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/blog/controller/blog_controller.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class BlogSearchBar extends StatefulWidget {
  final String placeholder;
  final ValueChanged<String>? onChanged;

  const BlogSearchBar({
    Key? key,
    this.placeholder = 'Search articles, guides and reviews',
    this.onChanged,
  }) : super(key: key);

  factory BlogSearchBar.fromMap(Map<String, dynamic>? json) {
    return BlogSearchBar(
      placeholder: (json?['placeholder'] ?? 'Search articles, guides and reviews')
          .toString(),
    );
  }

  @override
  State<BlogSearchBar> createState() => _BlogSearchBarState();
}

class _BlogSearchBarState extends State<BlogSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    if (Get.isRegistered<BlogController>()) {
      _controller.text = Get.find<BlogController>().searchQuery.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChange(String val) {
    widget.onChanged?.call(val);
    if (Get.isRegistered<BlogController>()) {
      Get.find<BlogController>().onSearchChanged(val);
    }
    setState(() {});
  }

  void _clearSearch() {
    _controller.clear();
    _onTextChange('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          onChanged: _onTextChange,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13.5,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 22,
              color: colorScheme.primary,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.cancel_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
        ),
      ),
    );
  }
}
