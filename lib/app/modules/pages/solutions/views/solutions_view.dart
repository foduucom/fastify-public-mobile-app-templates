import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:zouhi/core/foduuStudio/foduu_studio_layout_view.dart';
import '../controllers/solutions_controller.dart';

class SolutionsView extends GetView<SolutionsController> {
  const SolutionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeBackground,
      appBar: AppBar(
        title: const Text(
          'Solutions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Contact Team',
            icon: const Icon(Icons.headset_mic_outlined),
            onPressed: () => Get.toNamed(Routes.CONTACT),
          ),
        ],
      ),
      body: FoduuStudioLayoutView(
        widgetList: controller.widgetList,
        isLoading: controller.isLayoutLoading,
        hasError: controller.hasError,
        errorMessage: controller.errorMessage,
        onRefresh: controller.fetchSolutions,
      ),
    );
  }
}
