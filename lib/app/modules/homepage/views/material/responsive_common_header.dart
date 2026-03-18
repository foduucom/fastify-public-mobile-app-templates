import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/material/responsive_circle_icon.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import '/helpers/socket_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart'; // ✅ ADD THIS

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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: height * 0.015,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔍 Search Bar
          Expanded(
            child: GestureDetector(
              onTap: onSearchTap,
              child: Container(
                height: height * 0.055,
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.026,
                  vertical: height * 0.01,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? DefaultThemeColors.darklight
                        : context.outlineColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: height * 0.025,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? DefaultThemeColors.darklighter
                          : context.onSurfaceVariantColor,
                    ),
                    SizedBox(width: width * 0.02),
                    Expanded(
                      child: Text(
                        "Search Product...",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: height * 0.018,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? DefaultThemeColors.darklighter
                              : DefaultThemeColors.lightDarker,
                        ),
                      ),
                    ),
                  ],
                ),
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
