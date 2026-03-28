import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../components/shimmer/home_shimmer.dart';
import '/core/services/wishlistService.dart';
import '/app/modules/auth/auth_details.dart';
import '/app/modules/bottomar/controllers/bottombar_controller.dart';
import '/app/modules/homepage/controllers/homepage_controller.dart';
import '/app/modules/notification/controller/notification_controller.dart';
import '/app/modules/wishlist/controllers/wishlist_controller.dart';
import '/app/routes/app_pages.dart';
import '/components/buttons/appbutton.dart';
import '/components/commonWidgets/appbarIcons.dart';
import '../../../../components/studio_widget/customDrawer.dart';
import '/constants/constants.dart';
import '/constants/theme.dart';
import '../../../../core/foduuStudio/foduu_studio_layout_view.dart';
import '/helpers/socket_helper.dart';
import 'package:get/get.dart';

// 👇 IMPORTANT: Make sure to import your new shimmer file here
// import 'path/to/your/home_shimmer.dart';

class Testinghome extends GetView<HomepageController> {
  Testinghome({super.key});

  var controller = Get.put(HomepageController());

  @override
  Widget build(BuildContext context) {
    var scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.SHOPPRODUCTLISTVIEW);
        },
      ),
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/logo.png',
          width: 77,
        ),
        titleSpacing: 0,
        elevation: 0,
        leading: IconButton(
            onPressed: () => scaffoldKey.currentState!.openDrawer(),
            icon: const Icon(Icons.menu)),
        actions: [
          // IconButton(
          //     onPressed: () {
          //       Get.toNamed(Routes.CART);
          //     },
          //     icon: const Icon(Icons.shopping_cart)
          // ),
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
          SearchIcon(() {
            Get.toNamed(Routes.SEARCH);
          }),
          Obx(() => Text(controller.selectcategory.value.toString())),
          const SizedBox(width: 14),
          Obx(
                () => controller.notificatoinCount == 1
                ? GestureDetector(
              onTap: () {
                Get.toNamed(Routes.NOTIFICATION);
              },
              child: SvgPicture.asset(
                'assets/icon/appbarnotification.svg',
                height: 22,
                width: 22,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
            )
                : Get.find<BottombarController>().cartbadge(
                child: NotificationIcon(() {
                  Get.toNamed(Routes.NOTIFICATION);
                }),
                badgeNumber: Get.find<NotificationsController>()
                    .allnotificationList
                    .length),
          ),
          const SizedBox(width: 14),
          Obx(() => Get.find<BottombarController>().cartbadge(
              child: HeartIcon(() {
                Get.find<BottombarController>().currentPageIndex.value = 3;
                Get.find<BottombarController>().pageController.jumpToPage(3);
              }),
              badgeNumber: WishListService.to.wishListItemCount)),
          const SizedBox(width: 14),
        ],
      ),
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
                )),
            const SizedBox(height: 15),
            SizedBox(
              width: Get.width * 0.6,
              child: AppButton(
                  itemText: 'Login',
                  keypressEvent: () {
                    // Removed the unused isOtpLogin check
                    Get.offAllNamed(Routes.LOGIN);
                  }),
            ),
          ],
        ),
      ),
      // 👇 Wrap the body in an Obx to toggle between Shimmer and the real layout
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

