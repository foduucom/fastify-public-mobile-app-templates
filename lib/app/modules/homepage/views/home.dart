import 'package:flutter/material.dart';
import 'package:zouhi/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/commonWidgets/appbarIcons.dart';
import 'package:zouhi/components/home_component/customDrawer.dart';
import 'package:zouhi/core/foduuStudio/foduu_studio_layout_view.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:get/get.dart';

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
          SearchIcon(() {
            Get.toNamed(Routes.SEARCH);
          }),
          const SizedBox(width: 14),
        ],
      ),
      drawer: const CustomDrawer(),
      body: FoduuStudioLayoutView(
        widgetList: controller.widgetList,
        isLoading: controller.isLayoutLoading,
        hasError: controller.hasError,
        errorMessage: controller.errorMessage,
        onRefresh: () async {
          await controller.refreshAllData();
        },
      ),
    );
  }
}
