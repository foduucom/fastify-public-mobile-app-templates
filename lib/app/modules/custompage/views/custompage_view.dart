import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/app/modules/custompage/controllers/custompage_controller.dart';
import '../../../../core/foduuStudio/foduu_studio_layout_view.dart';
import '/helpers/socket_helper.dart';
import 'package:get/get.dart';

class CustomPageView extends GetView<CustomPageController> {
  CustomPageView({super.key});

  var controller = Get.put(CustomPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.pageLable),
        actions: [
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
        ],
      ),
      body: FoduuStudioLayoutView(
        widgetList: controller.widgetList,
        isLoading: controller.isLayoutLoading,
        onRefresh: () async {
          // await controller.getDashboardDesign(controller.pageSlug);
        },
      ),
    );
  }
}
