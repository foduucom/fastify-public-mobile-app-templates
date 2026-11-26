import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:zouhi/core/foduuStudio/foduu_studio_layout_view.dart';
import '../controllers/mtp_solution_controller.dart';

class MtpSolutionView extends GetView<MtpSolutionController> {
  const MtpSolutionView({super.key});

  static const _poppins = 'Poppins';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: context.themeBackground,
        appBar: AppBar(
          title: Text(
            'MTP Solution',
            style: TextStyle(
              fontFamily: _poppins,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: context.themeTextColor,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: context.themeTextColor),
          actions: [
            IconButton(
              icon: Icon(Icons.phone_in_talk_rounded,
                  size: 20, color: context.themePrimaryColor),
              tooltip: 'Call Support',
              onPressed: () => controller.callSupport(),
            ),
          ],
        ),
        body: FoduuStudioLayoutView(
          widgetList: controller.widgetList,
          isLoading: controller.isLayoutLoading,
          hasError: controller.hasError,
          errorMessage: controller.errorMessage,
          onRefresh: controller.fetchMtpSolutionLayout,
        ),
      ),
    );
  }
}
