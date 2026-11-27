import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';
import 'package:get/get.dart';

import '../controllers/aboutus_controller.dart';

class AboutusView extends GetView<AboutusController> {
  const AboutusView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: context.onSurfaceColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'About Us',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: context.onSurfaceColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.support_agent_rounded,
              color: context.primaryColor,
              size: 24,
            ),
            tooltip: 'Contact Support',
            onPressed: controller.goToContact,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: FoduuStudioLayoutView(
        widgetList: controller.widgetList,
        isLoading: controller.isLayoutLoading,
        hasError: controller.hasError,
        errorMessage: controller.errorMessage,
        onRefresh: controller.fetchAboutUs,
      ),
    );
  }
}
