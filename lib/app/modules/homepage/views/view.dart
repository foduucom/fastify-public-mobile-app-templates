import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/home_controller2.dart';
import '/app/modules/product/views/product_view.dart';
import '/app/modules/shop/bindings/shop_binding.dart';
import '/app/routes/app_pages.dart';


class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: controller.onRefresh,
        color: colorScheme.primary,
        child: CustomScrollView(
          slivers: [

            // ── AppBar ─────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              floating: true,
              pinned: false,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // ── Location chip ────────────────────────────
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        // child: Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //     Icon(Icons.location_on,
                        //         color: colorScheme.primary,
                        //         size: 16),
                        //     const SizedBox(width: 4),
                        //     Text(
                        //       'Chenango, New York',
                        //       style: textTheme.bodyMedium?.copyWith(
                        //         fontWeight: FontWeight.w600,
                        //         color: Colors.black87,
                        //         fontSize: 13,
                        //       ),
                        //     ),
                        //     const SizedBox(width: 4),
                        //     Icon(Icons.keyboard_arrow_down,
                        //         color: Colors.black54, size: 18),
                        //   ],
                        // ),
                      ),
                    ),

                    const Spacer(),

                    // // ── Chat icon ────────────────────────────────
                    // _AppBarIconButton(
                    //   icon: Icons.chat_bubble_outline_rounded,
                    //   onTap: () {},
                    // ),
                    const SizedBox(width: 10),

                    // ── Notification icon with badge ─────────────
                    Stack(
                      children: [
                        _AppBarIconButton(
                          icon: Icons.notifications_outlined,
                          onTap: () =>
                              Get.toNamed(Routes.NOTIFICATION),
                        ),
                        Positioned(
                          top: 6, right: 6,
                          child: Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Body content ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Greeting ─────────────────────────────────
                    Text(
                      'Hello, Jonatan! 👋',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Fulfill all your daily needs\nwith HarvestHub',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.3,
                        fontSize: 24,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Banner Carousel ───────────────────────────
                    _BannerCarousel(controller: controller),

                    const SizedBox(height: 28),

                    // ── Popular Store ─────────────────────────────
                    _SectionHeader(
                      title: 'Market Trendes🔥',
                      onSeeAll: () => Get.toNamed(Routes.EXPLORE),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // ── Popular Store horizontal list ─────────────────────
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.featuredProducts.isEmpty) {
                  return _buildStoreShimmer();
                }
                if (controller.featuredProducts.isEmpty) {
                  return const SizedBox.shrink();
                }
                return SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.featuredProducts.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final product = controller.featuredProducts[index]
                      as Map<String, dynamic>;
                      return _StoreCard(
                        product: product,
                        controller: controller,
                        textTheme: textTheme,
                        colorScheme: colorScheme,
                      );
                    },
                  ),
                );
              }),
            ),

            // ── Categories ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    _SectionHeader(
                      title: 'Categories',
                      onSeeAll: () => Get.toNamed(Routes.CATEGORY),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.categories.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final cat = controller.categories[index];
                          return GestureDetector(
                            onTap: () =>
                                Get.toNamed(Routes.CATEGORY),
                            child: Column(
                              children: [
                                Container(
                                  width: 60, height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade100,
                                    border: Border.all(
                                        color: Colors.grey.shade200),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Image.asset(
                                    cat['asset']!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cat['name']!,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Hot Products ────────────────────────────
                    _SectionHeader(
                      title: 'Hot Deals 🔥',
                      onSeeAll: () => Get.toNamed(Routes.EXPLORE),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // ── Hot Products Grid ─────────────────────────────────
            Obx(() {
              if (controller.isLoading.value &&
                  controller.hotProducts.isEmpty) {
                return SliverToBoxAdapter(child: _buildProductShimmer());
              }
              if (controller.hotProducts.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final product = controller.hotProducts[index]
                      as Map<String, dynamic>;
                      return _ProductCard(
                        product: product,
                        controller: controller,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      );
                    },
                    childCount: controller.hotProducts.length,
                  ),
                ),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: SizedBox(
        height: 220,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, __) => Container(
            width: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.68,
          ),
          itemCount: 4,
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

// ── AppBar icon button ────────────────────────────────────────────────────────
class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 18,
            )),
        GestureDetector(
          onTap: onSeeAll,
          child: Text('See All',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              )),
        ),
      ],
    );
  }
}

// ── Banner Carousel ───────────────────────────────────────────────────────────
class _BannerCarousel extends StatelessWidget {
  final HomeController controller;
  const _BannerCarousel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: controller.bannerPageController,
            onPageChanged: (i) => controller.currentBanner.value = i,
            itemCount: controller.banners.length,
            itemBuilder: (context, index) {
              final banner = controller.banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCF1E0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // ── Text left ──────────────────────────────
                    Positioned(
                      left: 20, top: 20, bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ── Delivery tag ──────────────────
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  banner['tag']!,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  banner['highlight']!,
                                  style: TextStyle(
                                    color: Colors.amber.shade400,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 170,
                            child: Text(
                              banner['title']!,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ── Image right ────────────────────────────
                    Positioned(
                      right: 0, top: 0, bottom: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(20)),
                        child: Image.asset(
                          banner['asset']!,
                          width: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // ── Dot indicators ────────────────────────────────────
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            controller.banners.length,
                (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: controller.currentBanner.value == i ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: controller.currentBanner.value == i
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        )),
      ],
    );
  }
}

// ── Store Card ────────────────────────────────────────────────────────────────
class _StoreCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final HomeController controller;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _StoreCard({
    required this.product,
    required this.controller,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = controller.getImageUrl(product);
    final name     = product['name']?.toString() ?? '';

    return GestureDetector(
      onTap: () {
        final id = product['_id']?.toString() ?? '';
        if (id.isNotEmpty) {
          Get.to(() => ProductView(),
              binding: ShopBinding(),
              arguments: {'productId': id});
        }
      },
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image with category tag ───────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 180, height: 150,
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: Colors.grey.shade200),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(Icons.store,
                            color: Colors.grey.shade400,
                            size: 40),
                      ),
                    )
                        : Container(
                      color: Colors.grey.shade200,
                      child: Icon(Icons.store,
                          color: Colors.grey.shade400, size: 40),
                    ),
                  ),
                ),
                // ── Category tag overlay ──────────────────────
                Positioned(
                  top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$name Store',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 3),
                Text(
                  'London, United Kingdom',
                  style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Product Card ──────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final HomeController controller;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ProductCard({
    required this.product,
    required this.controller,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl    = controller.getImageUrl(product);
    final name        = product['name']?.toString() ?? '';
    final price       = controller.getPrice(product);
    final salePrice   = controller.getSalePrice(product);
    final hasDiscount = salePrice > 0 && salePrice < price;
    final displayPrice = hasDiscount ? salePrice : price;
    final discountPct  = hasDiscount
        ? ((price - salePrice) / price * 100).round()
        : 0;

    return GestureDetector(
      onTap: () {
        final id = product['_id']?.toString() ?? '';
        if (id.isNotEmpty) {
          Get.to(() => ProductView(),
              binding: ShopBinding(),
              arguments: {'productId': id});
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15)),
                    child: SizedBox(
                      width: double.infinity,
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: Colors.grey.shade100),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey.shade100,
                          child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey.shade400),
                        ),
                      )
                          : Container(
                        color: Colors.grey.shade100,
                        child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$discountPct%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text('For 1Kg',
                        style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade500, fontSize: 11)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${displayPrice.toStringAsFixed(0)}',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                            if (hasDiscount)
                              Text(
                                '₹${price.toStringAsFixed(0)}',
                                style: textTheme.bodySmall?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.red.shade300,
                                  decorationColor: Colors.red.shade300,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                        Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: colorScheme.primary
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add,
                              color: colorScheme.primary, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}