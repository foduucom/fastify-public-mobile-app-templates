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
    return TextFormField(
      controller: SearchsController,
      onChanged: onChanged,
      onSaved: (String? value) {},
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        hintText: searchHintText,
        // focusColor: themeSecondryColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(03),
          borderSide: const BorderSide(),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(),
          borderRadius: BorderRadius.circular(03),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(),
          borderRadius: BorderRadius.circular(03),
        ),
        // fillColor: themegreyColor,
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          // color: themeSecondrytext,
        ),
      ),
    );
  }
}
