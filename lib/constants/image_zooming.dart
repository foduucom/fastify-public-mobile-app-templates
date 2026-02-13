import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageSlider2 extends StatefulWidget {
  ImageSlider2({
    Key? key,
  }) : super(key: key);
  @override
  State<ImageSlider2> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider2> {
  List sliderList = [];
  late PageController controller;
  double threshold = 200.0; // Initial threshold value

  @override
  void initState() {
    controller = PageController(initialPage: 0);
    controller.addListener(_onPageScroll);
    super.initState();
  }

  void _onPageScroll() {
    final double offset = controller.offset;
    final int currentPage = controller.page?.toInt() ?? 0;

    // Calculate the threshold based on the current page
    final double currentPageThreshold = currentPage == 0 ? 200.0 : 400.0;

    if (offset >= currentPageThreshold) {
      if (currentPage < sliderList.length - 1) {
        // Go to the next page
        controller.jumpToPage(currentPage + 1);
      } else {
        // Do something if the last page is reached
        print('Last page reached');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (sliderList.isEmpty) {
      for (var item in Get.arguments["images"]) {
        sliderList.add({"id": item["id"], "image": item["filepath"]});
        print('slider list $sliderList');
      }
      setState(() {});
    }
    return SafeArea(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.velocity.pixelsPerSecond.dx;
          if (velocity > 0 && controller.page != null) {
            // Right swipe
            final currentPage = controller.page!.round();
            if (currentPage > 0 && controller.offset >= threshold) {
              controller.jumpToPage(currentPage - 1);
            }
          } else if (velocity < 0 && controller.page != null) {
            // Left swipe
            final currentPage = controller.page!.round();
            if (currentPage < sliderList.length - 1 &&
                controller.offset >= threshold) {
              controller.jumpToPage(currentPage + 1);
            }
          }
        },
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(
                      url + sliderList[index]['image']),
                  initialScale: PhotoViewComputedScale.contained * 0.8,
                );
              },
              itemCount: sliderList.length,
              pageController: controller,
              onPageChanged: (value) {
                // widget.currentImage = value;
                print(value);
              },
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 12.0, top: 30.0, right: 12.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
