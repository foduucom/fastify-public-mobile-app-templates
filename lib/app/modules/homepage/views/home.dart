import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/commonWidgets/appbarIcons.dart';
import 'package:zouhi/components/home_component/customDrawer.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:zouhi/core/foduuStudio/foduu_studio_layout_view.dart';
import 'package:zouhi/helpers/socket_helper.dart';
import 'package:zouhi/services/api_health_service.dart';

class HomePageView extends GetView<HomepageController> {
  const HomePageView({super.key});

  @override
  HomepageController get controller => Get.isRegistered<HomepageController>()
      ? Get.find<HomepageController>()
      : Get.put(HomepageController());

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/VIC-Logo-Final-1213.png',
          width: 140,
        ),
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: context.colors.surface,
        surfaceTintColor: context.colors.surface,
        iconTheme: IconThemeData(color: context.colors.onSurface),
        leading: IconButton(
          onPressed: () => scaffoldKey.currentState!.openDrawer(),
          icon: Icon(Icons.menu, color: context.colors.onSurface),
        ),
        actions: [
          // ── Live WebSocket connection status indicator for Web build only ──
          if (kIsWeb)
            Obx(() {
              final isConnected = SocketHelper().isConnectedObs.value;
              return Tooltip(
                message: isConnected
                    ? 'Live Studio Connected'
                    : 'Live Studio Disconnected',
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isConnected ? Colors.green : Colors.red)
                            .withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            }),
          SearchIcon(() {
            Get.toNamed(Routes.SEARCH);
          }),
          const SizedBox(width: 14),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Obx(() {
        final backendDown = ApiHealthService.maybe?.status.value ==
                ApiHealth.down &&
            controller.widgetList.isEmpty;

        if (controller.isLoading.value &&
            controller.widgetList.isEmpty &&
            !backendDown) {
          return Center(child: HelperFunctions().loadingIndicator());
        }

        return FoduuStudioLayoutView(
          widgetList: controller.widgetList,
          isLoading: controller.isLoading,
          hasError: controller.hasError,
          errorMessage: controller.errorMessage,
          onRefresh: () async {
            await controller.refreshAllData();
          },
        );
      }),
    );
  }
}
