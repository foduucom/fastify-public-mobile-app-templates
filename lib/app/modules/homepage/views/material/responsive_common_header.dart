import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/material/responsive_circle_icon.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:get/get.dart';
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: 8.0,
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
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Row 1: Drawer Toggle, Brand Logo/Title & Top Action Icons
          Row(
            children: [
              /// ☰ Menu / Drawer
              ResponsiveCircleIcon(
                icon: Icons.menu_rounded,
                height: height,
                width: width,
                onTap: onMessageTap,
              ),

              const SizedBox(width: 12),

              /// Brand Identity (Logo or Stylized Store Brand)
              Expanded(
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icon/foduu-logo-removebg-preview.png',
                      height: 32,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            appName.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: colorScheme.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              if (kIsWeb)
                Obx(
                  () => Container(
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

              /// 🔔 Notification Icon
              ResponsiveCircleIcon(
                icon: Icons.notifications_none_rounded,
                height: height,
                width: width,
                onTap: onNotificationTap ??
                    () => Get.toNamed(Routes.NOTIFICATION),
                showDot: false,
              ),

              const SizedBox(width: 8),

              /// 🛒 Cart Icon with Live Reactive Badge
              Obx(() {
                final cartCount = Get.isRegistered<CartService>()
                    ? CartService.to.cartItems.length
                    : 0;

                return ResponsiveCircleIcon(
                  icon: Icons.shopping_bag_outlined,
                  height: height,
                  width: width,
                  badgeCount: cartCount,
                  onTap: onCartTap,
                );
              }),
            ],
          ),

          const SizedBox(height: 10),

          /// Row 2: Modern Full-Width Search Bar
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSearchTap ?? () => Get.toNamed(Routes.SEARCH),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.12),
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
                  Container(
                    height: 18,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                  Icon(
                    Icons.mic_none_rounded,
                    size: 19,
                    color: colorScheme.onSurfaceVariant,
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
