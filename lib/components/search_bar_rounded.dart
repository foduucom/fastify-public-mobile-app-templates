// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';

class SearchBarRounded extends StatelessWidget {
  const SearchBarRounded(
      {Key? key,
      required this.searchHintText,
      required this.SearchsController,
      this.focusNode,
      this.icon,
      required this.onChanged,
      this.onFieldSubmitted})
      : super(key: key);

  final String searchHintText;
  final TextEditingController SearchsController;

  final IconData? icon;
  final Function(String) onChanged;
  final FocusNode? focusNode;
  final Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: SearchsController,
      focusNode: focusNode,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      cursorColor: context.themePrimaryColor,
      onSaved: (String? value) {},
      style: TextStyle(fontSize: 14),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        hintText: searchHintText,
        focusColor: context.themeSecondryColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(themeButtonRadius),
          borderSide: BorderSide(color: context.themegreyColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.themegreyColor),
          borderRadius: BorderRadius.circular(themeButtonRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.themegreyColor),
          borderRadius: BorderRadius.circular(themeButtonRadius),
        ),
        fillColor: context.themegreyColor,
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 20,
          color: context.themeSecondrytext,
        ),
        // suffixIcon: TextButton(
        //   onPressed: () {},
        //   child: const Icon(
        //     Icons.camera_alt_outlined,
        //     color: themeSecondrytext,
        //     size: 20,
        //   ),
        //   style: ButtonStyle(
        //     minimumSize: MaterialStateProperty.all(Size.zero),
        //     padding: MaterialStateProperty.all(EdgeInsets.zero),
        //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        //       RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(33.0),
        //       ),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
