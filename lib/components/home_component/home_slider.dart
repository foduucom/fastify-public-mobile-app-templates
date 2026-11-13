// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:foduu_ecommerce/components/app_image_placeholder.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:foduu_ecommerce/app/modules/shop/shop_navigation.dart';
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
      // Use dynamic responsive height (240–265px) so banners don't get cropped
      final dynamic height = widget.sliderData['height'];
      final double dynamicH = (Get.width * 0.58).clamp(240.0, 265.0);
      if (height != null) {
        final h = height.toDouble();
        return h < dynamicH ? dynamicH : h;
      }
      return dynamicH;
    }
  }

  String _cleanHtml(String text) {
    if (text.isEmpty) return '';
    // Strip HTML tags and normalize whitespace without injecting stray bullets
    return text
        .replaceAll(
            RegExp(r'</?(li|p|div|h[1-6]|br)[^>]*>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
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
    List<Widget> list = [];
    //print("Slide Data : ${widget.sliderData['slider']['content']}");
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

                        // Extract title and content
                        final String title = sliderItem['heading'] ?? '';
                        final String description =
                            sliderItem['description'] ?? '';
                        // final String buttonText =
                        //     sliderItem['button_text'] ?? 'Shop Now';
                        final String? link = sliderItem['link'];
                        final String? sliderType = sliderItem['sliderType'];

                        // Determine text color based on background
                        final bool isDarkBackground =
                            sliderItem['dark_background'] ?? true;
                        final Color textColor = Colors.white;
                        final Color buttonColor =
                            Theme.of(context).primaryColor;
                        final String cleanTitle = _cleanHtml(title);
                        final String cleanDesc = _cleanHtml(description);

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
                          child: Padding(
                            padding: pageSurroundingPadding,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Background Image
                                  (index < _imageUrls.length &&
                                          _imageUrls[index].isNotEmpty &&
                                          _imageUrls[index] !=
                                              HelperFunctions.getNoImage())
                                      ? CachedNetworkImage(
                                          height: sliderHeight,
                                          imageUrl: _imageUrls[index],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorWidget:
                                              ((context, url, error) =>
                                                  const AppImagePlaceholder(
                                                    radius: 16,
                                                    fit: BoxFit.cover,
                                                  )),
                                          progressIndicatorBuilder:
                                              ((context, url, progress) =>
                                                  Container(
                                                    width: double.infinity,
                                                    height: sliderHeight,
                                                    decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surfaceContainerHighest),
                                                    child: Center(
                                                      child: HelperFunctions()
                                                          .loadingIndicator(),
                                                    ),
                                                  )),
                                        )
                                      : const AppImagePlaceholder(
                                          radius: 16,
                                          fit: BoxFit.cover,
                                        ),

                                  // Soft Ambient Scrim (keeps top 50% crystal clear for artwork)
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.30),
                                            Colors.black.withOpacity(0.72),
                                          ],
                                          stops: const [0.40, 0.70, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Title, Description & Action Button
                                  Positioned(
                                    left: 18,
                                    right: 18,
                                    bottom: 22,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 3.5),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.22),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.4)),
                                          ),
                                          child: const Text(
                                            'New Arrival',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        if (cleanTitle.isNotEmpty)
                                          Text(
                                            cleanTitle,
                                            style: const TextStyle(
                                              fontFamily: 'Lato',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              height: 1.15,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 6.0,
                                                  color: Colors.black,
                                                  offset: Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        if (cleanTitle.isNotEmpty &&
                                            cleanDesc.isNotEmpty)
                                          const SizedBox(height: 4),
                                        if (cleanDesc.isNotEmpty)
                                          Text(
                                            cleanDesc,
                                            style: TextStyle(
                                              fontFamily: 'Lato',
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white
                                                  .withOpacity(0.92),
                                              shadows: const [
                                                Shadow(
                                                  blurRadius: 4.0,
                                                  color: Colors.black,
                                                  offset: Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        const SizedBox(height: 8),
                                        // Modern "Shop Now →" Pill Button
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: buttonColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.28),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Shop Now',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 13,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Widget _indicator(bool isActive) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    height: 7,
    width: isActive ? 22 : 7,
    margin: const EdgeInsets.symmetric(horizontal: 3.5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
      color: isActive
          ? Theme.of(Get.context!).primaryColor
          : Colors.white.withOpacity(0.55),
      boxShadow: const [
        BoxShadow(
          color: Color(0x40000000),
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ],
    ),
  );
}
