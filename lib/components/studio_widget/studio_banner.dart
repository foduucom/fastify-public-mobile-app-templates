// ignore_for_file: prefer_typing_uninitialized_variables
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'studio_common_widgets.dart';


class HomeBanner extends StatefulWidget {
  final Map<String, dynamic> bannerContent;

  const HomeBanner({super.key, required this.bannerContent});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner>
    with AutomaticKeepAliveClientMixin {
  late var homeController;
  List banners = [];

  String getImage(Map<String, dynamic> bannerItem) {
    final featuredImage = bannerItem['featured_image'];
    return HelperFunctions().getImage(featuredImage);
  }

  @override
  void initState() {
    homeController = Get.find<HomepageController>();
    if (widget.bannerContent['banners'] != null) {
      banners = widget.bannerContent['banners'];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (banners.isEmpty) return const SizedBox();

    final title = widget.bannerContent['heading'] ?? '';
    final subtitle = widget.bannerContent['subheading'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: pageSurroundingPadding,
            child: StudioSectionHeader(
              title: title,
              subtitle: subtitle,
            ),
          ),
        for (var banner in banners) _buildBannerByType(banner),
      ],
    );
  }

  Widget _buildBannerByType(Map<String, dynamic> banner) {
    final type = banner['type'] ?? 'single';
    final items = banner['items'] ?? [];
    final config = banner['config'] ?? {};

    if (items.isEmpty) return const SizedBox();

    switch (type) {
      case 'carousel':
        return _buildCarouselBanner(items, config);
      case 'horizontal_scroll':
        return _buildHorizontalScrollBanner(items, config);
      case 'grid':
        return _buildGridBanner(items, config);
      case 'stacked_cards':
        return _buildStackedCardsBanner(items, config);
      case 'single':
        return _buildSingleBanner(items, config);
      default:
        return _buildSingleBanner(items, config);
    }
  }

  // Carousel Banner with auto-play
  Widget _buildCarouselBanner(List items, Map<String, dynamic> config) {
    return CarouselBanner(
      items: items,
      config: config,
      onTap: handleBannerTap,
      getImage: getImage,
    );
  }

  // Horizontal Scroll with Card Peek
  Widget _buildHorizontalScrollBanner(List items, Map<String, dynamic> config) {
    final cardWidth = config['card_width'] ?? 0.85;
    final cardHeight = config['card_height']?.toDouble() ?? 180.0;
    final peekAmount = config['peek_amount']?.toDouble() ?? 20.0;
    final spacing = config['spacing']?.toDouble() ?? 10.0;
    final borderRadius = config['border_radius']?.toDouble() ?? 15.0;

    return Container(
      height: cardHeight,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: peekAmount),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            width: MediaQuery.of(context).size.width * cardWidth,
            margin: EdgeInsets.only(right: spacing),
            child: GestureDetector(
              onTap: () => handleBannerTap(items[index]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: _buildCachedImage(items[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  // Grid Banner
  Widget _buildGridBanner(List items, Map<String, dynamic> config) {
    final columns = config['columns'] ?? 2;
    final aspectRatio = config['aspect_ratio']?.toDouble() ?? 1.5;
    final spacing = config['spacing']?.toDouble() ?? 8.0;
    final borderRadius = config['border_radius']?.toDouble() ?? 12.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing, vertical: 5),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: aspectRatio,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => handleBannerTap(items[index]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: _buildCachedImage(items[index]),
            ),
          );
        },
      ),
    );
  }

  // Stacked Cards Banner
  Widget _buildStackedCardsBanner(List items, Map<String, dynamic> config) {
    final visibleCards = config['visible_cards'] ?? 2;
    final cardHeight = config['card_height']?.toDouble() ?? 200.0;
    final overlapOffset = config['overlap_offset']?.toDouble() ?? 20.0;
    final borderRadius = config['border_radius']?.toDouble() ?? 15.0;

    return Container(
      height: cardHeight + (overlapOffset * (visibleCards - 1)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Stack(
        children: List.generate(
          items.length > visibleCards ? visibleCards : items.length,
          (index) {
            final reverseIndex =
                (items.length > visibleCards ? visibleCards : items.length) -
                    1 -
                    index;
            return Positioned(
              top: reverseIndex * overlapOffset,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => handleBannerTap(items[index]),
                child: Container(
                  height: cardHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: _buildCachedImage(items[index]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Single Banner
  Widget _buildSingleBanner(List items, Map<String, dynamic> config) {
    final height = config['height']?.toDouble() ?? 150.0;
    final borderRadius = config['border_radius']?.toDouble() ?? 10.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: GestureDetector(
        onTap: () => handleBannerTap(items[0]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: _buildCachedImage(items[0]),
          ),
        ),
      ),
    );
  }

  Widget _buildCachedImage(Map<String, dynamic> item) {
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: getImage(item),
      progressIndicatorBuilder: (context, url, progress) {
        return Container(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          child: HelperFunctions().loadingIndicator(),
        );
      },
      errorWidget: (context, url, error) {
        return Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.error, size: 40),
        );
      },
    );
  }

  void handleBannerTap(Map<String, dynamic> banner) {
    var linkType = banner['link_type'];
    var link = banner['link'];

    if (link == null) return;

    if (linkType == 'product') {
      Get.toNamed(Routes.PRODUCTDETAILS,
          arguments: {'productId': link['value']});
    } else if (linkType == 'category') {
      Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
        'source': 'category',
        'productId': link['value'],
        'categorySlug': link['value'],
        'name': link['label'] ?? link['name']
      });
    } else if (linkType == 'mobile_page') {
      Get.toNamed(Routes.CUSTOMPAGE,
          arguments: {'slug': link['value'], 'label': link['label']});
    } else if (linkType == 'url') {
      // launchUrl(Uri.parse(link['value']));
    }
  }

  @override
  bool get wantKeepAlive => true;
}

// Carousel Banner Widget with Auto-play
class CarouselBanner extends StatefulWidget {
  final List items;
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>) onTap;
  final String Function(Map<String, dynamic>) getImage;

  const CarouselBanner({
    super.key,
    required this.items,
    required this.config,
    required this.onTap,
    required this.getImage,
  });

  @override
  State<CarouselBanner> createState() => _CarouselBannerState();
}

class _CarouselBannerState extends State<CarouselBanner> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    final autoPlay = widget.config['auto_play'] ?? true;
    final autoPlayInterval = widget.config['auto_play_interval'] ?? 3000;

    if (autoPlay && widget.items.length > 1) {
      _timer =
          Timer.periodic(Duration(milliseconds: autoPlayInterval), (timer) {
        if (_currentPage < widget.items.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        }
      });
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
    final height = widget.config['height']?.toDouble() ?? 200.0;
    final borderRadius = widget.config['border_radius']?.toDouble() ?? 10.0;
    final showIndicators = widget.config['show_indicators'] ?? true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Column(
        children: [
          // Text('data' , style:  Theme.of(context).textTheme.tit,)
          SizedBox(
            height: height,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => widget.onTap(widget.items[index]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: widget.getImage(widget.items[index]),
                        progressIndicatorBuilder: (context, url, progress) {
                          return Container(
                            decoration:
                                BoxDecoration(color: Colors.grey.shade100),
                            child: HelperFunctions().loadingIndicator(),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.error, size: 40),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (showIndicators && widget.items.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.items.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
