import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foddu/helpers/socket_helper.dart';
import 'package:get/get.dart';
import 'responsive_circle_icon.dart';

class ResponsiveCommonHeader extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback? onSearchTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onNotificationTap;
  final int cartItemCount;
  final int wishlistItemCount;
  final String brandTitle;

  const ResponsiveCommonHeader({
    super.key,
    required this.width,
    required this.height,
    this.onSearchTap,
    this.onCartTap,
    this.onWishlistTap,
    this.onMessageTap,
    this.onNotificationTap,
    this.cartItemCount = 0,
    this.wishlistItemCount = 0,
    this.brandTitle = 'Kharido',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top Brand Bar ──
              Row(
                children: [
                  // Drawer / Menu icon
                  if (onMessageTap != null) ...[
                    ResponsiveCircleIcon(
                      icon: Icons.menu_rounded,
                      height: height,
                      width: width,
                      onTap: onMessageTap,
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Brand Title
                  Expanded(
                    child: Text(
                      brandTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.6,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),

                  if (kIsWeb)
                    Obx(
                      () => Container(
                        margin: const EdgeInsets.only(right: 4),
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          color: SocketHelper().isConnectedObs.value
                              ? colorScheme.primary
                              : colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                  // Wishlist Icon with reactive badge
                  if (onWishlistTap != null) ...[
                    ResponsiveCircleIcon(
                      icon: Icons.favorite_border_rounded,
                      height: height,
                      width: width,
                      onTap: onWishlistTap,
                      badgeCount: wishlistItemCount,
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Notification icon
                  if (onNotificationTap != null) ...[
                    ResponsiveCircleIcon(
                      icon: Icons.notifications_none_rounded,
                      height: height,
                      width: width,
                      onTap: onNotificationTap,
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Cart icon with reactive badge
                  if (onCartTap != null) ...[
                    ResponsiveCircleIcon(
                      icon: Icons.shopping_bag_outlined,
                      height: height,
                      width: width,
                      onTap: onCartTap,
                      badgeCount: cartItemCount,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 10),

              // ── Search Pill Bar ──
              GestureDetector(
                onTap: onSearchTap,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Search for products, collections...",
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
