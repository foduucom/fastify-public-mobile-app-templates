import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:zouhi/core/foduuStudio/foduu_studio_layout_view.dart';

import '../controllers/aboutus_controller.dart';

class AboutusView extends GetView<AboutusController> {
  const AboutusView({super.key});

  static const _poppins = 'Poppins';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeBackground,
      appBar: AppBar(
        backgroundColor: context.themeWhiteColor,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: context.themeTextColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'About Us',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: _poppins,
            fontSize: 17,
            color: context.themetitleColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.support_agent_rounded,
              color: context.themePrimaryColor,
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
