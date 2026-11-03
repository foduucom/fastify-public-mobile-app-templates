import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/homepage_controller.dart';
import '/core/foduuStudio/foduu_studio_layout_view.dart';

/// Home's CMS driven body. The common app header and bottom navigation are
/// provided by the bottom navigation shell.
class HomeView extends GetView<HomepageController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLayoutLoading.value && controller.widgetList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.widgetList.isEmpty) {
          final message = controller.layoutError.value;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.isEmpty
                        ? 'No home content is available right now.'
                        : message,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: controller.isLayoutLoading.value
                        ? null
                        : () =>
                            controller.getDashboardDesign(controller.pageSlug),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return FoduuStudioLayoutView(
          widgetList: controller.widgetList,
          isLoading: controller.isLayoutLoading,
          onRefresh: () async {
            await controller.getDashboardDesign(controller.pageSlug);
          },
        );
      }),
    );
  }
}
