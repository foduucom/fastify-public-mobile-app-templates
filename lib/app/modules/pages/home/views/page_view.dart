import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:zouhi/app/modules/pages/home/controllers/page_controller.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:get/get.dart';

class PageView extends GetView<PagesController> {
  const PageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.name.value, style: TextStyle(color: context.themeTextColor))),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: HelperFunctions().loadingIndicator());
        } else {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Html(
                  data: controller.pagedata.value,
                  style: {
                    "body": Style(color: context.themeTextColor),
                    "p": Style(color: context.themeTextColor),
                  },
                ),
                Obx(() {
                  return GridView.builder(
                    shrinkWrap:
                        true, // Allow the GridView to take only the required space
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable scrolling on GridView
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 columns
                      childAspectRatio: 1, // Aspect ratio for each item
                      crossAxisSpacing: 8.0, // Spacing between columns
                      mainAxisSpacing: 8.0, // Spacing between rows
                    ),
                    itemCount: controller.images.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        controller.images[index],
                        fit: BoxFit
                            .cover, // Cover the whole space of each grid item
                      );
                    },
                  );
                }),
              ],
            ),
          );
        }
      }),
    );
  }
}

