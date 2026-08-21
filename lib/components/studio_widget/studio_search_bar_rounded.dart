// import 'dart:html';

// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';

class SearchBarRounded extends StatelessWidget {
  const SearchBarRounded(
      {Key? key,
      required this.searchHintText,
      required this.SearchsController,
      this.icon,
      required this.onChanged})
      : super(key: key);

  final String searchHintText;
  final TextEditingController SearchsController;
  final IconData? icon;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: SearchsController,
      onChanged: onChanged,
      onSaved: (String? value) {},
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        hintText: searchHintText,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(
          icon ?? Icons.search,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
