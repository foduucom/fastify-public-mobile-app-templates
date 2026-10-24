import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/components/shimmer_effects.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:get/get.dart';

class FoduuSlider extends StatefulWidget {
  final String id;
  FoduuSlider({super.key, required this.id});

  @override
  _FoduuSliderState createState() => _FoduuSliderState();
}

class _FoduuSliderState extends State<FoduuSlider>
    with AutomaticKeepAliveClientMixin, BaseController {
  late HomepageController homeController;
  // Use the list from controller for better state management and refresh support
  List<dynamic> get sliderImage => homeController.sliderImageList;

  int _currentPage = 0;
  Timer? _autoSlideTimer;
  final PageController _pageController = PageController(
    initialPage: 0,
  );

  List<Widget> _buildPageIndicator(BuildContext context) {
    List<Widget> list = [];
    for (int i = 0; i < sliderImage.length; i++) {
      list.add(i == _currentPage
          ? _indicator(context, true)
          : _indicator(context, false));
    }
    return list;
  }


  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomepageController>();

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 8), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (sliderImage.isNotEmpty) {
        if (_currentPage < sliderImage.length - 1) {
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
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() => SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.transparent,
            ),
            height: double.infinity,
            child: sliderImage.isEmpty
                ? AppShimmer(
                    child: Container(
                      width: Get.width,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8EEF5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: Get.width * 0.55,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8EEF5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: Get.width * 0.4,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8EEF5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : PageView.builder(
                    physics: const ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: sliderImage.length,
                    itemBuilder: (context, index) {
                      final item = sliderImage[index];
                      if (item is! Map) return const SizedBox();
                      final Map<String, dynamic> sliderData =
                          Map<String, dynamic>.from(item);
                      final String cacheKey =
                          sliderData['_id']?.toString() ?? index.toString();
                      return SliderItemWidget(
                        key: ValueKey(cacheKey),
                        sliderData: sliderData,
                      );
                    }),
          ),
          Positioned(
            bottom: 16,
            child: sliderImage.isEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 6,
                        width: 22,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      Container(
                        height: 6,
                        width: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      Container(
                        height: 6,
                        width: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [..._buildPageIndicator(context)],
                  ),
          )
        ],
      ),
    ));
  }

  @override
  bool get wantKeepAlive => true;
}

Widget _indicator(BuildContext context, bool isActive) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    height: 7,
    width: isActive ? 22 : 7,
    margin: const EdgeInsets.symmetric(horizontal: 3.0),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: isActive
            ? context.themePrimaryColor
            : context.themePrimaryColor.withOpacity(0.2)),
  );
}

class SliderItemWidget extends StatefulWidget {
  final Map<String, dynamic> sliderData;

  const SliderItemWidget({
    required this.sliderData,
    super.key,
  });

  @override
  State<SliderItemWidget> createState() => _SliderItemWidgetState();
}

class _SliderItemWidgetState extends State<SliderItemWidget>
    with AutomaticKeepAliveClientMixin {
  late final String resolvedUrl;

  @override
  void initState() {
    super.initState();
    resolvedUrl = HelperFunctions().getImage(
      widget.sliderData,
      moduleName: 'appslider_item',
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sliderData = widget.sliderData;

    return Stack(
      children: [
        GestureDetector(
          onTap: () async {
            final link = (sliderData['link'] ?? '').toString().trim();
            final sliderType = sliderData['sliderType']?.toString() ?? '';

            if (sliderType == 'categories') {
              BottombarController.switchTab(
                1,
                arguments: {
                  'source': 'category',
                  'category': sliderData['link'],
                  'name': sliderData['heading'],
                },
              );
            } else if (link == '/product' || link == '/products' || link == '/shop') {
              BottombarController.switchTab(1);
            } else if (link.startsWith('http://') || link.startsWith('https://')) {
              final uri = Uri.tryParse(link);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.darken,
              ),
              child: RepaintBoundary(
                child: CachedNetworkImage(
                  height: double.infinity,
                  imageUrl: resolvedUrl,
                  fit: BoxFit.cover,
                  width: Get.width,
                  memCacheWidth:
                      (Get.width * MediaQuery.of(context).devicePixelRatio)
                          .round(),
                  memCacheHeight:
                      (200 * MediaQuery.of(context).devicePixelRatio).round(),
                  errorWidget: (context, url, error) => Container(
                    width: MediaQuery.of(context).size.width - 20,
                    height: 200,
                    decoration: BoxDecoration(color: context.themegreyColor),
                    child: const Center(
                      child: Icon(Icons.error),
                    ),
                  ),
                  progressIndicatorBuilder: (context, url, progress) => Container(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    decoration: BoxDecoration(
                      color: context.themegreyColor,
                    ),
                    child: Center(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: HelperFunctions().loadingIndicator(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          child: IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: Get.width * 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      sliderData['heading']?.toString() ?? '',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      sliderData['description']?.toString() ?? '',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.white70,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
