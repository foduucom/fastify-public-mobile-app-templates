import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/constants/theme.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:zouhi/core/foduuStudio/foduu_studio_layout_view.dart';
import '../controllers/termsandcondition_controller.dart';

class TermsandconditionView extends GetView<TermsandconditionController> {
  const TermsandconditionView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          title: Text(
            'Terms & Conditions',
            style: txtTheme()
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          ),
          iconTheme: IconThemeData(
            color: context.themeTextColor,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: FoduuStudioLayoutView(
          widgetList: controller.widgetList,
          isLoading: controller.isLayoutLoading,
          hasError: controller.hasError,
          errorMessage: controller.errorMessage,
          onRefresh: controller.termsAndCondition,
        ),
      ),
    );
  }
}
