// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class FoduuSlider extends StatefulWidget {
  final sliderData;
  FoduuSlider({super.key, required this.sliderData});

  @override
  _FoduuSliderState createState() => _FoduuSliderState();
}

class _FoduuSliderState extends State<FoduuSlider>
    with AutomaticKeepAliveClientMixin, BaseController {
  late HomepageController homeController;
  // var sliderImage = [];

  int _currentPage = 0;
  final PageController _pageController = PageController(
    initialPage: 0,
  );

  // Calculate slider height based on full_screen flag and height value
  double _getSliderHeight() {
    final bool isFullScreen = widget.sliderData['full_screen'] ?? false;
    if (isFullScreen) {
      // For full screen, calculate height based on width with 16:9 aspect ratio
      return Get.width * 9 / 16;
    } else {
      // Use the height from content_json, default to 200 if not provided
      final dynamic height = widget.sliderData['height'];
      return height != null ? height.toDouble() : 200.0;
    }
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    print("Slide Data : ${widget.sliderData['slider']['content']}");
    for (int i = 0; i < widget.sliderData['slider']['content'].length; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomepageController>();
    // sliderImage.clear();
    // initFetchSliderImage(widget.id);

    Timer.periodic(const Duration(seconds: 8), (Timer timer) {
      if (_currentPage < widget.sliderData['slider']['content'].length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // Call to the super method for AutomaticKeepAliveClientMixin
    final double sliderHeight = _getSliderHeight();

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.transparent,
          ),
          height: sliderHeight,
          child: widget.sliderData['slider']['content'].isEmpty
              ? Shimmer.fromColors(
                  child: Padding(
                    padding: pageSurroundingPadding,
                    child: Container(
                      padding: pageSurroundingPadding,
                      width: Get.width,
                      height: sliderHeight,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                )
              : ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: PageView.builder(
                      physics: const ClampingScrollPhysics(),
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemCount: widget.sliderData['slider']['content'].length,
                      itemBuilder: (context, index) {
                        final sliderItem =
                            widget.sliderData['slider']['content'][index];
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            final String? link = sliderItem['link'];
                            final String? sliderType = sliderItem['sliderType'];

                            if (sliderType == 'categories') {
                              Get.toNamed(Routes.SHOPPRODUCTLISTVIEW,
                                  arguments: {
                                    'source': 'category',
                                    'productId': link,
                                    'name': sliderItem['heading']
                                  });
                            } else if (sliderType == 'blog') {
                              Get.toNamed(Routes.BLOG, arguments: {
                                'id': link,
                              });
                            } else if (link != null && link.isNotEmpty) {
                              if (link.startsWith('http')) {
                                final Uri url = Uri.parse(link);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  HelperFunctions().showSnackBarError(
                                      "Could not launch the link.");
                                }
                              } else {
                                // If it's not a URL, it might be an internal page or invalid
                                HelperFunctions().showSnackBarError(
                                    "Invalid link or unsupported slider type.");
                              }
                            } else {
                              HelperFunctions().showSnackBarError(
                                  "No link associated with this slide.");
                            }
                          },
                          child: Stack(
                            children: [
                              Padding(
                                padding: pageSurroundingPadding,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: CachedNetworkImage(
                                      height: sliderHeight,
                                      imageUrl: HelperFunctions().getImage(
                                          widget.sliderData['slider']['content']
                                              [index]),
                                      fit: BoxFit.cover,
                                      width: Get.width,
                                      errorWidget: ((context, url, error) =>
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                20,
                                            height: sliderHeight,
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade300),
                                            child: Center(
                                              child: Icon(Icons.error),
                                            ),
                                          )),
                                      progressIndicatorBuilder:
                                          ((context, url, progress) =>
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                ),
                                                child: Center(
                                                  child: SizedBox(
                                                    height: 40,
                                                    width: 40,
                                                    child: HelperFunctions()
                                                        .loadingIndicator(),
                                                  ),
                                                ),
                                              ))),
                                ),
                              ),
                              Positioned(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 6),
                                    Text(
                                      widget.sliderData['slider']['content']
                                          [index]['heading'],
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      widget.sliderData['slider']['content']
                                          [index]['description'],
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                            ],
                          ),
                        );
                      }),
                ),
        ),
        Positioned(
          bottom: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [..._buildPageIndicator()],
          ),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Widget _indicator(bool isActive) {
  return Container(
    height: 10,
    width: isActive ? 20 : 10,
    margin: const EdgeInsets.symmetric(horizontal: 4.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
      color: isActive ? Theme.of(Get.context!).primaryColor : Colors.grey,
    ),
  );
}
