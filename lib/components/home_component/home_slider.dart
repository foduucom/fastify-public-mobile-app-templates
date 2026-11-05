// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:foddu/components/app_image_placeholder.dart';
import 'package:foddu/app/controllers/api_exception_handle_controller.dart';
import 'package:foddu/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:foddu/app/routes/app_pages.dart';
import 'package:foddu/constants/constants.dart';
import 'package:foddu/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:foddu/app/modules/shop/shop_navigation.dart';
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
  Timer? _timer;
  List<String> _imageUrls = [];

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

  void _resolveImageUrls() {
    _imageUrls.clear();
    final slider = widget.sliderData['slider'];
    if (slider != null) {
      final content = slider['content'];
      if (content is List) {
        for (var item in content) {
          _imageUrls.add(HelperFunctions().getImage(item));
        }
      }
    }
  }

  List<Widget> _buildPageIndicator() {
    final content = widget.sliderData['slider']?['content'];
    if (content is! List || content.length <= 1) return const [];
    List<Widget> list = [];
    for (int i = 0; i < content.length; i++) {
      list.add(_indicator(i == _currentPage));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomepageController>();
    // sliderImage.clear();
    // initFetchSliderImage(widget.id);

    _resolveImageUrls();

    _timer = Timer.periodic(const Duration(seconds: 8), (Timer timer) {
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
  void didUpdateWidget(covariant FoduuSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sliderData != oldWidget.sliderData) {
      _resolveImageUrls();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // Call to the super method for AutomaticKeepAliveClientMixin
    final double sliderHeight = _getSliderHeight();

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: widget.sliderData['_compact_home_spacing'] == true ? 2 : 4,
      ),
      child: Stack(
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
                        itemCount:
                            widget.sliderData['slider']['content'].length,
                        itemBuilder: (context, index) {
                          final sliderItem =
                              widget.sliderData['slider']['content'][index];

                          // Extract title and content
                          final String title = sliderItem['heading'] ?? '';
                          final String subHeading = sliderItem['sub_heading'] ??
                              sliderItem['subheading'] ??
                              '';
                          final String description =
                              sliderItem['description'] ?? '';
                          final String buttonText = sliderItem['button_text'] ??
                              (title.isNotEmpty ? 'Shop Now' : '');
                          final String? link = sliderItem['link'];
                          final String? sliderType = sliderItem['sliderType'];

                          // High-contrast text over dark gradient overlay
                          const Color textColor = Colors.white;
                          final Color buttonColor =
                              Theme.of(context).primaryColor;

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              if (sliderType == 'categories') {
                                openShop({
                                  'source': 'category',
                                  'productId': link,
                                  'name': title
                                });
                              } else if (sliderType == 'blog') {
                                Get.toNamed(Routes.BLOG_DETAILS, arguments: {
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
                            child: Container(
                              child: Stack(
                                children: [
                                  // Background Image
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: (index < _imageUrls.length &&
                                              _imageUrls[index].isNotEmpty &&
                                              _imageUrls[index] !=
                                                  HelperFunctions.getNoImage())
                                          ? CachedNetworkImage(
                                              height: sliderHeight,
                                              imageUrl: _imageUrls[index],
                                              fit: BoxFit.cover,
                                              width: Get.width,
                                              errorWidget:
                                                  ((context, url, error) =>
                                                      AppImagePlaceholder(
                                                        radius: 12,
                                                        height: sliderHeight,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                      )),
                                              progressIndicatorBuilder:
                                                  ((context, url, progress) =>
                                                      Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: sliderHeight,
                                                        decoration: BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .surfaceContainerHighest),
                                                        child: Center(
                                                          child: HelperFunctions()
                                                              .loadingIndicator(),
                                                        ),
                                                      )),
                                            )
                                          : AppImagePlaceholder(
                                              radius: 12,
                                              height: sliderHeight,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),

                                  // Gradient Overlay for subtle text contrast without darkening full photo
                                  Positioned.fill(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.12),
                                                Colors.black.withOpacity(0.65),
                                              ],
                                              stops: const [0.45, 0.72, 1.0],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Title, Subheading, Content, and CTA Button
                                  Positioned(
                                    left: 20,
                                    right: 20,
                                    bottom: 24,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (subHeading.isNotEmpty) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              subHeading.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                        ],
                                        if (title.isNotEmpty)
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              fontFamily: 'Lato',
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              height: 1.2,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 8.0,
                                                  color: Colors.black87,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (description.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            description,
                                            style: TextStyle(
                                              fontFamily: 'Lato',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              shadows: const [
                                                Shadow(
                                                  blurRadius: 6.0,
                                                  color: Colors.black54,
                                                  offset: Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        if (buttonText.isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  buttonText,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: 14,
                                                  color: Colors.black,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
          ),
          Positioned(
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [..._buildPageIndicator()],
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Widget _indicator(bool isActive) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    height: 5,
    width: isActive ? 20 : 6,
    margin: const EdgeInsets.symmetric(horizontal: 3.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
      color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ],
    ),
  );
}
