import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/material/responsive_circle_icon.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/commonWidgets/arrow_tooltip.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '/helpers/socket_helper.dart';

class ResponsiveCommonHeader extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onNotificationTap;
  final double width;
  final double height;

  const ResponsiveCommonHeader({
    Key? key,
    required this.width,
    required this.height,
    this.onSearchTap,
    this.onCartTap,
    this.onMessageTap,
    this.onNotificationTap,
  }) : super(key: key);

  String _resolveStoreName() {
    final stored = GetStorage().read('store_name')?.toString().trim() ?? '';
    if (stored.isNotEmpty) return stored;
    if (appName.trim().isNotEmpty && appName.toLowerCase() != 'store') {
      return appName;
    }
    return 'FODUU Electro';
  }

  String _resolveStoreLogoUrl() {
    final raw = GetStorage().read('store_logo')?.toString().trim() ?? '';
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return HelperFunctions().fixImageUrl(raw);
    }
    if (raw.startsWith('/')) {
      return HelperFunctions().fixImageUrl('$url${raw.substring(1)}');
    }
    if (raw.startsWith('images/') || raw.startsWith('uploads/')) {
      return HelperFunctions().fixImageUrl('$url$raw');
    }
    return HelperFunctions().fixImageUrl('${url}images/$raw');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final storeName = _resolveStoreName();
    final logoUrl = _resolveStoreLogoUrl();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: 10.0,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.08),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Row 1: Drawer Toggle, Brand Identity & Top Action Icons
          Row(
            children: [
              ArrowTooltip(
                message: 'Open Menu',
                direction: ArrowDirection.top,
                child: ResponsiveCircleIcon(
                  icon: Icons.menu_rounded,
                  height: height,
                  width: width,
                  onTap: onMessageTap,
                ),
              ),
              const SizedBox(width: 12),

              /// Dynamic Brand Identity (Backend logo or crisp native wordmark)
              Expanded(
                child: _BrandIdentityLockup(
                  storeName: storeName,
                  logoUrl: logoUrl,
                ),
              ),

              if (kIsWeb)
                Obx(
                  () => ArrowTooltip(
                    message: SocketHelper().isConnectedObs.value
                        ? 'Live Sync Connected'
                        : 'Live Sync Offline',
                    direction: ArrowDirection.top,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: SocketHelper().isConnectedObs.value
                            ? Colors.green
                            : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

              /// Notification Icon
              ArrowTooltip(
                message: 'Notifications & Alerts',
                direction: ArrowDirection.top,
                child: ResponsiveCircleIcon(
                  icon: Icons.notifications_none_rounded,
                  height: height,
                  width: width,
                  onTap: onNotificationTap ??
                      () => Get.toNamed(Routes.NOTIFICATION),
                  showDot: false,
                ),
              ),

              const SizedBox(width: 8),

              /// Cart Icon with Live Reactive Badge
              Obx(() {
                final cartCount = Get.isRegistered<CartService>()
                    ? CartService.to.cartItems.length
                    : 0;

                return ArrowTooltip(
                  message: cartCount > 0
                      ? 'View Cart ($cartCount items)'
                      : 'Your Shopping Cart',
                  direction: ArrowDirection.top,
                  child: ResponsiveCircleIcon(
                    icon: Icons.shopping_bag_outlined,
                    height: height,
                    width: width,
                    badgeCount: cartCount,
                    onTap: onCartTap,
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 10),

          /// Row 2: Modern Full-Width Search Bar with Filter Action
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSearchTap ?? () => Get.toNamed(Routes.SEARCH),
            child: Container(
              height: 44,
              padding: const EdgeInsets.only(left: 14, right: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.45),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.14),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Search iPhone, Laptops, Audio...",
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.75),
                      ),
                    ),
                  ),
                  ArrowTooltip(
                    message: 'Search & Filter Products',
                    direction: ArrowDirection.top,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandIdentityLockup extends StatelessWidget {
  final String storeName;
  final String logoUrl;

  const _BrandIdentityLockup({
    required this.storeName,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (logoUrl.isNotEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: CachedNetworkImage(
          imageUrl: logoUrl,
          height: 32,
          fit: BoxFit.contain,
          errorWidget: (_, __, ___) => _buildWordmark(colorScheme),
        ),
      );
    }

    return _buildWordmark(colorScheme);
  }

  Widget _buildWordmark(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.22),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.bolt_rounded,
            size: 19,
            color: colorScheme.onPrimary,
          ),
        ),
        const SizedBox(width: 9),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                storeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.3,
                  height: 1.1,
                ),
              ),
              Text(
                'OFFICIAL STORE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                  color: colorScheme.primary.withOpacity(0.75),
                  letterSpacing: 1.1,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
