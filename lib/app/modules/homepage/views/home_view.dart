import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../components/shimmer/home_shimmer.dart';
import '/app/modules/auth/auth_details.dart';
import '/app/modules/bottomar/controllers/bottombar_controller.dart';
import '/app/modules/homepage/controllers/homepage_controller.dart';
import '/app/modules/notification/controller/notification_controller.dart';
import '/app/routes/app_pages.dart';
import '/components/buttons/appbutton.dart';
import '../../../../components/studio_widget/customDrawer.dart';
import '/constants/constants.dart';
import '/constants/theme.dart';
import '../../../../core/foduuStudio/foduu_studio_layout_view.dart';
import '/helpers/socket_helper.dart';
import 'package:get/get.dart';

class Testinghome extends GetView<HomepageController> {
  Testinghome({super.key});

  var controller = Get.put(HomepageController());

  // ✅ Fix 1: Plain method — no Obx needed for non-reactive auth data
  String _getGreetingName() {
    final userDetails = AuthDetails.getUserDetails();
    if (AuthDetails.isUserLogin() && userDetails != null) {
      return userDetails['name']?.toString().split(' ').first ?? 'there';
    }
    return 'there';
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,

      // ── AppBar ──────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,

        // ── Greeting rows pinned as AppBar.bottom ────────────────────
        // ✅ Fix 1: Moved greeting here — plain Text, no Obx
        // ── Greeting rows pinned as AppBar.bottom ────────────────────
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110), // ✅ was 72 — too small for 2-line headline
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${_getGreetingName()}! 👋',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Fulfill all your daily needs\nwith HarvestHub',
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 24,  // ✅ was 20 — design shows ~28px
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Left: Location Pill ──────────────────────────────────────
        title: GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), // ✅ slightly taller
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: colorScheme.primary, size: 16),
                const SizedBox(width: 6),
                Obx(() => Text(
                  controller.selectcategory.value.toString().isNotEmpty
                      ? controller.selectcategory.value.toString()
                      : 'Select Location',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                )),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 18),
              ],
            ),
          ),
        ),

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
                      ? Colors.green
                      : Colors.red,
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
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline,
                  color: Colors.black87, size: 20),
            ),
          ),

          // Notification icon with red dot badge
          // ✅ allnotificationList IS .obs — Obx valid here
          Obx(() {
            final count = Get.find<NotificationsController>()
                .allnotificationList
                .length;
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
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        'assets/icon/appbarnotification.svg',
                        height: 20,
                        width: 20,
                        colorFilter: const ColorFilter.mode(
                          Colors.black87,
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
                          decoration: const BoxDecoration(
                            color: Colors.red,
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
      drawer: Drawer(
        child: AuthDetails.isUserLogin()
            ? const CustomDrawer()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'Login to View Profile',
                style: txtTheme().displayMedium,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: Get.width * 0.6,
              child: AppButton(
                itemText: 'Login',
                keypressEvent: () => Get.offAllNamed(Routes.LOGIN),
              ),
            ),
          ],
        ),
      ),

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