// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import '/components/app_image_placeholder.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/modules/homepage/controllers/homepage_controller.dart';
import '/app/routes/app_pages.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'studio_common_widgets.dart';

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

  List get _sliderContent =>
      (widget.sliderData['slider'] as Map?)?['content'] as List? ?? [];

  int _currentPage = 0;
  final PageController _pageController = PageController(
    initialPage: 0,
  );

  // Calculate slider height based on full_screen flag and height value
  double _getSliderHeight() {
    final bool isFullScreen = widget.sliderData['full_screen'] ?? false;
    if (isFullScreen) {
      return Get.width * 9 / 16;
    } else {
      final dynamic height = widget.sliderData['height'];
      final double h = height != null
          ? (double.tryParse(height.toString()) ?? 200.0)
          : 200.0;
      return h < 215.0 ? 215.0 : h;
    }
  }

  void _handleSliderClick(dynamic item) {
    if (item['sliderType'] == 'categories' && item['link'] != null) {
      Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
        'source': 'category',
        'productId': item['link'],
        'name': item['heading'] ?? 'Category',
      });
    } else if (item['sliderType'] == 'blog' && item['link'] != null) {
      Get.toNamed(Routes.BLOG, arguments: {
        'id': item['link'],
      });
    } else {
      Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
        'source': 'slider',
        'name': item['heading'] ?? 'Collection',
      });
    }
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _sliderContent.length; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomepageController>();

    Timer.periodic(const Duration(seconds: 8), (Timer timer) {
      if (_currentPage < _sliderContent.length - 1) {
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
    super.build(context);
    final double sliderHeight = _getSliderHeight();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StudioSectionHeader(
          title: widget.sliderData['section_title'] ??
              widget.sliderData['heading'],
          subtitle: widget.sliderData['section_subtitle'] ??
              widget.sliderData['description'],
        ),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.transparent,
              ),
              height: sliderHeight,
              child: _sliderContent.isEmpty
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
                          itemCount: _sliderContent.length,
                          itemBuilder: (context, index) {
                            final item = _sliderContent[index];
                            final String heading =
                                (item['heading'] ?? '').toString().trim();
                            final String description =
                                (item['description'] ?? '').toString().trim();
                            final String buttonText =
                                (item['button_text'] ?? '').toString().trim();

                            return GestureDetector(
                              onTap: () => _handleSliderClick(item),
                              child: Padding(
                                padding: pageSurroundingPadding,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14.0),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // 1. Background Image
                                      (HelperFunctions().getImage(item).isNotEmpty &&
                                              HelperFunctions().getImage(item) != HelperFunctions.getNoImage())
                                          ? CachedNetworkImage(
                                              height: sliderHeight,
                                              imageUrl:
                                                  HelperFunctions().getImage(item),
                                              fit: BoxFit.cover,
                                              width: Get.width,
                                              errorWidget: ((context, url, error) =>
                                                  AppImagePlaceholder(
                                                    radius: 14,
                                                    height: sliderHeight,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  )),
                                              progressIndicatorBuilder: ((context,
                                                      url, progress) =>
                                                  Container(
                                                    width: MediaQuery.of(context)
                                                            .size
                                                            .width -
                                                        20,
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
                                          : AppImagePlaceholder(
                                              radius: 14,
                                              height: sliderHeight,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),

                                      // 2. High-contrast luxury scrim overlay
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Colors.black.withValues(alpha: 0.85),
                                              Colors.black.withValues(alpha: 0.50),
                                              Colors.black.withValues(alpha: 0.15),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // 3. Editorial Text & CTA Button
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 22.0,
                                          vertical: 18.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (heading.isNotEmpty)
                                              Text(
                                                heading,
                                                style: const TextStyle(
                                                  fontFamily: 'Lato',
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                  letterSpacing: -0.3,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black45,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            if (description.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Text(
                                                description,
                                                style: TextStyle(
                                                  fontFamily: 'Lato',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.9),
                                                  height: 1.35,
                                                  shadows: const [
                                                    Shadow(
                                                      color: Colors.black38,
                                                      blurRadius: 3,
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 7,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.25),
                                                      blurRadius: 6,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      buttonText.toUpperCase(),
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color:
                                                            Color(0xFF111111),
                                                        letterSpacing: 0.8,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    const Icon(
                                                      Icons
                                                          .arrow_forward_rounded,
                                                      size: 13,
                                                      color: Color(0xFF111111),
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
                              ),
                            );
                          }),
                    ),
            ),
            if (_sliderContent.length > 1)
              Positioned(
                bottom: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [..._buildPageIndicator()],
                ),
              )
          ],
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Widget _indicator(bool isActive) {
  return Container(
    height: 5,
    width: isActive ? 22 : 6,
    margin: const EdgeInsets.symmetric(horizontal: 3.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
      color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.45),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 3,
        ),
      ],
    ),
  );
}
