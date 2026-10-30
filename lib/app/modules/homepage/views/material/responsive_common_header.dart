import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'responsive_circle_icon.dart';

class ResponsiveCommonHeader extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback? onSearchTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onNotificationTap;

  const ResponsiveCommonHeader({
    super.key,
    required this.width,
    required this.height,
    this.onSearchTap,
    this.onCartTap,
    this.onMessageTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: 8,
          ),
          child: Row(
            children: [
              // Drawer / Menu icon
              if (onMessageTap != null) ...[
                ResponsiveCircleIcon(
                  icon: Icons.menu_rounded,
                  height: height,
                  width: width,
                  onTap: onMessageTap,
                ),
                SizedBox(width: width * 0.025),
              ],

              // Search bar placeholder
              Expanded(
                child: GestureDetector(
                  onTap: onSearchTap,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Search products...",
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Notification / Cart icons
              if (onNotificationTap != null) ...[
                SizedBox(width: width * 0.02),
                ResponsiveCircleIcon(
                  icon: Icons.notifications_none_rounded,
                  height: height,
                  width: width,
                  onTap: onNotificationTap,
                ),
              ],

              if (onCartTap != null) ...[
                SizedBox(width: width * 0.02),
                ResponsiveCircleIcon(
                  icon: Icons.shopping_bag_outlined,
                  height: height,
                  width: width,
                  onTap: onCartTap,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

