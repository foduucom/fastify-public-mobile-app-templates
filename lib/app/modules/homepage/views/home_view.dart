import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/homepage_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8E5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _TopBar(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Create Your\nPerfect Home Vibe',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _CategoryRow(),
              const SizedBox(height: 24),
              _FeaturedProducts(),
              const SizedBox(height: 12),
              _NewCollectionsSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────
class _TopBar extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.toNamed('/profile'),
            child: Container(
              width: 52, height: 52,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFD9D9D9)),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/profile_avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.person, color: Color(0xFF9E9E9E), size: 28),
              ),
            ),
          ),
          const Spacer(),
          _IconCircleButton(
            iconPath: 'assets/images/Noti.png',
            fallbackIcon: Icons.notifications_outlined,
            onTap: controller.onNotificationTap,
          ),
          const SizedBox(width: 10),
          _IconCircleButton(
            iconPath: 'assets/images/cart.png',
            fallbackIcon: Icons.shopping_basket_outlined,
            onTap: controller.onCartTap,
          ),
        ],
      ),
    );
  }
}


class _CategoryRow extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,                                    // ✅ was 52
      child: Obx(() {
        final selected   = controller.selectedCategory.value;
        final categories = controller.categories.toList();

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final cat        = categories[index];
            final isSelected = selected == index;
            final isSparkle  = index == 0;
            final isAll      = index == 1;

            return GestureDetector(
              onTap: () => controller.onCategoryTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 62, height: 62,             // ✅ was 52
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1A1A1A)
                      : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isAll
                      ? Text('All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF1A1A1A),
                      ))
                      : isSparkle
                      ? Image.asset(
                    'assets/icons/ic_sparkle.png',
                    width: 34, height: 34,  // ✅ was 24
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF1A1A1A),
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.auto_awesome,
                      size: 28,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1A1A1A),
                    ),
                  )
                      : _CategoryIcon(
                    cat: cat,
                    isSelected: isSelected,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ── Category Icon ─────────────────────────────────────────────────
class _CategoryIcon extends StatelessWidget {
  final Map<String, dynamic> cat;
  final bool isSelected;
  const _CategoryIcon({required this.cat, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final iconUrl = HomeController.catImage(cat);

    if (iconUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: iconUrl,
        width: 34, height: 34,                      // ✅ was 24
        fit: BoxFit.contain,
        // ❌ REMOVED color: — was blending image to invisible
        placeholder: (_, __) => const SizedBox(width: 34, height: 34),
        errorWidget: (_, __, ___) => Icon(
          Icons.category_outlined,
          size: 28,                                   // ✅ was 22
          color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
        ),
      );
    }

    final iconPath = cat['iconPath']?.toString() ?? '';
    if (iconPath.isNotEmpty) {
      return Image.asset(
        iconPath,
        width: 34, height: 34,                      // ✅ was 24
        // ❌ REMOVED color: for same reason
        errorBuilder: (_, __, ___) => Icon(
          Icons.category_outlined,
          size: 28,
          color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
        ),
      );
    }

    return Icon(
      Icons.category_outlined,
      size: 28,
      color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
    );
  }
}

class _FeaturedProducts extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Obx(() {
        if (controller.isLoading.value) {
          return _buildSkeletons(width: 220, height: 320);
        }
        final products = controller.featuredProducts.toList();
        if (products.isEmpty) return const SizedBox.shrink();

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, i) => _ProductCard(item: products[i]),
        );
      }),
    );
  }
}


class _ProductCard extends GetView<HomeController> {
  final Map<String, dynamic> item;
  const _ProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final id       = HomeController.itemId(item);
    final name     = HomeController.itemName(item);
    final price    = HomeController.itemPrice(item);
    final imageUrl = HomeController.itemImage(item);

    return GestureDetector(
      onTap: () => controller.onProductTap(id),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ✅ Fixed height — no more Expanded stretching
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24)),
              child: SizedBox(
                width: double.infinity,
                height: 230,                      // ✅ fixed
                child: _NetImage(
                    url: imageUrl, width: double.infinity),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A1A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('\$${price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            )),
                      ],
                    ),
                  ),
                  Obx(() {
                    final loading = controller.addingToCartId.value == id;
                    return GestureDetector(
                      onTap: loading
                          ? null
                          : () => controller.onAddToCart(item),
                      child: Container(
                        width: 42, height: 42,
                        decoration: const BoxDecoration(
                            color: Color(0xFF1A1A1A),
                            shape: BoxShape.circle),
                        child: loading
                            ? const Padding(
                          padding: EdgeInsets.all(11),
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white),
                        )
                            : const Icon(
                            Icons.shopping_basket_outlined,
                            color: Colors.white, size: 18),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _NewCollectionsSection extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final collections = controller.newCollections.toList();

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('New collections',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    )),
                GestureDetector(
                  onTap: controller.onSeeAllTap,
                  child: const Text('See All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B6B6B),
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: controller.isLoading.value
                ? _buildSkeletons(width: 160, height: 220)
                : ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: collections.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) =>
                  _CollectionCard(item: collections[i]),
            ),
          ),
        ],
      );
    });
  }
}

// ── Collection Card ───────────────────────────────────────────────
class _CollectionCard extends GetView<HomeController> {
  final Map<String, dynamic> item;
  const _CollectionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final id       = HomeController.itemId(item);
    final name     = HomeController.itemName(item);
    final price    = HomeController.itemPrice(item);
    final imageUrl = HomeController.itemImage(item);

    return GestureDetector(
      onTap: () => controller.onProductTap(id),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ✅ Fixed height — no more Expanded stretching
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20)),
              child: SizedBox(
                width: double.infinity,
                height: 140,                      // ✅ fixed
                child: _NetImage(
                    url: imageUrl, width: double.infinity),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          )),
                      Obx(() {
                        final loading = controller.addingToCartId.value == id;
                        return GestureDetector(
                          onTap: loading
                              ? null
                              : () => controller.onAddToCart(item),
                          child: Container(
                            width: 32, height: 32,
                            decoration: const BoxDecoration(
                                color: Color(0xFF1A1A1A),
                                shape: BoxShape.circle),
                            child: loading
                                ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                            )
                                : const Icon(
                                Icons.shopping_basket_outlined,
                                color: Colors.white, size: 14),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Network Image ─────────────────────────────────────────────────
class _NetImage extends StatelessWidget {
  final String url;
  final double width;
  const _NetImage({required this.url, required this.width});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _fallback();

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: double.infinity,        // ✅ fills SizedBox height
      fit: BoxFit.cover,              // ✅ cover not contain
      placeholder: (_, __) => Container(
        color: const Color(0xFFF0EEEB),
        child: const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Color(0xFFD0D0D0)),
        ),
      ),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() => Container(
    color: const Color(0xFFF5F5F5),
    child: const Icon(Icons.chair_outlined,
        size: 40, color: Color(0xFFD0D0D0)),
  );
}

// ── Skeleton Loader ───────────────────────────────────────────────
Widget _buildSkeletons(
    {required double width, required double height}) {
  return ListView.separated(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    itemCount: 3,
    separatorBuilder: (_, __) => const SizedBox(width: 14),
    itemBuilder: (_, __) =>
        _SkeletonCard(width: width, height: height),
  );
}

class _SkeletonCard extends StatelessWidget {
  final double width;
  final double height;
  const _SkeletonCard({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF0EEEB),
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 10, width: width * 0.7,
                    color: const Color(0xFFF0EEEB)),
                const SizedBox(height: 6),
                Container(height: 10, width: width * 0.4,
                    color: const Color(0xFFF0EEEB)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Icon Circle Button ────────────────────────────────────────────
class _IconCircleButton extends StatelessWidget {
  final String? iconPath;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const _IconCircleButton({
    required this.iconPath,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48, height: 48,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: Center(
          child: iconPath != null
              ? Image.asset(iconPath!, width: 22, height: 22,
              errorBuilder: (_, __, ___) => Icon(fallbackIcon,
                  size: 22, color: const Color(0xFF1A1A1A)))
              : Icon(fallbackIcon,
              size: 22, color: const Color(0xFF1A1A1A)),
        ),
      ),
    );
  }
}
