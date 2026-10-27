import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/data/models/home_sections.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/shimmer_effects.dart';
import 'package:zouhi/constants/theme_ext.dart';

const _poppins = 'Poppins';

class VisionHeroSlider extends StatefulWidget {
  final HomeHeroSliderData data;
  final double height;

  const VisionHeroSlider({
    super.key,
    required this.data,
    this.height = 205.0,
  });

  @override
  State<VisionHeroSlider> createState() => _VisionHeroSliderState();
}

class _VisionHeroSliderState extends State<VisionHeroSlider> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  List<HomeSlideItem> get _slides => widget.data.slides;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_slides.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void didUpdateWidget(covariant VisionHeroSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.slides.length != widget.data.slides.length) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onSlideTap(HomeSlideItem slide) {
    final url = slide.btnUrl.toLowerCase();
    if (url.contains('solution')) {
      Get.toNamed(Routes.SOLUTION);
      return;
    }

    String categorySlug = '';
    final uri = Uri.tryParse(slide.btnUrl);
    if (uri != null && uri.queryParameters.containsKey('category')) {
      categorySlug = uri.queryParameters['category'] ?? '';
    }

    if (categorySlug.isNotEmpty) {
      BottombarController.switchTab(1, arguments: {
        'categorySlug': categorySlug,
        'category': categorySlug,
        'source': 'featured_collections',
      });
    } else {
      BottombarController.switchTab(1, arguments: {
        'name': 'All Products',
        'source': 'dashboard',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_slides.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: AppShimmer(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (i) {
                setState(() => _currentPage = i);
              },
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return GestureDetector(
                  onTap: () => _onSlideTap(slide),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image
                        CachedNetworkImage(
                          imageUrl: slide.imageUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: 1080,
                          placeholder: (_, __) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFF1E293B),
                            child: const Icon(Icons.broken_image, color: Colors.white24, size: 40),
                          ),
                        ),
                        // Dark gradient overlay for text readability
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.72),
                                Colors.black.withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                        // Content overlay
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (slide.subheading.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: context.themePrimaryColor.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    slide.subheading.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: _poppins,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.6,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              Text(
                                slide.heading,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: _poppins,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      slide.btnText.toUpperCase(),
                                      style: TextStyle(
                                        fontFamily: _poppins,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.4,
                                        color: context.themeTextColor,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 13,
                                      color: context.themeTextColor,
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
                );
              },
            ),
          ),
          // Page Indicator dots
          if (_slides.length > 1)
            Positioned(
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  final active = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 6,
                    height: 5,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
