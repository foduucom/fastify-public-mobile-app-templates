import 'package:flutter/material.dart';
import '/constants/theme.dart';

import 'package:get/get.dart';
import '../controllers/aboutus_controller.dart';

class AboutusView extends GetView<AboutusController> {
  const AboutusView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "About Us",
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Obx(() {
                //   if (controller.aboutUsDetials.isEmpty) {
                //     return Center(
                //       child: HelperFunctions().loadingIndicator(),
                //     );
                //   } else {
                //     return Html(
                //       data: controller.aboutUsDetials.toString(),
                //       style: {
                //         "body": Style(
                //           padding: EdgeInsets.zero,
                //           fontFamily: "Lato",
                //         ),
                //         "div": Style(
                //           padding: EdgeInsets.zero,
                //         ),
                //         "p": Style(
                //           padding: EdgeInsets.zero,
                //         ),
                //       },
                //     );
                //   }
                // }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
