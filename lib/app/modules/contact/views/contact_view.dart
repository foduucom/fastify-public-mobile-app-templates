import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/contact/controller/contact_controller.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';
import 'package:get/get.dart';

class ContactView extends GetView<ContactController> {
  const ContactView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0.0,
      ),
      body: GestureDetector(
        onTap: () => HelperFunctions().closeKeyboard(context),
        child: FoduuStudioLayoutView(
          widgetList: controller.widgetList,
          isLoading: controller.isLayoutLoading,
          hasError: controller.hasError,
          errorMessage: controller.errorMessage,
          onRefresh: controller.fetchContactLayout,
        ),
      ),
    );
  }
}
