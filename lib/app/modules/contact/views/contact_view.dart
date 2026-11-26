import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/modules/contact/controller/contact_controller.dart';
import 'package:zouhi/components/check_internet_widget.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:zouhi/core/foduuStudio/foduu_studio_layout_view.dart';

class ContactView extends GetView<ContactController> {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeBackground,
      appBar: AppBar(
        title: const Text('Contact Us'),
        elevation: 0.0,
      ),
      body: GestureDetector(
        onTap: () => HelperFunctions().closeKeyboard(context),
        child: FoduuCheckInternetBody(
          child: FoduuStudioLayoutView(
            widgetList: controller.widgetList,
            isLoading: controller.isLayoutLoading,
            hasError: controller.hasError,
            errorMessage: controller.errorMessage,
            onRefresh: controller.fetchContactLayout,
          ),
        ),
      ),
    );
  }
}
