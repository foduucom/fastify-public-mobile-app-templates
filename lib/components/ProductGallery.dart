import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/app/modules/product/controllers/product_controller.dart';
import '/components/ImagePreviewMultipleView.dart';
import '/constants/helper_functions.dart';
import '/constants/product_helper.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ProductGallery extends StatelessWidget {
  final ProductController controller;
  final List productGallery;
  final bool isLoading;

  const ProductGallery({
    super.key,
    required this.controller,
    required this.productGallery,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || productGallery.isEmpty) {
      return _buildShimmer();
    }

    // Outer Column with height constraint for gallery
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: productGallery.length == 1
                ? _buildSingleImage(context)
                : _buildPageView(),
          ),
        ),
        const SizedBox(height: 8),
        // Gallery indicator
        GalleryIndicator(controller: controller),
      ],
    );
  }

  /// -------------------- SHIMMER --------------------
  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: const Color.fromARGB(255, 197, 197, 197),
        child: SizedBox(
          height: Get.height * 0.6,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 300,
                color: Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// -------------------- SINGLE IMAGE --------------------
  Widget _buildSingleImage(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => ImageSlider(), arguments: {"images": productGallery});
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          width: Get.width,
          imageUrl: HelperFunctions().getImage(
            productGallery[0],
            isLog: false,
            moduleName: 'products details',
          ),
          errorWidget: (_, __, ___) => Container(
            color: Colors.grey.shade300,
            child: const Center(child: Icon(Icons.error)),
          ),
          progressIndicatorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade300,
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
    );
  }

  /// -------------------- MULTIPLE IMAGES --------------------
  Widget _buildPageView() {
    // PageView directly without inner Column to avoid unbounded height
    return PageView.builder(
      controller: controller.pageController,
      padEnds: false,
      onPageChanged: controller.selectedPageIndex,
      itemCount: productGallery.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () {
              Get.to(() => ImageSlider(),
                  arguments: {"images": productGallery});
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: HelperFunctions().getImage(productGallery[index]),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.error)),
                ),
                progressIndicatorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
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
        );
      },
    );
  }
}

/// -------------------- GALLERY INDICATOR --------------------
class GalleryIndicator extends StatelessWidget {
  final ProductController controller;

  const GalleryIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final gallery = ProductHelper.getProductGallery(
        Map<String, dynamic>.from(controller.productDetials),
        variantIndex: controller.selectedVariantIndex.value,
      );

      if (gallery.isEmpty) {
        return Container();
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          gallery.length,
          (index) => Obx(() {
            final isSelected = controller.selectedPageIndex.value == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 30 : 9,
              height: 9,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        ),
      );
    });
  }
}
