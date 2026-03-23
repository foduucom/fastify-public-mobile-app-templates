import 'package:cached_network_image/cached_network_image.dart'; // ✅ ADDED
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/products_details_controller.dart';

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8E5),
      body: Obx(() {
        if (controller.isLoading.value) return _LoadingView();
        if (controller.hasError.value)  return _ErrorView();
        return _ContentView();
      }),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFECE8E5),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF1A1A1A)),
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────
class _ErrorView extends GetView<ProductDetailsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8E5),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 56, color: Color(0xFF9E9E9E)),
            const SizedBox(height: 16),
            const Text('Failed to load product',
                style: TextStyle(fontSize: 16, color: Color(0xFF6B6B6B))),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: controller.goBack,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text('Go Back',
                    style: TextStyle(
                        color: Colors.white, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Main Content ──────────────────────────────────────────────────
class _ContentView extends GetView<ProductDetailsController> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImageGallery(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProductName(),
                    const SizedBox(height: 8),
                    _PriceRow(),
                    const SizedBox(height: 20),
                    _VariantSelector(),
                    const SizedBox(height: 24),
                    _Description(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
        _TopBar(),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: _AddToCartBar(),
        ),
      ],
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────
class _TopBar extends GetView<ProductDetailsController> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          GestureDetector(
            onTap: controller.goBack,
            child: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Color(0xFF1A1A1A)),
            ),
          ),

          Obx(() {
            final liked   = controller.isWishlisted.value;
            final loading = controller.wishlistLoading.value;

            return GestureDetector(
              onTap: controller.toggleWishlist,
              child: Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: loading
                    ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF1A1A1A)),
                )
                    : Icon(
                  liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 20,
                  color: liked
                      ? Colors.redAccent
                      : const Color(0xFF1A1A1A),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Image Gallery ─────────────────────────────────────────────────
class _ImageGallery extends GetView<ProductDetailsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final images  = controller.allImages;
      final current = controller.selectedImageIndex.value;

      if (images.isEmpty) {
        return Container(
          height: 380,
          color: const Color(0xFFF5F5F5),
          child: const Center(
            child: Icon(Icons.chair_outlined,
                size: 80, color: Color(0xFFD0D0D0)),
          ),
        );
      }

      return Column(
        children: [
          SizedBox(
            height: 380,
            width: double.infinity,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (i) =>
              controller.selectedImageIndex.value = i,
              itemBuilder: (_, i) => _NetImg(url: images[i]),
            ),
          ),
          if (images.length > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width:  current == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: current == i
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFFD0D0D0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
        ],
      );
    });
  }
}

// ── Product Name ──────────────────────────────────────────────────
class _ProductName extends GetView<ProductDetailsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Text(
      controller.name,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
        height: 1.3,
      ),
    ));
  }
}

// ── Price Row ─────────────────────────────────────────────────────
class _PriceRow extends GetView<ProductDetailsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final price    = controller.price;
      final original = controller.originalPrice;
      final hasDisc  = controller.hasDiscount;

      return Row(
        children: [
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          if (hasDisc) ...[
            const SizedBox(width: 10),
            Text(
              '\$${original.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9E9E9E),
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '-${(((original - price) / original) * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}

// ── Variant Selector ──────────────────────────────────────────────
class _VariantSelector extends GetView<ProductDetailsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final variants = controller.variants;
      final selected = controller.selectedVariantIndex.value;
      if (variants.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              )),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(variants.length, (i) {
              final label      = controller.variantLabel(variants[i]);
              final isSelected = selected == i;

              return GestureDetector(
                onTap: () => controller.selectVariant(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1A1A1A)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      );
    });
  }
}

// ── Description ───────────────────────────────────────────────────
class _Description extends GetView<ProductDetailsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final desc = controller.description;
      if (desc.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              )),
          const SizedBox(height: 10),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B6B6B),
              height: 1.6,
            ),
          ),
        ],
      );
    });
  }
}

// ── Add to Cart Bar ───────────────────────────────────────────────
class _AddToCartBar extends GetView<ProductDetailsController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(color: Color(0xFFECE8E5)),
      child: GestureDetector(
        onTap: controller.onAddToCart,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_basket_outlined,
                  color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Add to Cart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Network Image ─────────────────────────────────────────────────
// ✅ FIXED: replaced Image.network with CachedNetworkImage
class _NetImg extends StatelessWidget {
  final String url;
  const _NetImg({required this.url});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      placeholder: (_, __) => Container(
        color: const Color(0xFFF0EEEB),
        child: const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Color(0xFFD0D0D0)),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        color: const Color(0xFFF5F5F5),
        child: const Icon(Icons.chair_outlined,
            size: 60, color: Color(0xFFD0D0D0)),
      ),
    );
  }
}
