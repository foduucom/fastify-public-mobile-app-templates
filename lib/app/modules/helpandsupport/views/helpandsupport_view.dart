import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/components/commonWidgets/secondary_app_header.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';
import 'package:get/get.dart';

import '../controllers/helpandsupport_controller.dart';

class HelpandsupportView extends GetView<HelpandsupportController> {
  const HelpandsupportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SecondaryAppHeader(
          title: 'Help & FAQs',
          showRight: false,
        ),
      ),
      body: FoduuStudioLayoutView(
        widgetList: controller.widgetList,
        isLoading: controller.isLayoutLoading,
        hasError: controller.hasError,
        errorMessage: controller.errorMessage,
        onRefresh: () => controller.getFaqs(),
      ),
    );
  }
}
