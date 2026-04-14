// import 'dart:html';

// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/material/responsive_circle_icon.dart';

// ── CUSTOM HEADER WIDGET ──
class SearchViewHeader extends StatelessWidget {
  const SearchViewHeader({
    Key? key,
    required this.width,
    required this.height,
    required this.searchTextController,
    required this.onSearchChanged,
    this.onCartTap,
    this.onMessageTap,
    this.onNotificationTap,
  }) : super(key: key);

  final double width;
  final double height;
  final TextEditingController searchTextController;
  final Function(String) onSearchChanged;
  final VoidCallback? onCartTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: height * 0.015,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔍 Search Bar Container (Provides border and background)
          Expanded(
            child: Container(
              height: height * 0.055,
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.02,
                vertical: height * 0.008,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]!
                      : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: height * 0.025,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                  SizedBox(width: width * 0.02),

                  /// TextFormField - No borders, just plain text input
                  Expanded(
                    child: TextFormField(
                      controller: searchTextController,
                      onChanged: onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: "Search products, categories...",
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontSize: height * 0.018,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: width * 0.02),

          /// 🛒 Cart
          ResponsiveCircleIcon(
            icon: Icons.shopping_bag_outlined,
            height: height,
            width: width,
            onTap: onCartTap,
          ),

          SizedBox(width: width * 0.01),

          /// 💬 Messages
          ResponsiveCircleIcon(
            icon: Icons.message_outlined,
            height: height,
            width: width,
            onTap: onMessageTap,
          ),

          SizedBox(width: width * 0.02),

          /// 🔔 Notifications
          ResponsiveCircleIcon(
            icon: Icons.notifications_none,
            height: height,
            width: width,
            onTap: onNotificationTap,
          ),
        ],
      ),
    );
  }
}
