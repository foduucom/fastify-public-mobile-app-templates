import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../components/shimmer/home_shimmer.dart';
import '/app/modules/homepage/controllers/homepage_controller.dart';
import '/app/modules/notification/controller/notification_controller.dart';
import '/app/routes/app_pages.dart';
import '../../../../components/studio_widget/customDrawer.dart';
import '/constants/constants.dart';
import '../../../../core/foduuStudio/foduu_studio_layout_view.dart';
import '/helpers/socket_helper.dart';
import 'package:get/get.dart';

class Testinghome extends GetView<HomepageController> {
  Testinghome({super.key});

  var controller = Get.put(HomepageController());

  // ✅ Fix 1: Plain method — no Obx needed for non-reactive auth data
  // String _getGreetingName() {
  //   final userDetails = AuthDetails.getUserDetails();
  //   if (AuthDetails.isUserLogin() && userDetails != null) {
  //     return userDetails['name']?.toString().split(' ').first ?? 'there';
  //   }
  //   return 'there';
  // }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ── AppBar ──────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 56,

        // ── Left: Menu / Drawer Button ──────────────────────────────
        leading: Builder(
          builder: (innerContext) => Container(
            margin: const EdgeInsets.only(left: 16),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => Scaffold.of(innerContext).openDrawer(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF161616)
                      : colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: isDark
                      ? Border.all(color: Colors.white.withValues(alpha: 0.08))
                      : null,
                ),
                child: Icon(
                  Icons.menu_rounded,
                  color: colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),
          ),
        ),

        // ── Center: Brand Title ──────────────────────────────────────
        title: Text(
          appName,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
            fontSize: 20,
          ),
        ),
        centerTitle: true,

        // ── Right: Socket dot + Chat + Notification ──────────────────
        actions: [
          // Web socket live indicator
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

          // Chat icon
          IconButton(
            onPressed: () {
              // TODO: navigate to chat
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF161616)
                    : colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: isDark
                    ? Border.all(color: Colors.white.withValues(alpha: 0.08))
                    : null,
              ),
              child: Icon(Icons.chat_bubble_outline,
                  color: colorScheme.onSurface, size: 20),
            ),
          ),

          // Notification icon with red dot badge
          // ✅ allnotificationList IS .obs — Obx valid here
          Obx(() {
            final count =
                Get.find<NotificationsController>().allnotificationList.length;
            return GestureDetector(
              onTap: () => Get.toNamed(Routes.NOTIFICATION),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF161616)
                            : colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: isDark
                            ? Border.all(
                                color: Colors.white.withValues(alpha: 0.08))
                            : null,
                      ),
                      child: SvgPicture.asset(
                        'assets/icon/appbarnotification.svg',
                        height: 20,
                        width: 20,
                        colorFilter: ColorFilter.mode(
                          colorScheme.onSurface,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    if (count > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),

      // ── Drawer ──────────────────────────────────────────────────────
      drawer: const CustomDrawer(),

      // ── Body ────────────────────────────────────────────────────────
      // ✅ Fix 2: FoduuStudioLayoutView is the DIRECT body child —
      //    no Column/Expanded wrapper. It owns its own scroll context.
      body: Obx(() {
        if (controller.isLoading.value) {
          return const HomeShimmer();
        }

        return FoduuStudioLayoutView(
          widgetList: controller.widgetList,
          isLoading: controller.isLoading,
          onRefresh: () async {
            await controller.getDashboardDesign(controller.pageSlug);
          },
        );
      }),
    );
  }
}
