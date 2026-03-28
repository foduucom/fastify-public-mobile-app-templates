import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '/app/modules/blog/controller/blog_detail_controller.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class BlogDetailsView extends GetView<BlogDetailsController> {
  BlogDetailsView({Key? key}) : super(key: key);
  var controller = Get.put(BlogDetailsController());
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('News'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: pageSurroundingPadding,
              child: Obx(
                () => controller.blogDetails.isEmpty
                    ? Container(
                        height: Get.height * 0.6,
                        child:
                            Center(child: HelperFunctions().loadingIndicator()))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            child: Obx(
                              () => CachedNetworkImage(
                                  height: 200,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade300),
                                        child: const Center(
                                          child: Icon(Icons.error),
                                        ),
                                      ),
                                  // imageUrl: controller
                                  //         .blogDetails['featured_image'] ??
                                  //     ''),
                                  imageUrl: HelperFunctions().getImage(
                                      controller
                                          .blogDetails['featured_image'])),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          Obx(
                            () {
                              print('name rebuild');
                              return Text(
                                controller.blogDetails['name'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    fontFamily: 'lato'),
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          // Obx(() {
                          //   return
                          Html(
                              onLinkTap: (url, attributes, element) async {
                                if (url != null && await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  print('Could not launch $url');
                                }
                              },
                              data: controller.blogDetails['content'] ?? '')
                          // }
                          // ),
                        ],
                      ),
              ),
            ),

            // body: Text('data'),
          )),
    );
  }
}

class VideoPlayerShimmer extends StatelessWidget {
  const VideoPlayerShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        enabled: true,
        direction: ShimmerDirection.ltr,
        loop: 0,
        period: const Duration(seconds: 1),
        baseColor: Colors.grey.shade300,
        highlightColor: Color.fromARGB(255, 197, 197, 197),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
          ),
          width: Get.width,
          height: 220,
        ));
  }
}
