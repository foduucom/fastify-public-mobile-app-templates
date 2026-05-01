import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImagePreviewMultipleView extends GetView {
  ImagePreviewMultipleView({Key? key}) : super(key: key);

  List<dynamic> sliderList = [];
  int clickCounter = 0;
  late Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    // super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (sliderList.isEmpty) {
      for (var item in Get.arguments["images"]) {
        sliderList.add({"id": item["id"], "image": item["filepath"]});
      }
    }

    final PageController controller = PageController();
    final TransformationController transformationController =
        TransformationController();

    void smoothZoomIn() {
      // if (clickCounter >= 3) {
      transformationController.value *= Matrix4.diagonal3Values(1.2, 1.2, 1);
      // }
    }

    void smoothZoomOut() {
      // if (clickCounter >= 3) {
      transformationController.value *= Matrix4.diagonal3Values(0.8, 0.8, 0.8);
      // }
    }

    // void handleButtonClick() {
    //   if (clickCounter < 3) {
    //     clickCounter++;
    //   }
    // }

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      clickCounter = 0;
    });

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        body: Stack(
          children: [
            PageView(
              key: UniqueKey(),
              scrollBehavior:
                  ScrollConfiguration.of(context).copyWith(dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              }),
              scrollDirection: Axis.horizontal,
              controller: controller,
              children: sliderList.map((item) {
                return AnimatedBuilder(
                  animation: transformationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: transformationController.value.getRow(0)[0],
                      child: InteractiveViewer(
                        panEnabled: false,
                        minScale: 1.0,
                        maxScale: 2.5,
                        transformationController: transformationController,
                        child: Center(
                          child: LimitedBox(
                            maxHeight: Get.height * 0.8,
                            child: CachedNetworkImage(
                              height: Get.height * 0.8,
                              width: Get.width,
                              alignment: Alignment.center,
                              imageUrl: HelperFunctions().getImage(item["image"]),
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Container(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 26, 26, 26),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: HelperFunctions().loadingIndicator(),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        const Color.fromARGB(255, 26, 26, 26)),
                                child: const Center(
                                  child: Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // handleButtonClick();
                      smoothZoomIn();
                    },
                    child: Icon(Icons.zoom_in),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // handleButtonClick();
                      smoothZoomOut();
                    },
                    child: Icon(Icons.zoom_out),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class ImageSlider extends GetView {
//   ImageSlider({super.key});
//   List<dynamic> sliderList = [];

//   @override
//   Widget build(BuildContext context) {
//     if (sliderList.isEmpty) {
//       for (var item in Get.arguments["images"]) {
//         sliderList.add({"id": item["id"], "image": item["filepath"]});
//       }
//     }
//     return SafeArea(
//       child: Stack(
//         children: [
//           PhotoViewGallery.builder(
//             scrollPhysics: const BouncingScrollPhysics(),
//             builder: (BuildContext context, int index) {
//               return PhotoViewGalleryPageOptions(
//                 // imageProvider: AssetImage('assets/' + widget.imageList[index]),
//                 imageProvider:
//                     CachedNetworkImageProvider(url + sliderList[index]),
//                 initialScale: PhotoViewComputedScale.contained * 0.8,
//                 // heroAttributes: PhotoViewHeroAttributes(tag: galleryItems[index].id),
//               );
//             },
//             itemCount: sliderList.length,
//             pageController: controller,
//             onPageChanged: (value) {
//               // widget.currentImage = value;
//               print(value);
//             },
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 12.0, top: 30.0, right: 12.0),
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: Icon(
//                 Icons.arrow_back_ios,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class ImageSlider extends StatefulWidget {
  ImageSlider({
    Key? key,
  }) : super(key: key);

  // int currentImage;
  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  late PageController controller;
  List sliderList = [];
  List<ImageProvider> imagelist = [];

  double _scale = 1.0;

  @override
  void initState() {
    controller = PageController(initialPage: 0);
    super.initState();
    if (sliderList.isEmpty) {
      for (var item in Get.arguments["images"]) {
        sliderList.add({"id": item["id"], "image": item["filepath"]});
        print('slider list $sliderList');
      }
      setState(() {});
    }

    for (int i = 0; i < sliderList.length; i++) {
      imagelist.add(CachedNetworkImageProvider(
          HelperFunctions().getImage(Get.arguments["images"][i])));
    }
  }

  void _zoomIn() {
    // setState(() {
    //   _scale =
    //       (_scale + 0.4).clamp(1.0, 3.0); // Adjust the scale range as needed
    // });
  }

  void _zoomOut() {
    // setState(() {
    //   _scale =
    //       (_scale - 0.4).clamp(1.0, 3.0); // Adjust the scale range as needed
    // });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          sliderList.isEmpty
              ? HelperFunctions().loadingIndicator()
              : PhotoViewGallery.builder(
                  allowImplicitScrolling: true,
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      onTapDown: (context, details, controllerValue) {
                        print('down');
                      },
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                      heroAttributes:
                          PhotoViewHeroAttributes(tag: 'image$index'),
                      imageProvider: CachedNetworkImageProvider(
                        HelperFunctions().getImage(Get.arguments["images"][index]),
                      ),
                      initialScale: PhotoViewComputedScale.contained,
                    );
                  },
                  itemCount: sliderList.length,
                  loadingBuilder: (context, event) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  pageController: controller,
                  onPageChanged: (value) {
                    print(value);
                  },
                ),
          Positioned(
            left: 12.0,
            top: 30.0,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
